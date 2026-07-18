#!/usr/bin/env bash
# =============================================================================
# nvidia-ai.sh  —  NVIDIA Nemotron / NIM API istemcisi (bash + curl)
# =============================================================================
# Kullanim:
#   source .env            # NVIDIA_API_KEY'i yukler (veya env'de tanimli olmali)
#   ./nvidia-ai.sh models [filtre]        # katalogdaki modelleri listele
#   ./nvidia-ai.sh chat  "prompt" [model] # metin uretimi / soru-cevap
#   ./nvidia-ai.sh vision "prompt" <resim_url|dosya> [model]  # gorsel analizi
#   ./nvidia-ai.sh reason "prompt" [model]  # dusunen (reasoning) modeller
#   ./nvidia-ai.sh guard "metin" [model]    # icerik guvenligi / moderasyon
#   ./nvidia-ai.sh translate "metin" [hedef_dil] [model]  # ceviri
#   ./nvidia-ai.sh pii   "metin" [model]    # kisisel veri (PII) tespiti
#   ./nvidia-ai.sh whoami                 # anahtar gecerliligi
#
# Ortam: NVIDIA_API_KEY  (yoksa ./.env veya ~/nvidia-ai/.env aranir)
# Not: Bu hesapta CALISAN 50+ model var. Tam liste: ./nvidia-ai.sh models
# =============================================================================
set -uo pipefail

API="https://integrate.api.nvidia.com/v1"
TIMEOUT=120
MODEL_CHAT="nvidia/llama-3.3-nemotron-super-49b-v1.5"
MODEL_VISION="nvidia/nemotron-nano-12b-v2-vl"

# --- anahtari yukle ---------------------------------------------------------
load_key() {
  if [ -z "${NVIDIA_API_KEY:-}" ]; then
    for f in "./.env" "$HOME/nvidia-ai/.env" "$HOME/.env.nvidia"; do
      if [ -f "$f" ]; then
        # sadece NVIDIA_API_KEY satirini al
        export NVIDIA_API_KEY="$(grep -E '^export NVIDIA_API_KEY=' "$f" | head -1 | cut -d'"' -f2)"
        break
      fi
    done
  fi
  if [ -z "${NVIDIA_API_KEY:-}" ]; then
    echo "HATA: NVIDIA_API_KEY bulunamadi. 'source .env' yapin veya ortam degiskenini ayarlayin." >&2
    exit 1
  fi
}

# --- auth header ------------------------------------------------------------
auth_header() { echo "Authorization: Bearer $NVIDIA_API_KEY"; }

