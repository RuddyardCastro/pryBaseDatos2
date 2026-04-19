DELIMITER //

CREATE PROCEDURE sp_registrar_venta(
    IN p_id_cliente INT, 
    IN p_id_producto INT, 
    IN p_cantidad INT
)
BEGIN
    -- Declaramos una variable para manejar errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre cualquier error, deshacemos todo lo que se hizo
        ROLLBACK;
        SELECT 'Error en la transacción: Venta cancelada' AS Mensaje;
    END;

    -- Iniciamos la transacción (Requisito 1.1)
    START TRANSACTION;

        -- 1. Insertar la factura
        INSERT INTO facturas (id_cliente, total) 
        VALUES (p_id_cliente, 0); -- El total se actualizará luego o se calcula en el front
        
        SET @factura_id = LAST_INSERT_ID();

        -- 2. Insertar el detalle
        -- Aquí el Trigger 'tr_validar_stock' se dispara automáticamente
        INSERT INTO detalle_facturas (id_factura, id_producto, cantidad, precio_unitario)
        VALUES (@factura_id, p_id_producto, p_cantidad, 
               (SELECT precio FROM productos WHERE id_producto = p_id_producto));

        -- 3. Actualizar stock
        UPDATE productos 
        SET stock = stock - p_cantidad 
        WHERE id_producto = p_id_producto;

    -- Si todo fue bien, confirmamos (Requisito 1.1)
    COMMIT;
    SELECT CONCAT('Venta exitosa. Factura ID: ', @factura_id) AS Mensaje;
    
END //

DELIMITER ;