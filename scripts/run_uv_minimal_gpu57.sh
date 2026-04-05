#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CONDA_SH="${CONDA_SH:-/home/guozhihui/anaconda3/etc/profile.d/conda.sh}"
CONDA_ENV="${CONDA_ENV:-/home/guozhihui/anaconda3/envs/uv}"

source "$CONDA_SH"
conda activate "$CONDA_ENV"
cd "$PROJECT_ROOT"

RUN_ID="${RUN_ID:-MINIMAL_GPU57_$(date +%Y%m%d_%H%M%S)}"
OUT_DIR="${BASE_OUTPUT_DIR:-${PROJECT_ROOT}/eval_results/${RUN_ID}}"
LOG_DIR="${OUT_DIR}/logs"
LOG_FILE="${LOG_DIR}/run.log"

mkdir -p "$OUT_DIR" "$LOG_DIR"

set +e
set -o pipefail
RUN_TAG="${RUN_TAG:-MINIMAL_GPU57}" \
BASE_OUTPUT_DIR="$OUT_DIR" \
PHASE1_TASKS="${PHASE1_TASKS:-ocrbench}" \
ENABLE_PHASE2="${ENABLE_PHASE2:-0}" \
LIMIT="${LIMIT:-1}" \
BATCH_SIZE="${BATCH_SIZE:-1}" \
VLLM_TP="${VLLM_TP:-2}" \
GPU_MEM_UTIL_PHASE1="${GPU_MEM_UTIL_PHASE1:-0.45}" \
MAX_MODEL_LEN_PHASE1="${MAX_MODEL_LEN_PHASE1:-512}" \
CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-5,7}" \
SLEEP_SECONDS="${SLEEP_SECONDS:-1}" \
bash "${PROJECT_ROOT}/scripts/run_full_eval.sh" 2>&1 | tee "$LOG_FILE"
RC=${PIPESTATUS[0]}
set -e

RESULT_FILE=$(find "$OUT_DIR" -type f \( -name "*_results.json" -o -name "*_results.txt" \) | head -n 1 || true)

echo "__RUN_ID=${RUN_ID}__"
echo "__OUT_DIR=${OUT_DIR}__"
echo "__LOG_FILE=${LOG_FILE}__"
echo "__RESULT_FILE=${RESULT_FILE}__"
echo "__RC=${RC}__"

exit "$RC"
