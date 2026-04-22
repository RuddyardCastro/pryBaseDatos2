-- =========================================
-- CREAR BASE DE DATOS
-- =========================================
CREATE DATABASE SistemaVentas;
USE SistemaVentas;

-- =========================================
-- TABLA CLIENTE
-- =========================================
CREATE TABLE CLIENTE (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    telefono VARCHAR(20)
);

-- =========================================
-- TABLA EMPLEADO
-- =========================================
CREATE TABLE EMPLEADO (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    rol VARCHAR(50) NOT NULL
);

-- =========================================
-- TABLA PRODUCTO
-- =========================================
CREATE TABLE PRODUCTO (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL
);

-- =========================================
-- TABLA INVENTARIO
-- =========================================
CREATE TABLE INVENTARIO (
    id_inventario INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT UNIQUE,
    stock_actual INT NOT NULL,
    stock_minimo INT NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto)
);

-- =========================================
-- TABLA FACTURA
-- =========================================
CREATE TABLE FACTURA (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    total DECIMAL (10,2) ,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
);

-- =========================================
-- TABLA DETALLE_FACTURA
-- =========================================
CREATE TABLE DETALLE_FACTURA (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_factura INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_factura) REFERENCES FACTURA(id_factura),
    FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto)
);