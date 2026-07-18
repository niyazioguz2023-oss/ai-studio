#!/usr/bin/env bash
# Ek modeller: muzik (musicgen), Turkce ASR (wav2vec2-turkish)
PY="/c/pinokio/bin/miniconda/python.exe"
BASE="/c/Users/alici/ai-studio/models"
mkdir -p "$BASE/music" "$BASE/asr"

echo "[1/2] MusicGen-small (muzik uretimi) indiriliyor..."
"$PY" -c "
from huggingface_hub import snapshot_download
snapshot_download(repo_id='facebook/musicgen-small', local_dir='$BASE/music/musicgen-small', local_dir_use_symlinks=False)
print('MUSICGEN TAMAM')
" 2>&1 | tail -3

echo "[2/2] Turkce ASR (wav2vec2-turkish) indiriliyor..."
"$PY" -c "
from huggingface_hub import snapshot_download
snapshot_download(repo_id='__PrimaryKey__/wav2vec2-xls-r-300m-turkish', local_dir='$BASE/asr/wav2vec2-tr', local_dir_use_symlinks=False)
print('ASR TAMAM')
" 2>&1 | tail -3
echo "DONE"
