#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MODEL_PATH="${MODEL_PATH:-Qwen/Qwen2.5-VL-7B-Instruct}"
RUN_TAG="${RUN_TAG:-Qwen2.5-VL-7B}"
CURRENT_TIME="$(date +%Y%m%d_%H%M)"
RUN_NAME="${RUN_TAG}_${CURRENT_TIME}"
BASE_OUTPUT_DIR="${BASE_OUTPUT_DIR:-${PROJECT_ROOT}/eval_results/${RUN_NAME}}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
PHASE1_TASKS="${PHASE1_TASKS:-mme,mmmu_val,ocrbench,refcoco_bbox_val,mmbench_en_dev}"
PHASE2_TASKS="${PHASE2_TASKS:-videomme_w_subtitle}"
BATCH_SIZE="${BATCH_SIZE:-1}"
LIMIT="${LIMIT:-}"
VLLM_TP="${VLLM_TP:-1}"
GPU_MEM_UTIL_PHASE1="${GPU_MEM_UTIL_PHASE1:-0.8}"
GPU_MEM_UTIL_PHASE2="${GPU_MEM_UTIL_PHASE2:-0.8}"
MAX_MODEL_LEN_PHASE1="${MAX_MODEL_LEN_PHASE1:-8192}"
MAX_MODEL_LEN_PHASE2="${MAX_MODEL_LEN_PHASE2:-8192}"
ENABLE_PHASE2="${ENABLE_PHASE2:-1}"
SLEEP_SECONDS="${SLEEP_SECONDS:-20}"

export HF_ENDPOINT="${HF_ENDPOINT:-https://huggingface.co}"
export HF_HOME="${HF_HOME:-${PROJECT_ROOT}/.cache/huggingface}"
export HF_DATASETS_CACHE="${HF_DATASETS_CACHE:-${HF_HOME}/datasets}"
export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
export NCCL_BLOCKING_WAIT="${NCCL_BLOCKING_WAIT:-1}"
export NCCL_TIMEOUT="${NCCL_TIMEOUT:-600}"
export NCCL_ASYNC_ERROR_HANDLING="${NCCL_ASYNC_ERROR_HANDLING:-1}"
export NCCL_DEBUG="${NCCL_DEBUG:-WARN}"

if [[ "${HF_HOME}" != /* ]]; then
  HF_HOME="${PROJECT_ROOT}/${HF_HOME}"
  export HF_HOME
fi
if [[ "${HF_DATASETS_CACHE}" != /* ]]; then
  HF_DATASETS_CACHE="${PROJECT_ROOT}/${HF_DATASETS_CACHE}"
  export HF_DATASETS_CACHE
fi

mkdir -p "$BASE_OUTPUT_DIR"

printf "=========================================\n"
printf "HWME evaluation start - run: %s\n" "$RUN_NAME"
printf "Output directory: %s\n" "$BASE_OUTPUT_DIR"
printf "Model path/id: %s\n" "$MODEL_PATH"
printf "CUDA_VISIBLE_DEVICES: %s\n" "$CUDA_VISIBLE_DEVICES"
printf "=========================================\n"

PHASE1_CMD=("${PYTHON_BIN}" -m lmms_eval \
  --model vllm \
  --model_args "model=${MODEL_PATH},tensor_parallel_size=${VLLM_TP},gpu_memory_utilization=${GPU_MEM_UTIL_PHASE1},dtype=auto,trust_remote_code=True,max_model_len=${MAX_MODEL_LEN_PHASE1},enforce_eager=True" \
  --tasks "$PHASE1_TASKS" \
  --batch_size "$BATCH_SIZE" \
  --log_samples \
  --log_samples_suffix image_comprehensive \
  --output_path "${BASE_OUTPUT_DIR}/image_tasks")

if [ -n "$LIMIT" ]; then
  PHASE1_CMD+=(--limit "$LIMIT")
fi

"${PHASE1_CMD[@]}"

if ! find "${BASE_OUTPUT_DIR}/image_tasks" -type f -name "*_results.json" | grep -q .; then
  echo "[Phase 1] No *_results.json found under ${BASE_OUTPUT_DIR}/image_tasks"
  exit 1
fi

pkill -u "$(whoami)" -f "${PYTHON_BIN} -m lmms_eval" || true
pkill -u "$(whoami)" -f "vllm" || true
sleep "$SLEEP_SECONDS"

if [ "$ENABLE_PHASE2" = "1" ]; then
  PHASE2_CMD=("${PYTHON_BIN}" -m lmms_eval \
    --model vllm \
    --model_args "model=${MODEL_PATH},tensor_parallel_size=${VLLM_TP},gpu_memory_utilization=${GPU_MEM_UTIL_PHASE2},dtype=auto,trust_remote_code=True,max_model_len=${MAX_MODEL_LEN_PHASE2},enforce_eager=True" \
    --tasks "$PHASE2_TASKS" \
    --batch_size "$BATCH_SIZE" \
    --log_samples \
    --log_samples_suffix video_understanding \
    --output_path "${BASE_OUTPUT_DIR}/video_tasks")

  if [ -n "$LIMIT" ]; then
    PHASE2_CMD+=(--limit "$LIMIT")
  fi

  "${PHASE2_CMD[@]}"

  if ! find "${BASE_OUTPUT_DIR}/video_tasks" -type f -name "*_results.json" | grep -q .; then
    echo "[Phase 2] No *_results.json found under ${BASE_OUTPUT_DIR}/video_tasks"
    exit 1
  fi
else
  echo "[Phase 2] Skipped (ENABLE_PHASE2=$ENABLE_PHASE2)"
fi

printf "=========================================\n"
printf "Evaluation finished. Output: %s\n" "$BASE_OUTPUT_DIR"
printf "=========================================\n"
