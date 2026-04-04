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

RUN_ID="${RUN_ID:-SMOKE_$(date +%Y%m%d_%H%M%S)}"
OUT_DIR="${BASE_OUTPUT_DIR:-${PROJECT_ROOT}/eval_results/${RUN_ID}}"

RUN_TAG=SMOKE \
BASE_OUTPUT_DIR="$OUT_DIR" \
PHASE1_TASKS="${PHASE1_TASKS:-ocrbench}" \
ENABLE_PHASE2="${ENABLE_PHASE2:-0}" \
LIMIT="${LIMIT:-1}" \
BATCH_SIZE="${BATCH_SIZE:-1}" \
VLLM_TP="${VLLM_TP:-1}" \
GPU_MEM_UTIL_PHASE1="${GPU_MEM_UTIL_PHASE1:-0.45}" \
MAX_MODEL_LEN_PHASE1="${MAX_MODEL_LEN_PHASE1:-512}" \
CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}" \
SLEEP_SECONDS="${SLEEP_SECONDS:-1}" \
bash "${PROJECT_ROOT}/scripts/run_full_eval.sh"

RESULT=$(find "$OUT_DIR" -type f \( -name "*_results.json" -o -name "*_results.txt" \) | head -n 1 || true)
if [ -z "$RESULT" ]; then
  echo "[ERROR] smoke test finished but no result file found under $OUT_DIR"
  exit 1
fi

echo "[OK] smoke test output: $OUT_DIR"
echo "[OK] sample result file: $RESULT"
