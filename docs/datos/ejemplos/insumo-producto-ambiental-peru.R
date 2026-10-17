# Insumo-producto y huella de carbono con la MIP de Perú, 2007
# Renato Vargas
# Economista / Analista de Datos
# https://renatovargas.com/

# Este script reúne dos ejercicios con la matriz de 101 productos de 2007:
# (1) el ejercicio grande (101 x 101) con intensidades de empleo, y
# (2) el ejercicio pequeño (8 x 8) con emisiones de CO2 de 2019 a 2021 y
# ajuste por importaciones y exportaciones. Ambos usan Z, f y x.
# El texto completo está en
# materiales/documentos/insumo-producto-huella-peru/index.qmd
# Las rutas son relativas a la raíz del proyecto.


# === Preámbulo ===


# Limpiar el área de trabajo
rm(list = ls())

# Cargar librerías
library(readxl)    # leer los datos de Excel
library(tidyverse) # manipular datos
library(gt)        # tablas
library(openxlsx)  # exportar resultados a Excel

# Para que las tablas del documento sean legibles, definimos una función que
# las muestra con gt(). Los nombres de los ocho sectores agregados son
# largos, así que en las tablas las filas se abrevian con las etiquetas de la
# siguiente lista y las columnas solo con el número. La función no modifica
# los datos, solo cambia cómo se muestran.

cortos <- c(
  "01 Agricultura", "02 Minería", "03 Manufactura", "04 Electricidad",
  "05 Agua y saneamiento", "06 Construcción", "07 Transporte", "08 Servicios"
)

# Abrevia los nombres de los sectores agregados (empiezan con "01_" a "08_")
acortar <- function(nombres) {
  ifelse(
    grepl("^0[1-8]_", nombres),
    cortos[as.integer(substr(nombres, 1, 2))],
    nombres
  )
}

tabla_gt <- function(x, digitos = 0) {
  x <- as.data.frame(x)
  rownames(x) <- acortar(rownames(x))

  # En las columnas solo se deja el número del sector, para que quepan
  es_sector <- grepl("^0[1-8]_", names(x))
  names(x)[es_sector] <- substr(names(x)[es_sector], 1, 2)

  tabla <- x |>
    gt(rownames_to_stub = TRUE) |>
    fmt_number(decimals = digitos, use_seps = TRUE) |>
    tab_options(table.font.size = "small")

  if (any(es_sector)) {
    tabla <- tabla |>
      tab_source_note("Las columnas se identifican con el número del sector de las filas.")
  }
  tabla
}


# Lectura de los datos

# La hoja de la matriz tiene los 101 productos en filas y columnas, la
# demanda final por categoría a la derecha y, debajo de la matriz, filas con
# el empleo y otros coeficientes. Como vamos a leer varios rangos, definimos
# una función corta que devuelve una matriz sin nombres, y fijamos el archivo
# y la hoja. Las rutas son relativas a la raíz del proyecto.

archivo <- "datos/per/PER_Modelo_Insumo_Producto.xlsx"
hoja <- "MIP_Basico_2007_Corrientes_101_"

leer_rango <- function(rango, hoja_excel = hoja) {
  as.matrix(
    read_excel(
      archivo,
      sheet = hoja_excel,
      range = rango,
      col_names = FALSE,
      .name_repair = "minimal"
    )
  )
}

# Los nombres de los 101 productos están en el encabezado de la pestaña
# Empleo. Con ellos rotulamos filas y columnas de Z y las filas de la demanda
# final.

sectores <- c(leer_rango("C1:CY1", hoja_excel = "Empleo"))
length(sectores)
head(sectores, 3)

# La matriz de flujos Z es de 101 x 101. La demanda final viene desagregada
# en siete categorías (FDEM), con los mismos productos en las filas.

# Matriz de flujos intermedios Z (101 x 101)
Z <- leer_rango("N12:DJ112")
dimnames(Z) <- list(sectores, sectores)

