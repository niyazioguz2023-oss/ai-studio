#!/usr/bin/env bash
# ComfyUI'yi RTX 3050 (4GB) icin baslatir (yerel gorsel uretim)
PY="/c/pinokio/bin/miniconda/python.exe"
cd "$(dirname "$0")/comfyui/ComfyUI"
export CUDA_VISIBLE_DEVICES=0
# 4GB VRAM icin: --lowvram veya --medvram
"$PY" main.py --lowvram --listen 127.0.0.1 --port 8188 2>&1
