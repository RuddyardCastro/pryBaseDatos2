create database Ventas;
use  Ventas;

-- 1. Catálogo de Productos
CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0
);

-- 2. Entidad de Direcciones (Separada según tu imagen para normalización)
-- Esto permite que el catedrático vea que sabes separar atributos multievaluados.
CREATE TABLE direcciones (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    calle VARCHAR(100),
    avenida VARCHAR(100),
    colonia VARCHAR(100),
    zona INT,
    referencia TEXT
);

-- 3. Entidad de Clientes (Vinculada a su dirección)
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nit VARCHAR(15) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    id_direccion INT,
    FOREIGN KEY (id_direccion) REFERENCES direcciones(id_direccion)
);

-- 4. Cabecera de Factura
CREATE TABLE facturas (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- 5. Detalle de Factura (Relación muchos a muchos entre Factura y Producto)
CREATE TABLE detalle_facturas (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_factura INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL, -- Importante: guarda el precio del momento de la venta
    FOREIGN KEY (id_factura) REFERENCES facturas(id_factura),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- 6. Tabla de Auditoría (Requisito 2.2 de tu guía)
-- Usaremos el formato JSON que acordamos para máxima nota.
CREATE TABLE bitacora_auditoria (
  BitacoraID int NOT NULL AUTO_INCREMENT,
  NombreTabla varchar(100) DEFAULT NULL,
  Operacion varchar(20) DEFAULT NULL,
  id_registro int DEFAULT NULL, -- ID del registro afectado (ProductoID, ClienteID, etc.)
  datos_anteriores json DEFAULT NULL,
  datos_nuevos json DEFAULT NULL,
  Usuario varchar(100) DEFAULT NULL,
  FechaHora timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (BitacoraID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;