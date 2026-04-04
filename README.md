# HWME 正式交付说明（可复现评测版）

## 1. 交付定位
`HWME` 是面向交付与验收的最小必要评测代码集合。

本版本目标：
- 可对外说明来源与边界
- 可按文档复现最小验证
- 可映射到验收用例并给出证据文件与命令

当前统一结论：
- 该版本已在现有机器环境下完成最小评测链路实证验证。
- 后续使用者按 README 准备环境、模型、数据及 GPU 资源后，可复现最小验证 与评测流程。

## 2. 交付范围
当前保留任务：
- `mme`
- `mmmu_val`
- `ocrbench`
- `refcoco_bbox_val`
- `refcoco_bbox_rec_val`
- `mmbench_en_dev`
- `videomme_w_subtitle`

当前模型后端：
- `vllm`

## 3. 仓库内依赖 vs 仓库外依赖
### 3.1 仓库内（随 GitHub 一起交付）
- 评测代码：`lmms_eval/`
- 运行脚本：`scripts/run_full_eval.sh`, `scripts/run_minimal_validation.sh`
- 环境与自检：`environment.yml`, `.env.example`, `scripts/setup_env.sh`, `scripts/check_env.sh`
- 交付文档：`ACCEPTANCE_MAPPING.md`, `THIRD_PARTY.md`, `DATASETS.md`, `docs/*`

### 3.2 仓库外（使用者自行准备）
- CUDA/GPU 资源与驱动
- 模型权重（本地路径或 HF 模型 ID，如 `Qwen/Qwen2.5-VL-7B-Instruct`）
- 数据集文件（由任务 `dataset_path` 自动下载/读取缓存）
- `HF_TOKEN` 等认证信息
- （MMBench）外部评审 API（如 OpenAI/Azure 兼容接口）

## 4. 快速开始（面向首次 clone）
```bash
git clone <GITHUB_REPO_URL>
cd <repo_dir>
bash scripts/setup_env.sh
conda activate hwme
cp .env.example .env
# 编辑 .env：至少设置 MODEL_PATH / CUDA_VISIBLE_DEVICES / HF_TOKEN(如需要)
set -a; source .env; set +a
bash scripts/check_env.sh
```

## 5. 最小复现命令（最小验证）
```bash
set -a; source .env; set +a
bash scripts/run_minimal_validation.sh
```

默认 最小验证 配置：
- `PHASE1_TASKS=ocrbench`
- `LIMIT=1`
- `BATCH_SIZE=1`
- `VLLM_TP=1`
- `ENABLE_PHASE2=0`

成功标准：
- 在 `eval_results/<RUN_ID>/` 下产生至少一个结果文件：
  - `*_results.json` 或
  - 任务结果文本（如 `ocrbench_results.txt`）

## 6. 完整评测命令
```bash
set -a; source .env; set +a
bash scripts/run_full_eval.sh
```

## 7. 评测链路（命令实际触发代码）
1. `scripts/run_minimal_validation.sh` 或 `scripts/run_full_eval.sh`
2. `python -m lmms_eval` -> `lmms_eval/__main__.py`
3. `lmms_eval/evaluator.py`
4. 任务 YAML（如 `lmms_eval/tasks/ocrbench/ocrbench.yaml`）
5. 任务指标/聚合函数（各任务 `utils.py`）
6. 模型后端：`lmms_eval/models/chat/vllm.py` 与 `lmms_eval/models/simple/vllm.py`
7. 结果写出：`lmms_eval/loggers/evaluation_tracker.py`

## 8. 验收映射（1~4）
详见：`ACCEPTANCE_MAPPING.md`

## 9. 参考来源与版权说明
详见：`THIRD_PARTY.md`

## 10. 数据来源与公开性说明
详见：`DATASETS.md`

## 11. GitHub 仓库地址（交付信息）
- 当前预留位：`<GITHUB_REPO_URL>`
- 若已发布，请将该占位符替换为实际仓库地址。
