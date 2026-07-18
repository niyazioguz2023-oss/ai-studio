#!/usr/bin/env bash
# pipeline.sh — TEK KOMUTLA TAM ÜRETİM (çoklu modül zinciri)
# metin(karakter+senaryo) -> gorsel(ComfyUI) -> ses(TTS) -> video(OpenCV) -> sosyal paket
# Kullanim: ./pipeline.sh "karakter fikri" "konu" [sure_dk]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
CHAR_IDEA="${1:?karakter fikri gerekli}"
TOPIC="${2:-macera}"
DUR="${3:-5}"

echo "=== [1/5] KARAKTER ==="
./cartoon-character.sh "$CHAR_IDEA" character_auto.md 2>&1 | tail -2
echo "=== [2/5] SENARYO (YouTube $DUR dk) ==="
./cartoon-youtube.sh character_auto.md "$TOPIC" "$DUR" episode_auto.md 2>&1 | tail -2
echo "=== [3/5] GORSEL (ComfyUI gerekir: ./ai-studio.sh image start) ==="
mkdir -p renders
# sahne promptlarini cikarip render et
grep -oE 'GORSEL PROMPT \(INGILIZCE\):?.{0,400}' episode_auto.md | sed 's/GORSEL PROMPT (\(INGILIZCE\))*://' | head -5 | nl
echo "   (ComfyUI calisirken: ./ai-studio.sh image render \"<prompt>\" renders/sahne_N.png sd15)"
echo "=== [4/5] SES (TTS) ==="
./ai-studio.sh audio tts "Merhaba, ben bu bolumun anlatiticisiyim." renders/voice.wav 2>&1 | tail -2
echo "=== [5/5] VIDEO + SOSYAL ==="
ls renders/*.png >/dev/null 2>&1 && ./ai-studio.sh video make renders episode_auto.mp4 24 3 2>&1 | tail -2
./social.sh ig episode_auto.md social_auto 2>&1 | tail -2
echo "TAMAM: character_auto.md, episode_auto.md, renders/, episode_auto.mp4, social_auto/"
