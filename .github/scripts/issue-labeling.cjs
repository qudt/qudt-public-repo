const { writeFileSync } = require("node:fs");

const marker = "ai/suggested-labels";
const review = "ai/needs-human-review";
const allowedLabels = new Set([
  "type/bug", "type/enhancement", "type/design", "type/question", "type/documentation",
  "area/content", "area/tooling", "area/documentation",
  "effort/small", "effort/medium", "effort/large",
  "impact/high", "impact/medium", "impact/low",
  marker, review
]);

function labelNames(issue) {
  return issue.labels.map(label => typeof label === "string" ? label : label.name);
}

function validateResponse(response) {
  const text = response.trim();
  const fenced = text.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  const parsed = JSON.parse(fenced ? fenced[1].trim() : text);
  if (!parsed || !Array.isArray(parsed.labels) ||
      parsed.labels.some(label => typeof label !== "string")) {
    throw new Error("The response must contain a labels array of strings");
  }

  const proposed = [...new Set(parsed.labels)];
  const unknown = proposed.filter(label => !allowedLabels.has(label));
  const safe = proposed.filter(label => allowedLabels.has(label));
  for (const category of ["type", "area", "effort", "impact"]) {
    const count = safe.filter(label => label.startsWith(`${category}/`)).length;
    if ((category === "type" && count !== 1) || count > 1) {
      throw new Error(`Expected ${category === "type" ? "exactly" : "at most"} one ${category} label`);
    }
  }
  if (unknown.length > 0 || safe.includes("impact/high")) safe.push(review);
  safe.push(marker);
  return { parsed, proposed, unknown, safe: [...new Set(safe)] };
}

async function readIssue(github, context, issueNumber) {
  if (!Number.isSafeInteger(issueNumber) || issueNumber < 1) {
    throw new Error("A positive issue number is required");
  }
  const { data } = await github.rest.issues.get({
    ...context.repo, issue_number: issueNumber
  });
  if (data.pull_request) throw new Error("Pull requests cannot be classified as issues");
  return data;
}

async function wasClassified(github, context, issue) {
  if (labelNames(issue).includes(marker)) return true;
  // Label removal means the suggestions were reviewed, not that the issue is new.
  // Scan every page; a classification may predate many other issue events.
  for await (const { data } of github.paginate.iterator(github.rest.issues.listEvents, {
    ...context.repo, issue_number: issue.number, per_page: 100
  })) {
    if (data.some(event =>
      ["labeled", "unlabeled"].includes(event.event) && event.label?.name === marker
    )) return true;
  }
  // API failures propagate: unknown history must never authorize classification.
  return false;
}

async function collectIssues({ github, context, core, limit, state }) {
  if (!/^\d+$/.test(String(limit)) || Number(limit) < 1 || Number(limit) > 100) {
    throw new Error("The limit must be a number between 1 and 100");
  }
  if (!["open", "closed", "all"].includes(state)) throw new Error("Invalid issue state");
  const issues = [];
  for await (const { data } of github.paginate.iterator(github.rest.issues.listForRepo, {
    ...context.repo, state, sort: "created", direction: "asc", per_page: 100
  })) {
    for (const issue of data) {
      if (issue.pull_request || await wasClassified(github, context, issue)) continue;
      issues.push({ number: issue.number });
      if (issues.length === Number(limit)) break;
    }
    if (issues.length === Number(limit)) break;
  }
  core.setOutput("issues", JSON.stringify(issues));
  core.setOutput("count", String(issues.length));
  core.info(`Selected ${issues.length} never-classified issue(s).`);
}

async function prepareIssue({ github, context, core, issueNumber }) {
  const issue = await readIssue(github, context, issueNumber);
  if (await wasClassified(github, context, issue)) {
    core.setOutput("classify", "false");
    core.info(`Issue #${issueNumber} is already classified; skipping.`);
    return;
  }
  // Read the current issue after acquiring the shared per-issue concurrency group.
  writeFileSync("issue-title.txt", issue.title);
  writeFileSync("issue-body.md", issue.body || "");
  writeFileSync("issue-labels.json", JSON.stringify(issue.labels));
  core.setOutput("classify", "true");
}

async function applyLabels({ github, context, core, issueNumber, response, dryRun, promptVersion }) {
  if (typeof dryRun !== "boolean") throw new Error("dryRun must be a boolean");
  const issue = await readIssue(github, context, issueNumber);
  const existing = labelNames(issue);
  if (await wasClassified(github, context, issue)) {
    core.info(`Issue #${issueNumber} is already classified; skipping.`);
    return;
  }
  // Do not mark malformed or conflicting classifications as complete: they can be retried.
  const { parsed, proposed, unknown, safe } = validateResponse(response);
  const preserved = [];
  const labels = safe.filter(label => {
    const category = label.split("/")[0];
    if (!["type", "area", "effort", "impact"].includes(category)) return true;
    const current = existing.filter(name => name.startsWith(`${category}/`));
    if (current.some(name => name !== label)) {
      preserved.push(...current);
      return false;
    }
    return true;
  });
  if (preserved.length > 0 || existing.includes("impact/high")) labels.push(review);
  const labelsToApply = [...new Set(labels)].filter(label => !existing.includes(label));
  if (!dryRun) {
    // Submit classification and completion marker together; never replace existing labels.
    await github.rest.issues.addLabels({
      ...context.repo, issue_number: issueNumber, labels: labelsToApply
    });
  }

  await core.summary.addRaw([
    `### Issue #${issueNumber}`,
    "",
    `**Prompt version:** ${promptVersion || "unknown"}`,
    `**Suggested labels:** ${proposed.join(", ")}`,
    `**${dryRun ? "Would add" : "Added"} labels:** ${labelsToApply.join(", ") || "None"}`,
    `**Dry run:** ${dryRun}`,
    `**Existing category labels preserved:** ${[...new Set(preserved)].join(", ") || "None"}`,
    `**Unknown labels ignored:** ${unknown.join(", ") || "None"}`,
    `**Confidence:** ${parsed.confidence ?? "Not provided"}`,
    `**Reasoning:** ${parsed.reasoning || "Not provided"}`
  ].join("\n")).write();
}

module.exports = { allowedLabels, validateResponse, prepareIssue, applyLabels, collectIssues };
