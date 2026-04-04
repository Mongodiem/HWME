#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MODEL_PATH="${MODEL_PATH:-Qwen/Qwen2.5-VL-7B-Instruct}"
CURRENT_TIME="$(date +%Y%m%d_%H%M)"
RUN_NAME="${RUN_NAME:-Qwen2.5-VL-7B_RETRY_REFCOCO_${CURRENT_TIME}}"
BASE_OUTPUT_DIR="${BASE_OUTPUT_DIR:-${PROJECT_ROOT}/eval_results/${RUN_NAME}}"
CACHE_DIR="${CACHE_DIR:-${PROJECT_ROOT}/eval_results/.cache_refcoco}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
REFCOCO_TASK="${REFCOCO_TASK:-refcoco_bbox_rec_val}"

BATCH_SIZE="${BATCH_SIZE:-2}"
GPU_MEM_UTIL="${GPU_MEM_UTIL:-0.9}"
MAX_LEN="${MAX_LEN:-8192}"
GEN_KWARGS="${GEN_KWARGS:-temperature=0,top_p=1,max_new_tokens=24}"
APPLY_CHAT_TEMPLATE="${APPLY_CHAT_TEMPLATE:-0}"
LOG_SAMPLES="${LOG_SAMPLES:-1}"
VLLM_TP="${VLLM_TP:-1}"

export HF_ENDPOINT="${HF_ENDPOINT:-https://huggingface.co}"
export HF_HOME="${HF_HOME:-${PROJECT_ROOT}/.cache/huggingface}"
export HF_DATASETS_CACHE="${HF_DATASETS_CACHE:-${HF_HOME}/datasets}"
export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
export NCCL_BLOCKING_WAIT="${NCCL_BLOCKING_WAIT:-1}"
export NCCL_TIMEOUT="${NCCL_TIMEOUT:-600}"
export NCCL_ASYNC_ERROR_HANDLING="${NCCL_ASYNC_ERROR_HANDLING:-1}"

if [[ "${HF_HOME}" != /* ]]; then
  HF_HOME="${PROJECT_ROOT}/${HF_HOME}"
  export HF_HOME
fi
if [[ "${HF_DATASETS_CACHE}" != /* ]]; then
  HF_DATASETS_CACHE="${PROJECT_ROOT}/${HF_DATASETS_CACHE}"
  export HF_DATASETS_CACHE
fi

mkdir -p "$BASE_OUTPUT_DIR" "$CACHE_DIR"

CMD=("${PYTHON_BIN}" -m lmms_eval \
  --model vllm \
  --model_args "model=${MODEL_PATH},tensor_parallel_size=${VLLM_TP},gpu_memory_utilization=${GPU_MEM_UTIL},dtype=auto,trust_remote_code=True,max_model_len=${MAX_LEN}" \
  --tasks "$REFCOCO_TASK" \
  --batch_size "$BATCH_SIZE" \
  --use_cache "$CACHE_DIR" \
  --output_path "${BASE_OUTPUT_DIR}/${REFCOCO_TASK}")

if [ "$APPLY_CHAT_TEMPLATE" = "1" ]; then
  CMD+=(--apply_chat_template)
fi

if [ -n "$GEN_KWARGS" ]; then
  CMD+=(--gen_kwargs "$GEN_KWARGS")
fi

if [ "$LOG_SAMPLES" = "1" ]; then
  CMD+=(--log_samples --log_samples_suffix "${REFCOCO_TASK}_retry")
fi

"${CMD[@]}"

echo "RefCOCO retry finished: ${BASE_OUTPUT_DIR}/${REFCOCO_TASK}"
