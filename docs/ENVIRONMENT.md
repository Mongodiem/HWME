# Environment

## 1. 基础环境
推荐使用 `conda`：

```bash
cd <repo_root>
conda env create -f environment.yml -n hwme || conda env update -f environment.yml -n hwme
conda activate hwme
python -m pip install -e .
```

## 2. 运行变量
从模板创建：

```bash
cp .env.example .env
```

至少需要确认：
- `MODEL_PATH`：模型路径或模型 ID（必须）
- `CUDA_VISIBLE_DEVICES`：使用哪几张 GPU
- `HF_TOKEN`：如模型或数据需要鉴权
- `HF_HOME`、`HF_DATASETS_CACHE`：缓存目录

加载变量：

```bash
set -a; source .env; set +a
```

## 3. 轻量自检
```bash
bash scripts/check_env.sh
```

该脚本会检查：
- Python 可执行路径
- `torch/transformers/datasets/vllm/lmms_eval` 导入
- CUDA 可见卡
- 关键环境变量