# Demanda final por categoría (101 x 7)
categorias <- c(leer_rango("DN11:DT11"))
FDEM <- leer_rango("DN12:DT112")
dimnames(FDEM) <- list(sectores, categorias)

dim(Z)
dim(FDEM)
categorias

# El empleo directo de cada producto está en la fila 154 de la hoja:
# asalariados más empresarios individuales, sin ayudantes familiares. Lo
# comprobamos sumando las dos filas que lo componen.

empleo <- c(leer_rango("N154:DJ154"))
names(empleo) <- sectores

# Asalariados de la propia empresa (fila 145) más empresarios individuales (150)
isTRUE(all.equal(
  unname(empleo),
  c(leer_rango("N145:DJ145")) + c(leer_rango("N150:DJ150"))
))


# El modelo básico

# La demanda final total f es la suma de las categorías de cada producto. El
# producto total x es lo que se vende a otros sectores más la demanda final.

f <- rowSums(FDEM)
x <- rowSums(Z) + f

# Con x calculamos los coeficientes técnicos A = Zdiag(x)^-1 y la matriz de
# Leontief L = (I - A)^-1. El producto matricial descarta los nombres de
# filas y columnas, así que los reasignamos.

A <- Z %*% solve(diag(x))
L <- solve(diag(nrow(A)) - A)
dimnames(A) <- dimnames(L) <- list(sectores, sectores)

# Una comprobación básica: Lf debe devolver el producto total.

isTRUE(all.equal(c(L %*% f), x, check.attributes = FALSE))


# Intensidades de empleo

# La intensidad epsilon_i es el empleo directo por unidad de producto del
# sector i. Como son puestos por millón de soles de 2007, las cifras son del
# orden de decenas o cientos. La hoja de Excel trae el mismo cálculo en la
# fila 160, que usamos para contrastar.

epsilon <- empleo / x

# Contraste con el "Coeficiente de empleo" de la hoja (fila 160)
isTRUE(all.equal(
  unname(epsilon),
  c(leer_rango("N160:DJ160"))
))

tabla_gt(head(cbind(Intensidad = epsilon)), digitos = 1)


# Empleo a partir de la demanda final

# Si multiplicamos las intensidades por el producto que se necesita para
# satisfacer la demanda final, recuperamos el empleo directo de cada sector:
# e = diag(epsilon)Lf.

e <- diag(epsilon) %*% L %*% f
rownames(e) <- sectores
colnames(e) <- "Empleo"

isTRUE(all.equal(c(e), unname(empleo)))


# Multiplicadores

# El multiplicador de producto de cada sector es la suma de su columna de L.
# Indica cuánto producto total se genera por cada unidad de demanda final de
# ese producto.

i <- rep(1, nrow(L))
mp <- c(i %*% L)
names(mp) <- sectores
tabla_gt(head(cbind(Multiplicador = mp)), digitos = 2)

# El multiplicador de empleo sigue la misma idea: M_e = diag(epsilon)L. Cada
# columna j muestra el empleo que se genera en cada sector por una unidad de
# demanda final del producto j, y su suma es el multiplicador de empleo total
# de ese producto.

Me <- diag(epsilon) %*% L
dimnames(Me) <- list(sectores, sectores)

# Multiplicador de empleo total por producto demandado
mult_empleo <- colSums(Me)
tabla_gt(head(cbind(`Multiplicador de empleo` = mult_empleo)), digitos = 1)


# Empleo total según el producto demandado

# Al multiplicar M_e por la demanda final de cada producto, repartimos el
# empleo total entre los productos que lo originan. La suma de todo el vector
# es el empleo total del cuadro.

huella_producto <- c(epsilon %*% L %*% diag(f))
names(huella_producto) <- sectores

sum(huella_producto)
sum(empleo)


# Empleo diferenciado por categoría de demanda final

