#!/usr/bin/env bash
# ai-studio.sh — ÇOK MODÜLLÜ GENEL AI STÜDYOSU (NVIDIA API + yerel GPU)
# Sadece video/çizgi film degil; metin, kod, görsel, ses, video, sosyal, döküman.
# Moduller birbirinden bagimsiz; NVIDIA (metin/akil) + yerel (gorsel/ses/video) hibrit.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
NVIDIA_CLI="$ROOT/../nvidia-ai/nvidia-ai.sh"
source "$ROOT/lib.sh" 2>/dev/null || source "$ROOT/../cartoon-factory/lib.sh" 2>/dev/null

MODULE="${1:-help}"; shift || true
case "$MODULE" in
  # === METIN / AKIL (NVIDIA) ===
  text)
    SUB="${1:-chat}"; shift || true
    case "$SUB" in
      chat)  nvidia_chat "$1" ;;
      ozet)  bash "$NVIDIA_CLI" summarize "$1" ;;
      kod)   bash "$NVIDIA_CLI" code "$1" "${2:-Turkce}" ;;
      doc)   bash "$NVIDIA_CLI" doc "$1" ;;
      arastir) bash "$NVIDIA_CLI" research "$1" ;;
      char)  bash "$ROOT/cartoon-character.sh" "$@" ;;
      yt)    bash "$ROOT/cartoon-youtube.sh" "$@" ;;
      ig)    bash "$ROOT/cartoon-instagram.sh" "$@" ;;
      ep)    bash "$ROOT/cartoon-episode.sh" "$@" ;;
      *) echo "text: chat | ozet | kod | doc | arastir | char | yt | ig | ep" ;;
    esac ;;
  # === GORSEL (yerel ComfyUI/SD) ===
  image)
    SUB="${1:-render}"; shift || true
    case "$SUB" in
      render) PY="/c/pinokio/bin/miniconda/python.exe"; "$PY" "$ROOT/render_api.py" "$@" ;;
      start)  bash "$ROOT/start_comfyui.sh" ;;
      *) echo "image: render <prompt> <out.png> [sd15|sdxl] | start" ;;
    esac ;;
  # === SES (TTS - XTTS yerel) ===
  audio)
    SUB="${1:-tts}"; shift || true
    case "$SUB" in
      tts)  bash "$ROOT/tts.sh" "$@" ;;
      *) echo "audio: tts <metin> [cikis.wav] [konusmaci.wav]" ;;
    esac ;;
  # === VIDEO (gorselden video / SVD) ===
  video)
    SUB="${1:-make}"; shift || true
    case "$SUB" in
      make) bash "$ROOT/video.sh" "$@" ;;
      dl)   bash "$ROOT/download_video.sh" ;;  # SVD gated -> auth gerekir
      *) echo "video: make <gorsel_klasoru> [cikis.mp4] [fps] [sahne_sn] | dl (SVD, gated)" ;;
    esac ;;
  # === OTOMATIK PIPELINE (tam zincir) ===
  pipeline)
    bash "$ROOT/pipeline.sh" "$@" ;;
  # === OTONOM STÜDYO (fikir -> tam urun) ===
  auto|autopilot)
    bash "$ROOT/autopilot.sh" "$@" ;;
  # === ÇOK BAŞLIKLI OTOMON AJAN ===
  agent)
    bash "$ROOT/agent.sh" "$@" ;;
  # === ÖĞRENME / FEEDBACK ===
  learn)
    bash "$ROOT/learn.sh" "$@" ;;
  # === OTOMON DÖNGÜ (cron periyodik) ===
  loop|autonomy)
    bash "$ROOT/autonomy_loop.sh" "$@" ;;
  # === GELİŞMİŞ MODÜLLER ===
  music|muzik)
    /c/pinokio/bin/miniconda/python.exe "$ROOT/musicgen_tts.py" "$@" ;;
  research|trend)
    bash "$ROOT/research.sh" "$@" ;;
  multi|multi-agent)
    bash "$ROOT/multi_agent.sh" "$@" ;;
  social-manage)
    bash "$ROOT/social_manage.sh" "$@" ;;
  data|analytics)
    bash "$ROOT/data_analytics.sh" "$@" ;;
  text-hub)
    bash "$ROOT/text_hub.sh" "$@" ;;
  # === KENDİNİ GÜNCELLE (HF + GitHub) ===
  update|self-update)
    bash "$ROOT/self_update.sh" "$@" ;;
  # === SOSYAL MEDYA PAKETLEME ===
  social)
    bash "$ROOT/social.sh" "$@" ;;
  # === DÖKÜMAN / ANALİZ ===
  doc)
    SUB="${1:-analyze}"; shift || true
    case "$SUB" in
      analyze) bash "$NVIDIA_CLI" analyze "$@" ;;
      write)   bash "$NVIDIA_CLI" doc "$1" ;;
      *) echo "doc: analyze <resim> | write <konu>" ;;
    esac ;;
  help|*)
    cat <<'EOF'
ÇOK MODÜLLÜ AI STÜDYOSU (ai-studio.sh)
======================================
text   → NVIDIA: chat, ozet, kod, doc, arastir, char, yt, ig, ep
image  → yerel ComfyUI/SD: render <prompt> <out.png> [sd15|sdxl], start
audio  → TTS (XTTS, hazirlaniyor)
video  → AnimateDiff/SVD (hazirlaniyor)
social → Instagram/YouTube/TikTok paketleme
doc    → analiz (gorsel) / yazma

Örnek:
  ./ai-studio.sh text yt character.md "kedi uzayda" 5 youtube.md
  ./ai-studio.sh text kod "bash ile en buyuk 5 dosya"
  ./ai-studio.sh image start
  ./ai-studio.sh image render "cute cat" out.png sd15
  ./ai-studio.sh social ig youtube_5dk.md
EOF
    ;;
esac
