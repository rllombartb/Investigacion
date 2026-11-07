# Control de NordVPN en macOS

**Propósito de la VPN:** OpenEvidence no da servicio en España. La VPN se usa
para salir por un servidor de **EE. UU.** Es una decisión del usuario, que asume
el riesgo frente a las condiciones de uso de OpenEvidence (ver README).

## Qué mecanismo usar (y por qué)

| Mecanismo | Estado en macOS | Uso en esta skill |
|---|---|---|
| CLI oficial `nordvpn` | Solo existe para Linux. No está en macOS (a confirmar con `integration/scripts/audit_macos.sh`) | No |
| AppleScript / diccionario de scripting | La app no publica uno (a confirmar con la auditoría) | No |
| Shortcuts / App Intents | Puede existir según la versión; a confirmar con la auditoría | Opcional, si la auditoría lo confirma |
| `scutil --nc` | Solo lee perfiles VPN del sistema. Depende del protocolo/versión | Solo lectura (estado) |
| Endpoint público de NordVPN `api.nordvpn.com/v1/helpers/ips/insights` | Devuelve `"protected": true/false` para la IP pública | **Verificación principal** |
| Computer Use sobre la GUI de la app | Funciona con cualquier versión | **Conectar / desconectar** |

Conclusión: **leer el estado por red, actuar por GUI**. No hace falta MCP propio
mientras Computer Use sea fiable (ver «Cuándo proponer un MCP»).

## Comprobar estado

```bash
bash scripts/vpn_check.sh
# exit 0  protected=true country=US country_ok=true   -> listo
# exit 4  protected=true country=FR country_ok=false  -> VPN activa, país incorrecto
# exit 1  protected=false                             -> no protegido
# exit 3  protected=unknown                           -> no se pudo comprobar: tratar como NO protegido
```
`OE_REQUIRED_COUNTRY` cambia el país requerido (vacío = sin requisito).

El script no guarda la IP ni nada clínico; solo imprime el booleano y el país
si lo devuelve el endpoint.

## Conectar (Computer Use)

1. Lee primero la skill `computer-use` si está disponible.
2. Abre la app «NordVPN» (pide acceso a la app si Computer Use lo requiere).
3. Usa el buscador de países de la app → **United States** → conectar.
   **No** uses Quick Connect / Conexión rápida (elige el servidor más cercano,
   en Europa). No cambies protocolo, Kill Switch, Threat Protection ni ningún ajuste.
4. Si aparece login de NordVPN, Touch ID, contraseña de macOS o diálogo de
   permisos del sistema → **detente y pide al usuario que lo complete**.
5. Espera hasta 45 s; vuelve a ejecutar `vpn_check.sh` cada ~10 s.
6. Máximo 2 intentos de conexión. Si no da exit 0 (no protegido, desconocido o país distinto de US) → abortar el flujo.

## Cambiar de país (solo si el estado inicial era `conectado-otro-país` y el usuario lo aprobó)

1. Anota el país inicial (lo imprime `vpn_check.sh`).
2. En la app, buscador → United States → conectar. Verifica exit 0.
3. Al terminar: buscador → país inicial → conectar. Verifica con
   `OE_REQUIRED_COUNTRY=<país inicial> bash scripts/vpn_check.sh`.
   El servidor concreto puede ser distinto del original; el país, no.

## Desconectar (solo si el estado inicial era desconectado)

1. En la app NordVPN pulsa **Disconnect / Desconectar**.
2. Si la app ofrece «Pausar 5 min / 1 h / Desconectar», elige **Desconectar**.
3. Verifica `protected=false`. Si sigue conectada tras 2 intentos, informa al usuario
   (no es grave, pero el estado no se ha restaurado).

## Invariantes

- Registrar `ESTADO_INICIAL` **antes** de cualquier acción.
- Nunca desconectar ni reconectar si `ESTADO_INICIAL = conectado-US` (TEST 2).
- Nunca cambiar de país sin preguntar si la VPN ya estaba conectada a otro país (TEST 2b).
- Nunca abrir OpenEvidence sin exit 0 de `vpn_check.sh` justo antes (TEST 4).
- Restaurar el estado también si el flujo aborta.
- Una sola operación de VPN a la vez: no lances dos conexiones simultáneas.

## Cuándo proponer un MCP local

Solo si, tras usarlo de verdad, Computer Use falla de forma repetida (p. ej. >1 de
cada 5 ejecuciones) por cambios de interfaz, ventanas que no aparecen, etc.
En ese caso el MCP expondría `vpn_status`, `vpn_connect`, `vpn_disconnect`,
`vpn_verify`, con timeouts, lock de exclusión, log técnico sin contenido clínico
y sin credenciales. Ver `integration/docs/mcp-proposal.md`. **No está implementado**.
