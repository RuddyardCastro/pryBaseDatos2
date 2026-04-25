-- Nombre: sp_DevolucionVenta
-- Tipo: Stored Procedure (SP)
-- Descripción:
-- Este procedimiento permite realizar la devolución de una venta.
--
-- Funcionalidad:
-- 1. Verifica que la factura exista.
-- 2. Obtiene los productos asociados a la factura.
-- 3. Recorre cada producto utilizando un cursor.
-- 4. Devuelve el stock al inventario.
-- 5. Registra un egreso en la tabla caja.
--
-- Características técnicas:
-- - Uso de transacciones (START TRANSACTION, COMMIT, ROLLBACK).
-- - Uso de cursores para manejar múltiples productos.
-- - Manejo de errores con HANDLER.
-- - Nivel de aislamiento SERIALIZABLE.
--
-- Parámetros:
-- p_id_factura → ID de la factura a devolver.
--
-- Resultado:
-- Retorna un mensaje de confirmación, el ID de la factura y el monto devuelto.
--
-- Nota:
-- No elimina registros originales, mantiene trazabilidad mediante movimientos de caja.
-- =========================================================


USE Ventas;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_DevolucionVenta$$

CREATE PROCEDURE sp_DevolucionVenta(
    IN p_id_factura INT
)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_producto INT;
    DECLARE v_cantidad INT;
    DECLARE v_total DECIMAL(10,2);

    DECLARE cur_detalle CURSOR FOR
        SELECT id_producto, cantidad
        FROM detalle_facturas
        WHERE id_factura = p_id_factura;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error: no se pudo realizar la devolución' AS mensaje;
    END;

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    START TRANSACTION;

    -- Verificar factura
    IF NOT EXISTS (SELECT 1 FROM facturas WHERE id_factura = p_id_factura) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La factura no existe';
    END IF;

    -- Obtener total de factura
    SELECT total INTO v_total
    FROM facturas
    WHERE id_factura = p_id_factura;

    -- Recorrer productos
    OPEN cur_detalle;

    read_loop: LOOP
        FETCH cur_detalle INTO v_id_producto, v_cantidad;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Regresar stock
        UPDATE productos
        SET stock = stock + v_cantidad
        WHERE id_producto = v_id_producto;

    END LOOP;

    CLOSE cur_detalle;

    -- Registrar egreso en caja
    INSERT INTO caja(id_factura, tipo_movimiento, monto, fecha_movimiento, descripcion)
    VALUES(p_id_factura, 'EGRESO', v_total, NOW(), 'Devolución de venta');

    COMMIT;

    SELECT 'Devolución realizada correctamente' AS mensaje, p_id_factura AS id_factura, v_total AS monto;
END$$

DELIMITER ;



--
-- ejecutar para EJECUTAR LA devolucion
--
CALL sp_DevolucionVenta(101);


--
-- Verifica
--
SELECT * FROM productos;
SELECT * FROM caja;