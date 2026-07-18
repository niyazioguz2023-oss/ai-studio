#!/usr/bin/env bash
# text_hub.sh — Gelişmiş metin: cok dilli ceviri + blog->video koprusu
# Kullanim: ./text_hub.sh <aksiyon:translate|blog2video> <girdi> [hedef_dil]
source "$(dirname "$0")/lib.sh"
ACT="${1:-translate}"; shift || true
case "$ACT" in
  translate)
    IN="${1:?metin gerekli}"; LANG="${2:-English}"
    nvidia_chat "Asagidaki metni $LANG diline cevir (sadece ceviri): $IN" ;;
  blog2video)
    IN="${1:?blog/dokuman gerekli}"
    echo "=== BLOG -> VIDEO SENARYOSU ==="
    nvidia_chat "Asagidaki metni 3 dakikalik bir YouTube cizgi film/sunum senaryosuna cevir (sahne sahne, gorul prompt ingilizce): $(head -50 "$IN")" ;;
  doc)
    IN="${1:?konu gerekli}"
    nvidia_chat "'$IN' konusunda profesyonel teknik dokuman yaz (Turkce, yapilandirilmis)." ;;
esac
