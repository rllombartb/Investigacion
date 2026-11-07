#!/usr/bin/env bash
# Rollback: elimina la skill instalada y, opcionalmente, restaura la última copia de seguridad.
# No toca VPN, red, permisos ni Projects. El log técnico se conserva salvo PURGE_LOG=1.
set -euo pipefail
DEST="$HOME/.claude/skills/openevidence-research"
LAST_BK="$(ls -d "$DEST".bak-* 2>/dev/null | sort | tail -1 || true)"

echo "Se eliminará: $DEST"
[ -n "$LAST_BK" ] && echo "Copia de seguridad disponible: $LAST_BK"
if [ "${ASSUME_YES:-0}" != "1" ]; then
  read -r -p "¿Continuar? [s/N] " a; [[ "$a" =~ ^[sSyY]$ ]] || { echo "Cancelado."; exit 0; }
fi
rm -rf "$DEST"
if [ -n "$LAST_BK" ] && [ "${RESTORE_BACKUP:-0}" = "1" ]; then
  mv "$LAST_BK" "$DEST"; echo "Restaurada $LAST_BK"
fi
[ "${PURGE_LOG:-0}" = "1" ] && rm -rf "$HOME/Library/Logs/openevidence-research" && echo "Log técnico borrado"
echo "Hecho. En Cowork/Claude Desktop, elimina también la skill en Ajustes → Capacidades → Skills."
