#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MODEL_PATH="${MODEL_PATH:-Qwen/Qwen2.5-VL-7B-Instruct}"
CURRENT_TIME="$(date +%Y%m%d_%H%M)"
RUN_NAME="${RUN_NAME:-Qwen2.5-VL-7B_RETRY_VIDEO_${CURRENT_TIME}}"
BASE_OUTPUT_DIR="${BASE_OUTPUT_DIR:-${PROJECT_ROOT}/eval_results/${RUN_NAME}}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
VLLM_TP="${VLLM_TP:-1}"
GPU_MEM_UTIL="${GPU_MEM_UTIL:-0.9}"
MAX_MODEL_LEN="${MAX_MODEL_LEN:-32768}"

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

mkdir -p "$BASE_OUTPUT_DIR"

cleanup_gpu() {
  pkill -u "$(whoami)" -f "${PYTHON_BIN} -m lmms_eval" || true
  pkill -u "$(whoami)" -f "vllm" || true
  sleep 10
}

cleanup_gpu

"${PYTHON_BIN}" -m lmms_eval \
  --model vllm \
  --model_args "model=${MODEL_PATH},tensor_parallel_size=${VLLM_TP},gpu_memory_utilization=${GPU_MEM_UTIL},dtype=auto,trust_remote_code=True,max_model_len=${MAX_MODEL_LEN},enforce_eager=True" \
  --tasks videomme_w_subtitle \
  --batch_size 1 \
  --log_samples \
  --log_samples_suffix videomme_retry \
  --output_path "${BASE_OUTPUT_DIR}/videomme_w_subtitle"

cleanup_gpu

echo "VideoMME retry finished: ${BASE_OUTPUT_DIR}/videomme_w_subtitle"
