# FINAL_HANDOFF

## 1. Repository Identity
- Project name: `HWME`
- GitHub: `https://github.com/Mongodiem/HWME`
- License in repo: `MIT` (`LICENSE`)

## 2. What This Repository Delivers
- A delivery-scoped multimodal evaluation codebase based on `lmms_eval` core.
- Unified execution entry for:
  - minimal validation: `scripts/run_minimal_validation.sh`
  - full evaluation: `scripts/run_full_eval.sh`
- Formal delivery documentation for acceptance, datasets, and third-party boundary.

## 3. Acceptance Artifacts
- Acceptance mapping: `ACCEPTANCE_MAPPING.md`
- Third-party and source boundary: `THIRD_PARTY.md`
- Dataset provenance and capability coverage: `DATASETS.md`
- Pipeline and file map:
  - `docs/EVAL_PIPELINE.md`
  - `docs/FILE_MAP.md`

## 4. Minimal Validation Command
```bash
set -a; source .env; set +a
bash scripts/run_minimal_validation.sh
```

Expected output:
- Result files under `eval_results/<RUN_ID>/...`
- At least one result artifact (`*_results.json` or task result text file)

## 5. External Dependencies (Not Shipped in Repo)
- GPU/CUDA runtime
- model weights (local path or HF model id)
- datasets/caches (downloaded from public sources as configured)
- API credentials where required by specific tasks

## 6. Maintenance Principle
- All meaningful changes must be committed with clear messages.
- Keep acceptance mapping synchronized when behavior/scope changes.
- Do not claim completion for items not directly supported by repository evidence.
