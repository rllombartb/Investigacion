---
name: openevidence-research
description: Consulta OpenEvidence (vía Claude in Chrome con la sesión del usuario) a través de NordVPN con salida en EE. UU. y devuelve una síntesis clínica estructurada con referencias verificables. Úsala cuando la tarea requiera evidencia científica actualizada - buscar evidencia, contrastar una afirmación clínica, documentar antecedentes de un manuscrito, justificar un proyecto ante un comité de ética, revisar literatura para una revisión sistemática o redactar introducción/discusión/métodos con citas. NO la uses para ortografía, formato APA, notas de reunión, emails administrativos, redacción creativa ni preguntas que no necesiten evidencia actualizada.
---

# openevidence-research

Capacidad transversal para Projects de investigación clínica. No sustituye las
instrucciones de cada Project: se suma a ellas.

## 0. Reglas no negociables

1. **No inventar nada.** Toda referencia, DOI, PMID, autor, revista, fecha o cifra
   que aparezca en la salida debe haber sido **vista en pantalla en OpenEvidence**
   o **verificada en PubMed** (herramienta `PubMed` si está disponible). Si no se
   puede verificar, se marca `[NO VERIFICADO]` o se omite.
2. **Sin datos identificables.** Antes de enviar nada a OpenEvidence, ejecuta el
   control de privacidad (§3). Si falla, detente.
3. **Sin VPN verificada en EE. UU. no hay OpenEvidence.** OpenEvidence no da
   servicio en España; la VPN se usa para salir por un servidor de EE. UU. (decisión
   y riesgo asumidos por el usuario, ver README). Si la verificación falla
   (no protegido o país distinto), el flujo se detiene antes de abrir la web.
4. **Autenticación humana.** Face ID, Touch ID, contraseña de macOS, 2FA, captcha,
   pantallas de consentimiento o login: **detente y pide al usuario que lo haga**.
   Nunca escribas credenciales.
5. **No tocar configuración del sistema.** Ni red, DNS, Keychain, Firewall,
   Kill Switch, ajustes de NordVPN ni permisos de macOS. Solo conectar/desconectar.
6. **Restaurar el estado inicial de la VPN** siempre, también si el flujo falla
   (ver `references/nordvpn-control.md`).
7. OpenEvidence es una **fuente secundaria** (agregador con IA). Nunca se cita
   OpenEvidence como fuente; se citan los estudios primarios que muestra.

## 1. Decidir si se activa

Lee `references/activation-criteria.md`. Resumen:

| Situación | Acción |
|---|---|
| Pregunta clínica/científica que requiere evidencia actual | Activar |
| Redacción científica con afirmaciones que requieren cita | Activar (sobre las afirmaciones) |
| Ortografía, formato, traducción, notas, emails, tareas administrativas | **No** activar |
| Duda razonable (pregunta vaga, sin población/intervención/desenlace claros) | **Preguntar** antes de tocar la VPN |

Si no activas, no compruebes la VPN ni abras Chrome.

## 2. Formular la consulta

1. Reformula en inglés clínico, una sola pregunta, estructura PICO cuando aplique:
   `In [P], does [I] compared with [C] affect [O]?`
2. Si faltan P, I u O y no se pueden inferir con seguridad → pregunta al usuario
   (TEST 8). No adivines el desenlace.
3. Muestra al usuario la consulta exacta que vas a enviar (una línea) antes de enviarla.

## 3. Control de privacidad (obligatorio, antes de la VPN)

1. Ejecuta: `python3 scripts/phi_check.py "<consulta reformulada>"`
   (ruta relativa a la carpeta de esta skill). Código de salida 0 = limpio,
   1 = posibles identificadores (los lista), 2 = error de uso.
2. Además revisa tú mismo: nombres, iniciales + edad exacta, fechas concretas,
   nº de historia, DNI/NIE/NUSS, teléfonos, emails, direcciones, centro + fecha,
   casos únicos reconocibles, imágenes.
3. Si hay identificadores: elimínalos/generaliza (p. ej. "varón de 67 años" →
   "adult male") y vuelve a ejecutar el script. Si no es posible anonimizar sin
   perder el sentido, **pide al usuario que anonimice** (TEST 9).
