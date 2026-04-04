#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "${PROJECT_ROOT}/.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "${PROJECT_ROOT}/.env"
  set +a
fi

echo "[CHECK] python: $(command -v python || true)"
python -V

python - <<'PY'
import importlib
mods = ["torch", "transformers", "datasets", "vllm", "lmms_eval"]
for m in mods:
    importlib.import_module(m)
print("[OK] core imports passed:", ", ".join(mods))
PY

python - <<'PY'
import torch
print(f"[CHECK] torch.cuda.is_available={torch.cuda.is_available()}")
print(f"[CHECK] cuda_device_count={torch.cuda.device_count()}")
if torch.cuda.is_available() and torch.cuda.device_count() > 0:
    print(f"[CHECK] cuda_device_0={torch.cuda.get_device_name(0)}")
PY

: "${MODEL_PATH:?MODEL_PATH is not set. Put it in .env or export it first.}"
if [ -n "${HF_HOME:-}" ]; then
  if [[ "${HF_HOME}" != /* ]]; then
    HF_HOME="${PROJECT_ROOT}/${HF_HOME}"
  fi
  mkdir -p "$HF_HOME"
fi
if [ -n "${HF_DATASETS_CACHE:-}" ]; then
  if [[ "${HF_DATASETS_CACHE}" != /* ]]; then
    HF_DATASETS_CACHE="${PROJECT_ROOT}/${HF_DATASETS_CACHE}"
  fi
  mkdir -p "$HF_DATASETS_CACHE"
fi

echo "[CHECK] MODEL_PATH=${MODEL_PATH}"
echo "[CHECK] HF_HOME=${HF_HOME:-<not set>}"
echo "[CHECK] HF_DATASETS_CACHE=${HF_DATASETS_CACHE:-<not set>}"
echo "[CHECK] CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-<not set>}"

echo "[OK] environment check passed"
