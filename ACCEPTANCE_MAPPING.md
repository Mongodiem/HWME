# ACCEPTANCE_MAPPING

> 面向交付/验收的逐条映射。所有结论均以当前 `HWME` 代码与文档为准。

## 验收用例 1
### 用例
基于 Qwen2.5-VL-7B-Instruct 的多模态模型部署与评测调用能力。

### 当前状态
- 已完成 `vLLM` 推理链路下的模型部署与评测调用。

### 证据文件
- `scripts/run_full_eval.sh`（`--model vllm`，`MODEL_PATH=Qwen/Qwen2.5-VL-7B-Instruct`）
- `lmms_eval/models/__init__.py`（仅保留 `vllm`）
- `lmms_eval/models/simple/vllm.py`

### 对应命令
```bash
set -a; source .env; set +a
bash scripts/run_minimal_validation.sh
```

### 输出结果
- 输出目录：`eval_results/<RUN_ID>/...`
- 结果文件：至少 `*_results.json` 或任务结果文本（如 `ocrbench_results.txt`）

---

## 验收用例 2
### 用例
基于大模型能力，提供多模态大模型评测的性能指标。

### 当前状态
- **已满足（在当前评测链路范围内）**：任务 YAML 与聚合函数已定义并可输出指标。

### 证据文件
- 入口脚本：`scripts/run_full_eval.sh`, `scripts/run_minimal_validation.sh`
- 指标定义（示例）：
  - `lmms_eval/tasks/ocrbench/ocrbench.yaml` -> `ocrbench_accuracy`
  - `lmms_eval/tasks/mme/mme.yaml` -> `mme_perception_score`, `mme_cognition_score`
  - `lmms_eval/tasks/mmmu/mmmu_val.yaml` -> `mmmu_acc`
  - `lmms_eval/tasks/videomme/videomme_w_subtitle.yaml` -> `videomme_perception_score`

### 对应命令
- 最小验证：
```bash
set -a; source .env; set +a
bash scripts/run_minimal_validation.sh
```
- 完整主链路：
```bash
set -a; source .env; set +a
bash scripts/run_full_eval.sh
```

### 输出结果
- `eval_results/<RUN_ID>/image_tasks/.../*_results.json`
- 任务特定附加产物（例如 OCRBench 文本汇总）

### 备注
- 指标产出取决于外部资源（模型、数据、GPU、API）的可用性。

---

## 验收用例 3
### 用例
提供多模态大模型的精度评测数据集，支持不同性能指标测评（图像理解、目标检测、OCR 等）。

### 当前状态
- **已满足“代码与数据接入能力”**：任务配置已覆盖图像理解、OCR、定位/检测、视频理解等能力。
- **实测边界**：本次最小实证链路以 `ocrbench` 最小验证 为主；其他任务为已保留可运行链路。

### 证据文件
- `DATASETS.md`（任务-数据集-能力映射）
- 任务 YAML：
  - `lmms_eval/tasks/mme/mme.yaml`
  - `lmms_eval/tasks/mmmu/mmmu_val.yaml`
  - `lmms_eval/tasks/ocrbench/ocrbench.yaml`
  - `lmms_eval/tasks/refcoco/refcoco_bbox_val.yaml`
  - `lmms_eval/tasks/refcoco/refcoco_bbox_rec_val.yaml`
  - `lmms_eval/tasks/mmbench/mmbench_en_dev.yaml`
  - `lmms_eval/tasks/videomme/videomme_w_subtitle.yaml`

### 对应命令
```bash
set -a; source .env; set +a
bash scripts/run_full_eval.sh
```
或按任务裁剪：
```bash
PHASE1_TASKS=ocrbench ENABLE_PHASE2=0 LIMIT=1 BATCH_SIZE=1 VLLM_TP=1 bash scripts/run_full_eval.sh
```

### 输出结果
- 统一输出根目录：`eval_results/<RUN_ID>/`

### 边界说明
- 仓库不分发数据本体，仅提供评测代码与公开获取方式。

---

## 验收用例 4
### 用例
提供测评代码的 GitHub 仓库地址。

### 当前状态
- **预留位已提供**：当前文档使用占位符，待仓库创建后替换。

### 证据文件
- `README.md` 的 “GitHub 仓库地址（交付信息）”章节。

### 当前填写
- `<GITHUB_REPO_URL>`

### 说明
- 尚未写入正式可访问 URL（若仓库尚未发布）。
