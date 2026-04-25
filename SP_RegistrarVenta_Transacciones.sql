-- =========================================================
-- Nombre: sp_RegistrarVenta
-- Tipo: Stored Procedure (SP)
-- Descripción:
-- Este procedimiento almacena una nueva venta en el sistema.
-- 
-- Funcionalidad:
-- 1. Valida que el producto tenga suficiente stock.
-- 2. Calcula el total de la venta.
-- 3. Inserta un registro en la tabla facturas.
-- 4. Inserta el detalle de la venta en detalle_facturas.
-- 5. Actualiza el stock del producto.
-- 6. Registra el ingreso en la tabla caja.
--
-- Características técnicas:
-- - Uso de transacciones (START TRANSACTION, COMMIT, ROLLBACK).
-- - Manejo de errores con SIGNAL y HANDLER.
-- - Nivel de aislamiento SERIALIZABLE para evitar inconsistencias.
--
-- Parámetros:
-- p_id_cliente → ID del cliente que realiza la compra.
-- p_id_producto → ID del producto vendido.
-- p_cantidad → Cantidad de producto a vender.
--
-- Resultado:
-- Retorna un mensaje de confirmación, el ID de la factura generada y el total.
-- =========================================================

USE VENTAS;

SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM facturas;
SELECT * FROM detalle_facturas;
SELECT * FROM caja;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_RegistrarVenta$$

CREATE PROCEDURE sp_RegistrarVenta(
    IN p_id_cliente INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_stock_actual INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_id_factura INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: la venta no pudo registrarse. Se revirtieron los cambios.' AS mensaje;
    END;

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    START TRANSACTION;

    SELECT stock, precio
    INTO v_stock_actual, v_precio
    FROM productos
    WHERE id_producto = p_id_producto
    FOR UPDATE;

    IF v_stock_actual < p_cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para realizar la venta.';
    END IF;

    SET v_total = v_precio * p_cantidad;

    INSERT INTO facturas(id_cliente, fecha, total)
    VALUES(p_id_cliente, NOW(), v_total);

    SET v_id_factura = LAST_INSERT_ID();

    INSERT INTO detalle_facturas(id_factura, id_producto, cantidad, precio_unitario)
    VALUES(v_id_factura, p_id_producto, p_cantidad, v_precio);

    UPDATE productos
    SET stock = stock - p_cantidad
    WHERE id_producto = p_id_producto;

    INSERT INTO caja(id_factura, tipo_movimiento, monto, fecha_movimiento, descripcion)
    VALUES(v_id_factura, 'INGRESO', v_total, NOW(), 'Venta registrada desde procedimiento almacenado');

    COMMIT;

    SELECT 'Venta registrada correctamente' AS mensaje, v_id_factura AS id_factura, v_total AS total;
END$$

DELIMITER ;


--
-- ejecutar para registrar la venta
--
CALL sp_RegistrarVenta(1, 5, 2);



--
-- ver los cambios en las tablas
--
SELECT * FROM facturas;
SELECT * FROM detalle_facturas;
SELECT * FROM productos WHERE id_producto = 5;
SELECT * FROM caja;


