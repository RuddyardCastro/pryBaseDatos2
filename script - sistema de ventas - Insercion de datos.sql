-- =========================================
-- INSERCION DE DATOS
-- =========================================

-- INSERTAR CLIENTES
INSERT INTO CLIENTE (nombre, correo, telefono) VALUES
('Juan Perez', 'juan@gmail.com', '12345678'),
('Maria Lopez', 'maria@gmail.com', '87654321');

-- INSERTAR EMPLEADOS
INSERT INTO EMPLEADO (nombre, rol) VALUES
('Carlos Ramirez', 'Vendedor'),
('Ana Torres', 'Cajera');

-- INSERTAR PRODUCTOS
INSERT INTO PRODUCTO (nombre, precio) VALUES
('Laptop', 5000.00),
('Mouse', 150.00),
('Teclado', 300.00);

-- INSERTAR INVENTARIO
INSERT INTO INVENTARIO (id_producto, stock_actual, stock_minimo) VALUES
(1, 10, 2),
(2, 50, 5),
(3, 30, 5);

SELECT * FROM cliente;
SELECT * FROM detalle_factura;
SELECT * FROM empleado;
SELECT * FROM factura;
SELECT * FROM inventario;
SELECT * FROM producto;
