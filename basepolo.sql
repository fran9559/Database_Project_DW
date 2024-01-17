CREATE DATABASE polo

--SCHEMA STG
CREATE SCHEMA stg; 

--tabla para cargar datos
CREATE TABLE stg.carga (
[Producto] VARCHAR(255) NOT NULL,
[CodigoProd] VARCHAR(255) NOT NULL,
[Categoria] VARCHAR(255) NOT NULL,
[Cliente] VARCHAR(255) NOT NULL,
[Codigo] VARCHAR(255) NOT NULL,
[Pais] VARCHAR(255) NOT NULL,
[ID Pais] VARCHAR(255) NOT NULL,
[codvendedor] VARCHAR(255) NOT NULL,
[Nombre] VARCHAR(255) NOT NULL,
[Apellido] VARCHAR(255) NOT NULL,
[sucursal] VARCHAR(255) NOT NULL,
[cod sucursal] VARCHAR(255) NOT NULL,
[Fecha de Venta] DATE NOT NULL,
[Cantidad_Vendida] VARCHAR(255) NOT NULL,
[Precio] VARCHAR(255) NOT NULL,
[Costo] VARCHAR(255) NOT NULL );

SELECT * FROM stg.carga

--schema produccion
CREATE SCHEMA prod;

--tabla categorias
CREATE TABLE prod.Categoria (
[ID categoria] INT PRIMARY KEY IDENTITY,
[Categoria] VARCHAR(255) NOT NULL);
INSERT INTO prod.Categoria
SELECT DISTINCT Categoria
FROM stg.carga

SELECT * FROM prod.Categoria

--tabla producto 
CREATE TABLE prod.Productos (
[ID producto] VARCHAR(255) PRIMARY KEY,
[Nombre] VARCHAR(255) NOT NULL,
[ID categoria] INT);
INSERT INTO prod.Productos
SELECT DISTINCT t1.CodigoProd,
		t1.Producto,
		CONVERT(INT,t2.[ID categoria]) AS categoria
FROM stg.carga as t1
left join prod.Categoria as t2
ON t1.Categoria = t2.[categoria]

SELECT * FROM prod.Productos

--- tabla clientes
CREATE TABLE prod.Clientes(
ID_Clientes VARCHAR (255) PRIMARY KEY,
Nombre VARCHAR(255) NOT NULL);
INSERT INTO prod.Clientes
SELECT DISTINCT Codigo,
		Cliente  
FROM stg.carga

SELECT * FROM prod.Clientes


--tabla pais
CREATE TABLE prod.Pais(
ID_pais VARCHAR(255) PRIMARY KEY,
Pais VARCHAR(255) NOT NULL);
INSERT INTO prod.Pais
SELECT DISTINCT [ID Pais],
		Pais 
FROM stg.carga

SELECT * FROM prod.Pais

--tabla sucursal 


CREATE TABLE  prod.Sucursales(
ID_sucursal VARCHAR (255) PRIMARY KEY,
cuidad VARCHAR (255) NOT NULL,
Pais VARCHAR (255) NOT NULL);
INSERT INTO prod.Sucursales
SELECT DISTINCT [cod sucursal],
		sucursal,
		[ID Pais]
FROM stg.carga

SELECT * FROM prod.sucursales

--tabla vendedores

CREATE TABLE prod.Vendedores (
ID_Vendedor VARCHAR (255) PRIMARY KEY,
Nombre_Vendedor VARCHAR (255) NOT NULL);
INSERT INTO prod.Vendedores
SELECT DISTINCT codvendedor,
				CONCAT(Nombre,' ',Apellido) 
FROM stg.carga

SELECT * FROM prod.Vendedores


