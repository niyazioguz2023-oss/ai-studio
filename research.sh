#!/usr/bin/env bash
# research.sh — Trend/arxiv/haber tarayip icerik fikri uretir (NVIDIA ile)
# Kullanim: ./research.sh "<konu>" [kaynak:arxiv|news|trend]
source "$(dirname "$0")/lib.sh"
TOPIC="${1:-yapay zeka}"
SRC="${2:-trend}"
case "$SRC" in
  arxiv)
    echo "[RESEARCH] arXiv: $TOPIC"
    # arXiv API (public, anahtar gerektirmez)
    curl -s --max-time 30 "http://export.arxiv.org/api/query?search_query=all:$(echo $TOPIC | sed 's/ /+/g')&start=0&max_results=3" 2>/dev/null \
      | grep -oE '<title>[^<]*</title>' | sed 's/<[^>]*>//g' | head -3 ;;
  news)
    echo "[RESEARCH] Haber trendi: $TOPIC"
    nvidia_chat "$TOPIC konusunda son gunlerin en cok konusulan 3 trendi maddele." ;;
  trend|*)
    echo "[RESEARCH] Otonom icerik fikri: $TOPIC"
    nvidia_chat "'$TOPIC' konusunda YouTube/Shorts icin 5 orijinal, viral olabilecek cizgi film/factual video fikri uret (her biri 1 cumle)." ;;
esac
echo "---"
echo "Bu fikirler agent.sh ile otonom videoya donusturulebilir."
