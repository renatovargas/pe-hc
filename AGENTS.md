# Notas del proyecto

## Rutas en código de R

El archivo `_quarto.yml` del sitio define `execute-dir: project`. Los paths en código de R son relativos a la raíz del proyecto. Nunca usar `here::here()` ni funciones similares.

## Lenguajes

Todo el proyecto usa solo R. Nunca crear herramientas auxiliares en Python.

## Estilo de prosa

- Nunca usar rayas largas (em dashes) ni oraciones que las necesiten.
- Preferir oraciones declarativas. Si se necesita una subordinada, usar punto y coma, comas o dos puntos.
- Nunca usar la construcción "No es X, es Y" ni sus derivados.
