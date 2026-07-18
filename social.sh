#!/usr/bin/env bash
# social.sh — uretilen icerigi platform formatina paketler
# Kullanim: ./social.sh <platform:ig|youtube|tiktok> <girdi_md> [cikti_klasoru]
source "$(dirname "$0")/lib.sh"
PLAT="${1:-ig}"; IN="${2:-youtube.md}"; OUT="${3:-social_pack}"
mkdir -p "$OUT"
case "$PLAT" in
  ig) # Instagram: 1080x1080 (post) / 1080x1920 (reels)
    echo "=== INSTAGRAM PAKETİ ==="
    grep -E 'CAPTION|HASHTAG|GORSEL PROMPT' "$IN" | head -20 > "$OUT/ig_caption.txt"
    echo "Post (1080x1080) + Reels (1080x1920) icin goruntu uret:" >> "$OUT/ig_caption.txt"
    grep -oE 'GORSEL PROMPT \(INGILIZCE\):?.{0,400}' "$IN" | sed 's/GORSEL PROMPT (\(INGILIZCE\))*://' >> "$OUT/ig_caption.txt"
    echo "IG paketi: $OUT/ig_caption.txt" ;;
  youtube) # 1280x720 yada 1920x1080, 5-10dk
    echo "=== YOUTUBE PAKETİ ==="
    grep -E '^### S[0-9]|^SAHNE|^S[0-9]' "$IN" > "$OUT/yt_script.txt"
    echo "YouTube 1280x720/1920x1080, bolumluk yapı hazir." ;;
  tiktok) # 1080x1920 dikey, 15-60sn
    echo "=== TIKTOK PAKETİ ==="
    grep -oE 'GORSEL PROMPT \(INGILIZCE\):?.{0,400}' "$IN" | head -8 > "$OUT/tt_caption.txt"
    echo "TikTok 1080x1920 dikey, kisa bolumler icin prompt'lar hazir." ;;
  *) echo "Platform: ig | youtube | tiktok" ;;
esac
echo "Paket hazir: $OUT/"