# Como el modelo es lineal, podemos reemplazar el vector f por la matriz
# completa FDEM. Cada columna del resultado es el vector e de una categoría
# de demanda final (hogares, gobierno, inversión, exportaciones, etc.). El
# resultado tiene los sectores en las filas (101) y las categorías en las
# columnas (7).

e_categoria <- diag(epsilon) %*% L %*% FDEM
dimnames(e_categoria) <- list(sectores, categorias)

# La suma de las categorías reproduce el vector e
isTRUE(all.equal(rowSums(e_categoria), c(e), check.attributes = FALSE))

# Finalmente, el empleo total por categoría y su participación en el total.

tibble(
  Categoría = categorias,
  Empleo = colSums(e_categoria),
  `Participación (%)` = round(100 * Empleo / sum(Empleo), 1)
) |>
  gt() |>
  fmt_number(columns = Empleo, decimals = 0, use_seps = TRUE) |>
  fmt_number(columns = `Participación (%)`, decimals = 1)

# Guardamos los resultados que vamos a exportar, porque en el ejercicio
# pequeño reutilizaremos los nombres Z, f y x.

res_101 <- list(
  "101_Z" = Z,
  "101_FDEM" = FDEM,
  "101_f_x" = data.frame(f = f, x = x),
  "101_A" = A,
  "101_L" = L,
  "101_empleo_intensidad" = data.frame(
    empleo = empleo,
    x = x,
    epsilon = epsilon,
    mult_producto = mp,
    mult_empleo = mult_empleo,
    empleo_por_producto_dem = huella_producto
  ),
  "101_Me" = Me,
  "101_empleo_categoria" = e_categoria
)


# Importaciones y exportaciones en la matriz de 101

# Las importaciones por producto están en la columna E de la hoja (celdas
# E12:E112) y las exportaciones son la última columna de FDEM. Las celdas
# vacías de importaciones son ceros. Antes de usarlas, conviene verificar un
# detalle de la hoja: la columna D trae la producción nacional, y la suma de
# producción e importaciones coincide con el producto total x que calculamos
# con Z y f.

m <- c(leer_rango("E12:E112"))
m[is.na(m)] <- 0
names(m) <- sectores

produccion <- c(leer_rango("D12:D112"))

# x es producción nacional más importaciones
isTRUE(all.equal(unname(produccion + m), unname(x)))
c(importaciones = sum(m), produccion = sum(produccion), x = sum(x))

ex <- FDEM[, "Exportaciones"]


# Separar el uso de origen nacional del importado

# La hoja no dice qué parte de cada compra es importada. Usamos el supuesto
# habitual de proporcionalidad: cada usuario (industrias, hogares, gobierno,
# inversión) compra un producto con la misma proporción de importaciones. La
# proporción del producto i es s_i = m_i / (x_i - ex_i), es decir, las
# importaciones entre el uso interno total (las exportaciones no usan
# importaciones en este supuesto). Con s separamos Z y la demanda final en
# una parte nacional y otra importada.

s <- m / (x - ex)
summary(s)

# Cada fila i se multiplica por (1 - s_i), o por s_i
Zd <- (1 - s) * Z
Zm <- s * Z

FDEMd <- (1 - s) * FDEM
FDEMm <- s * FDEM
# Las exportaciones son producción nacional
FDEMd[, "Exportaciones"] <- ex
FDEMm[, "Exportaciones"] <- 0

# Las importaciones se reparten completamente entre usos
isTRUE(all.equal(
  unname(rowSums(Zm) + rowSums(FDEMm)),
  unname(m)
))

res_101[["101_importaciones"]] <- data.frame(
  produccion = produccion, m = m, ex = ex, x = x, s = s
)


# Agregación de la matriz

# La cuenta de emisiones al aire reporta ocho categorías, así que agregamos
# los 101 productos a esos mismos ocho sectores. La tabla de correspondencia
# asigna cada producto a un sector agregado (new_name). Antes de usarla,
# verificamos que sus códigos coincidan uno a uno con los de nuestros 101
# productos.

