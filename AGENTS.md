# Notas del proyecto

## Rutas en código de R

El sitio es un proyecto Quarto de tipo website. El bloque `project` de `_quarto.yml` es:

```yaml
project:
  type: website
  output-dir: docs
  execute-dir: project
```

`execute-dir: project` solo afecta al código ejecutable: los paths en código de R son relativos a la raíz del proyecto, sin importar dónde esté el `.qmd`. Nunca usar `here::here()` ni funciones similares.

Los enlaces y las imágenes del texto (markdown o HTML) no dependen de `execute-dir`; se resuelven relativos al `.qmd`. Desde `slides/<nombre>/index.qmd` los archivos de `datos/` se enlazan con `../../datos/ejemplos/archivo`. La carpeta `datos/` está en `resources` de `_quarto.yml`, y Quarto la copia a `docs/datos/` al renderizar el proyecto completo.

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

## Documentos de materiales y datos de Perú

- **Documentos en `materiales/documentos/`:** `contexto-asistencia-tecnica` (misiones, logros, datos y secuencia), `contexto-huella-de-carbono-peru` (concepto, método, experiencias, insumos de energía y emisiones, IMF-MARIO), `insumo-producto-huella-peru` (huella de carbono de Perú con 8 sectores, 2019 a 2021) e `insumo-producto-peru-101` (modelo de 101 actividades con empleo, mismo método). Cada documento debe poder leerse sin los demás; los enlaces cruzados son opcionales. No renumerar secciones de la nota de huellas: otros documentos citan "sección 3.3", "5" o "6"; lo nuevo va como encabezado de cuarto nivel.
- **Misiones del FMI (informes en `refs/`):** julio de 2023 (diagnóstica, `tarea2024008`), febrero de 2025 (`tarea2025092`, informe emitido en octubre de 2025), octubre de 2025 (back-to-office report `BTO_Peru...`, interno) y octubre de 2026 (`TAR_CARBON FOOTPRINT...docx`). Son cuatro, no tres. El informe `tarea2025092` no es de la misión de octubre de 2025.
- **Cuentas del INEI:** los Excel oficiales están en `datos/per/` (`PERU_CUENTA_EXPERIMENTAL_DE_EMISIONES_AL_AIRE_2019-2021.xlsx` y `PERU_Cuenta_Experimental_de_los_Flujos_Fisicos_de_la_Energia_2019-2022.xlsx`). Los PDF de `refs/` son solo carátulas, sin cifras. Las cifras de los documentos se leen de esos Excel con R; no copiar números a mano. Claves bibliográficas: `inei2026emisiones` e `inei2026energia`. Las fechas difieren: carátula de setiembre de 2026, difusión el 13 de octubre de 2026 según el informe de misión.
- **Estructura del Excel de emisiones:** hoja `aea_1` (cuadro 4), filas de actividades en `A9:D18`, en toneladas de CO2 equivalente (CO2, CH4 y N2O; inventario INGEI 2000 a 2021 del MINAM). Las industrias no especificadas se suman a manufactura para obtener los 8 sectores de `Z`; los hogares van aparte. El PIB constante de 2007 está en `int_pbi_1`. El Excel de energía (terajulios) tiene `Ind_Kte1` (consumo por actividad) y tablas `D_<año>` (importaciones, exportaciones).
- **Huella de consumo:** `Huella = Territorial - EEE + EEI`, donde Territorial incluye las emisiones directas de los hogares. Estas no pasan por la matriz de Leontief ni se ajustan por importaciones; se suman a `CFHogaresAutoC` y `CFHogaresMercado`, repartidas en proporción a su demanda final (supuesto, no afecta el total). Las intensidades se dividen entre la producción nacional `q = x - m`, no entre `x` (la matriz de 101 es de uso total: las importaciones están dentro de `Z` y `f`). Las importaciones se valoran con tecnología nacional (DTA) y se separan con el supuesto de proporcionalidad `s = m / (x - ex)`. La estructura es la de 2007 y las emisiones son de 2019 a 2021, así que el ejercicio es didáctico y no oficial.
- **Matriz de 101 (`datos/per/PER_Modelo_Insumo_Producto.xlsx`, hoja `MIP_Basico_2007_Corrientes_101_`):** `Z` en `N12:DJ112`, demanda final `FDEM` (7 categorías: `CFHogaresAutoC`, `CFHogaresMercado`, `CFGobierno`, `ISFL`, `FBCF`, `VE`, `Exportaciones`) en `DN12:DT112`, producción en `D12:D112`, importaciones en `E12:E112` (celdas vacías son ceros), nombres de actividades en `Empleo!C1:CY1`. La correspondencia a 8 sectores está en `datos/ejemplos/correspondencia.xlsx`.
- **Verificación sin renderizar:** `knitr::purl()` del `.qmd` y correr el código en un entorno nuevo (el preámbulo hace `rm(list = ls())`), sin el chunk de exportación. Para chunks sueltos con `knitr::knit()`, fijar `knitr::opts_knit$set(root.dir = <raíz del proyecto>)`, porque `knit` cambia el directorio de trabajo. Las citas se comprueban con `pandoc --citeproc` y la bibliografía del documento.
- **IMF-MARIO:** versión 0 en validación (octubre de 2026), 212 economías, 179 productos, 145 industrias, 1990 a 2023, acceso controlado. Fuentes: `refs/IMF-MARIO_PAPER_2025.pdf` (`guilhoto2025`) y la presentación del taller Eurostat-FMI-CML del 1 de octubre de 2026 (`pegoue2026`).
- **Cuadros de oferta y utilización 2024 (`refs/`):** dos archivos por año. `matrizprod<año>_corrientes_365_prod_x_101_activ.xlsx` (hoja `MPro`, `V` a precios básicos, productos en filas `D8:CZ372`) y `PER_<año>_ corr.xlsx` (hoja `Tip`, nombre con espacio: oferta `D11:L375`, utilización a precios de comprador `O11:DK375`, demanda final `DO11:DU375`, valor agregado fila 377). Cuadran entre sí; los códigos de actividad coinciden con la matriz de 2007. Una prueba en memoria mostró que márgenes, `r` y `s`, `B`, `D` y `T` funcionan y que oferta nacional = utilización nacional + demanda final por producto. La rutina no está implementada; el diseño y las decisiones pendientes están en la subsección `#rutina-rectangular` de `contexto-asistencia-tecnica`.
