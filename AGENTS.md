# Notas del proyecto

## Rutas en código de R

El archivo `_quarto.yml` del sitio define `execute-dir: project`. Los paths en código de R son relativos a la raíz del proyecto. Nunca usar `here::here()` ni funciones similares.

## Entorno de trabajo

El sandbox de bash solo permite escribir dentro del proyecto y en `$TMPDIR`; no se puede escribir en `/tmp` ni usar heredocs. Para editar archivos usar las herramientas `edit` o `write`, o `perl -pi` dentro del proyecto.

## Lenguajes

Todo el proyecto usa solo R. Nunca crear herramientas auxiliares en Python.

## Estilo de prosa

- Nunca usar rayas largas (em dashes) ni oraciones que las necesiten.
- Preferir oraciones declarativas. Si se necesita una subordinada, usar punto y coma, comas o dos puntos.
- Nunca usar la construcción "No es X, es Y" ni sus derivados.

## Presentaciones (revealjs)

Las presentaciones viven en `slides/` (las páginas que las embeben viven en `materiales/presentaciones/`) y usan el tema `slides/pstyles.scss` (colores nombrados `$theme-IMF*`, footer de tres columnas con marca, texto del YAML y autor). Cada presentación vive en su propia carpeta (`slides/<nombre>/index.qmd`, con su `images/` y su `refs.bib`) y referencia el tema como `../pstyles.scss`. Las existentes son `01-intro-algebra`, `02-modelo-insumo-producto`, `03-extension-ambiental` y `04-matrices-rectangulares` (emisiones de CO2, multiplicadores, matrices `M_e` y `G`); la 01 sirve de referencia de abordaje. El contenido de cada una sale del script de `refs/modulo_NN.R`, cuyos comentarios se aprovechan como texto de las diapositivas explicativas.

- **Renderizado:** `docs/` es salida generada. No renderizar el proyecto sin que el usuario lo pida; él renderiza y revisa en pantalla. Los cambios visuales (tamaños, anchos, altura de diapositivas) quedan sin verificar hasta que lo haga.
- **MathJax:** Quarto carga MathJax 2.7.9 en revealjs (clase `.MathJax`, no `mjx-container`). No forzar `font-size` de las fórmulas con CSS: rompe el espaciado con el texto vecino. La escala se define en el YAML de la presentación con `include-in-header` (`window.MathJax = { "HTML-CSS": { scale: 80 } }`); ajustar solo ese número.
- **Recursos referenciados desde el CSS:** el logo `imf-statistics-logo.svg` y el estilo de citas viven en `assets/`, y la carpeta `assets/` está en `resources` de `_quarto.yml`. Quarto copia los recursos a `docs/` solo al renderizar el proyecto completo, no al renderizar un solo archivo. La ruta en el scss (`../../../../assets/imf-statistics-logo.svg`) es relativa al CSS compilado en `docs/site_libs/revealjs/dist/theme/`.
- **Citas y bibliografía:** cada presentación usa `bibliography: refs.bib` (en su carpeta), `csl: ../../assets/apa-es.csl` (APA 7 en español) y `lang: es`, que hace falta para que salgan "y" y "3.ª ed." en vez de "&" y "3rd ed.". Las citas en el texto son `[@millerblair2022]`; no escribir "(Miller & Blair, 2022)" a mano. La diapositiva de bibliografía contiene solo `::: {#refs}` y `:::`, para que Quarto coloque ahí la lista y no genere una diapositiva aparte. Las rutas de `bibliography` y `csl` son relativas al `.qmd`.
- **Footer:** Quarto fija `.reveal .footer` con `position: fixed; width: 100%`. Como el tema le agrega `padding` lateral, necesita `box-sizing: border-box`; sin eso la barra desborda a la derecha y se corta la tercera columna (el autor, en `&::after`, con `$theme-IMFgrey`). Las columnas son `15% 70% 15%`.
- **Vínculos internos:** usar el id directo, `[texto](#suma)`, sin `/`, y fijar ids explícitos en el título (`## Suma {#suma}`).
- **Estructura de las diapositivas de operaciones:** dos columnas con `[Notación]{.emphasis}`, `[En Excel]{.emphasis}` y `[En R]{.emphasis}`. Las capturas de Excel son imágenes `images/paste-N.png` o texto de marcador, sin div envolvente (se quitó `::: captura`; la regla `.captura` del scss quedó sin uso). Cuando un tema necesita explicación, se separa en una diapositiva de texto y otra "en la práctica".
- **Marcadores de captura de Excel:** el usuario sabe dónde están los ejemplos en el Excel de referencia y toma las capturas él. En la columna "En Excel" que aún no tiene imagen se escribe solo "Insertar captura de pantalla de Excel aquí." (sin notas de ubicación en la hoja).
- **Colores de matrices (presentación 02):** `Z` verde `#B5E6A2`, `f` rosa `#F2CEEF`, `x` azul `#A6C9EC`, `L` naranja claro `#F7C7AC`. En texto y tablas se usan las clases `.bg-Z`, `.bg-f`, `.bg-x` y `.bg-L` de `pstyles.scss` (`[$\mathbf{Z}$]{.bg-Z}`, `[150]{.bg-Z}` en celdas de tabla). En fórmulas se usa `\bbox[#B5E6A2,3px]{\mathbf{Z}}` escrito de forma literal. En los cuadros de flujos, `x` también va en azul en la fila de totales de insumos (`x'`) y se omiten las sumas redundantes (columna "Producto total" de las filas de pagos a factores y de totales). Las frases que presentan un símbolo ("el elemento $z_{ij}$ de la matriz Z muestra...") van sobre las columnas, no dentro de una.
- **MathJax 2, trampas:** (1) No definir `Macros` con colores hexadecimales en el YAML: el `#` de `#A6C9EC` se lee como parámetro de macro y la fórmula se renderiza como código fuente en un recuadro. Escribir el `\bbox` literal. (2) `\hat{\mathbf{x}}` sale corrido a la derecha; se usa `\widehat{...}` y, con color, el acento va dentro del bbox: `\bbox[#A6C9EC,3px]{\widehat{\mathbf{x}}}`. Ambos arreglos están sin verificar visualmente; la presentación 01 todavía usa `\hat`.
- **Derivaciones:** cuando una demostración tiene pasos que se saltan (por ejemplo la matriz de Leontief), se separa en varias diapositivas de texto con cada paso justificado: planteamiento, despeje y interpretación.
- **Terminología:** "Suma" y "sustracción"/"Resta" (no "Adición"). El vector de ejemplo en R se llama `c`; se conserva ese nombre.

