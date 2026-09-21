const assert = require("node:assert/strict");
const { test } = require("node:test");
const { mkdtempSync, readFileSync, rmSync } = require("node:fs");
const { tmpdir } = require("node:os");
const { join } = require("node:path");
const { allowedLabels, validateResponse, prepareIssue, applyLabels, collectIssues } = require("./issue-labeling.cjs");

const marker = "ai/suggested-labels";
const review = "ai/needs-human-review";
const response = JSON.stringify({ labels: ["type/bug", "area/content", "impact/high"] });

function fixture(labels = []) {
  const issue = { number: 42, title: "Current title", body: null, labels: labels.map(name => ({ name })) };
  const calls = [];
  const events = [];
  const eventPages = new Map([[42, [events]]]);
  const issuePages = [];
  const reads = [];
  const outputs = {};
  const summaries = [];
  const github = { rest: { issues: {
    get: async () => ({ data: issue }),
    listEvents() {},
    listForRepo() {},
    addLabels: async args => {
      calls.push(args);
      issue.labels.push(...args.labels.map(name => ({ name })));
      events.push(...args.labels.map(name => ({ event: "labeled", label: { name } })));
    }
  } } };
  github.paginate = {
    async *iterator(method, args) {
      reads.push({ method, args });
      assert.equal(args.owner, "qudt");
      assert.equal(args.repo, "qudt-public-repo");
      assert.equal(args.per_page, 100);
      const pages = method === github.rest.issues.listForRepo
        ? issuePages : eventPages.get(args.issue_number) || [[]];
      for (const data of pages) yield { data };
    }
  };
  const core = {
    info() {},
    setOutput: (key, value) => { outputs[key] = value; },
    summary: { addRaw(text) { summaries.push(text); return this; }, async write() {} }
  };
  const options = {
    github, core, context: { repo: { owner: "qudt", repo: "qudt-public-repo" } },
    issueNumber: 42, response, dryRun: false, promptVersion: "test"
  };
  return { issue, calls, outputs, summaries, options, events, eventPages, issuePages, reads };
}

test("accepts plain and fenced JSON, deduplicates and flags high impact/unknown labels", () => {
  for (const format of [text => text, text => `\`\`\`json\n${text}\n\`\`\``, text => `\`\`\`\n${text}\n\`\`\``]) {
    const result = validateResponse(format(JSON.stringify({ labels: ["type/bug", "type/bug", "impact/high", "unapproved"] })));
    assert.deepEqual(result.safe, ["type/bug", "impact/high", review, marker]);
    assert.deepEqual(result.unknown, ["unapproved"]);
  }
});

for (const invalid of ["", "not JSON", "null", "[]", "{}", '{"labels":"type/bug"}',
  '{"labels":[null]}', '{"labels":[]}', '{"labels":["unknown"]}',
  '{"labels":["type/bug","type/design"]}',
  '{"labels":["type/bug","area/content","area/tooling"]}',
  '{"labels":["type/bug","effort/small","effort/large"]}',
  '{"labels":["type/bug","impact/low","impact/high"]}']) {
  test(`invalid response cannot apply labels or a completion marker: ${invalid}`, async () => {
    const f = fixture();
    await assert.rejects(applyLabels({ ...f.options, response: invalid }));
    assert.equal(f.calls.length, 0);
  });
}

test("preflight skips an already classified issue before inference", async () => {
  const f = fixture([marker]);
  await prepareIssue(f.options);
  assert.equal(f.outputs.classify, "false");
  assert.equal(f.calls.length, 0);
});

test("preflight writes current issue content literally, including shell-like input", async () => {
  const f = fixture(["bug"]);
  f.issue.title = '$(touch unexpected-file) `false` ${{ github.token }}';
  const previous = process.cwd();
  const dir = mkdtempSync(join(tmpdir(), "issue-labeling-"));
  try {
    process.chdir(dir);
    await prepareIssue(f.options);
    assert.equal(f.outputs.classify, "true");
    assert.equal(readFileSync("issue-title.txt", "utf8"), f.issue.title);
    assert.equal(readFileSync("issue-body.md", "utf8"), "");
    assert.deepEqual(JSON.parse(readFileSync("issue-labels.json", "utf8")), f.issue.labels);
  } finally {
    process.chdir(previous);
    rmSync(dir, { recursive: true });
  }
});

