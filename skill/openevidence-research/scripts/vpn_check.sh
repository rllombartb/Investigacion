#!/usr/bin/env bash
# Comprueba si el tráfico sale por NordVPN y desde qué país. Solo lectura.
# Imprime una línea:
#   protected=true|false|unknown [country=XX] [country_ok=true|false|unknown]
# Códigos de salida:
#   0  protegido y país correcto (o sin requisito de país)
#   1  no protegido
#   3  estado desconocido (sin red / endpoint caído) -> tratar como NO protegido
#   4  protegido pero país de salida distinto del requerido o no determinable
# Variables:
#   OE_REQUIRED_COUNTRY  código ISO del país de salida requerido (por defecto US;
#                        vacío = sin requisito)
#   NORDVPN_INSIGHTS_URL, VPN_CHECK_TIMEOUT
# No guarda la IP ni ningún dato. No modifica nada del sistema.
set -u

ENDPOINT="${NORDVPN_INSIGHTS_URL:-https://api.nordvpn.com/v1/helpers/ips/insights}"
TIMEOUT="${VPN_CHECK_TIMEOUT:-8}"
REQ="${OE_REQUIRED_COUNTRY-US}"

body="$(curl -fsS --max-time "$TIMEOUT" "$ENDPOINT" 2>/dev/null)" || {
  echo "protected=unknown"
  exit 3
}

# Parseo sin dependencias (jq puede no estar instalado en macOS). sed -E es portable GNU/BSD.
protected="$(printf '%s' "$body" | tr -d ' \n' | sed -En 's/.*"protected":(true|false).*/\1/p')"
country="$(printf '%s' "$body" | tr -d '\n' | sed -En 's/.*"country_code"[[:space:]]*:[[:space:]]*"([A-Za-z]*)".*/\1/p')"
country="$(printf '%s' "$country" | tr '[:lower:]' '[:upper:]')"
REQ="$(printf '%s' "$REQ" | tr '[:lower:]' '[:upper:]')"

case "$protected" in
  false) echo "protected=false${country:+ country=$country}"; exit 1 ;;
  true)  ;;
  *)     echo "protected=unknown"; exit 3 ;;
esac

if [ -z "$REQ" ]; then
  echo "protected=true${country:+ country=$country}"; exit 0
fi
if [ -z "$country" ]; then
  echo "protected=true country_ok=unknown"; exit 4
fi
if [ "$country" = "$REQ" ]; then
  echo "protected=true country=$country country_ok=true"; exit 0
fi
echo "protected=true country=$country country_ok=false"; exit 4
