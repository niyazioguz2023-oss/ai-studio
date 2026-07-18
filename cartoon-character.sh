#!/usr/bin/env bash
# cartoon-character.sh — Tutarli karakter olusturur (devamli karakter sheet)
# Kullanim: ./cartoon-character.sh "Karakter fikri" [cikti_dosyasi]
source "$(dirname "$0")/lib.sh"

IDEA="${1:?Karakter fikri gerekli (orn: 'kahverengi tuylu macera seven kedi')}"
OUT="${2:-character_sheet.md}"

PROMPT="Sen profesyonel bir cizgi film karakter tasarimcisisin. Asagidaki fikirden yola cikarak TUTARLI bir karakter olustur. Ciktini tam olarak su basliklarla ver (Madde isaretli, net):

# KARAKTER: [isim]
## FIZIKISEL OZELLIKLER (her sahnede AYNI kalacak)
- Tur/Koken:
- Boy/Kilo orani (chibi/normal/uzun):
- Ten/kürk/deri rengi:
- Sac rengi ve stili:
- Goz rengi ve sekli:
- Ozel isaretler (ben/molly/scarf):
- Kiyafet (ust/alt/ayakkabi) - RENK KODLARIYLE (#HEX):
- Aksesuarlar:
## RENK PALETI (marka kimligi - HEX)
- Ana renk:
- Ikincil renk:
- Vurgu rengi:
## KISILIK
- Kisilik ozellikleri:
- Konusma tarzi:
- Ses tonu (seslendirme icin):
## KARAKTER REFERANS PROMPTU (gorsel ureticiye verilecek, INGILIZCE, stable-diffusion icin)
[Detayli, karakteri sabit tanimlayan tek paragraf prompt. 'consistent character design, [fiziksel ozellikler], [kiyafet], flat vector illustration style, [renk paleti]']

Fikir: $IDEA"

RESULT="$(nvidia_chat "$PROMPT")"
printf '%s\n' "$RESULT" > "$OUT"
echo "Karakter olusturuldu: $OUT"
printf '%s\n' "$RESULT"
