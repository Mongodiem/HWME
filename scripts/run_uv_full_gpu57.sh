#!/bin/bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_PATH}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CONDA_SH="${CONDA_SH:-/home/guozhihui/anaconda3/etc/profile.d/conda.sh}"
CONDA_ENV="${CONDA_ENV:-/home/guozhihui/anaconda3/envs/uv}"

if [ ! -f "$CONDA_SH" ]; then
  echo "[ERROR] conda.sh not found: $CONDA_SH"
  exit 1
fi

if [ ! -d "$CONDA_ENV" ]; then
  echo "[ERROR] conda env path not found: $CONDA_ENV"
  exit 1
fi

source "$CONDA_SH"
conda activate "$CONDA_ENV"
cd "$PROJECT_ROOT"

if ! command -v python >/dev/null 2>&1; then
  echo "[ERROR] python not found after conda activate"
  exit 1
fi

: "${MODEL_PATH:?MODEL_PATH is required. Example: export MODEL_PATH=Qwen/Qwen2.5-VL-7B-Instruct}"

CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-5,7}"
VLLM_TP="${VLLM_TP:-2}"
BATCH_SIZE="${BATCH_SIZE:-1}"

PHASE1_TASKS="${PHASE1_TASKS:-mme,mmmu_val,ocrbench,refcoco_bbox_val,mmbench_en_dev}"
PHASE2_TASKS="${PHASE2_TASKS:-videomme_w_subtitle}"
ENABLE_PHASE2="${ENABLE_PHASE2:-1}"
LIMIT="${LIMIT:-}"

GPU_MEM_UTIL_PHASE1="${GPU_MEM_UTIL_PHASE1:-0.8}"
GPU_MEM_UTIL_PHASE2="${GPU_MEM_UTIL_PHASE2:-0.8}"
MAX_MODEL_LEN_PHASE1="${MAX_MODEL_LEN_PHASE1:-8192}"
MAX_MODEL_LEN_PHASE2="${MAX_MODEL_LEN_PHASE2:-8192}"
SLEEP_SECONDS="${SLEEP_SECONDS:-20}"

export HF_ENDPOINT="${HF_ENDPOINT:-https://huggingface.co}"
export HF_HOME="${HF_HOME:-${PROJECT_ROOT}/.cache/huggingface}"
export HF_DATASETS_CACHE="${HF_DATASETS_CACHE:-${HF_HOME}/datasets}"
export NCCL_BLOCKING_WAIT="${NCCL_BLOCKING_WAIT:-1}"
export NCCL_TIMEOUT="${NCCL_TIMEOUT:-600}"
export NCCL_ASYNC_ERROR_HANDLING="${NCCL_ASYNC_ERROR_HANDLING:-1}"
export NCCL_DEBUG="${NCCL_DEBUG:-WARN}"

if [[ "$HF_HOME" != /* ]]; then
  HF_HOME="${PROJECT_ROOT}/${HF_HOME}"
fi
if [[ "$HF_DATASETS_CACHE" != /* ]]; then
  HF_DATASETS_CACHE="${PROJECT_ROOT}/${HF_DATASETS_CACHE}"
fi
export HF_HOME HF_DATASETS_CACHE

RUN_ID="${RUN_ID:-FULL_GPU57_$(date +%Y%m%d_%H%M%S)}"
OUT_DIR="${BASE_OUTPUT_DIR:-${PROJECT_ROOT}/eval_results/${RUN_ID}}"
LOG_DIR="${OUT_DIR}/logs"
mkdir -p "$OUT_DIR" "$LOG_DIR"

split_csv() {
  local input="$1"
  echo "$input" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | sed '/^$/d'
}

cleanup_vllm() {
  pkill -u "$(whoami)" -f "python -m lmms_eval" || true
  pkill -u "$(whoami)" -f "vllm" || true
  sleep "$SLEEP_SECONDS"
}

run_one_task() {
  local stage="$1"
  local task="$2"
  local gpu_mem_util="$3"
  local max_len="$4"

  local task_out_dir="${OUT_DIR}/${stage}/${task}"
  local task_log_file="${LOG_DIR}/${stage}_${task}.log"
  mkdir -p "$task_out_dir"

  echo "[INFO] stage=${stage} task=${task} out=${task_out_dir}"

  local -a cmd
  cmd=(python -m lmms_eval
    --model vllm
    --model_args "model=${MODEL_PATH},tensor_parallel_size=${VLLM_TP},gpu_memory_utilization=${gpu_mem_util},dtype=auto,trust_remote_code=True,max_model_len=${max_len},enforce_eager=True"
    --tasks "$task"
    --batch_size "$BATCH_SIZE"
    --log_samples
    --log_samples_suffix "${stage}_${task}"
    --output_path "$task_out_dir")

  if [ -n "$LIMIT" ]; then
    cmd+=(--limit "$LIMIT")
  fi

  set +e
  set -o pipefail
  CUDA_VISIBLE_DEVICES="$CUDA_VISIBLE_DEVICES" "${cmd[@]}" 2>&1 | tee "$task_log_file"
  local rc=${PIPESTATUS[0]}
  set -e

  if [ "$rc" -ne 0 ]; then
    echo "[ERROR] task failed: ${task}, rc=${rc}, log=${task_log_file}"
    return "$rc"
  fi

  local result_file
  result_file=$(find "$task_out_dir" -type f \( -name "*_results.json" -o -name "*_results.txt" \) | head -n 1 || true)
  if [ -z "$result_file" ]; then
    echo "[ERROR] no result file generated for task=${task} under ${task_out_dir}"
    return 1
  fi

  echo "[OK] task done: ${task}"
  echo "[OK] task log: ${task_log_file}"
  echo "[OK] task result sample: ${result_file}"

  cleanup_vllm
}

echo "========================================="
echo "[INFO] PROJECT_ROOT=${PROJECT_ROOT}"
echo "[INFO] python=$(command -v python)"
echo "[INFO] MODEL_PATH=${MODEL_PATH}"
echo "[INFO] CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES}"
echo "[INFO] VLLM_TP=${VLLM_TP}"
echo "[INFO] BATCH_SIZE=${BATCH_SIZE}"
echo "[INFO] OUT_DIR=${OUT_DIR}"
echo "========================================="

while IFS= read -r task; do
  run_one_task "phase1" "$task" "$GPU_MEM_UTIL_PHASE1" "$MAX_MODEL_LEN_PHASE1"
done < <(split_csv "$PHASE1_TASKS")

if [ "$ENABLE_PHASE2" = "1" ]; then
  while IFS= read -r task; do
    run_one_task "phase2" "$task" "$GPU_MEM_UTIL_PHASE2" "$MAX_MODEL_LEN_PHASE2"
  done < <(split_csv "$PHASE2_TASKS")
else
  echo "[INFO] phase2 skipped (ENABLE_PHASE2=$ENABLE_PHASE2)"
fi

echo "========================================="
echo "__RUN_ID=${RUN_ID}__"
echo "__OUT_DIR=${OUT_DIR}__"
echo "__LOG_DIR=${LOG_DIR}__"
echo "__RC=0__"
echo "========================================="
