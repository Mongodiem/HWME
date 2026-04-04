#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_NAME="${CONDA_ENV_NAME:-hwme}"

if ! command -v conda >/dev/null 2>&1; then
  echo "[ERROR] conda not found. Please install Miniconda/Anaconda first."
  exit 1
fi

conda env create -f "${PROJECT_ROOT}/environment.yml" -n "$ENV_NAME" || conda env update -f "${PROJECT_ROOT}/environment.yml" -n "$ENV_NAME"

eval "$(conda shell.bash hook)"
conda activate "$ENV_NAME"

python -m pip install --upgrade pip
python -m pip install -e "$PROJECT_ROOT"

echo "[OK] Environment ready."
echo "Next:"
echo "  conda activate $ENV_NAME"
echo "  cp .env.example .env"
echo "  set -a; source .env; set +a"
echo "  bash scripts/check_env.sh"
