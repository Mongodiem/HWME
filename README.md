# HWME 交付版说明

## 1. 目录定位
- 正式交付目录（当前目录）：`<repo_root>`
- 之前已跑通的参考目录：`<reference_repo_root>`

## 2. 与参考版本关系（核心链路）
- `HWME` 是基于 `lmms-eval` 的交付化整理包。
- 核心运行链路保持一致：
  1. `python -m lmms_eval`（`lmms_eval/__main__.py`）
  2. `lmms_eval/evaluator.py`
  3. `lmms_eval/loggers/evaluation_tracker.py`
  4. vLLM 后端（`lmms_eval/models/chat/vllm.py`、`lmms_eval/models/simple/vllm.py`）
  5. 交付任务 YAML（`mme/mmmu_val/ocrbench/refcoco_bbox_val/mmbench_en_dev/videomme_w_subtitle`）
- 当前差异主要在交付层（目录裁剪、脚本参数化、文档补充），不改核心逻辑。

## 3. 原始入口（优先）
交付版保留与参考版本一致的真实入口：`python -m lmms_eval`。

最小原始命令示例（`ocrbench`）：

```bash
cd <repo_root>
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

## 4. 当前 HWME 脚本入口（对原始入口的封装）
- `scripts/run_minimal_validation.sh`
- `scripts/run_full_eval.sh`

这两个脚本内部仍调用 `python -m lmms_eval`，用于减少手工参数错误。

## 5. 最小复现（脚本版）
```bash
cd <repo_root>
conda env create -f environment.yml -n hwme || conda env update -f environment.yml -n hwme
conda activate hwme
python -m pip install -e .
cp .env.example .env
set -a; source .env; set +a
bash scripts/check_env.sh
bash scripts/run_minimal_validation.sh
```

默认最小验证行为：
- 任务：`ocrbench`
- `LIMIT=1`
- `BATCH_SIZE=1`
- `ENABLE_PHASE2=0`

## 6. 结果与日志位置
- 默认输出根目录：`eval_results/<RUN_ID>/`
- `scripts/run_minimal_validation.sh`：`eval_results/SMOKE_<time>/...`
- `scripts/run_full_eval.sh`：
  - 图片任务：`eval_results/<RUN_ID>/image_tasks/`
  - 视频任务：`eval_results/<RUN_ID>/video_tasks/`
- 本机定制脚本（`scripts/run_uv_*`）细节见 `docs/HANDOFF.md`（不作为公开默认入口）。

## 7. 先看哪些文档
1. `docs/EVAL_PIPELINE.md`
2. `docs/ENVIRONMENT.md`
3. `docs/RUN_GUIDE.md`
4. `docs/GPU_2_5_USAGE.md`
5. `docs/HANDOFF.md`

## 8. 当前状态（保守说明）
- 已完成：核心代码一致性核对、脚本/文档整理、`.gitignore` 整理。
- 未在本轮重跑完整评测；当前机器上的完整运行状态仍需你手动确认。
