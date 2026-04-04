# DATASETS

## 1. 总体说明
`HWME` 不直接分发评测数据本体，仅提供任务配置、读取逻辑和评测流程。
数据由使用者在本地通过公开来源（主要为 Hugging Face Hub）获取。

## 2. 当前交付任务与数据来源

| 任务 | YAML 入口 | dataset_path | 能力覆盖 | 公开性说明 |
|---|---|---|---|---|
| MME | `lmms_eval/tasks/mme/mme.yaml` | `lmms-lab/MME` | 图像理解、感知/认知问答 | 通过 HF 标识访问，通常可公开获取（具体访问策略以数据页为准） |
| MMMU (val) | `lmms_eval/tasks/mmmu/mmmu_val.yaml` | `lmms-lab/MMMU` | 多学科多模态理解与推理 | 通过 HF 标识访问，具体权限以数据页为准 |
| OCRBench | `lmms_eval/tasks/ocrbench/ocrbench.yaml` | `echo840/OCRBench` | OCR 与文本识别/场景文本理解 | 通过 HF 标识访问，具体权限以数据页为准 |
| RefCOCO bbox | `lmms_eval/tasks/refcoco/refcoco_bbox_val.yaml` | `lmms-lab/RefCOCO` | 指代表达定位（框生成文本评估） | 通过 HF 标识访问，具体权限以数据页为准 |
| RefCOCO bbox_rec | `lmms_eval/tasks/refcoco/refcoco_bbox_rec_val.yaml` | `lmms-lab/RefCOCO` | 指代表达目标检测/定位（IoU、ACC@阈值） | 通过 HF 标识访问，具体权限以数据页为准 |
| MMBench en_dev | `lmms_eval/tasks/mmbench/mmbench_en_dev.yaml` | `lmms-lab/MMBench`（由 include 模板指定） | 图像问答与综合理解 | 通过 HF 标识访问；评审依赖外部 API |
| VideoMME w_subtitle | `lmms_eval/tasks/videomme/videomme_w_subtitle.yaml` | `lmms-lab/Video-MME` | 视频理解 | 通过 HF 标识访问，具体权限以数据页为准 |

## 3. 指标与数据关系（示例）
- `mme`: `mme_perception_score`, `mme_cognition_score`
- `mmmu_val`: `mmmu_acc`
- `ocrbench`: `ocrbench_accuracy`
- `refcoco_bbox_val`: BLEU/METEOR/ROUGE/CIDEr 等
- `refcoco_bbox_rec_val`: IoU, ACC@0.1~0.9, Center_ACC
- `mmbench_en_dev`: `gpt_eval_score`, `submission`
- `videomme_w_subtitle`: `videomme_perception_score`

## 4. 数据获取方式
1. 配置 `.env`：至少包含 `HF_TOKEN`（若数据受限）、`HF_HOME`、`HF_DATASETS_CACHE`。
2. 执行评测命令（如最小验证）：任务会按 `dataset_path` 自动下载或读取缓存。

## 5. 仓库外依赖边界
- 数据文件本体：仓库外
- 模型权重：仓库外
- HF 认证信息：仓库外

## 6. 验收相关说明
- 本次“最小闭环实证”聚焦 `ocrbench` 最小验证 链路。
- 其他任务在当前版本中为“代码与配置已保留”，可按 README 命令复现；是否执行全量由资源窗口决定。
