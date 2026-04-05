# Eval Pipeline

## 1. 入口脚本
最小验证：

```bash
bash scripts/run_minimal_validation.sh
```

完整评测：

```bash
bash scripts/run_full_eval.sh
```

## 2. 核心调用链（与参考版一致）
1. `scripts/run_minimal_validation.sh` 或 `scripts/run_full_eval.sh`
2. `python -m lmms_eval`
3. `lmms_eval/__main__.py`
4. `lmms_eval/evaluator.py`
5. 任务 YAML（`lmms_eval/tasks/*/*.yaml`）
6. 任务后处理（`lmms_eval/tasks/*/utils.py`）
7. vLLM 后端（`lmms_eval/models/chat/vllm.py`、`lmms_eval/models/simple/vllm.py`）
8. 结果写出（`lmms_eval/loggers/evaluation_tracker.py`）

## 3. 交付任务
- `mme`
- `mmmu_val`
- `ocrbench`
- `refcoco_bbox_val`
- `refcoco_bbox_rec_val`
- `mmbench_en_dev`
- `videomme_w_subtitle`

## 4. 输出路径规则
- 默认输出根目录：`eval_results/<RUN_ID>/`
- `run_full_eval.sh`：
  - `image_tasks/`
  - `video_tasks/`
- `run_minimal_validation.sh`：
  - 默认 `SMOKE_<timestamp>/`，仅 phase1 的最小任务

可通过环境变量覆盖：

```bash
BASE_OUTPUT_DIR=/path/to/output bash scripts/run_full_eval.sh
```
