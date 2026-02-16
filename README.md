# exec-error-doctor

Cross-tool OpenClaw skill to diagnose and mitigate exec-related command failures.

## Includes

- `SKILL.md`
- `scripts/exec_error_triage.sh`
- `scripts/gh_search_repos_safe.sh`
- `scripts/clawhub_publish_safe.sh`
- `references/error-taxonomy.md`
- `dist/exec-error-doctor.skill`

## Quick start

```bash
bash scripts/exec_error_triage.sh "Unknown JSON field: nameWithOwner"
bash scripts/gh_search_repos_safe.sh "safe-exec" 10
```
