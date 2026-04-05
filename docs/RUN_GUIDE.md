# RUN_GUIDE

本文档只描述交付版推荐执行顺序。机器内定制脚本（`run_uv_*`）保留，但不是交付方首选入口。

## 1. 进入目录并准备环境
```bash
cd <repo_root>
conda activate hwme
set -a; source .env; set +a
```

如果首次配置，先参考 `docs/ENVIRONMENT.md` 完成环境与 `.env`。

## 2. 先做轻量检查
```bash
bash scripts/check_env.sh
```

## 3. 跑最小复现
```bash
bash scripts/run_minimal_validation.sh
```

默认最小复现：
- 任务 `ocrbench`
- `LIMIT=1`
- `ENABLE_PHASE2=0`

## 4. 跑完整评测
```bash
bash scripts/run_full_eval.sh
```

默认完整评测：
- phase1: `mme,mmmu_val,ocrbench,refcoco_bbox_val,mmbench_en_dev`
- phase2: `videomme_w_subtitle`

## 5. 结果与日志查看
- 最小复现或完整评测输出根目录：`eval_results/<RUN_ID>/`
- `run_full_eval.sh`：
  - 图片任务：`eval_results/<RUN_ID>/image_tasks/`
  - 视频任务：`eval_results/<RUN_ID>/video_tasks/`

## 6. GPU 2/5 占卡说明
GPU 占卡、查看、释放、重占，请直接看：

- `docs/GPU_2_5_USAGE.md`

该文档只覆盖 GPU `2` 和 GPU `5`，并严格对应：

- 本机脚本 `test.py`（路径与命令见 `docs/GPU_2_5_USAGE.md`）
