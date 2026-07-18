#!/usr/bin/env python3
# tts_glue.py — metin dosyasini TTS ile seslendirir (XTTS, yerel)
# Kullanim: python tts_glue.py <metin.txt> <cikis.wav>
import sys, os
TXT = sys.argv[1] if len(sys.argv) > 1 else "voice.txt"
OUT = sys.argv[2] if len(sys.argv) > 2 else "voice.wav"
MODELS = r"C:\Users\alici\ai-studio\models\tts\xtts"
text = open(TXT, encoding="utf-8").read().strip()[:500]  # XTTS 500 char siniri
try:
    from TTS.api import TTS
    tts = TTS(model_path=os.path.join(MODELS, "model.pth"),
              config_path=os.path.join(MODELS, "config.json"), progress_bar=False)
    tts.tts_to_file(text=text, language="tr", file_path=OUT)
    print(f"SES: {OUT}")
except Exception as e:
    print(f"TTS HATA: {e}")
    sys.exit(1)
