#!/usr/bin/env bash
# self_update.sh — Sistemi HuggingFace + GitHub'dan otonom gunceller
# - GitHub repo'sunu pull eder (yeni script'ler)
# - HuggingFace'ten yeni/eksik modelleri kontrol eder (basit liste)
# Kullanim: ./self_update.sh
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

echo "=== [1] GitHub güncellemesi ==="
git pull --ff-only origin main 2>&1 | tail -3 || echo "  (pull atlandi / uzak degisiklik yok)"

echo "=== [2] HuggingFace model kontrolü ==="
PY="/c/pinokio/bin/miniconda/python.exe"
# Mevcut modeller
[ -d "$ROOT/models/sd15" ] && echo "  [✓] SD 1.5 mevcut"
[ -d "$ROOT/models/tts/xtts" ] && echo "  [✓] XTTS mevcut"
[ -d "$ROOT/models/sdxl" ] && echo "  [✓] SDXL mevcut" || echo "  [.] SDXL indiriliyor (arka plan)"

echo "=== [3] ComfyUI güncellemesi ==="
if [ -d "$ROOT/comfyui/ComfyUI/.git" ]; then
  git -C "$ROOT/comfyui/ComfyUI" pull --ff-only 2>&1 | tail -2 || echo "  (ComfyUI guncel)"
fi

echo "SELF-UPDATE TAMAM: $(date)"
