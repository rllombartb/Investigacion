# Propuesta de MCP local para NordVPN (NO implementado)

Solo se construirá si los tests de aceptación demuestran que Computer Use no es
fiable para conectar/desconectar NordVPN (≥2 fallos en 5 ejecuciones del TEST 1).

## Herramientas

| Herramienta | Entrada | Salida | Timeout |
|---|---|---|---|
| `vpn_status` | — | `{protected: bool\|null, source}` | 10 s |
| `vpn_verify` | — | igual que status, con 3 reintentos | 30 s |
| `vpn_connect` | — | `{ok, protected}` | 60 s |
| `vpn_disconnect` | — | `{ok, protected}` | 30 s |

## Requisitos

- Lock de exclusión (fichero con `flock`/PID) para impedir operaciones simultáneas.
- Log técnico idéntico a `tech_log.sh` (evento, resultado, sin contenido clínico).
- Sin credenciales: si NordVPN pide login, devuelve `{ok:false, reason:"login_required"}`.
- Sin cambios de ajustes de NordVPN, red, DNS ni Kill Switch.

## Problema de base

Sin CLI ni AppleScript oficiales en macOS, el MCP también tendría que actuar
sobre la GUI (Accessibility API / `osascript` con System Events), que exige
permiso de Accesibilidad para el proceso del MCP y es tan frágil ante cambios de
interfaz como Computer Use. Solo ganaría en timeouts, lock y trazabilidad. Si la
auditoría encuentra un Atajo (Shortcuts/App Intents) de NordVPN, esa sería la vía
preferente: `shortcuts run "<nombre>"`, sin GUI.