# icerigi guvenli sekilde cikar (content veya reasoning_content)
extract_content() {
  local resp="$1"
  if echo "$resp" | grep -qE '"error"|"status":[0-9]{3}|"detail"'; then
    echo "API HATASI: $resp" >&2
    return 1
  fi
  local c
  c="$(printf '%s' "$resp" | grep -oP '"content":"\K(?:\\.|[^"\\])*' | head -1)"
  if [ -z "$c" ]; then
    c="$(printf '%s' "$resp" | grep -oP '"reasoning_content":"\K(?:\\.|[^"\\])*' | head -1)"
  fi
  if [ -z "$c" ]; then
    echo "ICERIK OKUNAMADI. Ham yanit:" >&2
    echo "$resp" >&2
    return 1
  fi
  # JSON kacislarini coz (sed dosyasi ile)
  c="$(printf '%s' "$c" | sed -f "$(dirname "$0")/unescape.sed")"
  printf '%s\n' "$c"
}

# --- yardimci: JSON escape (tek satir) --------------------------------------
json_escape() {
  # escape.sed ile guvenli JSON escape (kabuk yorumlamasindan kacinmak icin)
  printf '%s' "$1" | sed -f "$(dirname "$0")/escape.sed" | tr '\n' '\n'
}

# --- 1) modelleri listele ---------------------------------------------------
cmd_models() {
  local filter="${1:-}"
  if [ "$filter" = "working" ]; then
    # sadece bu hesapta calisan modeller (working_models.txt)
    local wf="$(dirname "$0")/working_models.txt"
    if [ -f "$wf" ]; then
      if [ $# -ge 2 ]; then
        grep -i "${2:-}" "$wf"
      else
        cat "$wf"
      fi
    else
      echo "working_models.txt yok. Once tarama yapin." >&2
    fi
    return
  fi
  local out
  out="$(curl -s --max-time $TIMEOUT "$API/models" -H "$(auth_header)")"
  if [ -n "$filter" ]; then
    echo "$out" | grep -oE '"id":"[^"]*"' | sed 's/"id":"//;s/"$//' | grep -i "$filter"
  else
    echo "$out" | grep -oE '"id":"[^"]*"' | sed 's/"id":"//;s/"$//'
  fi
}

# --- 2) metin sohbeti -------------------------------------------------------
cmd_chat() {
  local prompt="${1:?prompt gerekli}"; local model="${2:-nvidia/llama-3.3-nemotron-super-49b-v1.5}"
  local body tmp tmpw
  tmp="$(mktemp)"; tmpw="$(cygpath -w "$tmp")"
  {
    printf '{"model":"%s","messages":[{"role":"user","content":"%s"}],"max_tokens":512,"temperature":0.7,"top_p":0.9,"stream":false}' \
      "$model" "$(json_escape "$prompt")"
  } > "$tmp"
  local resp
  resp="$(curl -s --max-time $TIMEOUT "$API/chat/completions" \
    -H "$(auth_header)" -H "Content-Type: application/json; charset=utf-8" --data "@$tmpw")"
  rm -f "$tmp"
  extract_content "$resp"
}

# --- 3) gorsel analizi ------------------------------------------------------
cmd_vision() {
  local prompt="${1:?prompt gerekli}"; local img="${2:?resim url veya dosya gerekli}"
  local model="${3:-nvidia/nemotron-nano-12b-v2-vl}"
  local url="$img"
  # yerel dosya ise base64 data URI'ye cevir
  if [ -f "$img" ]; then
    local mime="image/png"
    case "$img" in
      *.jpg|*.jpeg) mime="image/jpeg" ;;
      *.gif) mime="image/gif" ;;
      *.webp) mime="image/webp" ;;
    esac
    url="data:$mime;base64,$(base64 -w0 "$img")"
  fi
  local body tmp tmpw
  tmp="$(mktemp)"; tmpw="$(cygpath -w "$tmp")"
  {
    printf '{"model":"%s","messages":[{"role":"user","content":[{"type":"text","text":"%s"},{"type":"image_url","image_url":{"url":"%s"}}]}],"max_tokens":256,"temperature":0.2,"stream":false}' \
      "$model" "$(json_escape "$prompt")" "$url"
  } > "$tmp"
  local resp
  resp="$(curl -s --max-time $TIMEOUT "$API/chat/completions" \
    -H "$(auth_header)" -H "Content-Type: application/json" --data "@$tmpw")"
  rm -f "$tmp"
  extract_content "$resp"
}

# --- 4) embedding -----------------------------------------------------------
cmd_embed() {
  local text="${1:?metin gerekli}"; local model="${2:-nvidia/llama-3.2-nv-embedqa-1b-v1}"
  local body="{\"input\":\"$(json_escape "$text")\",\"model\":\"$model\",\"encoding_format\":\"float\"}"
  curl -s --max-time $TIMEOUT "$API/embeddings" \
    -H "$(auth_header)" -H "Content-Type: application/json" -d "$body" \
    | grep -oE '"embedding":\[[^]]*' | head -c 200 | sed 's/$/ ...]/'
}

# --- 5) ceviri (genel LLM ile; riva-translate bu hesapta stabil degil) ----
cmd_translate() {
  local text="${1:?metin gerekli}"; local tgt="${2:-Turkish}"; local model="${3:-nvidia/llama-3.3-nemotron-super-49b-v1.5}"
  local prompt="Translate the following text to $tgt. Return only the translation, no explanation or quotation marks:

$text"
  local tmp="$(mktemp)"; local tmpw="$(cygpath -w "$tmp")"
  {
    printf '{"model":"%s","messages":[{"role":"user","content":"%s"}],"max_tokens":200,"temperature":0.1,"stream":false}' \
      "$model" "$prompt"
  } > "$tmp"
  local resp
  resp="$(curl -s --max-time $TIMEOUT "$API/chat/completions" \
    -H "$(auth_header)" -H "Content-Type: application/json" --data "@$tmpw")"
  rm -f "$tmp"
  extract_content "$resp"
}

# --- 6) PII tespiti (NVIDIA GLiNER) -----------------------------------------
cmd_pii() {
  local text="${1:?metin gerekli}"; local model="${2:-nvidia/gliner-pii}"
  local prompt="List all personally identifiable information in the text below as 'TYPE: value' lines (e.g. PERSON: Ali, EMAIL: x@y.com, PHONE: 555-...). Text: $(json_escape "$text")"
  local tmp="$(mktemp)"; local tmpw="$(cygpath -w "$tmp")"
  {
    printf '{"model":"%s","messages":[{"role":"user","content":"%s"}],"max_tokens":256,"temperature":0.0,"stream":false}' \
      "$model" "$prompt"
  } > "$tmp"
  local resp
  resp="$(curl -s --max-time $TIMEOUT "$API/chat/completions" \
    -H "$(auth_header)" -H "Content-Type: application/json; charset=utf-8" --data "@$tmpw")"
  rm -f "$tmp"
  extract_content "$resp"
}

# --- 7) dusunen (reasoning) modeller --------------------------------------
cmd_reason() {
  local prompt="${1:?prompt gerekli}"; local model="${2:-nvidia/nemotron-3-nano-omni-30b-a3b-reasoning}"
  local tmp="$(mktemp)"; local tmpw="$(cygpath -w "$tmp")"
  {
    printf '{"model":"%s","messages":[{"role":"user","content":"%s"}],"max_tokens":1024,"temperature":0.6,"top_p":0.95,"stream":false}' \
      "$model" "$(json_escape "$prompt")"
  } > "$tmp"
  local resp
  resp="$(curl -s --max-time $TIMEOUT "$API/chat/completions" \
    -H "$(auth_header)" -H "Content-Type: application/json; charset=utf-8" --data "@$tmpw")"
  rm -f "$tmp"
  extract_content "$resp"
}

# --- 8) icerik guvenligi / moderasyon (NVIDIA Nemotron/GliaGuard) ----------
cmd_guard() {
  local text="${1:?metin gerekli}"; local model="${2:-nvidia/nemotron-3.5-content-safety}"
  local prompt="Classify the safety of the following text. Respond ONLY with a JSON object like {safety: safe or unsafe, category: ..., reason: ...}. Text: $(json_escape "$text")"
  local tmp="$(mktemp)"; local tmpw="$(cygpath -w "$tmp")"
  {
    printf '{"model":"%s","messages":[{"role":"user","content":"%s"}],"max_tokens":256,"temperature":0.0,"stream":false}' \
      "$model" "$prompt"
  } > "$tmp"
  local resp
  resp="$(curl -s --max-time $TIMEOUT "$API/chat/completions" \
    -H "$(auth_header)" -H "Content-Type: application/json; charset=utf-8" --data "@$tmpw")"
  rm -f "$tmp"
  extract_content "$resp"
}

# --- 9) kimlik / hesap dogrulama --------------------------------------------
cmd_whoami() {
  local code
  code="$(curl -s --max-time $TIMEOUT -o /dev/null -w "%{http_code}" \
    "$API/models" -H "$(auth_header)")"
  if [ "$code" = "200" ]; then
    echo "ANAHTAR GECERLI (HTTP 200). Modeller listelenebilir."
  else
    echo "ANAHTAR SORGULANamadi: HTTP $code" >&2
    return 1
  fi
}

# --- 10) genel amacli: ozetle / kod / dokuman / arastirma / analiz ----------
# Tek bir esnek "ask" cagrisi; sistem mesaji ile rol belirlenir.
ask_with_role() {
  local role="$1"; local prompt="$2"; local model="${3:-$MODEL_CHAT}"
  local sys="$(json_escape "$role")"
  local tmp="$(mktemp)"; local tmpw="$(cygpath -w "$tmp")"
  {
    printf '{"model":"%s","messages":[{"role":"system","content":"%s"},{"role":"user","content":"%s"}],"max_tokens":2000,"temperature":0.7,"top_p":0.95,"stream":false}' \
      "$model" "$sys" "$(json_escape "$prompt")"
  } > "$tmp"
  local resp
  resp="$(curl -s --max-time $TIMEOUT "$API/chat/completions" \
    -H "$(auth_header)" -H "Content-Type: application/json" --data "@$tmpw")"
  rm -f "$tmp"
  extract_content "$resp"
}
cmd_summarize() { ask_with_role "Sen bir ozetleme uzmanisin. Verilen metni net, maddeli, bilgi kaybi olmadan ozetle (Turkce)." "${1:?metin gerekli}"; }
cmd_code()      { ask_with_role "Sen kidemli bir yazilim muhendisisin. ${2:-Turkce} aciklama ve calisan kod uret." "${1:?gorev gerekli}"; }
cmd_doc()       { ask_with_role "Sen teknik dokuman yazarisin. Verilen konuyu yapilandirilmis, profesyonel bir dokuman haline getir (Turkce)." "${1:?konu gerekli}"; }
cmd_research()  { ask_with_role "Sen arastirma analistiisin. Konuyu cok yonlu arastir, kaynak oner, arti/eksi ve uygulanabilir cikarimlar sun (Turkce)." "${1:?konu gerekli}"; }
cmd_analyze()   { cmd_vision "$@"; }  # gorsel analizi icin alias

# --- dispatcher -------------------------------------------------------------
main() {
  load_key
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    models|list)    cmd_models "$@" ;;
    chat|text)      cmd_chat "$@" ;;
    vision|image)   cmd_vision "$@" ;;
    reason|think)   cmd_reason "$@" ;;
    guard|safety)   cmd_guard "$@" ;;
    embed)          cmd_embed "$@" ;;
    translate|tr)   cmd_translate "$@" ;;
    pii)            cmd_pii "$@" ;;
    whoami|test)    cmd_whoami "$@" ;;
    summarize|ozet) cmd_summarize "$@" ;;
    code|kod)       cmd_code "$@" ;;
    doc|dokuman)    cmd_doc "$@" ;;
    research|arastir) cmd_research "$@" ;;
    analyze|analiz) cmd_analyze "$@" ;;
    help|-h|--help)
      grep -E '^#' "$0" | sed 's/^# \{0,1\}//' | sed '1,2d' ;;
    *) echo "Bilinmeyen komut: $cmd"; echo "Yardim icin: $0 help"; exit 1 ;;
  esac
}
main "$@"
