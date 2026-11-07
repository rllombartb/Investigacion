# Integración con Projects

La skill es global y no modifica ningún Project. Las instrucciones de cada Project
mandan sobre el formato; las reglas de seguridad de SKILL.md §0 mandan sobre todo.

| Project | Qué hace la skill | Plantilla |
|---|---|---|
| Scientific Article Writing | Detecta afirmaciones que necesitan cita, busca evidencia, redacta párrafos con citas numeradas | `manuscript-paragraph.md` |
| Manuscript Peer Review | Lista afirmaciones del manuscrito sin respaldo, contradicciones con la evidencia, referencias desactualizadas | `peer-review-check.md` |
| Ethics Committee Applications | Justificación científica, estado del conocimiento, vacío de evidencia, referencias clave | `ethics-justification.md` |
| Systematic Reviews & Meta-Analyses | Tabla PICO, términos MeSH/Emtree candidatos, borrador de estrategia reproducible; OpenEvidence solo exploratorio | `systematic-review-pico.md` |
| Research Projects / Clinical Research | Síntesis de evidencia para hipótesis, tamaño de efecto esperado (si consta), diseño | `synthesis.md` |
| Medical Literature Review | Síntesis por desenlace con certeza | `synthesis.md` |

## Escritura científica: identificar afirmaciones que requieren cita

Requieren cita: cifras de incidencia/prevalencia, efectos de tratamientos,
comparaciones, afirmaciones causales, "se ha demostrado", "la literatura indica",
estado de guías. No requieren: definiciones de manual, descripción de los propios métodos.

Haz **una consulta por afirmación clave** (máx. 3–5 por sesión salvo que el usuario
pida más), no una por frase.

## Coordinación con otras skills del usuario

- `verificar-referencias`: úsala después para comprobar las referencias finales.
- `systematic-review-hub:*` / `protocolo-busqueda-rs`: para el protocolo y la
  búsqueda reproducible; esta skill solo aporta la fase exploratoria.
- `solicitud-cei-unav`: aporta la sección de justificación científica; el formato
  lo marca esa skill.
- `zotero-research-hub:*`: las referencias verificadas se pueden pasar a Zotero.
