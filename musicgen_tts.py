#!/usr/bin/env python3
# musicgen_tts.py — Muzik uretimi (MusicGen-small, yerel, RTX 3050)
# Kullanim: python musicgen_tts.py "<prompt>" <cikis.wav>
import sys, os
PROMPT = sys.argv[1] if len(sys.argv) > 1 else "happy upbeat cartoon theme"
OUT = sys.argv[2] if len(sys.argv) > 2 else "music.wav"
MODELS = r"C:\Users\alici\ai-studio\models\music\musicgen-small"
try:
    from transformers import AutoProcessor, MusicgenForConditionalGeneration
    import scipy
    proc = AutoProcessor.from_pretrained(MODELS)
    model = MusicgenForConditionalGeneration.from_pretrained(MODELS).to("cuda")
    inputs = proc(text=[PROMPT], padding=True, return_tensors="pt").to("cuda")
    audio = model.generate(**inputs, max_new_tokens=512)
    scipy.io.wavfile.write(OUT, model.config.audio_encoder.sampling_rate, audio[0, 0].cpu().numpy())
    print(f"MUZIK: {OUT}")
except Exception as e:
    print(f"MUSICGEN HATA: {e}")
