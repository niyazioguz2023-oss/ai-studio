#!/usr/bin/env bash
# Video modeli: Stable Video Diffusion (public, HuggingFace) indirir
PY="/c/pinokio/bin/miniconda/python.exe"
BASE="/c/Users/alici/ai-studio/models"
mkdir -p "$BASE/video"
echo "[1/1] SVD (Stable Video Diffusion) indiriliyor..."
"$PY" -c "
from huggingface_hub import snapshot_download
snapshot_download(repo_id='stabilityai/stable-video-diffusion-img2vid-xt-1-1', local_dir='$BASE/video/svd', local_dir_use_symlinks=False)
print('SVD TAMAM')
" 2>&1 | tail -3
echo "DONE"
