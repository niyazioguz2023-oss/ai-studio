#!/usr/bin/env bash
# tts.sh — XTTS ile yerel seslendirme (RTX 3050, bulut key GEREKMEZ)
# Kullanim: ./tts.sh "metin" <cikis.mp3> [konusmaci_ref.wav]
PY="/c/pinokio/bin/miniconda/python.exe"
BASE="/c/Users/alici/ai-studio"
MODELS="$BASE/models/tts/xtts"
TEXT="${1:?metin gerekli}"
OUT="${2:-tts_out.wav}"
SPEAKER="${3:-}"

# Gereksinim: pip install TTS (ilk calistirmada)
"$PY" -c "import TTS" 2>/dev/null || "$PY" -m pip install --quiet TTS

"$PY" - <<PYEOF
from TTS.api import TTS
import os
m = "$MODELS"
# XTTS v2 yerel checkpoint
tts = TTS(model_path=os.path.join(m, "model.pth"),
          config_path=os.path.join(m, "config.json"),
          progress_bar=False)
spk = "$SPEAKER" if "$SPEAKER" else None
tts.tts_to_file(text="$TEXT", speaker_wav=spk, language="tr", file_path="$OUT")
print("SES: $OUT")
PYEOF
