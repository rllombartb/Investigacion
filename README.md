# OpenEvidence + NordVPN para Claude Cowork

Skill global `openevidence-research` que, ante preguntas que necesitan evidencia
científica, comprueba/activa NordVPN, consulta OpenEvidence con la sesión de
Chrome del usuario (Claude in Chrome), extrae respuesta y referencias visibles,
devuelve una síntesis estructurada y restaura el estado inicial de la VPN.

> **Estado:** artefactos construidos; tests automatizados de scripts en verde
> (Linux). **Tests de aceptación en macOS pendientes** — ver
> `integration/tests/acceptance-tests.md`. No está validado de extremo a extremo.

## Arquitectura (mínima)

```
Cowork (skill openevidence-research)
 ├─ phi_check.py ......... control de identificadores (local)
 ├─ vpn_check.sh ......... estado de protección vía endpoint público NordVPN (solo lectura)
 ├─ Computer Use ......... conectar/desconectar en la app NordVPN (GUI)
 ├─ Claude in Chrome ..... OpenEvidence con tu sesión
 └─ PubMed (conector) .... verificación de referencias
```
Sin MCP propio. Ver `integration/docs/mcp-proposal.md` para cuándo haría falta.

## Estructura

```
skill/openevidence-research/     → se copia a ~/.claude/skills/ y se empaqueta en ZIP para Cowork
  SKILL.md, troubleshooting.md
  references/  activation-criteria · nordvpn-control · openevidence-protocol · evidence-appraisal · projects-integration
  templates/   synthesis · manuscript-paragraph · peer-review-check · ethics-justification · systematic-review-pico
  scripts/     phi_check.py · vpn_check.sh · tech_log.sh
integration/
  scripts/  audit_macos.sh (solo lectura) · install.sh · uninstall.sh
  tests/    test_phi_check.py · test_scripts.sh · acceptance-tests.md
  docs/     mcp-proposal.md
```

## Instalación paso a paso

1. **Auditoría (solo lectura):**
   `bash integration/scripts/audit_macos.sh > ~/Desktop/oe-audit.txt` y revisa el resultado.
2. **Tests locales:** `python3 -m unittest discover -s integration/tests -v && bash integration/tests/test_scripts.sh`
3. **Instalar:** `bash integration/scripts/install.sh` (pide confirmación; hace copia de seguridad si ya existe).
   - Claude Code: queda en `~/.claude/skills/openevidence-research/`.
   - **Cowork / Claude Desktop:** sube `~/Desktop/openevidence-research.zip` en
     Ajustes → Capacidades → Skills. `~/.claude/skills` por sí solo puede no ser
     leído por Cowork.
4. **Permisos** (los concedes tú; el instalador no los toca):
   - Ajustes del Sistema → Privacidad y seguridad → **Accesibilidad** y **Grabación de pantalla**: Claude.
   - Claude Desktop: **Computer Use** habilitado; **Claude in Chrome** conectado.
   - Chrome: sesión iniciada en openevidence.com.
   - Computer Use pedirá acceso a la app NordVPN la primera vez.
5. **Tests de aceptación:** `integration/tests/acceptance-tests.md`.

No se modifican Projects, red, DNS, Keychain, Firewall ni Kill Switch.

## Rollback

`bash integration/scripts/uninstall.sh` (opcional: `RESTORE_BACKUP=1`, `PURGE_LOG=1`)
y elimina la skill en Ajustes → Capacidades → Skills. Nada más queda en el sistema.

## Log técnico

`~/Library/Logs/openevidence-research/tech.log`: fecha, evento, resultado.
`tech_log.sh` rechaza eventos no listados y resultados con espacios o >24 caracteres.

## ⚠️ Condiciones de uso de OpenEvidence

Si la VPN sirve para que OpenEvidence te vea desde otro país, puede chocar con
sus condiciones de uso (acceso por geografía/profesional verificado) y con el
principio de este proyecto de no usar «mecanismos que vulneren las condiciones de
uso». No se ha podido verificar el texto vigente desde el entorno de construcción.
Revísalo antes de usar la integración. La skill **no** cambia de país ni de
servidor para sortear errores de región.
