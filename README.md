# HWME

HWME 是一个面向交付复现的多模态评测仓库，基于 `lmms_eval` 调用链组织了可直接执行的评测脚本与文档。

默认推荐用脚本启动；底层真实入口仍是 `python -m lmms_eval`。

## 1. 快速开始
以下命令默认在仓库根目录执行：

```bash
conda env create -f environment.yml -n hwme || conda env update -f environment.yml -n hwme
conda activate hwme
python -m pip install -e .

cp .env.example .env
# 编辑 .env，至少设置 MODEL_PATH

set -a; source .env; set +a
bash scripts/check_env.sh
```

## 2. 最小复现（脚本版，优先）
```bash
set -a; source .env; set +a
bash scripts/run_minimal_validation.sh
```

默认最小复现参数：
- `PHASE1_TASKS=ocrbench`
- `LIMIT=1`
- `BATCH_SIZE=1`
- `ENABLE_PHASE2=0`

说明：`run_minimal_validation.sh` 是封装脚本，内部仍调用 `python -m lmms_eval`。

## 3. 最小复现（原始入口版）
```bash
set -a; source .env; set +a

python -m lmms_eval \
  --model vllm \
  --model_args "model=${MODEL_PATH},tensor_parallel_size=${VLLM_TP:-1},gpu_memory_utilization=${GPU_MEM_UTIL_PHASE1:-0.45},dtype=auto,trust_remote_code=True,max_model_len=${MAX_MODEL_LEN_PHASE1:-512},enforce_eager=True" \
  --tasks ocrbench \
  --batch_size "${BATCH_SIZE:-1}" \
  --limit "${LIMIT:-1}" \
  --log_samples \
  --output_path "eval_results/SMOKE_MANUAL_$(date +%Y%m%d_%H%M%S)"
```

## 4. 完整评测
```bash
set -a; source .env; set +a
bash scripts/run_full_eval.sh
```

## 5. 输出位置
- 默认输出根目录：`eval_results/<RUN_ID>/`
- 最小复现：`eval_results/SMOKE_<timestamp>/...`
- 完整评测：
  - 图像任务：`eval_results/<RUN_ID>/image_tasks/`
  - 视频任务：`eval_results/<RUN_ID>/video_tasks/`

## 6. 仓库结构
- `lmms_eval/`：评测核心实现与任务定义
- `scripts/`：环境检查与评测脚本
- `docs/`：环境、流程、运行说明
- `environment.yml`：conda 环境定义
- `.env.example`：运行变量模板

## 7. 常见问题
- `MODEL_PATH is not set`：先在 `.env` 中设置 `MODEL_PATH`，再 `set -a; source .env; set +a`。
- `CUDA not available`：检查驱动、可见 GPU 与环境激活状态。
- 没有输出结果：先查看 `scripts/check_env.sh` 是否通过，再检查 `eval_results/<RUN_ID>/` 目录。

## 8. 更多文档
- `docs/ENVIRONMENT.md`
- `docs/EVAL_PIPELINE.md`
- `docs/RUN_GUIDE.md`

补充说明：本仓库是交付整理版，核心评测调用链保持与已跑通版本一致。
