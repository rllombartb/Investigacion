#!/usr/bin/env bash
# Comprueba si el tráfico sale protegido por NordVPN. Solo lectura.
# Imprime una línea:  protected=true|false|unknown [country=XX]
# Código de salida: 0 true, 1 false, 3 unknown.
# No guarda la IP ni ningún dato. No modifica nada del sistema.
set -u

ENDPOINT="${NORDVPN_INSIGHTS_URL:-https://api.nordvpn.com/v1/helpers/ips/insights}"
TIMEOUT="${VPN_CHECK_TIMEOUT:-8}"

body="$(curl -fsS --max-time "$TIMEOUT" "$ENDPOINT" 2>/dev/null)" || {
  echo "protected=unknown"
  exit 3
}

# Parseo sin dependencias (jq puede no estar instalado en macOS).
protected="$(printf '%s' "$body" | tr -d ' \n' | sed -En 's/.*"protected":(true|false).*/\1/p')"
country="$(printf '%s' "$body" | tr -d '\n' | sed -En 's/.*"country_code"[[:space:]]*:[[:space:]]*"([A-Za-z]*)".*/\1/p')"

case "$protected" in
  true)  echo "protected=true${country:+ country=$country}";  exit 0 ;;
  false) echo "protected=false${country:+ country=$country}"; exit 1 ;;
  *)     echo "protected=unknown"; exit 3 ;;
esac
