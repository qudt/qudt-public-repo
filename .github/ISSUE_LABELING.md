# Issue labeling

The workflows classify QUDT issues with GitHub Copilot and suggest labels for
type, area, effort, and impact. Existing labels and maintainer decisions are
preserved. Classification rules and the 16 approved labels are defined in
[`prompts/issue-label-system.txt`](./prompts/issue-label-system.txt).

## Setup

- Confirm that the organization permits **Allow use of Copilot CLI billed to the
  organization**. Enterprise policy may override this setting. See
  [GitHub's Copilot CLI setup instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli-in-actions).
- Allow `actions/checkout`, `actions/setup-node`, `actions/ai-inference`, and
  `actions/github-script` in the organization's Actions policy.
- The workflows use the built-in `GITHUB_TOKEN` with `contents: read`,
  `issues: write`, and `copilot-requests: write`. No personal token or additional
  repository secret is needed for this configuration.
- Optionally set the Actions variable `COPILOT_MODEL` to an allowed model
  identifier. Otherwise Copilot chooses its default model.
- Review [Copilot authentication and billing in Actions](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/copilot-cli-in-github-actions)
  and configure an appropriate organization budget.

### Label names and descriptions

Prefer creating the approved labels in the repository before enabling automatic
labeling, with descriptions and colors that help maintainers interpret them.
Use the exact names in the prompt; existing labels such as `bug` are not renamed
to `type/bug` by these workflows.

GitHub label descriptions are optional. The classifier receives label meanings
from the checked-in prompt, so empty descriptions on GitHub do not prevent
classification. Descriptions and colors can be added later.

With `issues: write`, GitHub can create missing labels when they are added to an
issue. These workflows use the same label-addition endpoint as
[GitHub's labeler action](https://github.com/actions/labeler#recommended-permissions).
They send only names: they do not populate descriptions, choose colors, or
provision all 16 labels up front. A label that is never suggested may therefore
remain absent.

## Automatic labeling

[`workflows/ai-label-new-issues.yml`](./workflows/ai-label-new-issues.yml) runs when
issues are opened, reopened, or edited. Eligible issues are classified using
the current title, body, labels, curated QUDT context, and repository excerpts.

The response must contain valid JSON with exactly one approved `type/*` label
and at most one `area/*`, `effort/*`, and `impact/*` label. Duplicate suggestions
are removed. Unknown labels are ignored and trigger `ai/needs-human-review`, as
do high-impact suggestions and conflicts with existing category labels. Existing
labels take precedence and are never removed by the workflows.

Each classification has a 15-minute timeout. Its Actions summary records the
prompt version, proposed and added labels, conflicts, confidence, and reasoning.

## Labeling existing issues

In GitHub Actions, select **AI label existing issues** and choose **Run workflow**.
The workflow accepts:

- `limit`: 1–100 eligible issues, default 25.
- `state`: `open`, `closed`, or `all`, default `open`.
- `dry_run`: default `true`; set to `false` to apply labels.

The workflow selects never-classified issues oldest first, skipping pull
requests and previously classified issues before counting the limit. Up to five
classifications run in parallel. Dry runs still call Copilot and consume usage,
but only write job summaries; they do not apply labels or create label history.

## Maintainer review and repeat-run protection

The workflows add `ai/suggested-labels` with the classification labels in one
request. A maintainer reviews and adjusts the labels, then removes
`ai/suggested-labels` when review is complete.

Removal does not make the issue eligible again. Both workflows check current
labels and paginated issue-event history for a `labeled` or `unlabeled` event
whose label name is `ai/suggested-labels`. Any matching event counts, regardless
of who applied the label. This also protects issues classified before these
history checks were introduced. No extra persistent label or bot comment is used.

The history check runs during backlog selection, before inference, and again
before applying labels. Both workflows share an `ai-label-issue-<number>`
concurrency group, so their classification jobs for the same issue cannot run
at the same time. Keep the marker's name unchanged because history checks match
it by name. There is no force-reclassification option.

A history-read failure stops the job rather than risking relabeling. Failed
attempts that never applied the marker and dry runs remain eligible. Humans and
unrelated bots do not share the concurrency group and can still change labels
between the final read and write.

## Troubleshooting and testing

- For Copilot authentication or model errors, check the organization policy,
  allowed model, and billing configuration using the GitHub links above.
- For label-write failures, confirm `issues: write` access and check that labels
  are available. Descriptions are not required. Check the issue's actual labels
  and job logs before retrying a failed run.
- For a skipped issue, look for the current marker or its addition/removal in
  the issue timeline. Removing it again does not reset eligibility.
- Invalid model responses fail without marking the issue complete. History
  scans on large backlogs require extra API requests and may encounter rate limits.

Run the offline operational tests with Node.js 24:

```shell
node --test .github/scripts/issue-labeling.test.cjs
```

[`workflows/test-issue-labeling.yml`](./workflows/test-issue-labeling.yml) runs these
mocked tests on relevant pull requests and supports manual runs. They do not
call Copilot or modify GitHub issues.

QUDT's `mvn -Pzip install` build checks Markdown formatting. Workflow syntax can
also be checked with actionlint 1.7.12:

```shell
actionlint -ignore 'unknown permission scope "copilot-requests"' .github/workflows/ai-label-new-issues.yml .github/workflows/ai-label-existing-issues.yml .github/workflows/test-issue-labeling.yml
```

The narrow exception accounts for actionlint 1.7.12 not yet recognizing the
GitHub-documented `copilot-requests` permission; other lint errors remain failures.
