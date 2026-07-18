#!/usr/bin/env bash
# social_manage.sh — Sosyal medya yayin plani + analiz (otonom)
# Kullanim: ./social_manage.sh <platform:ig|youtube|tiktok> <icerik_md> [aksiyon:plan|analyze]
source "$(dirname "$0")/lib.sh"
PLAT="${1:-youtube}"
IN="${2:-episode_auto.md}"
ACT="${3:-plan}"
mkdir -p ".memory/social"
case "$ACT" in
  plan)
    echo "=== [$PLAT] YAYIN PLANI ==="
    nvidia_chat "'$PLAT' platformu icin asagidaki icerik hangi gun/saat yayinlanmali? Optimal zaman + baslik + aciklama + hashtag oner (Turkce): $(head -20 "$IN")" ;;
  analyze)
    echo "=== [$PLAT] PERFORMANS ANALIZI ==="
    # basit: gecmis loglardan
    if [ -f ".memory/social/metrics.txt" ]; then
      nvidia_chat "Bu izlenme verisine gore icerik stratejisini degistir: $(cat .memory/social/metrics.txt)"
    else
      echo "  (henuz veri yok - ilk videodan sonra analyze calistir)"
    fi ;;
esac
