#!/usr/bin/env bash
# data_analytics.sh — Izlenme/etkilesim verisini analiz eder, strateji uretir
# Kullanim: ./data_analytics.sh [veri_dosyasi]
source "$(dirname "$0")/lib.sh"
DATA="${1:-.memory/social/metrics.txt}"
echo "=== VERİ ANALİTİĞİ ==="
if [ -f "$DATA" ]; then
  nvidia_chat "Asagidaki icerik performans verisini analiz et, hangi tur icerik daha cok izleniyor, sonraki icerikler icin 3 strateji oner: $(cat "$DATA")"
else
  echo "  (veri dosyasi yok: $DATA)"
  echo "  Örnek: .memory/social/metrics.txt icine 'video1: 1200 izlenme, 45 begeni' satirlari ekleyin"
fi
