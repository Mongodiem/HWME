# Environment

## Recommended
- Use `conda` + `environment.yml`.
- Create and activate:
  ```bash
  conda env create -f environment.yml -n hwme
  conda activate hwme
  ```

## Required runtime variables
Configure via `.env` (copy from `.env.example`):
- `MODEL_PATH`
- `HF_TOKEN` (if needed by model/dataset)
- `HF_HOME`
- `HF_DATASETS_CACHE`
- `CUDA_VISIBLE_DEVICES`

## Sanity check
```bash
set -a; source .env; set +a
bash scripts/check_env.sh
```
