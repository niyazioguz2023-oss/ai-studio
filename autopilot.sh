#!/usr/bin/env bash
# autopilot.sh — OTANOM VİDEO/İÇERİK ÜRETİM STÜDYOSU
# Bir fikir verirsin -> sistem kendi kararlarini verip TAM URUNU cikarir:
#   karakter -> senaryo -> gorsel prompt -> render(ComfyUI) -> ses(TTS) -> video(OpenCV) -> sosyal paket
# Tamamen otomatik; ara mudahale gerektirmez.
# Kullanim: ./autopilot.sh "<fikir>" [sure_dk] [platform:all|ig|youtube|tiktok]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
IDEA="${1:?fikir gerekli}"
DUR="${2:-5}"
PLAT="${3:-all}"

TS="$(date +%Y%m%d_%H%M%S)"
WORK="autopilot_$TS"
mkdir -p "$WORK/renders" "$WORK/social"
echo "============================================"
echo "OTONOM ÜRETİM BAŞLADI: $IDEA"
echo "Çalışma: $WORK | Süre: ${DUR}dk | Platform: $PLAT"
echo "============================================"

# 1) KARAKTER (sistem kendi karar verir: fikirden karakter turet)
echo "[1/6] Karakter tasarlanıyor..."
./cartoon-character.sh "$IDEA" "$WORK/character.md" >/dev/null 2>&1
echo "      -> $WORK/character.md"

# 2) SENARYO (YouTube uzun metraj)
echo "[2/6] Senaryo yazılıyor (${DUR}dk)..."
./cartoon-youtube.sh "$WORK/character.md" "$IDEA" "$DUR" "$WORK/episode.md" >/dev/null 2>&1
echo "      -> $WORK/episode.md"

# 3) GORSEL PROMPTLARI -> RENDER (ComfyUI calisirsa)
echo "[3/6] Görseller üretiliyor..."
# sahne promptlarini cikar
grep -oE 'GORSEL PROMPT \(INGILIZCE\):?.{0,400}' "$WORK/episode.md" \
  | sed 's/GORSEL PROMPT (\(INGILIZCE\))*://' > "$WORK/prompts.txt"
N=0
while IFS= read -r P; do
  [ -z "$P" ] && continue
  N=$((N+1))
  # ComfyUI calisiyor mu?
  if curl -s --max-time 3 http://127.0.0.1:8188/system_stats >/dev/null 2>&1; then
    /c/pinokio/bin/miniconda/python.exe render_api.py "$P" "$WORK/renders/scene_$(printf '%03d' $N).png" sd15 >/dev/null 2>&1 &
  else
    echo "      (ComfyUI kapali - prompt kaydedildi: scene_$(printf '%03d' $N))"
    echo "$P" > "$WORK/renders/scene_$(printf '%03d' $N).prompt"
  fi
done < "$WORK/prompts.txt"
wait
echo "      -> $WORK/renders/ ($N sahne)"

# 4) SES (TTS)
echo "[4/6] Seslendirme..."
# senaryodan anlatim metnini cikar (SAHNE/DIALOG satirlari)
grep -E 'ANLATIM|DIALOG|DIALOGUE' "$WORK/episode.md" | head -10 | sed 's/.*: //' > "$WORK/voice.txt"
if [ -s "$WORK/voice.txt" ]; then
  /c/pinokio/bin/miniconda/python.exe tts_glue.py "$WORK/voice.txt" "$WORK/voice.wav" 2>/dev/null \
    || echo "      (TTS hazir degil - metin kaydedildi)"
fi

# 5) VIDEO
echo "[5/6] Video oluşturuluyor..."
if ls "$WORK/renders"/*.png >/dev/null 2>&1; then
  ./video.sh "$WORK/renders" "$WORK/video.mp4" 24 3 2>/dev/null \
    && echo "      -> $WORK/video.mp4" || echo "      (video araçları bekleniyor)"
fi

# 6) SOSYAL PAKET
echo "[6/6] Sosyal medya paketleniyor..."
case "$PLAT" in
  all) for p in ig youtube tiktok; do ./social.sh "$p" "$WORK/episode.md" "$WORK/social/$p" >/dev/null 2>&1; done ;;
  *) ./social.sh "$PLAT" "$WORK/episode.md" "$WORK/social/$PLAT" >/dev/null 2>&1 ;;
esac
echo "      -> $WORK/social/"

echo "============================================"
echo "BİTTİ: $WORK/"
echo "  character.md | episode.md | renders/ | video.mp4 | social/"
echo "============================================"
