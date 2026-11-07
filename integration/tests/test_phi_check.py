"""Tests automatizados de phi_check.py (TEST 9 parcial). Ejecutar:
    python3 -m unittest discover -s integration/tests -v
"""
import pathlib
import subprocess
import sys
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parents[2] / "skill/openevidence-research/scripts/phi_check.py"
sys.path.insert(0, str(SCRIPT.parent))
import phi_check  # noqa: E402


def run(text):
    return subprocess.run([sys.executable, str(SCRIPT), text], capture_output=True, text=True)


class CleanQueries(unittest.TestCase):
    CLEAN = [
        "In adults with fifth metatarsal fractures, is limb dominance associated with fracture incidence?",
        "Does diluted epinephrine in irrigation saline reduce bleeding during endoscopic spine surgery?",
        "In patients aged 60-80 years with lumbar stenosis, what is the reoperation rate at 2 years?",
        "Adrenalina 1:500000 en suero de irrigación en cirugía endoscópica de columna",
        "Dosis de 10 mg/kg de ácido tranexámico en artroplastia de cadera",
    ]

    def test_clean(self):
        for q in self.CLEAN:
            with self.subTest(q=q):
                self.assertEqual(phi_check.check(q), {})
                self.assertEqual(run(q).returncode, 0)


class IdentifiableQueries(unittest.TestCase):
    CASES = {
        "email": "Paciente con fractura, contacto juan.perez@gmail.com",
        "telefono": "Llamar al 612 345 678 para seguimiento",
        "dni_nie": "DNI 12345678Z con fractura de Jones",
        "fecha_concreta": "Intervenido el 03/04/2025 por estenosis",
        "historia_clinica": "NHC: 4455667, varón con fractura",
        "nombre_con_tratamiento": "Paciente María López con fractura del quinto metatarsiano",
        "iniciales_paciente": "Patient J.P. with Jones fracture",
        "direccion": "Vive en calle Mayor 3",
    }

    def test_detected(self):
        for cat, q in self.CASES.items():
            with self.subTest(cat=cat):
                self.assertIn(cat, phi_check.check(q))
                r = run(q)
                self.assertEqual(r.returncode, 1)
                # La salida no debe repetir el dato detectado
                self.assertNotIn("juan.perez", r.stdout)
                self.assertNotIn("12345678Z", r.stdout)

    def test_usage_error(self):
        r = subprocess.run([sys.executable, str(SCRIPT)], capture_output=True, text=True)
        self.assertEqual(r.returncode, 2)


if __name__ == "__main__":
    unittest.main()
