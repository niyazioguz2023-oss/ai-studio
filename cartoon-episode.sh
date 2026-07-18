#!/usr/bin/env bash
# cartoon-episode.sh — Bolum senaryosu + her sahne icin gorsel prompt uretir
# Kullanim: ./cartoon-episode.sh <karakter_sheet.md> <bolum_fikri> [cikti]
source "$(dirname "$0")/lib.sh"

SHEET="${1:?Karakter sheet dosyasi gerekli}"
IDEA="${2:?Bolum fikri gerekli (orn: 'karakter ilk kez denize gidiyor')}"
OUT="${3:-episode_$(date +%Y%m%d_%H%M).md}"

CHAR="$(cat "$SHEET" 2>/dev/null || echo '')"

PROMPT="Bir cizgi film bolumu senaryosu ve gorsel prompt'lari uret. KARAKTER TUTARLILIGI ESAS: asagidaki karakter tanimini HER sahnede birebir koru.

KARAKTER TANIMI:
$CHAR

BOLUM FIKRI: $IDEA

Ciktiyi su formatta ver:

# BOLUM: [baslik]
## OZET (1 cumle)
## FORMAT: Dikey 9:16 (Instagram Reels / YouTube Shorts), sure ~30-45 sn

## SAHNELER (3-5 sahne)
### Sahne 1
- AKSİYON/DIALOG: [ne oluyor, karakter ne diyor - Turkce, kisa, cocuk dostu]
- GORSEL PROMPT (INGILIZCE, stable-diffusion icin, karakter SABIT):
  [character sheet'teki fizik + kiyafet + renk paleti] + [sahneye ozel aksiyon/mekân], flat vector illustration, 9:16 vertical composition, consistent character design
- KAMERA: [POV/close-up/wide]
- SURE: [sn]

## SOSYAL MEDYA PAKETI
- INSTAGRAM CAPTION: [akisik, emoji, cagri]
- HASHTAGS: [#...]
- YOUTUBE TITLE: [tiklatmali]
- YOUTUBE DESCRIPTION: [2-3 cumle + timestamp]
- YOUTUBE TAGS: [virgulle]
- THUMBNAIL IDEA: [dikkat ceken kare aciklamasi]"

RESULT="$(nvidia_chat "$PROMPT")"
printf '%s\n' "$RESULT" > "$OUT"
echo "Bolum uretildi: $OUT"
printf '%s\n' "$RESULT"
