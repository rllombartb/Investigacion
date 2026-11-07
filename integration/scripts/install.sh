#!/usr/bin/env bash
# Instala la skill openevidence-research.
#  1) Copia la skill a ~/.claude/skills/openevidence-research (Claude Code).
#     Si ya existe, hace copia de seguridad con fecha antes de sustituirla.
#  2) Genera un ZIP para subir a Claude Desktop/Cowork (Ajustes → Capacidades → Skills).
# No cambia permisos del sistema, ni red, ni VPN, ni Projects.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/../../skill/openevidence-research" && pwd)"
DEST="$HOME/.claude/skills/openevidence-research"
ZIP_OUT="${ZIP_OUT:-$HOME/Desktop/openevidence-research.zip}"

echo "Origen : $SRC"
echo "Destino: $DEST"
echo "ZIP    : $ZIP_OUT"
if [ "${ASSUME_YES:-0}" != "1" ]; then
  read -r -p "¿Continuar? [s/N] " a; [[ "$a" =~ ^[sSyY]$ ]] || { echo "Cancelado."; exit 0; }
fi

mkdir -p "$HOME/.claude/skills"
if [ -e "$DEST" ]; then
  BK="$DEST.bak-$(date +%Y%m%d-%H%M%S)"
  mv "$DEST" "$BK"; echo "Copia de seguridad: $BK"
fi
cp -R "$SRC" "$DEST"
chmod +x "$DEST"/scripts/*.sh "$DEST"/scripts/*.py

( cd "$(dirname "$SRC")" && rm -f "$ZIP_OUT" && zip -qr "$ZIP_OUT" openevidence-research -x '*/__pycache__/*' )
echo "OK. Instalada en $DEST"
echo "Para Cowork/Claude Desktop: sube $ZIP_OUT en Ajustes → Capacidades → Skills."