## Contenido matemático y de R/Excel

- **Referencia:** Miller & Blair (2022), *Input-Output Analysis: Foundations and Extensions*, 3.ª ed., Cambridge University Press, DOI 10.1017/9781108676212 (clave `millerblair2022` en `refs.bib`; datos contrastados con Crossref). Las definiciones en las diapositivas son paráfrasis, no citas textuales, y no se han contrastado con el libro. Verificar antes de añadir sección o página.
- **Matriz de ejemplo:** `M` (2×3) = [2 1 3; 4 6 12], `N` = [1 2 3; 3 2 1], `Q` (3×3) = [2 0 4; 1 1 2; 3 4 5], `A` = [2 1; 5 3], `b` = (10, 26), inversa de `A` = [3 -1; -5 2], solución x = (4, 2). Todos los resultados mostrados están verificados a mano.
- **Igualdad en R:** `isTRUE(M == N)` da `FALSE` aunque las matrices sean iguales, porque `==` devuelve una matriz lógica. Usar `all(M == N)` para valores, `identical()` para igualdad exacta (incluye tipo y atributos) y `isTRUE(all.equal())` para decimales.
- **Excel en español:** las fórmulas usan nombres en español (`Y`, `SUMAPRODUCTO`, `FILAS`, `COLUMNAS`, `TRANSPONER`, `MINVERSA`). Las operaciones matriciales se seleccionan con el rango del resultado y se confirman con CTRL + ENTER.
- **Inversa a mano:** el método es eliminación de Gauss-Jordan sobre la matriz ampliada [A | I] de n × 2n (no el método simplex, que es de programación lineal).

## Matrices rectangulares y pipeline de datos (presentación 04)

- **Contexto del proyecto:** la misión en Perú parte de sus cuentas de energía y emisiones de CO2 y apunta a la huella de carbono. Los cuadros reales están en `refs/COU_2019_PRECIOSCORRIENTES_365x101.xls.xlsx` (aún no explorados). La 04 es teoría con el ejercicio de juguete de `refs/7a Environmental Extenstions Exercise.xlsx`; el paper `refs/LPR_Vargas.tex` (secciones 4.1.1 a 4.2) es la fuente del método.
- **Notación de la 04:** `U` utilización (productos × industrias), `V` producción (industrias × productos), `f` demanda final (como en la 02; `e` queda para emisiones, como en la 03), `x` producto por industria, `q` producto por producto, `B = U x̂^-1`, `D = V q̂^-1`, `T = (I - DB)^-1 D` (5 × 8 en el ejemplo; en R se llama `Treq`). El Excel del colega usa `g` para `x`.
- **Orden de la preparación de los cuadros reales:** (1) márgenes de comercio y transporte, que pasan a filas de servicios; (2) importaciones competitivas e impuestos, con las fracciones `r` y `s` (`U = Ũ - r̂Ũ - ŝŨ`, igual para `f`); (3) importaciones no competitivas como industria sin insumos; (4) verificar balances. Los pasos 1 y 2 no se han implementado en R.
- **Controles que el pipeline debe correr:** `q = V'i = Ui + f` por producto y `x = Vi = colSums(U) + va` por industria; `colSums(D) == 1`. Si no cuadran, no seguir. En el ejercicio del colega no cuadraban (hierro en `V` y demanda final de combustible); se corrigieron a `V[minas, hierro] = 100` y `f[combustible] = 600`, pendiente de confirmar con él.
- **Trampas de R:** `%*%` y `diag()` descartan los nombres de filas y columnas, así que reasignar `dimnames` tras cada producto matricial. `diag()` de una matriz de una columna extrae la diagonal; usar `diag(c(x))`. Verificar calibración con `isTRUE(all.equal(...))`, no con `==`.
- **Multiplicadores:** salen por producto demandado (columnas de `T`), no por industria. Productos fabricados por la misma industria tienen el mismo multiplicador (acero y autos). Con el vector `epsilon` de coeficientes por industria (el mismo símbolo, \varepsilon, que en la presentación 03): directo `epsilon'D`, total `epsilon'T`.
- **Cita SNA:** `sna2009` en `refs.bib` usa a United Nations como autor único (cita corta) y lista a los demás organismos en `note`; datos de la entrada tomados del registro que dio el usuario.
