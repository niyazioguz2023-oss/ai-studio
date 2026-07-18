#!/usr/bin/env bash
# cartoon-instagram.sh — Instagram icin gorsel icerik (post/carousel/story) uretir
# Kullanim: ./cartoon-instagram.sh <character_sheet.md> <icerik_tipi:post|carousel|story> <konu> [cikti]
source "$(dirname "$0")/lib.sh"

SHEET="${1:?Karakter sheet dosyasi gerekli}"
TYPE="${2:-post}"   # post | carousel | story
TOPIC="${3:?Konu gerekli}"
OUT="${4:-instagram_${TYPE}_$(date +%Y%m%d).md}"

CHAR="$(cat "$SHEET" 2>/dev/null || echo '')"

PROMPT="Instagram icin '$TYPE' tipinde cizgi film karakterli icerik uret. KARAKTER TUTARLI.

KARAKTER:
$CHAR

KONU: $TOPIC

$TYPE icin gerekli cikti:

POST ise:
- GORSEL PROMPT (INGILIZCE, 4:5 dikey 1080x1350): [character ozellikleri + kiyafet + renk] + [konuya ozel aksiyon/mekân], flat vector cartoon, instagram aesthetic, consistent character design
- CAPTION: [akisik, emoji, hikaye]
- HASHTAGS: [#... 15 adet]
- ALT TEXT: [erisebilirlik]

CAROUSEL ise (5 slide):
- HER SLIDE ICIN: GORSEL PROMPT + CAPTION (hikaye akisi)
- FINAL CTA slide

STORY ise (3-5 slide, 9:16 dikey 1080x1920):
- HER SLIDE: GORSEL PROMPT + metin overlay + sticker/CTA onerisi

Tum gorsel prompt'larda karakter SABIT kalsin (consistent character design)."

RESULT="$(nvidia_chat "$PROMPT")"
printf '%s\n' "$RESULT" > "$OUT"
echo "Instagram ($TYPE) icerik uretildi: $OUT"
printf '%s\n' "$RESULT"
