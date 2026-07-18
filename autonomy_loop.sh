#!/usr/bin/env bash
# autonomy_loop.sh — OTOMON DÖNGÜ (cron ile periyodik calisir)
# Her calistirmada: trend bul -> video uret -> muzik ekle -> sosyal paketle -> ogren
# Kullanim: ./autonomy_loop.sh [konu] (cron'dan cagrilir)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
mkdir -p .memory
TS="$(date +%Y%m%d_%H%M%S)"

# Konu: verilmezse trend'den otonom sec
TOPIC="${1:-}"
if [ -z "$TOPIC" ]; then
  TOPIC="$(bash "$ROOT/research.sh" "viral cizgi film" trend 2>/dev/null | grep -E '^[0-9]\.|[-]' | head -1 | sed 's/^[0-9]\. //')"
  [ -z "$TOPIC" ] && TOPIC="macera seven bir kedi"
fi

echo "[$TS] OTOMON DÖNGÜ basladi: $TOPIC" | tee -a .memory/loop.log
# 1) Video (otonom)
bash "$ROOT/autopilot.sh" "$TOPIC" 3 all >> .memory/loop.log 2>&1
# 2) Muzik (varsa)
if [ -d "$ROOT/models/music/musicgen-small" ]; then
  /c/pinokio/bin/miniconda/python.exe "$ROOT/musicgen_tts.py" "upbeat cartoon theme for: $TOPIC" "autonomy_$TS.wav" >> .memory/loop.log 2>&1
fi
# 3) Sosyal paket
bash "$ROOT/social.sh" ig "episode_auto.md" "social_$TS" >> .memory/loop.log 2>&1
# 4) Ogrenme
bash "$ROOT/learn.sh" >> .memory/loop.log 2>&1
echo "[$TS] DÖNGÜ BİTTİ" | tee -a .memory/loop.log