correspondencia <- read_excel(
  "datos/ejemplos/correspondencia.xlsx",
  sheet = "correspondencia",
  range = "E1:F102",
  col_names = TRUE
)

# Los primeros seis caracteres son el código de actividad
all(substr(sectores, 1, 6) == substr(correspondencia$old_name, 1, 6))

correspondencia |>
  count(new_name, name = "Productos") |>
  rename(`Sector agregado` = new_name) |>
  gt()

# Para agregar sumamos las filas de cada grupo con rowsum(); en las matrices
# cuadradas repetimos la operación sobre las columnas (con la transpuesta).
# La demanda final solo se agrega por filas. Agregamos con la misma función
# la matriz total y sus partes nacional e importada.

grupo <- correspondencia$new_name

agregar_Z <- function(M) t(rowsum(t(rowsum(M, grupo)), grupo))

Z <- agregar_Z(Z)
Zd <- agregar_Z(Zd)
Zm <- agregar_Z(Zm)

FDEM <- rowsum(FDEM, grupo)
FDEMd <- rowsum(FDEMd, grupo)
FDEMm <- rowsum(FDEMm, grupo)

# Vectores: drop() conserva los nombres de los sectores
m <- drop(rowsum(m, grupo))
ex <- FDEM[, "Exportaciones"]

dim(Z)
dim(FDEM)

# Comprobamos que la agregación conserva los totales y que las partes
# nacional e importada suman la matriz total.

c(
  Z = isTRUE(all.equal(sum(Z), sum(res_101[["101_Z"]]))),
  FDEM = isTRUE(all.equal(sum(FDEM), sum(res_101[["101_FDEM"]]))),
  m = isTRUE(all.equal(sum(m), sum(res_101[["101_importaciones"]]$m))),
  Z_partes = isTRUE(all.equal(Z, Zd + Zm)),
  FDEM_partes = isTRUE(all.equal(FDEM, FDEMd + FDEMm))
)


# El modelo básico en 8 x 8

# Mantenemos los nombres Z, f y x para la versión de uso total. A ellos
# agregamos la producción nacional q = x - m y las matrices de coeficientes:
# A^d (insumos nacionales por unidad de producción nacional) y A^m (insumos
# importados por unidad de producción nacional). Con A^d obtenemos la matriz
# de Leontief nacional L^d = (I - A^d)^-1.

sectores <- rownames(Z)

f <- rowSums(FDEM)
x <- rowSums(Z) + f
q <- x - m

Ad <- Zd %*% solve(diag(q))
Am <- Zm %*% solve(diag(q))
Ld <- solve(diag(nrow(Ad)) - Ad)
dimnames(Ad) <- dimnames(Am) <- dimnames(Ld) <- list(sectores, sectores)

# La producción nacional cubre el uso interno de origen nacional y las exportaciones
isTRUE(all.equal(c(Ld %*% rowSums(FDEMd)), q, check.attributes = FALSE))

# La matriz Z agregada y los vectores de oferta y uso (en millones de soles
# de 2007):

tabla_gt(Z)

cbind(
  f = f, x = x, m = m, q = q, ex = ex,
  `s (%)` = 100 * m / (x - ex)
) |>
  tabla_gt(digitos = 1)


# Emisiones directas de 2019 a 2021

# El archivo de la cuenta de emisiones trae una fila por año y una columna
# por sector. La última columna no tiene encabezado en el archivo; por su
# posición corresponde a los servicios, el octavo sector, así que rotulamos
# todas las columnas con los nombres de Z después de verificar que los siete
# primeros coincidan.

emisiones <- read_excel("datos/per/PER_Cuenta_Emisiones_2019-2021.xlsx")

stopifnot(all(names(emisiones)[2:8] == sectores[1:7]))
names(emisiones)[2:9] <- sectores

