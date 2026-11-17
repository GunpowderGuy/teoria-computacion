# Contexto de trabajo

El usuario estudia teoría de la computación y está resolviendo ejercicios sobre pertenencia a NP, verificadores polinomiales, certificados, decididores no deterministas y reducciones polinomiales.

Responder en español y ser sucinto cuando el usuario lo pida. Antes de revisar un ejercicio, leer la versión actual del archivo porque el usuario lo edita entre mensajes. Distinguir con precisión entre reconocedor, decididor, verificador determinista y máquina no determinista.

## Archivos

- `federMartes.txt`: notas y pruebas que el usuario modifica activamente.
- `ejercicios-examen3.pdf`: lista de ejercicios. La sección “Tratabilidad”, página 3, contiene los lenguajes y el ejercicio 5 pide demostrar que están en NP.
- `Introduction to the Theory of Computation 3rd Edition.pdf`: libro de Michael Sipser. La sección 7.3 explica verificadores y NP: páginas 293–297 del libro, páginas 317–321 del PDF. La definición 7.18 define verificador; la 7.19 define NP; el teorema 7.20 relaciona NP con decididores no deterministas polinomiales.
- `tiempo-polinomial.txt`: resumen sobre tiempo polinomial, factorial, números triangulares y tamaño de entradas numéricas.

## Estado de los ejercicios en `federMartes.txt`

- **LCUAD:** la idea del verificador con certificado `x0` y la comprobación `x0^2 = n` es correcta. El certificado tiene tamaño polinomial. Probar todos los números hasta el valor `n` no es polinomial respecto de la longitud binaria de la entrada.
- **LEC-2-GRADO:** el cálculo del verificador es correcto, pero la notación mezcla `x` y `x0`. Todavía conviene definir formalmente el lenguaje y justificar el tamaño polinomial del certificado.
- **LCOMPUESTO:** el verificador actual con dos divisores `y,z`, todos distintos y positivos, y el rechazo de `x=0`, es correcto. También puede simplificarse a un solo certificado `d` con `1 < d < x` y `d | x`. El usuario observó que Sipser no explicita que el divisor debe ser no trivial y considera esa omisión una sobresimplificación.
- **LFACTOR:** en el archivo del usuario, la definición actual busca `p` tal que `1 < p < n` y `p | m`. Esto difiere del PDF de ejercicios, donde se busca `1 < p < m` y `p | n`; no intercambiar estas condiciones al revisar. La prueba actual usa un decididor no determinista que adivina `P0`, con `1 < P0 < N`, y comprueba si divide a `M`. Al final del archivo ya se añadió la justificación de corrección, tamaño del certificado y tiempo polinomial.

## Al revisar nuevas pruebas

- Comprobar aceptación exacta: toda entrada del lenguaje debe tener una rama o certificado aceptado, y ninguna entrada fuera del lenguaje debe ser aceptada.
- Verificar que todos los pasos sean polinomiales en la longitud de la entrada y que los certificados tengan longitud polinomial.
- Recordar que una demostración de pertenencia a NP no demuestra NP-completitud; para NP-completitud también se necesita una reducción polinomial desde un lenguaje NP-completo.
- No sobrescribir las notas del usuario ni cambiar sus definiciones salvo que lo solicite.
