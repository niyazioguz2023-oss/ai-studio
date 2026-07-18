#!/usr/bin/env python3
# ComfyUI API ile yerel SD (RTX 3050) gorsel uretimi
# Kullanim: python render_api.py "<prompt>" <cikis_dosyasi> [model_adı]
import sys, json, urllib.request, urllib.error, time, os

PROMPT = sys.argv[1] if len(sys.argv) > 1 else "a cute cartoon cat"
OUT = sys.argv[2] if len(sys.argv) > 2 else "out.png"
CKPT = sys.argv[3] if len(sys.argv) > 3 else "sd15"  # sd15 veya sdxl

COMFY = "http://127.0.0.1:8188"

# SD 1.5 checkpoints yolu (cartoon-factory/models altinda)
MODELS_DIR = os.path.join(os.path.dirname(__file__), "..", "models")
SD15 = os.path.abspath(os.path.join(MODELS_DIR, "sd15"))
SDXL = os.path.abspath(os.path.join(MODELS_DIR, "sdxl"))

def post(url, data):
    req = urllib.request.Request(url, data=json.dumps(data).encode(),
                                 headers={"Content-Type": "application/json"})
    return json.load(urllib.request.urlopen(req, timeout=300))

# Checkpoint yolu belirle
if CKPT == "sdxl":
    ckpt_path = None
    for f in os.listdir(SDXL) if os.path.isdir(SDXL) else []:
        if f.endswith(".safetensors") or f.endswith(".ckpt"):
            ckpt_path = f; break
    model_name = ckpt_path or "sd_xl_base_1.0.safetensors"
    width, height = 1024, 1024
else:
    model_name = "v1-5-pruned-emaonly.ckpt"
    width, height = 512, 512

# Basit text-to-image workflow (ComfyUI API formati)
workflow = {
    "3": {"class_type": "KSampler", "inputs": {
        "seed": 42, "steps": 25, "cfg": 7.0, "sampler_name": "euler",
        "scheduler": "normal", "denoise": 1.0,
        "model": ["4", 0], "positive": ["6", 0], "negative": ["7", 0],
        "latent_image": ["5", 0]}},
    "4": {"class_type": "CheckpointLoaderSimple", "inputs": {"ckpt_name": model_name}},
    "5": {"class_type": "EmptyLatentImage", "inputs": {"width": width, "height": height, "batch_size": 1}},
    "6": {"class_type": "CLIPTextEncode", "inputs": {"text": PROMPT, "clip": ["4", 1]}},
    "7": {"class_type": "CLIPTextEncode", "inputs": {"text": "low quality, blurry, bad", "clip": ["4", 1]}},
    "8": {"class_type": "VAEDecode", "inputs": {"samples": ["3", 0], "vae": ["4", 2]}},
    "9": {"class_type": "SaveImage", "inputs": {"filename_prefix": "cartoon", "images": ["8", 0]}},
}

# ComfyUI prompt kuyruguna gonder
try:
    r = post(f"{COMFY}/prompt", {"prompt": workflow, "client_id": "cartoon-factory"})
    pid = r.get("prompt_id")
    print(f"Prompt ID: {pid}")
except urllib.error.HTTPError as e:
    print(f"HATA: ComfyUI calismiyor mu? {e}")
    print("Oncelikle: bash start_comfyui.sh calistirin")
    sys.exit(1)

# Gorsel hazir mi bekle
save_dir = os.path.join(os.path.dirname(__file__), "..", "comfyui", "ComfyUI", "output")
print(f"Gorsel uretiliyor... ({width}x{height}, {model_name})")
for _ in range(120):
    time.sleep(2)
    for f in os.listdir(save_dir) if os.path.isdir(save_dir) else []:
        if f.startswith("cartoon") and f.endswith(".png"):
            src = os.path.join(save_dir, f)
            import shutil
            shutil.copy(src, OUT)
            print(f"GORSEL: {OUT}")
            sys.exit(0)
print("ZAMAN ASIMI: gorsel urelemedi")
sys.exit(1)
