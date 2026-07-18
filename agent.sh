#!/usr/bin/env bash
# agent.sh — ÇOK BAŞLIKLI OTOMON AI AJANI
# Video/gorsel DISI basliklar da var: video, audio, text, research, social, data
# Sistem kendi kararini verir; HuggingFace/GitHub'dan arac ceker; ogrenir.
# Kullanim: ./agent.sh "<gorev>" [baslik:auto|video|audio|text|research|social|data]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/lib.sh" 2>/dev/null
cd "$ROOT"
TASK="${1:?gorev gerekli}"
DOMAIN="${2:-auto}"

# Baslik secimi (auto -> gorevden cikar)
if [ "$DOMAIN" = "auto" ]; then
  case "$TASK" in
    *video*|*film*|*çizgi*|*kısa*) DOMAIN=video ;;
    *ses*|*müzik*|*şarkı*|*anlat*) DOMAIN=audio ;;
    *araştır*|*arxiv*|*haber*|*trend*) DOMAIN=research ;;
    *instagram*|*youtube*|*tiktok*|*sosyal*) DOMAIN=social ;;
    *veri*|*analiz*|*csv*|*istatistik*) DOMAIN=data ;;
    *) DOMAIN=text ;;
  esac
fi

echo "════════════════════════════════════════"
echo "OTONOM AJAN: baslik=$DOMAIN"
echo "Görev: $TASK"
echo "════════════════════════════════════════"

case "$DOMAIN" in
  video)
    echo "[VIDEO] Otonom video uretimi baslatiliyor..."
    bash "$ROOT/autopilot.sh" "$TASK" 5 all ;;
  audio)
    echo "[AUDIO] Ses/müzik uretimi..."
    bash "$ROOT/tts.sh" "$TASK" "audio_out.wav" 2>&1 | tail -3 ;;
  text)
    echo "[TEXT] Metin/kod/döküman..."
    nvidia_chat "$TASK" ;;
  research)
    echo "[RESEARCH] Arastirma (NVIDIA research modu)..."
    bash "$ROOT/../nvidia-ai/nvidia-ai.sh" research "$TASK" 2>&1 | head -30 ;;
  social)
    echo "[SOCIAL] Sosyal medya icerigi..."
    bash "$ROOT/cartoon-instagram.sh" character_auto.md carousel "$TASK" social_auto.md 2>&1 | tail -5 ;;
  data)
    echo "[DATA] Veri analizi (NVIDIA ile)..."
    nvidia_chat "Verilen veriyi analiz et: $TASK" ;;
esac

# ÖĞRENME: cikti loglanir (sonraki calistirmalar icin feedback)
TS="$(date +%Y%m%d_%H%M%S)"
mkdir -p "$ROOT/.memory"
echo "[$TS] DOMAIN=$DOMAIN TASK=$TASK" >> "$ROOT/.memory/tasks.log"
echo "════════════════════════════════════════"
echo "AJAN TAMAMLADI. Log: .memory/tasks.log"
echo "════════════════════════════════════════"
