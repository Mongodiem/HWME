# HWME

HWME 是一个基于 **LMMs-Eval** 开发的多模态模型评测项目。  
上游框架：`https://github.com/evolvinglmms-lab/lmms-eval`

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

## 2. 当前完成情况与结果摘要
### 2.1 当前整理完成情况
- 在 `lmms-eval` 基础上完成了任务范围收敛、运行脚本整理、环境模板整理和结果文档整理。
- 当前运行方式与上游评测调用链一致：原始入口为 `python -m lmms_eval`，脚本用于参数封装与复现便利。

### 2.2 已完成评测能力与指标
以下结果来自已归档汇报材料（`A_huibao` 三份报告），并已整理到 `docs/RESULTS.md`。

| Benchmark | 主要能力 | 任务名 | 样本数 | 主指标 | 当前结果 |
|---|---|---|---:|---|---:|
| MME | 感知能力 + 认知推理 | `mme` | 2374 | cognition / perception | 613.93 / 1701.69 |
| MMBench | 综合视觉问答与细粒度理解 | `mmbench_en_dev` | 4329 | `gpt_eval_score` | 83.16 |
| MMMU | 多学科知识与推理 | `mmmu_val` | 900 | accuracy | 50.67% |
| OCRBench | OCR识别与文档/场景文字理解 | `ocrbench` | 1000 | accuracy | 84.9%（849/1000） |
| Video-MME | 视频感知与视频理解 | `videomme_w_subtitle` | 2700 | perception_score | 64.52% |

详细结果与分项表格见：`docs/RESULTS.md`。

## 3. 最小复现（脚本版，优先）
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

## 4. 最小复现（原始入口版）
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

## 5. 完整评测
```bash
set -a; source .env; set +a
bash scripts/run_full_eval.sh
```

## 6. 输出位置
- 默认输出根目录：`eval_results/<RUN_ID>/`
- 最小复现：`eval_results/SMOKE_<timestamp>/...`
- 完整评测：
  - 图像任务：`eval_results/<RUN_ID>/image_tasks/`
  - 视频任务：`eval_results/<RUN_ID>/video_tasks/`

## 7. 仓库结构
- `lmms_eval/`：评测核心实现与任务定义
- `scripts/`：环境检查与评测脚本
- `docs/`：环境、流程、运行说明
- `environment.yml`：conda 环境定义
- `.env.example`：运行变量模板

## 8. 常见问题
- `MODEL_PATH is not set`：先在 `.env` 中设置 `MODEL_PATH`，再 `set -a; source .env; set +a`。
- `CUDA not available`：检查驱动、可见 GPU 与环境激活状态。
- 没有输出结果：先查看 `scripts/check_env.sh` 是否通过，再检查 `eval_results/<RUN_ID>/` 目录。

## 9. 更多文档
- `docs/ENVIRONMENT.md`
- `docs/EVAL_PIPELINE.md`
- `docs/RUN_GUIDE.md`
- `docs/RESULTS.md`