--tabla transacciones
CREATE TABLE prod.Transacciones (
ID_Operacion INT PRIMARY KEY IDENTITY,
Fecha DATE NOT NULL,
ID_Sucursal VARCHAR (255) NOT NULL,
ID_Vendedor VARCHAR (255) NOT NULL,
ID_Producto VARCHAR (255) NOT NULL,
Cantidad INT NOT NULL,
Precio_unitario DECIMAL(9,2) NOT NULL,
Costo_unitario DECIMAL(9,2) NOT NULL,
ID_cliente VARCHAR (255) NOT NULL,
);
INSERT INTO prod.Transacciones
SELECT [Fecha de Venta],
		[cod sucursal],
		codvendedor,
		CodigoProd,
		Cantidad_Vendida,
		CONVERT(DECIMAL(9,2),REPLACE(Precio,',','.')),
		CONVERT(DECIMAL(9,2),REPLACE(Costo,',','.')),
		Codigo
FROM stg.carga

SELECT * FROM prod.Transacciones

---- creacion de relaciones

ALTER TABLE prod
ADD CONSTRAINT FK_
FOREIGN KEY () REFERENCES prod.()
ON DELETE SET NULL ON UPDATE SET NULL; 
ON DELETE NO ACTION ON UPDATE NO ACTION; 

-- relacion entre sucursales y pais
ALTER TABLE prod.Sucursales
ADD CONSTRAINT FK_sucursal_pais
FOREIGN KEY (Pais) REFERENCES prod.Pais(ID_pais)
ON DELETE NO ACTION ON UPDATE NO ACTION; 

---relacion entre categorias y productos

ALTER TABLE prod.Productos
ADD CONSTRAINT FK_productos_categorias
FOREIGN KEY ([ID categoria]) REFERENCES prod.Categoria([ID categoria])
ON DELETE SET NULL ON UPDATE SET NULL; 

--- relacion entre transacciones y sucursal

ALTER TABLE prod.Transacciones
ADD CONSTRAINT FK_tras_suc
FOREIGN KEY (ID_Sucursal) REFERENCES prod.Sucursales(ID_Sucursal)
ON DELETE NO ACTION ON UPDATE NO ACTION; 

--- relacion entre transacciones y vendedores
ALTER TABLE prod.Transacciones
ADD CONSTRAINT FK_tras_ven
FOREIGN KEY (ID_Vendedor) REFERENCES prod.Vendedores(ID_Vendedor)
ON DELETE NO ACTION ON UPDATE NO ACTION; 

--- relacion entre transacciones y producto
ALTER TABLE prod.Transacciones
ADD CONSTRAINT FK_tras_prod
FOREIGN KEY (ID_Producto) REFERENCES prod.Productos([ID producto])
ON DELETE NO ACTION ON UPDATE NO ACTION; 

--relacion entre transacciones y clientes
ALTER TABLE prod.Transacciones
ADD CONSTRAINT FK_tras_cliente
FOREIGN KEY (ID_Cliente) REFERENCES prod.Clientes(ID_clientes)
ON DELETE NO ACTION ON UPDATE NO ACTION; 

--cantidad de articulos vendidos por categoria

SELECT  T3.Categoria, 
	SUM(Cantidad) AS cantidad_vendida
FROM prod.Transacciones AS T1
LEFT JOIN prod.Productos AS T2
 ON T1.ID_Producto = T2.[ID producto]
LEFT JOIN prod.Categoria AS T3
 ON T3.[ID categoria] = T2.[ID categoria]
GROUP BY T3.Categoria

--funcion para calcular los artuculos x categoria

GO
CREATE FUNCTION prod.venta_x_categorias(@v_categoria VARCHAR(255))
RETURNS DECIMAL(11,2)
AS
	BEGIN
		DECLARE @Resultado DECIMAL(11,2)
		SET @Resultado =	(SELECT  SUM(Cantidad) AS cantidad_vendida
							FROM prod.Transacciones AS T1
							LEFT JOIN prod.Productos AS T2
							  ON T1.ID_Producto = T2.[ID producto]
							LEFT JOIN prod.Categoria AS T3
							  ON T3.[ID categoria] = T2.[ID categoria]
							WHERE Categoria LIKE CONCAT('%',@v_categoria,'%')
							GROUP BY T3.Categoria) 
		RETURN @Resultado
	END;
GO

SELECT prod.venta_x_categorias('ofi')
