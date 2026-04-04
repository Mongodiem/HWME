# MAINTENANCE

## 1. Scope
This document defines maintenance rules for `HWME` as a delivery repository.

## 2. Branch and commit policy
- Default branch: `main`
- Every meaningful change must be committed with a clear message.
- Avoid bundling unrelated changes into one commit.
- Keep docs synchronized with behavior changes in scripts/tasks.

## 3. Mandatory update checklist for each release round
1. If runtime behavior changed:
   - update `README.md`
   - update `docs/EVAL_PIPELINE.md`
2. If acceptance evidence changed:
   - update `ACCEPTANCE_MAPPING.md`
3. If dataset/task scope changed:
   - update `DATASETS.md`
4. If third-party boundary changed:
   - update `THIRD_PARTY.md`
5. Record summary in:
   - `CHANGELOG.md`
   - `FINAL_HANDOFF.md` (when preparing a handoff build)

## 4. Versioning/release suggestions
- Optional lightweight tag format: `vYYYY.MM.DD-rN`
- Recommended release notes structure:
  - Scope
  - Key changes
  - Acceptance evidence updates
  - Known limitations

## 5. Non-negotiable documentation rules
- Do not claim completion without repository evidence.
- Keep original acceptance item text when required by delivery process.
- Clearly separate:
  - implemented facts
  - external dependencies
  - pending confirmation items

## 6. Security and secrets
- Never commit secrets/tokens to repository.
- Keep runtime secrets in local `.env` (ignored by git).
