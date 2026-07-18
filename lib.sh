# =============================================================================
# cartoon-factory/  —  NVIDIA API ile çizgi film + sosyal medya içerik fabrikası
# =============================================================================
# Bu klasör, NVIDIA Nemotron/LLM modelleriyle:
#   1) Tutarli karakter tanimi (devamli karakter sheet)
#   2) Bolum senaryolari (Instagram Reels / YouTube Shorts icin dikey format)
#   3) Her sahne icin gorsel prompt (karakter sabit)
#   4) Sosyal medya caption / hashtag / description
# uretmek icin bir script ailesidir.
#
# Gorsel uretim (goruntu) NVIDIA API'de text-to-image olarak YOK; bu yuzden
# gorsel prompt'lari burada uretilir, goruntu RTX 3050 (yerel SD) veya baska
# bir aracla uretilir. Bkz: render/ klasoru (ComfyUI entegrasyonu).
#
# Bilgisayar: i7-12700H, 16GB RAM, RTX 3050 4GB, Windows 11.
# =============================================================================

# Ortak: NVIDIA anahtarlari (3 adet, ayni hesap, rate-limit yonetimi icin)
source "$(dirname "$0")/../nvidia-ai/.env"
source "$(dirname "$0")/../nvidia-ai/.env2" 2>/dev/null
source "$(dirname "$0")/../nvidia-ai/.env3" 2>/dev/null

# Anahtar listesi (bos olmayanlar)
KEYS=()
[ -n "${NVIDIA_API_KEY:-}" ] && KEYS+=("$NVIDIA_API_KEY")
[ -n "${NVIDIA_API_KEY_2:-}" ] && KEYS+=("$NVIDIA_API_KEY_2")
[ -n "${NVIDIA_API_KEY_3:-}" ] && KEYS+=("$NVIDIA_API_KEY_3")
KEY_IDX=0
next_key() { KEY_IDX=$(( (KEY_IDX+1) % ${#KEYS[@]} )); }

API="https://integrate.api.nvidia.com/v1"
MODEL_CHAT="nvidia/llama-3.3-nemotron-super-49b-v1.5"
MODEL_REASON="nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"

# JSON escape (escape.sed ile)
json_escape() {
  printf '%s' "$1" | sed -f "$(dirname "$0")/../nvidia-ai/escape.sed"
}

nvidia_chat() {
  # $1 = prompt, $2 = model (opsiyonel)
  local prompt="$1"; local model="${2:-$MODEL_CHAT}"
  local tmp="$(mktemp)"; local tmpw="$(cygpath -w "$tmp")"
  local tries=0; local max=${#KEYS[@]}; local resp=""
  while [ $tries -lt $max ]; do
    local K="${KEYS[$KEY_IDX]}"
    {
      printf '{"model":"%s","messages":[{"role":"user","content":"%s"}],"max_tokens":1500,"temperature":0.8,"top_p":0.95,"stream":false}' \
        "$model" "$(json_escape "$prompt")"
    } > "$tmp"
    resp="$(curl -s --max-time 150 "$API/chat/completions" \
      -H "Authorization: Bearer $K" -H "Content-Type: application/json" --data "@$tmpw")"
    # 429 (rate limit) veya 503 ise diger anahtara gec
    if echo "$resp" | grep -qE '"code":(429|503)|Rate ?limit|Too many'; then
      next_key; tries=$((tries+1)); continue
    fi
    break
  done
  rm -f "$tmp"
  # content veya reasoning_content cikar
  local c
  c="$(printf '%s' "$resp" | grep -oP '"content":"\K(?:\\.|[^"\\])*' | head -1)"
  [ -z "$c" ] && c="$(printf '%s' "$resp" | grep -oP '"reasoning_content":"\K(?:\\.|[^"\\])*' | head -1)"
  [ -z "$c" ] && { echo "HATA: $resp" >&2; return 1; }
  printf '%s' "$c" | sed -f "$(dirname "$0")/../nvidia-ai/unescape.sed"
}
