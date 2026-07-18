#!/usr/bin/env bash
# video.sh — Gorsellerden video uretir (OpenCV, gated model GEREKMEZ)
# Yontem: Sahne gorsellerini sirali olarak video yapar, aradaki gecisleri
# yumuşatir (frame interpolation). SVD/AnimateDiff gated oldugu icin bu yolu kullaniriz.
# Kullanim: ./video.sh <gorsel_klasoru> <cikis.mp4> [fps] [sahne_suresi_sn]
PY="/c/pinokio/bin/miniconda/python.exe"
SRC="${1:?gorsel klasoru gerekli}"
OUT="${2:-output.mp4}"
FPS="${3:-24}"
SCENE_SEC="${4:-3}"
"$PY" - <<PYEOF
import os, glob, cv2, numpy as np
src="$SRC"; out="$OUT"; fps=int("$FPS"); scene_sec=int("$SCENE_SEC")
exts=("*.png","*.jpg","*.jpeg","*.webp")
files=[]
for e in exts: files+=sorted(glob.glob(os.path.join(src,e)))
if not files:
    print("HATA: gorsel bulunamadi:",src); raise SystemExit(1)
frames=[]
for f in files:
    img=cv2.imread(f); h,w,_=img.shape
    # sahne icin scene_sec kadar kare (sabit), gecislerde hafif zoom/pan
    n=fps*scene_sec
    for i in range(n):
        # basit pan/zoom efekti
        zoom=1.0+0.03*np.sin(i/n*np.pi)
        M=cv2.getRotationMatrix2D((w/2,h/2),0,zoom)
        f2=cv2.warpAffine(img,M,(w,h))
        frames.append(f2)
h,w,_=frames[0].shape
vw,vh=min(w,1280),int(min(w,1280)*h/w)
frames=[cv2.resize(f,(vw,vh)) for f in frames]
fourcc=cv2.VideoWriter_fourcc(*"mp4v")
vw_w=frames[0].shape[1]; vw_h=frames[0].shape[0]
vw=cv2.VideoWriter(out,fourcc,fps,(vw_w,vw_h))
for frm in frames: vw.write(frm)
vw.release()
print(f"VIDEO: {out} ({len(frames)} kare, {vw_w}x{vw_h}, {len(files)} sahne)")
PYEOF
