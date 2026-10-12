# Extensión ambiental y multiplicadores
# Renato Vargas
# Economista / Analista de Datos
# https://renatovargas.com/

# 1. El modelo básico con emisiones

#           Hacia   Sectores
#                  Agr   Manuf  FinDem  Total Producto
# Desde
#   Agricultura    150     500     350          1000
#   Manufacturas   200     100    1700          2000
#
# Pagos a factores 650    1400    1100
# Total insumos   1000    2000    3150
#
# Emisiones de CO2 (t)  300     500

# Primero creamos nuestro cuadro de flujos entre industrias

sectores <- c("Agricultura", "Manufacturas")

Z <- matrix(c(150, 500, 200, 100), nrow = 2, byrow = TRUE)
colnames(Z) <- sectores
rownames(Z) <- sectores

# Nuestro vector de producto total y de demanda final
x <- c(1000, 2000)
f <- c(350, 1700)

# Coeficientes técnicos y matriz de Leontief
A <- Z %*% solve(diag(x))
L <- solve(diag(dim(A)[1]) - A)
L

# Comprobación: L por f devuelve el producto total
L %*% f


# 2. La extensión ambiental básica

# Las emisiones directas de dióxido de carbono (CO2), en toneladas,
# son 300 para agricultura y 500 para manufacturas.

eprima <- c(300, 500)
names(eprima) <- sectores
eprima

# El coeficiente de emisiones (intensidad) es la cantidad emitida
# por unidad monetaria de producto: epsilon' = e' %*% xhat^-1.
# En álgebra matricial se transpone el vector de emisiones y se
# posmultiplica por la inversa de la diagonal de x.

epsilon <- t(as.matrix(eprima)) %*% solve(diag(x))
epsilon

# También se puede usar la regla de reciclaje de R y dividir directamente
eprima / x

# Emisiones calculadas desde la demanda final: e = epsilonhat %*% L %*% f
# Reproduce las emisiones del cuadro.

e <- diag(c(epsilon)) %*% L %*% f
rownames(e) <- sectores
colnames(e) <- "Toneladas de CO2"
e


# 3. Multiplicadores de producto

# Un multiplicador responde qué pasa en toda la economía cuando la
# demanda final de un solo sector sube una unidad.

# Primero, la demanda adicional de solo el primer sector
L
deltaf1 <- c(1, 0)
L %*% deltaf1

# Ahora, la del segundo sector
deltaf2 <- c(0, 1)
L %*% deltaf2

# El multiplicador de cada sector es la suma de su columna de L.
# Con un vector sumatorio i lo hacemos para todos los sectores a la vez.

# Dimensiones de L
dim(L)

# Vector sumatorio de largo apropiado
i <- rep(1, dim(L)[1])

# Multiplicadores
mo <- i %*% L
mo


# 4. Multiplicadores de emisiones

# Me = epsilonhat %*% L. El elemento m_ij son las toneladas de CO2 que
# se emiten en el sector i cuando se necesita una unidad monetaria
# adicional de producto del sector j para satisfacer la demanda final.

Me <- diag(c(epsilon)) %*% L
rownames(Me) <- sectores
colnames(Me) <- sectores
Me

# Multiplicadores de emisiones (suma de cada columna)
colSums(Me)


# 5. Huella de carbono en toneladas

# El multiplicador está por unidad monetaria. Para obtener la huella
# total de cada sector, en toneladas, se multiplica por su demanda final.

huella <- epsilon %*% L %*% diag(f)
colnames(huella) <- sectores
huella

# Equivale a multiplicar elemento por elemento
colSums(Me) * f

# La suma es el total de emisiones del cuadro
sum(huella)