4. Nunca subas imágenes ni documentos clínicos a OpenEvidence.

El script es una red de seguridad, no una garantía. Tu revisión manual manda.

## 4. NordVPN: estado, conexión y verificación

Sigue `references/nordvpn-control.md`. Esquema:

1. `bash scripts/vpn_check.sh` (país requerido por defecto: `US`).
   Registra `ESTADO_INICIAL`:
   - exit 0 → `conectado-US`
   - exit 4 → `conectado-otro-país` (anota el país que imprime)
   - exit 1 o 3 → `desconectado`
2. `conectado-US` → **no toques la VPN** (TEST 2). Ve a §5.
3. `conectado-otro-país` → **pregunta** al usuario si cambias a EE. UU. Si dice no,
   no consultes OpenEvidence. Si dice sí, cambia de país en la app (TEST 2b).
4. `desconectado` → conecta con Computer Use en la app NordVPN **a United States**
   (buscador de países → "United States" → conectar). **No** uses "Conexión rápida":
   elige el servidor más cercano, que estará en Europa. Espera hasta 45 s.
5. Vuelve a ejecutar `vpn_check.sh`. Si no devuelve exit 0 tras 2 intentos →
   **ABORTA** (TEST 4): informa, restaura estado inicial, no abras OpenEvidence.
6. `unknown` (sin red o endpoint caído) → trátalo como **no protegido**.

## 5. OpenEvidence en Chrome

Sigue `references/openevidence-protocol.md`. Esquema:

1. Lee primero la skill `chrome-browser` si está disponible.
2. Reutiliza una pestaña de `openevidence.com` o abre una nueva.
3. Comprueba sesión: si aparece login/registro/verificación NPI → **detente**,
   pide al usuario que inicie sesión manualmente y espera su confirmación (TEST 5).
4. Escribe la consulta, envía, espera a que termine la generación
   (el texto deja de crecer durante ~5 s y aparecen las referencias).
   Timeout 120 s.
5. Extrae **solo lo visible**: respuesta, numeración de citas, lista de
   referencias (título, autores, revista, año, DOI/PMID/enlace si aparecen).
6. Una consulta por pregunta. Sin bucles, sin consultas masivas, sin descargar
   contenido en bloque.
7. Si no responde o da error → informa claramente. No rellenes con conocimiento propio
   presentado como si fuera de OpenEvidence.

## 6. Restaurar la VPN (siempre)

- `desconectado` → desconecta con Computer Use y verifica `protected=false` (TEST 3).
- `conectado-US` → no hagas nada.
- `conectado-otro-país` (y cambiaste a EE. UU.) → vuelve a conectar al país inicial
  y verifica con `OE_REQUIRED_COUNTRY=<país> bash scripts/vpn_check.sh`.
- Hazlo también tras cualquier aborto de §5.

## 7. Evaluar y sintetizar

1. Aplica `references/evidence-appraisal.md` a cada referencia.
2. Verifica en PubMed (si la herramienta existe) las referencias clave:
   título + primer autor + año → PMID/DOI. Marca cada una
   `[Verificada PubMed]`, `[Vista en OpenEvidence]` o `[NO VERIFICADO]`.
3. Separa **lo que dice la evidencia** de **tu interpretación**.
4. Usa la plantilla adecuada de `templates/`:
   - general → `templates/synthesis.md`
   - escritura científica → `templates/manuscript-paragraph.md`
   - peer review → `templates/peer-review-check.md`
   - comité de ética → `templates/ethics-justification.md`
   - revisión sistemática → `templates/systematic-review-pico.md`

## 8. Integración con Projects

Ver `references/projects-integration.md`. Las instrucciones del Project
prevalecen sobre el formato de esta skill; las reglas de §0 prevalecen sobre todo.

## 9. Registro técnico

Si necesitas dejar traza, usa `scripts/tech_log.sh <evento> <resultado>`.
Solo eventos técnicos (vpn_status, vpn_country, vpn_connect, oe_session, oe_timeout...).
**Nunca** la consulta, la respuesta ni datos clínicos.

## 10. Errores

Ver `troubleshooting.md`.
