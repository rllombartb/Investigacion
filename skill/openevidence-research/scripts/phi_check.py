#!/usr/bin/env python3
"""Detector heurístico de posibles datos identificables en una consulta clínica.

Uso:
    python3 phi_check.py "texto de la consulta"
    echo "texto" | python3 phi_check.py -

Salida:
    0  -> no se detectan identificadores
    1  -> posibles identificadores (se listan por categoría, sin repetir el texto)
    2  -> error de uso

Es una red de seguridad, no una garantía: la revisión humana/modelo manda.
No escribe nada en disco ni en red.
"""
from __future__ import annotations

import re
import sys

PATTERNS: dict[str, re.Pattern[str]] = {
    "email": re.compile(r"[\w.+-]+@[\w-]+\.[\w.-]+"),
    "telefono": re.compile(r"(?<!\d)(?:\+?34[\s.-]?)?[6789]\d{2}[\s.-]?\d{3}[\s.-]?\d{3}(?!\d)"),
    "dni_nie": re.compile(r"\b(?:\d{8}[A-HJ-NP-TV-Z]|[XYZ]\d{7}[A-HJ-NP-TV-Z])\b", re.I),
    "nuss_tarjeta_sanitaria": re.compile(r"\b\d{2}[\s/-]?\d{8}[\s/-]?\d{2}\b"),
    "fecha_concreta": re.compile(
        r"\b(?:\d{1,2}[/.-]\d{1,2}[/.-]\d{2,4}|\d{4}-\d{2}-\d{2}"
        r"|\d{1,2}\s+de\s+(?:enero|febrero|marzo|abril|mayo|junio|julio|agosto|"
        r"septiembre|setiembre|octubre|noviembre|diciembre)(?:\s+de\s+\d{4})?)\b",
        re.I,
    ),
    "historia_clinica": re.compile(
        r"\b(?:NHC|N\.?\s?H\.?\s?C\.?|historia\s+cl[ií]nica|MRN|medical\s+record)"
        r"\s*(?:n[ºo°.]?\s*)?[:#]?\s*\d+",
        re.I,
    ),
    "id_numerico_largo": re.compile(r"\b\d{7,}\b"),
    "nombre_con_tratamiento": re.compile(
        r"\b(?i:paciente|patient|sr\.?|sra\.?|don|doña|d\.|dña\.|mr\.?|mrs\.?|ms\.?)\s+"
        r"[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)?"
    ),
    "iniciales_paciente": re.compile(r"\b(?:paciente|patient)\s+[A-Z]\.\s?[A-Z]\.", re.I),
    "direccion": re.compile(
        r"\b(?:calle|c/|avda\.?|avenida|plaza|paseo|street|st\.|avenue)\s+\S+", re.I
    ),
    "codigo_postal_es": re.compile(r"\b(?:0[1-9]|[1-4]\d|5[0-2])\d{3}\b(?=\s+[A-ZÁÉÍÓÚ])"),
}


def check(text: str) -> dict[str, int]:
    """Devuelve {categoria: nº de coincidencias} para categorías con coincidencias."""
    found: dict[str, int] = {}
    for name, pattern in PATTERNS.items():
        n = len(pattern.findall(text))
        if n:
            found[name] = n
    return found


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print(__doc__.strip().splitlines()[2], file=sys.stderr)
        return 2
    text = sys.stdin.read() if argv[1] == "-" else argv[1]
    found = check(text)
    if not found:
        print("phi_check: OK (sin identificadores detectados)")
        return 0
    print("phi_check: POSIBLES IDENTIFICADORES -> anonimizar antes de continuar")
    for name, n in found.items():
        print(f"  - {name}: {n}")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
