# Eval Pipeline

## Main command
```bash
bash scripts/run_full_eval.sh
```

## 最小验证 command
```bash
bash scripts/run_minimal_validation.sh
```

## Execution chain
1. Shell entry script (`scripts/run_full_eval.sh` or `scripts/run_minimal_validation.sh`)
2. `python -m lmms_eval`
3. `lmms_eval/__main__.py`
4. `lmms_eval/evaluator.py`
5. Task yaml under `lmms_eval/tasks/*/*.yaml`
6. Task metric/postprocess utils under `lmms_eval/tasks/*/utils.py`
7. Model backend `lmms_eval/models/*/vllm.py`
8. Output writer `lmms_eval/loggers/evaluation_tracker.py`

## Output
Default output root:
- `eval_results/<RUN_ID>/`

Override:
- `BASE_OUTPUT_DIR=/path/to/output`
