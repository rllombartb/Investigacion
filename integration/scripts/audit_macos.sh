#!/usr/bin/env bash
# FASE 1 — Auditoría de SOLO LECTURA del Mac.
# No instala, no cambia permisos, no toca red/VPN, no lee credenciales ni Keychain.
# Uso:  bash integration/scripts/audit_macos.sh > ~/Desktop/oe-audit.txt
# Revisa el resultado antes de compartirlo (contiene nombres de apps y versiones,
# no contiene IP ni datos personales).
set -u
h(){ printf '\n## %s\n' "$1"; }
v(){ /usr/bin/defaults read "$1/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "?"; }

[ "$(uname)" = "Darwin" ] || { echo "Este script es para macOS."; exit 1; }

h "macOS"
sw_vers; uname -m

h "NordVPN — aplicación"
found=0
for app in "/Applications/NordVPN.app" "$HOME/Applications/NordVPN.app"; do
  if [ -d "$app" ]; then
    found=1
    echo "Ruta: $app"
    echo "Versión: $(v "$app")"
    echo "Bundle ID: $(/usr/bin/defaults read "$app/Contents/Info" CFBundleIdentifier 2>/dev/null)"
    if [ -d "$app/Contents/_MASReceipt" ]; then echo "Origen: Mac App Store"; else echo "Origen: descarga directa (o desconocido)"; fi
    sdef "$app" >/dev/null 2>&1 && echo "AppleScript: SÍ publica diccionario (sdef)" || echo "AppleScript: no publica diccionario"
    /usr/bin/defaults read "$app/Contents/Info" NSAppleScriptEnabled 2>/dev/null | sed 's/^/NSAppleScriptEnabled: /'
    ls "$app/Contents/Extensions" 2>/dev/null | grep -i intent && echo "App Intents/Shortcuts: posible" || echo "App Intents: no detectados en Extensions"
  fi
done
[ $found -eq 0 ] && echo "NordVPN.app no encontrada en /Applications ni ~/Applications"

h "NordVPN — CLI"
command -v nordvpn >/dev/null 2>&1 && { echo "CLI encontrada: $(command -v nordvpn)"; nordvpn --version 2>/dev/null; } || echo "No hay CLI 'nordvpn' en PATH (esperado en macOS)"

h "NordVPN — proceso y perfiles de red (lectura)"
pgrep -fl -i nordvpn | sed 's/^[0-9]* //' | head -5 || echo "Proceso NordVPN no en ejecución"
scutil --nc list 2>/dev/null | grep -i nord || echo "Sin perfiles NordVPN visibles en scutil --nc list"

h "NordVPN — estado de protección (endpoint público, solo booleano)"
bash "$(dirname "$0")/../../skill/openevidence-research/scripts/vpn_check.sh" || true

h "Shortcuts"
command -v shortcuts >/dev/null && { echo "CLI shortcuts disponible"; shortcuts list 2>/dev/null | grep -i -E 'nord|vpn' || echo "Ningún atajo con 'nord'/'vpn' en el nombre"; } || echo "CLI shortcuts no disponible"

h "Navegadores"
for b in "Google Chrome" "Safari" "Firefox" "Microsoft Edge" "Arc" "Brave Browser"; do
  [ -d "/Applications/$b.app" ] && echo "$b $(v "/Applications/$b.app")"
done

h "Claude in Chrome (extensión)"
CHROME_DIR="$HOME/Library/Application Support/Google/Chrome"
if [ -d "$CHROME_DIR" ]; then
  hits=$(grep -l -i -s '"name": *"Claude' "$CHROME_DIR"/*/Extensions/*/*/manifest.json 2>/dev/null | wc -l | tr -d ' ')
  echo "Manifiestos de extensión con nombre 'Claude…': $hits"
else
  echo "Perfil de Chrome no encontrado"
fi

h "Claude Desktop / Cowork / Claude Code"
[ -d "/Applications/Claude.app" ] && echo "Claude.app $(v /Applications/Claude.app)" || echo "Claude.app no encontrada"
command -v claude >/dev/null && echo "Claude Code CLI: $(claude --version 2>/dev/null)" || echo "Claude Code CLI no en PATH"
[ -d "$HOME/.claude/skills" ] && { echo "~/.claude/skills:"; ls "$HOME/.claude/skills"; } || echo "~/.claude/skills no existe"

h "Permisos (no se pueden leer sin privilegios; comprobar a mano)"
cat <<'TXT'
Ajustes del Sistema → Privacidad y seguridad:
  - Accesibilidad: ¿Claude activado?            (necesario para Computer Use)
  - Grabación de pantalla y audio: ¿Claude?     (necesario para Computer Use)
  - Automatización: Claude → (no necesario si no se usa AppleScript)
En Claude Desktop → Ajustes: ¿Computer Use habilitado? ¿Claude in Chrome conectado?
En Chrome: ¿sesión iniciada en openevidence.com?
TXT

h "Fin de la auditoría (no se ha modificado nada)"