test("a retry after a successful write makes no second labeling request", async () => {
  const f = fixture(["bug", "area/content"]);
  await applyLabels(f.options);
  await applyLabels(f.options);
  assert.equal(f.calls.length, 1);
  assert.deepEqual(f.calls[0].labels, ["type/bug", "impact/high", review, marker]);
  assert.ok(f.issue.labels.some(label => label.name === "bug"));
});

test("live recheck skips an issue classified since collection, even with invalid response", async () => {
  const f = fixture([marker]);
  await applyLabels({ ...f.options, response: "not JSON" });
  assert.equal(f.calls.length, 0);
});

test("dry runs preview without marking the issue, so a real run remains possible", async () => {
  const f = fixture();
  await applyLabels({ ...f.options, dryRun: true });
  assert.equal(f.calls.length, 0);
  assert.match(f.summaries[0], /Would add.*ai\/suggested-labels/);
  await applyLabels(f.options);
  assert.equal(f.calls.length, 1);
});

test("preserves conflicting human category labels and asks for review", async () => {
  const f = fixture(["type/design", "area/tooling", "effort/large", "impact/low", "custom"]);
  await applyLabels(f.options);
  assert.deepEqual(f.calls[0].labels.sort(), [review, marker].sort());
  assert.match(f.summaries[0], /Existing category labels preserved.*type\/design/);
});

test("existing high impact requires review even when the model omits impact", async () => {
  const f = fixture(["impact/high"]);
  await applyLabels({ ...f.options, response: '{"labels":["type/bug"]}' });
  assert.ok(f.calls[0].labels.includes(review));
});

test("failed writes leave the issue eligible for retry", async () => {
  const f = fixture();
  const add = f.options.github.rest.issues.addLabels;
  f.options.github.rest.issues.addLabels = async () => { throw new Error("API unavailable"); };
  await assert.rejects(applyLabels(f.options), /API unavailable/);
  assert.deepEqual(f.issue.labels, []);
  f.options.github.rest.issues.addLabels = add;
  await applyLabels(f.options);
  assert.equal(f.calls.length, 1);
});

test("rejects pull requests, bad issue numbers, non-boolean dry runs and read failures", async () => {
  const f = fixture();
  for (const issueNumber of [0, -1, NaN, 1.5]) {
    await assert.rejects(applyLabels({ ...f.options, issueNumber }), /issue number/);
  }
  await assert.rejects(applyLabels({ ...f.options, dryRun: "false" }), /boolean/);
  f.issue.pull_request = {};
  await assert.rejects(applyLabels(f.options), /Pull requests/);
  f.options.github.rest.issues.get = async () => { throw new Error("Read failed"); };
  await assert.rejects(applyLabels(f.options), /Read failed/);
  assert.equal(f.calls.length, 0);
});

test("prompt taxonomy matches the production allowlist", () => {
  const prompt = readFileSync(new URL("../prompts/issue-label-system.txt", `file://${__filename}`), "utf8");
  const approved = prompt.split("\n").filter(line => /^[a-z]+\/[a-z-]+ — /.test(line)).map(line => line.split(" — ")[0]);
  assert.deepEqual(approved.sort(), [...allowedLabels].sort());
});


test("maintainer review and marker removal never allow another classification", async () => {
  const f = fixture();
  await applyLabels(f.options);
  // The maintainer changes the classification, removes the marker, then edits/reopens.
  f.issue.labels = [{ name: "type/design" }, { name: "maintainer-reviewed" }];
  f.events.push({ event: "unlabeled", label: { name: marker } });
  const reviewedLabels = structuredClone(f.issue.labels);
  await prepareIssue(f.options);
  assert.equal(f.outputs.classify, "false");
  // Also protects an already running job whose model response arrived after review.
  await applyLabels(f.options);
  assert.equal(f.calls.length, 1);
  assert.deepEqual(f.issue.labels, reviewedLabels);
});

