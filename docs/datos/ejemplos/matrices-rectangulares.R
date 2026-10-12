# Matrices rectangulares de insumo-producto
# Renato Vargas
# Economista / Analista de Datos
# https://renatovargas.com/

# 1. Datos del ejercicio

# Un ejercicio con 8 productos y 5 industrias, adaptado de un ejercicio
# de extensiones ambientales. Los valores son monetarios.

#   U: utilización (productos x industrias)
#   V: producción (industrias x productos)
#   f: demanda final por producto
#   va: valor agregado por industria

productos <- c("ganado", "hierro", "leche", "queso",
               "combustible", "acero", "autos", "publicidad")
industrias <- c("granjas", "minas", "alimentos",
                "manufacturas", "servicios")

# Utilización
U <- matrix(
  c(10,   0,  80,  10,  0,
     0,   0,   0, 100,  0,
    10,   5, 100,   0,  5,
     0,   5,   0,   0,  5,
   100, 200,  10,  50, 50,
     0,   5,   0, 145,  0,
    10,   5,   5,   5, 10,
     5,  15,  20,  40, 20),
  nrow = 8, byrow = TRUE,
  dimnames = list(productos, industrias))
U

# Producción. Las minas producen hierro y combustible; las manufacturas
# producen combustible, acero y autos. Es producción secundaria, que un
# cuadro cuadrado tendría que reasignar.
V <- matrix(
  c(100,   0, 100,  10,    0,   0,   0,   0,
      0, 100,   0,   0, 1000,   0,   0,   0,
      0,   0,  80, 200,    0,   0,   0,   0,
      0,   0,   0,   0,   10, 150, 200,   0,
      0,   0,   0,   0,    0,   0,   0, 100),
  nrow = 5, byrow = TRUE,
  dimnames = list(industrias, productos))
V

# Demanda final y valor agregado
f <- c(0, 0, 60, 200, 600, 0, 165, 0)
names(f) <- productos
f

va <- c(75, 865, 65, 10, 10)
names(va) <- industrias
va


# 2. Totales y balances

# x = V i (producto total por industria)
# q = V' i (producto total por producto)

# Vectores sumatorios de largo apropiado
ic <- rep(1, 8)
ii <- rep(1, 5)

x <- V %*% ic
q <- t(V) %*% ii

# Producto total contra utilización más demanda final
cbind(q, U %*% ii + f)

# Cada industria usa insumos y valor agregado por el mismo valor que
# su producto total. Si ambas columnas coinciden en todas las filas,
# el cuadro es consistente (calibración del sistema).
cbind(x, colSums(U) + va)


# 3. Preparación de los cuadros reales (solo conceptual)

# La utilización está a precios de comprador y la oferta a precios de
# productor. En datos reales hay que pasar por tres ajustes antes de
# calcular coeficientes: márgenes de comercio y transporte, importaciones
# competitivas e impuestos. En este ejercicio los datos ya están
# a un solo juego de precios y sin importaciones.


# 4. El modelo con matrices rectangulares

# Paso 1: la matriz B = U xhat^-1 (coeficientes de insumo por producto)
# Es de 8 x 5, igual que U. Con diag() usamos c(x) porque x es una matriz
# de una columna y diag() extrae la diagonal si se le pasa una matriz.

B <- U %*% solve(diag(c(x)))
dimnames(B) <- dimnames(U)
round(B, 3)

# Paso 2: la matriz D = V qhat^-1 (participación de mercado)
# Es de 5 x 8, igual que V, y cada columna suma 1.

D <- V %*% solve(diag(c(q)))
dimnames(D) <- dimnames(V)
round(D, 3)

# Cada columna suma 1
colSums(D)

# Paso 3: DB es de 5 x 5 (industrias por industrias), por lo que ya
# se le puede restar una identidad e invertir.

DB <- D %*% B
dim(DB)

IDB <- diag(nrow(DB)) - DB
round(IDB, 3)

# Paso 4: la matriz de requerimientos totales T = (I - DB)^-1 D
# Es de 5 x 8. La llamamos Treq porque T es TRUE en R.

Treq <- solve(IDB) %*% D
dimnames(Treq) <- dimnames(V)
round(Treq, 3)


# 5. Calibración del modelo

# Si T f devuelve el producto total observado de las industrias,
# el modelo es consistente con los cuadros originales.

Treq %*% f

# Comparación con x
isTRUE(all.equal(c(Treq %*% f), c(x)))


# 6. Un escenario de demanda final

# La demanda final de autos aumenta en 100 unidades monetarias.
# La matriz T no cambia: la tecnología es la misma y cambia solo la demanda.

deltaf <- c(0, 0, 0, 0, 0, 0, 100, 0)

deltax <- Treq %*% deltaf
round(deltax, 2)


# 7. Extensión ambiental

# Una extensión ambiental asigna a cada industria una intensidad de
# emisiones por unidad de producción, epsilon' (1 x 5).
# El ejercicio usa valores ilustrativos.

epsilon <- c(0.5, 0.8, 0.3, 0.4, 0.1)

# Emisiones totales
sum(epsilon * x)

# Multiplicadores por producto: epsilon' T es un vector de 1 x 8
round(epsilon %*% Treq, 3)

# Multiplicadores por producto: directo, total e indirecto
directo <- c(epsilon %*% D)
total <- c(epsilon %*% Treq)

data.frame(
  producto = productos,
  directo = round(directo, 3),
  total = round(total, 3),
  indirecto = round(total - directo, 3))

# Las emisiones por categoría de demanda final (hogares, gobierno,
# capital, exportaciones) se calculan igual que con f, pero con el
# vector de demanda de cada categoría: epsilon' T f_k. Este ejercicio
# tiene un solo vector f.


# 8. Anexo: una matriz cuadrada equivalente

# Los mismos resultados se obtienen con una sola matriz cuadrada que pone
# industrias y productos juntos, en ese orden, en filas y columnas.

nI <- nrow(V)
nP <- ncol(V)

Zs <- rbind(
  cbind(matrix(0, nI, nI), V),
  cbind(U, matrix(0, nP, nP)))

fs <- c(rep(0, nI), f)
xs <- c(x, q)

As <- Zs %*% solve(diag(xs))
Ls <- solve(diag(nI + nP) - As)

# El bloque superior derecho es T
Tbloque <- Ls[1:nI, (nI + 1):(nI + nP)]
isTRUE(all.equal(unname(Tbloque), unname(Treq)))

# Reproduce x y q
isTRUE(all.equal(c(Ls %*% fs), xs))

# Hay que cuidar al agregar: xs mezcla producción de industrias y de
# productos, así que sumarlo cuenta dos veces.
