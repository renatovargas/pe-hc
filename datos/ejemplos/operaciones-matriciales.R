# Álgebra matricial para insumo-producto
# Renato Vargas

# Limpiar el área de trabajo
rm(  list = ls()  )


## Crear una matriz

c <- c(2, 1, 3, 4, 6, 12)
c

M <- matrix(c, nrow = 2, ncol = 3, byrow = TRUE)
M


## Índices

M[2, 3]
M[2, 2]

# En vectores, por posición
c[5]


## Suma

N <- matrix(
  c(1,2,3, 3,2,1),
  nrow = 2,
  ncol = 3,
  byrow = TRUE
)
N

dim(M)
dim(N)
dim(M) == dim(N)

S <- M + N
S


## Suma de matrices de dimensiones diferentes no definida

# Como esta operación matricial no está definida, R la marca como un error.
# try() permite que el resto del script se siga ejecutando.

O <- matrix(c(2,2,3,4), ncol = 2, nrow = 2, byrow = TRUE)
M
O

try(M + O)


## Resta

D <- M - N
M
N
D


## Igualdad

dim(M) == dim(N) # mismas dimensiones
M
N
M == N # comparación elemento por elemento
all(M == N) # todos los elementos no son iguales
M2 <- M
M2
all(M == M2) # todos los elementos son iguales


## La matriz nula

Z <- matrix(
  c(0,0,0, 0,0,0),
  nrow = 2,
  ncol = 3,
  byrow = TRUE
)
M
Z

M + Z


## Multiplicación por un escalar

M

Mx2 <- M * 2
Mx2


## Multiplicación de matrices

Q <- matrix(
  c(2,0,4, 1,1,2, 3,4,5),
  nrow = 3,
  ncol = 3,
  byrow = TRUE
)
Q

# A mano
c(
  (2*2 + 1*1 + 3*3),(2*0 + 1*1 + 3*4),(2*4 + 1*2 + 3*5),
  (4*2 + 6*1 + 12*3),(4*0 + 6*1 + 12*4),(4*4 + 6*2 + 12*5)
)

P <- M %*% Q
P


## Multiplicación no conformable

# Q tiene 3 columnas y M solo 2 filas
try(Q %*% M)


## Identidad

# Una matriz de 1s no es la identidad
M %*% matrix(1, nrow = 3, ncol = 3)

# Posmultiplicación por la identidad
I <- matrix(
  c(1,0,0, 0,1,0, 0,0,1),
  nrow = 3,
  ncol = 3,
  byrow = TRUE
)

I
M

M %*% I

# Identidad para matrices grandes
dim(M)
dim(M)[1]
dim(M)[2]

I3 <- diag(3)
I3

diag(  dim(M)[2]  )

# Premultiplicación por la identidad
diag(dim(M)[1]) %*% M


## Transposición

Mt <- t(M)
Mt

# En R, los vectores no tienen dimensiones. R los conforma como fila o
# columna al multiplicar, siempre que su largo sea el requerido para la
# pre o posmultiplicación. Pero se puede forzar al convertirlos en matrices
# y transponerlas según sea necesario.

t(c) # transpone y convierte un vector en matriz
t(t(c))


## Sistemas de ecuaciones lineales

# 2x_1 +  x_2 = 10
# 5x_1 + 3x_2 = 26
A <- matrix(c(2,1,5,3), nrow = 2, ncol = 2, byrow = TRUE)
b <- matrix(c(10, 26), nrow = 2, ncol = 1, byrow = TRUE)
A
b

# La inversa
A
solve(A)

# Productos cruzados iguales: matriz singular, no tiene inversa
C <- matrix(c(2,4,6,12), nrow = 2, ncol = 2)
try(solve(C))

# Solución del sistema de ecuaciones
A
b
x <- solve(A) %*% b
x


## Matrices diagonales

g <- c(8,9,17)
g

# G sombrero: solo la diagonal
Ghat <- diag(g)
Ghat

# Inversa de una matriz diagonal
Ghat
invGhat <- solve(Ghat)
invGhat

invGhat %*% Ghat


## Vectores sumatorios

# Suma de filas
M
isum <- matrix(1, nrow = 3, ncol = 1)
M %*% isum
# Alternativamente
M %*% c(1,1,1)

# Suma de columnas
matrix(1, ncol = 2, nrow = 1) %*% M

c(1,1) %*% M


## Atajos en R

colSums(M)
rowSums(M)
