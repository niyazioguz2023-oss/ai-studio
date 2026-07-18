#!/usr/bin/env bash
# multi_agent.sh — ÇOK ADIMLI OTOMON AJAN
# Plan yapar -> uretir -> degerlendirir -> geri beslemeyle duzeltir
# Kullanim: ./multi_agent.sh "<fikir>" [dongu_sayisi]
source "$(dirname "$0")/lib.sh"
ROOT="$(cd "$(dirname "$0")" && pwd)"
IDEA="${1:?fikir gerekli}"
LOOPS="${2:-2}"
TS="$(date +%Y%m%d_%H%M%S)"
LOG="$ROOT/.memory/multi_$TS.log"
mkdir -p "$ROOT/.memory"

for i in $(seq 1 $LOOPS); do
  echo "══════ITERASYON $i/$LOOPS══════" | tee -a "$LOG"
  # 1) PLAN
  PLAN="$(nvidia_chat "'$IDEA' icin $i. iterasyon. Kisa bir uretim plani yap: sahne sayisi, stil, hedef kitle.")"
  echo "[PLAN] $PLAN" | tee -a "$LOG"
  # 2) URUN (autopilot ile video)
  bash "$ROOT/autopilot.sh" "$IDEA" 3 all 2>&1 | tee -a "$LOG" | tail -3
  # 3) DEGERLENDIRME
  EVAL="$(nvidia_chat "Su plana gore uretilen icerik nasil olur? 3 iyilestirme onerisi ver: $PLAN")"
  echo "[EVAL] $EVAL" | tee -a "$LOG"
  # 4) DUZELTME (sonraki iterasyon icin fikri guncelle)
  IDEA="$(nvidia_chat "Onceki fikri su iyilestirmelerle guncelle: $EVAL. Yeni fikir (1 cumle):")"
  echo "[UPDATE] $IDEA" | tee -a "$LOG"
done
echo "ÇOK ADIMLI AJAN BİTTİ: $LOG"
