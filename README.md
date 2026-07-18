AI STÜDYO (ai-studio)
======================
ÇOK MODÜLLÜ GENEL YAPAY ZEKA STÜDYOSU — sadece video/çizgi film değil;
metin, kod, görsel, ses, video, sosyal medya, döküman, analiz.

NVIDIA API (bulut, akil/metin) + yerel GPU (RTX 3050, görsel/ses/video) hibrit.

MODÜLLER
--------
text   → NVIDIA: chat, ozet, kod, doc, arastir, char, yt, ig, ep
image  → yerel ComfyUI/SD: render <prompt> <out.png> [sd15|sdxl], start
audio  → TTS (XTTS, hazirlaniyor)
video  → AnimateDiff/SVD (hazirlaniyor)
social → Instagram/YouTube/TikTok paketleme
doc    → gorsel analiz / dokuman yazma

KULLANIM
--------
./ai-studio.sh text kod "bash ile en buyuk 5 dosya"
./ai-studio.sh text yt character.md "kedi uzayda" 5 youtube.md
./ai-studio.sh image start
./ai-studio.sh image render "cute cat" out.png sd15
./ai-studio.sh social ig youtube_5dk.md

NVIDIA ANAHTARLARI: ../nvidia-ai/.env (veya bu klasorde .env)
GORSEL: ComfyUI + SD 1.5/SDXL (RTX 3050, yerel, bulut key GEREKMEZ)
