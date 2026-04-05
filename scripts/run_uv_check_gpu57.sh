#!/bin/bash
set -euo pipefail

PROJECT_ROOT="/mnt/18T/guozhihui/Projects/huawei/HWME"
CONDA_SH="${CONDA_SH:-/home/guozhihui/anaconda3/etc/profile.d/conda.sh}"
CONDA_ENV="${CONDA_ENV:-/home/guozhihui/anaconda3/envs/uv}"
CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-5,7}"

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

echo "[CHECK] 1) python path"
PY_PATH=$(command -v python || true)
if [ -z "$PY_PATH" ]; then
  echo "[ERROR] python not found after conda activate"
  exit 1
fi
echo "[OK] python=${PY_PATH}"
python -V

echo "[CHECK] 2) torch import"
python - <<'PY'
import torch
print(f"[OK] torch={torch.__version__}")
PY

echo "[CHECK] 3) CUDA visible cards"
export CUDA_VISIBLE_DEVICES
python - <<'PY'
import os
import torch
print(f"[INFO] CUDA_VISIBLE_DEVICES={os.getenv('CUDA_VISIBLE_DEVICES')}")
print(f"[INFO] torch.cuda.is_available={torch.cuda.is_available()}")
print(f"[INFO] torch.cuda.device_count={torch.cuda.device_count()}")
if not torch.cuda.is_available():
    raise SystemExit("[ERROR] CUDA not available in current env")
for i in range(torch.cuda.device_count()):
    print(f"[INFO] logical_gpu_{i}={torch.cuda.get_device_name(i)}")
print("[OK] CUDA visibility check passed")
PY

if command -v nvidia-smi >/dev/null 2>&1; then
  echo "[INFO] physical GPU memory snapshot for GPU 5 and 7"
  nvidia-smi --query-gpu=index,memory.used,memory.free,utilization.gpu --format=csv,noheader,nounits | awk -F, '$1==5 || $1==7 {print $0}'
fi

echo "[CHECK] 4) lmms_eval import"
python - <<'PY'
import lmms_eval
print("[OK] lmms_eval import passed")
PY

echo "[CHECK] 5) task list"
python -m lmms_eval --tasks list >/tmp/hwme_task_list_gpu57.txt
if [ ! -s /tmp/hwme_task_list_gpu57.txt ]; then
  echo "[ERROR] task list output is empty"
  exit 1
fi
echo "[OK] task list generated: /tmp/hwme_task_list_gpu57.txt"
head -n 20 /tmp/hwme_task_list_gpu57.txt

echo "[DONE] environment checks passed"