# Matriz de 8 sectores (filas) por 3 años (columnas)
E <- t(as.matrix(emisiones[, -1]))
colnames(E) <- emisiones$Año
tabla_gt(E)


# Intensidades de emisiones

# Cada columna de epsilon es el vector de intensidades de un año: emisiones
# directas del sector divididas entre su producción nacional q. Por la regla
# de reciclaje de R, dividir la matriz E entre q divide cada columna elemento
# por elemento.

epsilon <- E / q
tabla_gt(epsilon, digitos = 1)


# Importaciones por categoría de demanda final

# Para atribuir las importaciones a cada categoría de demanda final sumamos
# dos partes: la importada directamente en la compra final (FDEMm) y la
# importada como insumo de la producción nacional que atiende esa categoría,
# A^mL^dF^d. Para las exportaciones, la segunda parte son los insumos
# importados que se reexportan incorporados. Las columnas suman el vector de
# importaciones m.

FDEMimp <- FDEMm + Am %*% Ld %*% FDEMd
dimnames(FDEMimp) <- dimnames(FDEM)

isTRUE(all.equal(unname(rowSums(FDEMimp)), unname(m)))

# Importaciones destinadas al uso interno (sin las incorporadas en exportaciones)
m_uso <- rowSums(FDEMimp[, colnames(FDEM) != "Exportaciones"])


# Huella de carbono por año

# Para cada año calculamos tres cosas con la tecnología nacional: Recorremos
# los tres años con lapply() y guardamos un resultado por año. El
# multiplicador de emisiones M_e = diag(epsilon)L^d también se guarda.

anios <- colnames(epsilon)

resultados <- lapply(
  setNames(anios, anios),
  function(anio) {
    eps <- epsilon[, anio]

    Me <- diag(eps) %*% Ld
    dimnames(Me) <- list(sectores, sectores)

    interno <- c(eps %*% Ld %*% FDEMd)
    importado <- c(eps %*% Ld %*% FDEMimp)
    names(interno) <- names(importado) <- colnames(FDEM)

    # Emisiones por sector emisor y categoría (solo parte interna)
    sector_categoria <- Me %*% FDEMd
    dimnames(sector_categoria) <- dimnames(FDEM)

    list(
      Me = Me,
      mult_emisiones = colSums(Me),
      interno = interno,
      importado = importado,
      sector_categoria = sector_categoria,
      EEE_producto = c(eps %*% Ld %*% diag(ex)),
      EEI_producto = c(eps %*% Ld %*% diag(m_uso))
    )
  }
)

# Con estos resultados armamos el balance de cada año y verificamos la
# identidad: las emisiones nacionales que provoca toda la demanda final
# (interna y exportaciones) reproducen las emisiones territoriales, y la
# huella de consumo es igual a emisiones territoriales menos EEE más EEI.

balance <- map_dfr(
  anios,
  function(anio) {
    r <- resultados[[anio]]
    interna <- colnames(FDEM) != "Exportaciones"
    tibble(
      Año = anio,
      Territorial = sum(E[, anio]),
      EEE = sum(r$EEE_producto),
      EEI = sum(r$EEI_producto),
      Huella = sum(r$interno[interna] + r$importado[interna]),
      Saldo = EEI - EEE,
      Diferencia = 100 * (Huella / Territorial - 1)
    )
  }
)

# Las emisiones nacionales de toda la demanda final reproducen las territoriales
sapply(anios, function(anio) isTRUE(all.equal(sum(resultados[[anio]]$interno), sum(E[, anio]))))

# La huella cumple la identidad
isTRUE(all.equal(balance$Huella, balance$Territorial - balance$EEE + balance$EEI))


# Resultados

# El balance de cada año, en millones de las unidades de la cuenta de
# emisiones. La última columna compara la huella de consumo con las emisiones
# territoriales.

