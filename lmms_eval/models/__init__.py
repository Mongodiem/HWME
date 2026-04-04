from loguru import logger

# HWME delivery keeps only the vLLM route used by official run scripts.
AVAILABLE_SIMPLE_MODELS = {"vllm": "VLLM"}
AVAILABLE_CHAT_TEMPLATE_MODELS = {"vllm": "VLLM"}


def get_model(model_name, force_simple: bool = False):
    if model_name != "vllm":
        raise ValueError("HWME delivery only supports --model vllm")

    model_type = "simple" if force_simple else "chat"
    model_module = f"lmms_eval.models.{model_type}.vllm"
    model_class = "VLLM"
    try:
        module = __import__(model_module, fromlist=[model_class])
        return getattr(module, model_class)
    except Exception as e:
        logger.error(f"Failed to import {model_class} from {model_name}: {e}")
        raise
