#!/usr/bin/env bash
# cartoon-youtube.sh — 5-10 dakikalik uzun metraj cizgi film senaryosu + gorsel prompt uretir
# Kullanim: ./cartoon-youtube.sh <character_sheet.md> <konu> [sure_dk] [cikti]
source "$(dirname "$0")/lib.sh"

SHEET="${1:?Karakter sheet dosyasi gerekli}"
TOPIC="${2:?Konu/fikir gerekli}"
DURATION="${3:-8}"   # dakika
OUT="${4:-youtube_${DURATION}dk_$(date +%Y%m%d).md}"

CHAR="$(cat "$SHEET" 2>/dev/null || echo '')"

# Sure hesaplamalari (bash aritmetik, prompt disinda)
TOTSEC=$((DURATION*60))
# Sahne sayisi: her sahne 12 sn ortalama => tam sayi
SCENES=$((TOTSEC/12))

PROMPT="KESIN OLARAK ${DURATION} dakika (${TOTSEC} saniye) suren bir uzun metraj cizgi film senaryosu yaz. KARAKTER TUTARLILIGI ESAS: asagidaki karakteri HER sahnede birebir koru.

KARAKTER:
$CHAR

KONU: $TOPIC

ONEMLI KURAL: Senaryo TAM ${SCENES} SAHNE olmali (S01 ile S${SCENES} arasinda, ara vermeden). Her sahne yaklasik 10-15 saniye. Zaman damgalari S01=[00:00-00:12], S02=[00:12-00:24] ... şeklinde ${TOTSEC} saniyeye kadar kesintisiz devam etmeli. SON sahne S${SCENES} [ss:ss] ile bitmeli ve toplam ${TOTSEC} sn olmali.

Yapi:
1. GIRIS/HOOK (S01-S03, ilk 30-45 sn)
2. GELISME (S04-S$((SCENES-6)), ana seruven)
3. KLIMAX (son 6 sahne icinde zirve)
4. COZUM + KAPANIS (son 2 sahne)

Ciktiyi su formatta ver (TURKCE, cocuk/aila dostu, enerjik):

# FILM: [baslik] (${DURATION} dk / ${SCENES} sahne)
## LOG LINE (1 cumle)
## SAHNE PLANI
### S01 [00:00 - 00:12] AKSİYON
- OLAY:
- DİYALOG: [Karakter: '...']
- MEKAN:
- GORSEL PROMPT (INGILIZCE): [character sheet ozellikleri + kiyafet + renk] + [sahneye ozel], flat vector cartoon, cinematic, consistent character design
- KAMERA:
### S02 [00:12 - 00:24] AKSİYON
... (S${SCENES}'e kadar AYNEN devam, her sahne zaman damgasi bir oncekinin bitisinden baslamali)
### S${SCENES} [son iki basamak] AKSİYON
- (film bu sahnede bitmeli)

## SESLI ANLATIM / VOICEOVER (her sahne icin 1 cumle, akici, toplam ${SCENES} parcada)
## MUZIK/SES EFEKTI (her sahne)
## YOUTUBE PAKETI
- TITLE: [60 karakter]
- DESCRIPTION: [2 paragraf + 00:00 Giris, 00:XX Gelisme ... zaman damgalari]
- TAGS: [virgulle]
- THUMBNAIL:
- END SCREEN / CTA:"

RESULT="$(nvidia_chat "$PROMPT")"
printf '%s\n' "$RESULT" > "$OUT"
echo "YouTube senaryo uretildi ($DURATION dk): $OUT"
printf '%s\n' "$RESULT"
