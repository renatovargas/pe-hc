# El Modelo de Insumo Producto
# Renato Vargas
# Economista / Analista de Datos
# https://renatovargas.com/

# 1. El modelo básico


#           Hacia   Sectores
#                  Agr   Manuf  FinDem  Total Producto
# Desde
#   Agricultura    150     500     350          1000
#   Manufacturas   200     100    1700          2000
# 
# Pagos a factores 650    1400    1100          3150
# Total insumos   1000    2000    3150          6150 


# Coeficientes técnicos (la matriz A) 

#           Hacia    Sectores
#                   Agr   Manuf  
# Desde
#   Agricultura    0.15    0.25
#   Manufacturas   0.20    0.05

# Primero creamos nuestro cuadro de flujos entre industrias

Z <- matrix( c(150,500,200,100), nrow = 2, ncol = 2, byrow = TRUE)

# Es importante identificar los sectores en nuestra matriz

sectores <- c("Agricultura", "Manufacturas")
colnames(Z) <- sectores 
rownames(Z) <- sectores

# Ingresamos nuestra demanda final (según el diagrama)
f <- c(350, 1700)
f

# Nuestro vector de producto total
x <- c(1000, 2000)
x

# Una matriz diagonal con la producción total por sector
xhat <- diag(x)
xhat

#  Nuestra matriz de coeficientes técnicos.
A <- Z %*% solve( xhat )
A

# Ahora necesitamos conocer las dimensiones de A.
dim(A)

# Para poder crear nuestra matriz identidad de tamaño apropiado

I <- diag(   dim(A)[1]    )
I

I - A

# Y así estimar nuestra matriz de Leontief
L <- solve( I - A )
L

# Verificamos que nuestro modelo calcula x = Lf (¡Estamos calibrados!) 
L %*% f

# ¿Ahora qué pasaría si cambiamos nuestra demanda final?

# Si la demanda final de los productos agrícolas se incrementa a $600
# el siguiente año y la de las manufacturas bajara a $1500,
# ¿cuánto producto de los dos sectores sería necesario para satisfacer
# esta nueva demanda?

fnueva <- c(600, 1500)

xnueva <- L %*% fnueva
xnueva

# De nuestra definición de coeficientes Z= A %*% xhat encontramos Znueva

Znueva <- A %*% diag(xnueva)  # error

# Nos da un error porque xnueva no es entendido como vector por R, es una
# matriz y diag() funciona de manera distinta si se le pasa una matriz.

help("diag")
help("as.vector")

Znueva <- A %*% diag(c(xnueva))
Znueva <- A %*% diag(as.vector(xnueva))
Znueva

# Nuestro nuevo cuadro

#             Hacia   Sectores
#                    Agr    Manuf  FinDem  Total Producto
# Desde
#  Agricultura    187.13   460.40     600       1247.52
#  Manufacturas   249.51    92.08    1500       1841.58  
# 
# Pago a factores 810.89  1289.11    1100       3200.00
# Total insumos  1247.53  1841.58    3200       6289.10

# A veces queremos saber cuáles son los cambios, en lugar
# de los nuevos niveles.

# Cambios en demanda
deltaf <- fnueva - f

# Cambios en producto
deltax <- xnueva - x

# Cambios a toda la tabla Z
deltaZ <- Znueva - Z

# En moneda local. Tipo de cambio 7.70 ML por 1 USD

tc <- 7.70

deltaf * tc
deltax * tc
deltaZ * tc

