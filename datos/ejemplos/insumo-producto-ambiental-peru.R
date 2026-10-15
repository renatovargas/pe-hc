# Extensión ambiental y multiplicadores con la MIP de Perú, 2007
# Renato Vargas
# Economista / Analista de Datos
# https://renatovargas.com/

# Este script repite el de insumo-producto-ambiental.R, pero con los datos
# de Perú. Las rutas son relativas a la raíz del proyecto.

library(readxl)
library(tidyverse)

rm(list = ls())

archivo <- "datos/per/PER_Modelo_Insumo_Producto.xlsx"
hoja <- "MIP_Basico_2007_Corrientes_101_"


# 1. Carga de los datos

# Nombres de los productos (101), tomados de la pestaña "Empleo"
sectores <- unlist(
  read_excel(archivo, sheet = "Empleo", range = "C1:CY1",
             col_names = FALSE, .name_repair = "minimal"),
  use.names = FALSE)

# Matriz de flujos entre industrias Z (101 x 101)
Z <- as.matrix(
  read_excel(archivo, sheet = hoja, range = "N12:DJ112",
             col_names = FALSE, .name_repair = "minimal"))
dimnames(Z) <- list(sectores, sectores)

# Demanda final desagregada (101 x 7). Las columnas son las categorías de
# demanda final; las filas son los mismos sectores de Z.
categorias <- unlist(
  read_excel(archivo, sheet = hoja, range = "DN11:DT11",
             col_names = FALSE, .name_repair = "minimal"),
  use.names = FALSE)

FDEM <- as.matrix(
  read_excel(archivo, sheet = hoja, range = "DN12:DT112",
             col_names = FALSE, .name_repair = "minimal"))
dimnames(FDEM) <- list(sectores, categorias)

# Emisiones directas de cada sector (vector fila de la hoja)
eprima <- unlist(
  read_excel(archivo, sheet = hoja, range = "N154:DJ154",
             col_names = FALSE, .name_repair = "minimal"),
  use.names = FALSE)
names(eprima) <- sectores

dim(Z)
dim(FDEM)
length(eprima)


# 2. El modelo básico

# La demanda final total es la suma de las categorías de cada sector
f <- rowSums(FDEM)

# El producto total es lo que se vende a otros sectores más la demanda final
x <- rowSums(Z) + f

# Coeficientes técnicos y matriz de Leontief
A <- Z %*% solve(diag(x))
L <- solve(diag(dim(A)[1]) - A)
dimnames(L) <- list(sectores, sectores)

# Comprobación: L por f devuelve el producto total
isTRUE(all.equal(c(L %*% f), x, check.attributes = FALSE))


# 3. La extensión ambiental básica

# Coeficientes de emisiones (intensidad): emisiones por unidad de producto
epsilon <- t(as.matrix(eprima)) %*% solve(diag(x))

# También se puede usar la regla de reciclaje de R y dividir directamente
head(eprima / x)

# Emisiones calculadas desde la demanda final: e = epsilonhat %*% L %*% f
# Reproduce las emisiones del cuadro.
e <- diag(c(epsilon)) %*% L %*% f
rownames(e) <- sectores
colnames(e) <- "Emisiones"
isTRUE(all.equal(c(e), unname(eprima), check.attributes = FALSE))


# 4. Multiplicadores de producto

# El multiplicador de cada sector es la suma de su columna de L
i <- rep(1, dim(L)[1])
mo <- i %*% L
head(t(mo))


# 5. Multiplicadores de emisiones

# Me = epsilonhat %*% L
Me <- diag(c(epsilon)) %*% L
dimnames(Me) <- list(sectores, sectores)

# Multiplicadores de emisiones (suma de cada columna)
head(colSums(Me))


# 6. Huella de carbono total

huella <- epsilon %*% L %*% diag(f)
colnames(huella) <- sectores

# La suma es el total de emisiones del cuadro
sum(huella)


# 7. Emisiones diferenciadas por categoría de demanda final

# Como el modelo es lineal, se multiplica con la matriz FDEM completa en
# lugar del vector f. Cada columna es el vector e de una categoría
# (hogares, gobierno, inversión, exportaciones, etc.).
# Resultado: sectores que emiten (101) x categorías de demanda final (7).

eDif <- diag(c(epsilon)) %*% L %*% FDEM
dimnames(eDif) <- list(sectores, categorias)

head(eDif)

# La suma de las categorías reproduce el vector e
isTRUE(all.equal(rowSums(eDif), c(e), check.attributes = FALSE))

# Emisiones totales, en las unidades de la hoja, por categoría
# de demanda final
colSums(eDif)

# Participación de cada categoría en el total
round(100 * colSums(eDif) / sum(eDif), 1)
