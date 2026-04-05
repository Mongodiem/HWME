# RESULTS

本文档汇总当前仓库对应的已复现结果与对比结论，作为 README 的详细补充。

## 1. 数据来源
本页内容整理自以下已归档材料：
- `01_飞书汇报版.md`
- `02_技术附录版.md`
- `03_官方Qwen2.5VL对比分析.md`

以上材料位于历史评测归档目录 `A_huibao`，本页只做结构化整理。

## 2. 当前已完成内容（交付视角）
本仓库当前已完成：
- 核心评测调用链保留（`python -m lmms_eval`）
- 交付脚本整理（最小复现、完整评测、环境检查）
- 环境模板与运行说明补全（`environment.yml`、`.env.example`、`docs/*`）
- 已复现结果摘要与对比说明补全（本文件）

说明：本次交付整理以文档与脚本可用性为主，不包含核心评测逻辑重构。

## 3. 已复现任务与主指标

| Benchmark | 任务名 | 样本数（effective） | 主指标 | 当前结果 |
|---|---|---:|---|---:|
| MME | `mme` | 2374 | cognition / perception | 613.93 / 1701.69 |
| MMBench | `mmbench_en_dev` | 4329 | `gpt_eval_score` | 83.16 |
| MMMU | `mmmu_val` | 900 | accuracy | 50.67% |
| OCRBench | `ocrbench` | 1000 | accuracy | 84.9%（849/1000） |
| Video-MME | `videomme_w_subtitle` | 2700 | perception_score | 64.52% |

## 4. 关键结果表（分项）

### 4.1 OCRBench 分项
| 维度 | 满分 | 得分 | 准确率 |
|---|---:|---:|---:|
| Text Recognition | 300 | 272 | 90.7% |
| Scene Text-centric VQA | 200 | 179 | 89.5% |
| Doc-oriented VQA | 200 | 175 | 87.5% |
| Key Information Extraction | 200 | 177 | 88.5% |
| Handwritten Mathematical Expression | 100 | 46 | 46.0% |
| Total | 1000 | 849 | 84.9% |

### 4.2 MMBench（摘要）
| 项目 | 数值 |
|---|---:|
| Overall (`gpt_eval_score`) | 83.1615 |
| 较低项示例 | spatial_relationship 0.4222 |
| 较高项示例 | image_scene 0.9904 |

### 4.3 MMMU（摘要）
| 项目 | 数值 |
|---|---:|
| Overall | 0.50667 |
| 高分子项示例 | Art_Theory 0.8333, Literature 0.8333 |
| 低分子项示例 | Energy_and_Power 0.2333, Electronics 0.2667 |

### 4.4 Video-MME（摘要）
| 项目 | 数值 |
|---|---:|
| Overall | 64.5185 |
| Short / Medium / Long | 74.9 / 63.7 / 55.0 |
| 相对薄弱项 | temporal reasoning 43.5, counting 41.4 |

## 5. 与官方/参考结果对比

### 5.1 官方 Qwen2.5-VL 对比（按归档报告整理）
| 维度 | 当前结果 | 官方Qwen2.5-VL-7B | 差值 | 口径说明 |
|---|---:|---:|---:|---|
| OCRBench | 84.9 | 86.4 | -1.5 | 基本同口径，可参考 |
| MMMU | 50.67 | 58.6 | -7.93 | 评测口径基本一致，可对照参考 |
| Video-MME | 64.52 | 71.6 | -7.08 | 评测设置存在差异，结果用于趋势判断 |
| MMBench | 83.16（`en_dev`） | 82.6（`EN_test`） | +0.56 | split/指标不同，不做严格横比 |
| MME | 2315.62（总分） | 官方未给同项 | - | 仅内部纵向参考 |

### 5.2 对比解读
- OCR 能力接近官方公开水平。
- 在 MMMU 与 Video-MME 上与官方公开值仍有差距。
- MMBench 当前口径与官方公开口径不同，建议仅做趋势参考。

## 6. 结果覆盖与验证状态

| 项目 | 当前状态 | 说明 |
|---|---|---|
| `mme` / `mmbench_en_dev` / `mmmu_val` / `ocrbench` / `videomme_w_subtitle` | 已覆盖 | 已有归档结果与指标汇总 |
| RefCOCO REC | 未纳入正式采信 | 归档说明显示输出格式与解析器预期不一致，指标暂不采信 |

## 7. 结果文件定位（来自归档材料）
归档中给出的代表性结果文件路径示例：
- `eval_results/Qwen2.5-VL-7B_FULL_20260213_0907/...`
- `bash/eval_results/Qwen2.5-VL-7B_RETRY_VIDEO_FULLGPU_20260213_1124/...`

说明：本仓库当前以交付复现为目标，不在 README 首页堆叠全部原始明细；详细结论以本文件为准。
