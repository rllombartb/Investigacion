# Resolución de problemas

| Síntoma | Causa probable | Qué hace Claude | Qué haces tú |
|---|---|---|---|
| `protected=unknown` | Sin red, endpoint de NordVPN caído o bloqueado | Trata como no protegido; si tras conectar sigue `unknown`, aborta | Comprueba la conexión a Internet |
| VPN no conecta en 45 s | Servidor saturado, app pide login, Kill Switch/Threat Protection en conflicto | 2 intentos y aborta; restaura estado | Abre NordVPN y conecta a mano para ver el error |
| App NordVPN pide login / Touch ID | Sesión de NordVPN caducada | Se detiene y te lo pide | Inicia sesión en la app |
| Computer Use no ve la app | Permisos de Accesibilidad/Grabación de pantalla no concedidos a Claude | Se detiene | Ajustes del Sistema → Privacidad y seguridad → Accesibilidad y Grabación de pantalla → Claude |
| Computer Use no puede actuar en NordVPN | La app está en un nivel de acceso restringido | Pide acceso a la app | Aprueba el acceso cuando lo solicite |
| OpenEvidence muestra login | Sesión caducada en Chrome | Se detiene (TEST 5) | Inicia sesión en Chrome y confirma |
| OpenEvidence muestra error de región | El servicio no admite tu ubicación/IP | Se detiene y lo comunica | Decide tú; ver nota sobre condiciones de uso en `README` |
| Claude in Chrome no responde | Extensión desactivada o Chrome cerrado | Lo informa | Abre Chrome y activa la extensión Claude |
| Respuesta truncada | Generación aún en curso o timeout | Espera hasta 120 s; si no, informa que es parcial | Repetir la consulta más tarde |
| Referencias sin DOI/PMID | OpenEvidence no los muestra | Busca en PubMed; si no, `[NO VERIFICADO]` | — |
| La VPN no se desconecta al final | Diálogo de pausa, app colgada | Lo informa | Desconecta a mano |
| `phi_check` da falso positivo (p. ej. un nº de dosis largo) | Heurística regex | Reformula (p. ej. "10 000 000 UI" → "10 million IU") | — |
| La skill no se activa | Descripción no coincide o skill no instalada en Cowork | — | Comprueba Ajustes → Capacidades → Skills; reinstala el ZIP |
| Se activa cuando no debe | Pregunta ambigua | Debe preguntar antes | Di "no uses OpenEvidence" |

## Log técnico

`~/Library/Logs/openevidence-research/tech.log` (macOS). Solo fecha, evento y
resultado. Se puede borrar sin consecuencias.
