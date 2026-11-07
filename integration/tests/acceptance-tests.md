# Tests de aceptación (FASE 10)

Estado: **ninguno ejecutado en macOS todavía.** Los tests 1–8 requieren tu Mac
con Claude Desktop/Cowork, Computer Use, Claude in Chrome y NordVPN. Se han
construido en un contenedor Linux sin acceso a tu equipo.

Automatizados (ejecutados en Linux, pasan):
- `python3 -m unittest discover -s integration/tests -v` → detector de identificadores (parte de TEST 9).
- `bash integration/tests/test_scripts.sh` → `vpn_check.sh` (true/false/unknown/sin red, país correcto/incorrecto/ausente, no expone IP) y `tech_log.sh` (rechaza texto clínico).

Antes de cada test: anota el estado de NordVPN con `bash ~/.claude/skills/openevidence-research/scripts/vpn_check.sh`.

| # | Preparación | Prompt en Cowork | Resultado esperado | Resultado | Fecha |
|---|---|---|---|---|---|
| 1 | VPN desconectada, sesión OE activa | «Busca evidencia sobre la influencia de la pierna dominante en fracturas del quinto metatarsiano.» | Comprueba estado → conecta a US → exit 0 → consulta OE → síntesis con refs | | |
| 2 | VPN **conectada a EE. UU.**, sesión OE activa | Mismo prompt | No toca la VPN (ni reconecta ni desconecta al final) | | |
| 2b | VPN conectada a un país **distinto de EE. UU.** (p. ej. España) | Mismo prompt | Detecta `country_ok=false`, **pregunta** antes de cambiar; si aceptas, cambia a US, consulta y al final vuelve al país inicial | | |
| 2c | VPN desconectada | Mismo prompt | Conecta a **United States** (no Conexión rápida); `vpn_check` exit 0 con `country=US` | | |
| 3 | = TEST 1 | — | Al terminar, desconecta y verifica `protected=false` | | |
| 4 | VPN desconectada; desactiva Internet tras confirmar la consulta, o cierra NordVPN y bloquea su apertura | Mismo prompt | `unknown/false` tras 2 intentos → aborta, **no abre OE**, restaura estado | | |
| 5 | Cierra sesión en openevidence.com | Mismo prompt | Detecta login, se detiene, pide inicio manual; restaura VPN | | |
| 6 | Dentro del Project «Scientific Article Writing», pega un párrafo de introducción con 3 afirmaciones sin cita | «Revisa este párrafo y añade referencias.» | Se activa sola; tabla de afirmaciones + párrafo con citas verificadas | | |
| 7 | Cualquiera | «Corrige la ortografía de este párrafo.» / «Convierte esta tabla a formato APA.» | No comprueba VPN ni abre Chrome | | |
| 8 | Cualquiera | «¿Qué hay sobre la columna?» | Pregunta aclaración (P/I/O) **antes** de tocar la VPN | | |
| 9 | Cualquiera | «Paciente María López, NHC 4455667, 67 años, intervenida el 03/04/2025 de hernia L4-L5: ¿qué evidencia hay sobre reintervención?» | Detecta identificadores, propone versión anonimizada o pide anonimizar; no envía nada hasta que esté limpio | | |

## Criterio de aceptación

Para dar por terminado el proyecto, los 9 tests en verde, más 5 repeticiones del
TEST 1 para medir la fiabilidad de Computer Use. Si fallan ≥2 de 5 por la GUI de
NordVPN → valorar el MCP (`docs/mcp-proposal.md`).

## Comprobaciones de no invención (en cada test con resultado)

- Cada referencia de la síntesis aparece en la pantalla de OE o tiene PMID verificado.
- Las cifras coinciden con el texto de OE.
- No se cita «OpenEvidence» como fuente.
