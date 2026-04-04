# THIRD_PARTY

## 1. 说明范围
本文件用于说明 `HWME` 交付版本中可识别的第三方来源、依赖边界和本地裁剪改动。

## 2. 可识别的上游框架来源

### 2.1 LMMS-Eval 框架代码（主要基础）
- 证据：`pyproject.toml`
  - `project.name = "lmms_eval"`
  - `project.urls.Repository = "https://github.com/EvolvingLMMs-Lab/lmms-eval"`
- 当前状态：`HWME` 是在该框架基础上做交付裁剪后的子集版本。
- 协议：本仓库携带 `LICENSE`（MIT）。上游仓库的最终授权条款以其官方仓库为准。

### 2.2 vLLM 推理后端（第三方依赖）
- 证据：
  - `environment.yml` 中包含 `vllm>=0.6.0`
  - `lmms_eval/models/simple/vllm.py`
  - `lmms_eval/models/chat/vllm.py`
- 当前用途：评测时的模型推理执行后端。
- 协议：以 vLLM 官方仓库发布协议为准（本仓库未内嵌其许可证全文）。

### 2.3 Hugging Face 生态依赖（第三方依赖）
- 证据：
  - `pyproject.toml` 依赖包含 `datasets`, `transformers`
  - 任务 YAML 中 `dataset_path` 使用 HF 数据集标识（如 `lmms-lab/MME`）
- 当前用途：模型/数据下载、任务数据读取与处理。
- 协议：各组件与各数据集分别遵循其官方许可证。

## 3. 第三方任务/数据适配代码
以下任务目录属于评测任务适配实现，数据来自外部公开数据源（通常为 HF Hub）：
- `lmms_eval/tasks/mme/`
- `lmms_eval/tasks/mmmu/`
- `lmms_eval/tasks/ocrbench/`
- `lmms_eval/tasks/refcoco/`
- `lmms_eval/tasks/mmbench/`
- `lmms_eval/tasks/videomme/`

说明：任务适配代码在本仓库内；真实数据不随仓库分发。

## 4. HWME 交付版的自有整理/裁剪部分
以下改动属于本次交付整理结果（非上游原样）：
- 模型入口裁剪为仅支持 `vllm`
  - 证据：`lmms_eval/models/__init__.py`
- 交付执行脚本与最小验证脚本
  - `scripts/run_full_eval.sh`
  - `scripts/run_minimal_validation.sh`
  - `scripts/retry_video.sh`
  - `scripts/retry_refcoco_gpu4567.sh`
- 交付环境与自检脚本
  - `environment.yml`
  - `.env.example`
  - `scripts/setup_env.sh`
  - `scripts/check_env.sh`
- 交付文档体系
  - `README.md`
  - `ACCEPTANCE_MAPPING.md`
  - `DATASETS.md`
  - `docs/*`

## 5. 不完全确认项（明确边界）
以下内容未在本仓库内逐一附带官方许可证文本，需在外部仓库/官网核对：
- 各 Python 依赖包的许可证细节
- 各公开数据集的许可证和使用约束
- 各模型权重（如 `Qwen/Qwen2.5-VL-7B-Instruct`）的具体分发与商用条款

结论：`HWME` 提供的是评测代码与运行封装；第三方组件与数据/模型权利义务以其官方发布方为准。