for (const event of ["labeled", "unlabeled"]) {
  test(`finds historical ${event} markers beyond the first event page`, async () => {
    const f = fixture();
    f.eventPages.set(42, [
      Array.from({ length: 100 }, () => ({ event: "closed" })),
      [{ event, label: { name: marker } }]
    ]);
    await prepareIssue(f.options);
    assert.equal(f.outputs.classify, "false");
    await applyLabels({ ...f.options, response: "not JSON" });
    assert.equal(f.calls.length, 0);
  });
}

test("unrelated historical labels do not prevent a first classification", async () => {
  const f = fixture();
  f.events.push({ event: "labeled", label: { name: "type/bug" } });
  f.events.push({ event: "unlabeled", label: { name: review } });
  await applyLabels(f.options);
  assert.equal(f.calls.length, 1);
});

test("current marker skips history calls", async () => {
  const f = fixture([marker]);
  await prepareIssue(f.options);
  await applyLabels(f.options);
  assert.equal(f.reads.length, 0);
});

test("history read failures block inference, writes, and backlog selection", async () => {
  const f = fixture();
  f.options.github.paginate.iterator = async function* (method) {
    if (method === f.options.github.rest.issues.listForRepo) yield { data: [f.issue] };
    else throw new Error("History unavailable");
  };
  await assert.rejects(prepareIssue(f.options), /History unavailable/);
  await assert.rejects(applyLabels(f.options), /History unavailable/);
  await assert.rejects(collectIssues({ ...f.options, limit: "25", state: "open" }), /History unavailable/);
  assert.deepEqual(f.outputs, {});
  assert.equal(f.calls.length, 0);
});

test("backlog scans beyond reviewed issues and pull requests before counting the limit", async () => {
  const f = fixture();
  f.issuePages.push([
    { number: 1, labels: [{ name: marker }] },
    { number: 2, labels: [], pull_request: {} },
    { number: 3, labels: [] }
  ], [{ number: 4, labels: [] }, { number: 5, labels: [] }], [{ number: 6, labels: [] }]);
  f.eventPages.set(3, [[{ event: "labeled", label: { name: marker } }]]);
  await collectIssues({ ...f.options, limit: "2", state: "closed" });
  assert.deepEqual(JSON.parse(f.outputs.issues), [{ number: 4 }, { number: 5 }]);
  assert.equal(f.outputs.count, "2");
  assert.deepEqual(f.reads.filter(r => r.args.issue_number).map(r => r.args.issue_number), [3, 4, 5]);
  assert.equal(f.reads[0].args.state, "closed");
  assert.equal(f.reads[0].args.sort, "created");
  assert.equal(f.reads[0].args.direction, "asc");
});

test("backlog with only reviewed issues produces an empty matrix", async () => {
  const f = fixture();
  f.issuePages.push([f.issue]);
  f.events.push({ event: "unlabeled", label: { name: marker } });
  await collectIssues({ ...f.options, limit: "25", state: "all" });
  assert.equal(f.outputs.issues, "[]");
  assert.equal(f.outputs.count, "0");
});

test("backlog returns fewer than the requested limit when eligible issues are exhausted", async () => {
  const f = fixture();
  f.issuePages.push([f.issue]);
  await collectIssues({ ...f.options, limit: "25", state: "open" });
  assert.equal(f.outputs.issues, '[{"number":42}]');
  assert.equal(f.outputs.count, "1");
});

test("backlog rejects invalid limits and states before reading GitHub", async () => {
  const f = fixture();
  for (const limit of ["", "0", "101", "-1", "1.5", "no", "Infinity"]) {
    await assert.rejects(collectIssues({ ...f.options, limit, state: "open" }), /limit/);
  }
  await assert.rejects(collectIssues({ ...f.options, limit: "25", state: "invalid" }), /state/);
  assert.equal(f.reads.length, 0);
});
