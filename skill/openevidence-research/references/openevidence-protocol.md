# Protocolo de consulta a OpenEvidence (Claude in Chrome)

## Precondiciones

- VPN verificada en EE. UU. (`vpn_check.sh` exit 0) en este mismo flujo.
- Consulta anonimizada y validada con `phi_check.py`.
- El usuario ha visto la consulta exacta que se va a enviar.

## Pasos

1. **Pestaña.** Busca entre las pestañas abiertas una con `openevidence.com`.
   Si existe, úsala; si no, abre una nueva en `https://www.openevidence.com/`.
   No cierres ni recargues otras pestañas del usuario.
2. **Sesión.** Lee la página. Señales de **sesión no activa**: botones
   "Log in"/"Sign up", formulario de email/contraseña, verificación de
   profesional sanitario, captcha, banner de consentimiento.
   → Detente. Mensaje: «OpenEvidence no tiene la sesión iniciada en Chrome.
   Inicia sesión manualmente y dime cuando esté listo.» No intentes
   rellenar nada.
3. **Consulta.** Haz clic en la caja de pregunta, escribe la consulta
   reformulada, envía (Enter o botón).
4. **Espera.** Comprueba cada ~5 s. La respuesta está completa cuando:
   - el texto no ha cambiado en dos lecturas seguidas, **y**
   - ha desaparecido el indicador de generación (o aparece la sección de referencias).
   Timeout total: 120 s. Si se agota → informa «OpenEvidence no respondió a tiempo».
5. **Extracción.** Lee el texto de la página (no capturas si se puede leer como texto):
   - Respuesta (literal o casi literal, sin reescribir cifras).
   - Marcadores de cita en el texto ([1], [2]…).
   - Lista de referencias: título, autores, revista, año, y DOI/PMID/URL **solo si aparecen**.
   - Enlaces de cada referencia, si están visibles.
6. **Devolver** a la síntesis (SKILL.md §7). No dejes la pestaña en un estado raro;
   no hace falta cerrarla.

## Prohibido

- Rellenar credenciales, saltar captchas o verificaciones.
- Lanzar muchas consultas en bucle o automatizar descargas masivas.
- Modificar ajustes de la cuenta de OpenEvidence.
- Subir archivos, imágenes o PDFs clínicos.
- Completar referencias "de memoria". Lo que no se vio, no existe.

## Si OpenEvidence muestra un error de región/acceso

1. Comprueba `vpn_check.sh`. Si ya no es exit 0, la VPN se ha caído: vuelve a §4 de SKILL.md.
2. Si es exit 0, reconecta **una vez** a otro servidor de United States en la app
   y recarga la página.
3. Si persiste → detente, comunícalo literalmente y restaura la VPN. No pruebes
   más servidores ni otros países, ni intentes ocultar la ubicación por otras vías
   (zona horaria, idioma, extensiones).
4. Si OpenEvidence pide verificación de identidad o de licencia profesional,
   detente: lo hace el usuario.
