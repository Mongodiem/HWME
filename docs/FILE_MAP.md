# File Map

- `README.md`: GitHub reproduction guide.
- `ACCEPTANCE_MAPPING.md`: acceptance use-case to evidence/command/output mapping.
- `THIRD_PARTY.md`: third-party source, license boundary, and local customization notes.
- `DATASETS.md`: dataset/task provenance and capability coverage.
- `environment.yml`: conda environment definition.
- `.env.example`: runtime variable template.
- `scripts/setup_env.sh`: environment bootstrap.
- `scripts/check_env.sh`: dependency/runtime checks.
- `scripts/run_minimal_validation.sh`: low-cost end-to-end 最小验证.
- `scripts/run_full_eval.sh`: full two-phase evaluation entry.
- `scripts/retry_video.sh`: retry for `videomme_w_subtitle`.
- `scripts/retry_refcoco_gpu4567.sh`: retry for one RefCOCO task.
- `lmms_eval/`: evaluation framework and task/model implementations.
