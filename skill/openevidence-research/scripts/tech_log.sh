#!/usr/bin/env bash
# Registro técnico mínimo, SIN contenido clínico.
# Uso: tech_log.sh <evento> <resultado>
#   evento   ∈ vpn_status vpn_country vpn_connect vpn_disconnect vpn_verify oe_session oe_query oe_timeout oe_error phi_block abort
#   resultado: palabra corta (ok, fail, true, false, unknown, timeout, login_required...)
# Cualquier otro evento o un resultado con espacios/longitud >24 se rechaza,
# para impedir que se cuele texto de la consulta en el log.
set -u
LOG_DIR="${OE_LOG_DIR:-$HOME/Library/Logs/openevidence-research}"
[ "$(uname)" = "Darwin" ] || LOG_DIR="${OE_LOG_DIR:-$HOME/.local/state/openevidence-research}"

ev="${1:-}"; res="${2:-}"
case "$ev" in
  vpn_status|vpn_country|vpn_connect|vpn_disconnect|vpn_verify|oe_session|oe_query|oe_timeout|oe_error|phi_block|abort) ;;
  *) echo "tech_log: evento no permitido" >&2; exit 2 ;;
esac
if ! printf '%s' "$res" | grep -Eq '^[A-Za-z0-9_=.-]{1,24}$'; then
  echo "tech_log: resultado no permitido" >&2; exit 2
fi
mkdir -p "$LOG_DIR"
printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$ev" "$res" >> "$LOG_DIR/tech.log"
