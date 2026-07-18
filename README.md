# AI-STUDIO — Çok Başlıklı Otonom İçerik Üretim Sistemi

NVIDIA API (bulut) + yerel GPU (RTX 3050, ComfyUI/SD/TTS/MusicGen) ile
çalışan, **kendi kendine karar veren, HuggingFace/GitHub'dan otonom çeken**
çok başlıklı AI ajans sistemi.

## Modüller
| Komut | Başlık | Ne yapar |
|--------|---------|-----------|
| `./ai-studio.sh auto "fikir"` | VİDEO | Fikir→karakter→senaryo→görsel→ses→video→sosyal (tam otonom) |
| `./ai-studio.sh music "prompt"` | SES/MÜZİK | MusicGen ile orijinal soundtrack |
| `./ai-studio.sh text-hub translate "metin" EN` | METİN | Çok dilli çeviri + blog→video + doküman |
| `./ai-studio.sh research "konu" trend` | ARAŞTIRMA | arXiv/haber/trend → viral fikir |
| `./ai-studio.sh multi "fikir"` | ÇOK ADIMLI AJAN | Plan→üret→değerlendir→düzelt döngüsü |
| `./ai-studio.sh social-manage youtube ep.md plan` | SOSYAL | Yayın planı + performans analizi |
| `./ai-studio.sh data metrics.txt` | VERİ | İzlenme verisi → strateji |
| `./ai-studio.sh agent "görev"` | OTOMON ORKESTRATÖR | Başlığı kendisi seçer (video/audio/text/research/social/data) |
| `./ai-studio.sh loop` | OTOMON DÖNGÜ | Cron ile periyodik: trend→video→müzik→sosyal→öğren |
| `./ai-studio.sh learn` | ÖĞRENME | Geçmiş çıktıları değerlendirir, feedback üretir |
| `./ai-studio.sh update` | SELF-UPDATE | HF模型 + GitHub kod + ComfyUI günceller |

## Kurulum
1. NVIDIA anahtarları: `cp nvidia-ai/.env .env` (4 anahtar ayni hesap)
2. Yerel modeller (Pinokio conda):
   - ComfyUI: `bash setup_comfyui_pinokio.sh`
   - SD/SDXL: `bash download_models.sh`
   - TTS (XTTS): `bash download_extra.sh`
   - Müzik (MusicGen): `bash download_extra2.sh`
3. `pip install TTS opencv-python-headless transformers scipy`

## Gereksinimler
- Windows 11 + RTX 3050 4GB + Pinokio (miniconda python)
- NVIDIA API anahtarı (bulut metin/vizyon)
- ~15GB disk (modeller)

## Yapı
```
ai-studio/
├── ai-studio.sh          # ana giriş noktası (dispatcher)
├── agent.sh             # çok başlıklı otonom orkestratör
├── autonomy_loop.sh     # cron periyodik döngü
├── autopilot.sh         # video hattı (otonom)
├── multi_agent.sh       # çok adımlı ajan
├── musicgen_tts.py      # müzik üretimi
├── tts.sh / tts_glue.py# seslendirme (XTTS)
├── research.sh          # trend/arxiv
├── social_manage.sh     # sosyal yönetim
├── data_analytics.sh    # veri analitiği
├── text_hub.sh         # gelişmiş metin
├── video.sh             # görsel→video (OpenCV)
├── social.sh           # sosyal paketleme
├── learn.sh            # feedback loop
├── self_update.sh      # HF/GitHub otonom güncelleme
├── lib.sh              # NVIDIA wrapper (3 anahtar)
└── .memory/            # öğrenme logları
```

## Otonom Çalıştırma (cron)
```bash
# Her gun 09:00'da otonom icerik uret
0 9 * * * cd /c/Users/alici/ai-studio && bash autonomy_loop.sh >> .memory/loop.log 2>&1
```

## Notlar
- NVIDIA bulut HESABI bu makinede text-to-image DESTEKLEMIYOR (SDXL nvcf 404).
  Bu yüzden görsel üretimi YEREL (ComfyUI/SD) yapılır.
- SDXL indirme token'sız HF'da çok yavaş; HF_TOKEN eklenirse hızlanır.
- Türkçe ASR (wav2vec2-turkish) gated repo — indirilemedi, opsiyonel.
