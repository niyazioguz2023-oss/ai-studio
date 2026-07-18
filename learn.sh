#!/usr/bin/env bash
# learn.sh — Sistemin kendi ciktilarini degerlendirip ogrendigi basit feedback loop
# .memory/tasks.log + .memory/feedback.log'u okur, hatalari tespit eder,
# bir sonraki calistirma icin not uretir.
ROOT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$ROOT/.memory"
echo "=== ÖĞRENME RAPORU ==="
if [ -f "$ROOT/.memory/tasks.log" ]; then
  echo "Toplam görev: $(wc -l < "$ROOT/.memory/tasks.log")"
  echo "Başlık dağılımı:"
  grep -oE 'DOMAIN=[a-z]+' "$ROOT/.memory/tasks.log" | sort | uniq -c
else
  echo "Henüz görev yok."
fi
# Hata tespiti (gecmis ciktilarda 'HATA'/'FAIL' arama)
echo "--- Hata özeti ---"
grep -hiE 'hata|fail|blocker' "$ROOT/.memory/"*.log 2>/dev/null | tail -5 || echo "  (hata kaydi yok)"
echo "--- Öneri ---"
echo "  Sistem: $([ -d "$ROOT/models/sdxl" ] && echo 'SDXL hazir' || echo 'SDXL bekleniyor')"
echo "  Öğrenme dosyası: $ROOT/.memory/feedback.log"