balance |>
  gt() |>
  cols_label(
    Saldo = "EEI - EEE",
    Diferencia = "Dif. (%)"
  ) |>
  tab_source_note(
    "Territorial: emisiones territoriales. EEE y EEI: emisiones incorporadas en exportaciones e importaciones. Dif. (%): huella frente a emisiones territoriales."
  ) |>
  fmt_number(
    columns = c(Territorial, EEE, EEI, Huella, Saldo),
    scale_by = 1e-6, decimals = 1
  ) |>
  fmt_number(columns = Diferencia, decimals = 1)

# La huella de consumo por categoría de demanda final, separada en la parte
# producida en el país (interna) y la parte que corresponde a lo importado,
# valorada con tecnología nacional. Las exportaciones no forman parte de la
# huella de consumo.

huella_categoria <- do.call(
  cbind,
  lapply(
    anios,
    function(anio) {
      r <- resultados[[anio]]
      out <- cbind(
        Interno = r$interno,
        Importado = r$importado,
        Total = r$interno + r$importado
      )
      colnames(out) <- paste(anio, colnames(out), sep = "_")
      out
    }
  )
)

interna <- rownames(huella_categoria) != "Exportaciones"
rbind(
  huella_categoria[interna, ],
  `Huella de consumo` = colSums(huella_categoria[interna, ])
) |>
  tabla_gt(digitos = 1) |>
  tab_spanner_delim(delim = "_") |>
  fmt_number(decimals = 2, scale_by = 1e-6)

# Los multiplicadores de emisiones por producto demandado (M_e, suma de
# columnas), calculados con la matriz nacional y en las unidades de la cuenta
# por millón de soles de 2007 de demanda final:

mult_emisiones <- sapply(resultados, `[[`, "mult_emisiones")
rownames(mult_emisiones) <- sectores
tabla_gt(mult_emisiones, digitos = 0)


# === Exportación a Excel ===

# Para dejar registro, exportamos a un solo libro las matrices agregadas, los
# resultados de ambos ejercicios y las emisiones de entrada. Cada objeto va
# en su pestaña, con los nombres de filas en la primera columna. El nombre de
# cada pestaña empieza con 101_ o 8x8_ según el ejercicio.

por_anio_matriz <- function(nombre) {
  sapply(resultados, `[[`, nombre) |>
    `rownames<-`(sectores)
}

res_8x8 <- list(
  "8x8_Z" = Z,
  "8x8_Z_nacional" = Zd,
  "8x8_Z_importado" = Zm,
  "8x8_FDEM" = FDEM,
  "8x8_FDEM_nacional" = FDEMd,
  "8x8_FDEM_importado" = FDEMm,
  "8x8_f_x_m_q_ex" = data.frame(f = f, x = x, m = m, q = q, ex = ex),
  "8x8_A_nacional" = Ad,
  "8x8_A_importado" = Am,
  "8x8_L_nacional" = Ld,
  "8x8_importaciones_categoria" = FDEMimp,
  "8x8_emisiones_directas" = E,
  "8x8_epsilon" = epsilon,
  "8x8_mult_emisiones" = mult_emisiones,
  "8x8_balance" = balance |> column_to_rownames("Año"),
  "8x8_huella_categoria" = huella_categoria,
  "8x8_EEE_producto" = por_anio_matriz("EEE_producto"),
  "8x8_EEI_producto" = por_anio_matriz("EEI_producto")
)

# Una pestaña por año para Me y para las emisiones por sector emisor y categoría
por_anio <- unlist(
  lapply(
    anios,
    function(anio) {
      setNames(
        list(resultados[[anio]]$Me, resultados[[anio]]$sector_categoria),
        c(paste0("8x8_Me_", anio), paste0("8x8_sector_categoria_", anio))
      )
    }
  ),
  recursive = FALSE
)

libro <- c(res_101, res_8x8, por_anio) |>
  lapply(as.data.frame)

write.xlsx(
  libro,
  file = "datos/salidas/insumo-producto-huella-peru.xlsx",
  rowNames = TRUE,
  overwrite = TRUE
)

names(libro)

