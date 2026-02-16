# exec-error-doctor

Cross-tool OpenClaw skill to diagnose and mitigate exec-related command failures.

## Includes

- `SKILL.md`
- `scripts/exec_error_triage.sh`
- `scripts/gh_search_repos_safe.sh`
- `scripts/clawhub_publish_safe.sh`
- `scripts/clawhub_inspect_safe.sh`
- `references/error-taxonomy.md`
- `dist/exec-error-doctor.skill`

## Beginner quick start

If you just hit an `Exec` error and want a fast answer, do this:

### 1) Classify the error text

```bash
bash scripts/exec_error_triage.sh "Unknown JSON field: nameWithOwner"
```

You’ll get output like:

- `CATEGORY=...`
- `CONFIDENCE=...`
- `WHY=...`
- `NEXT=...`

Start with the `NEXT` line.

### 2) Run the recommended safe wrapper

For GitHub CLI JSON-field issues:

```bash
bash scripts/gh_search_repos_safe.sh "safe-exec" 10
```

For ClawHub inspect visibility lag right after publish:

```bash
bash scripts/clawhub_inspect_safe.sh exec-error-doctor 12 10
```

For ClawHub publish + verify:

```bash
bash scripts/clawhub_publish_safe.sh ./skills/my-skill my-skill "My Skill" 1.0.0 "Initial release"
```

## Common examples

### Example A — GitHub CLI field mismatch

Error:

`Unknown JSON field: nameWithOwner`

Fix:
- Use `fullName` instead of `nameWithOwner`, or
- run `gh_search_repos_safe.sh` and let it auto-fallback.

### Example B — ClawHub inspect says "Skill not found" after publish

Fix:
- Retry with backoff using `clawhub_inspect_safe.sh`.
- If web page `/skills/<slug>` exists, treat as transient indexing inconsistency and retry later.

## Troubleshooting

- `command not found` / `ENOENT`: install missing binary and verify with `command -v <bin>`
- `Not logged in`: re-auth and verify with `whoami`
- timeout / SIGKILL: increase timeout or reduce workload

## Quick start (original)

```bash
bash scripts/exec_error_triage.sh "Unknown JSON field: nameWithOwner"
bash scripts/gh_search_repos_safe.sh "safe-exec" 10
```