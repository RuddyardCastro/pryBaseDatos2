DELIMITER //

CREATE TRIGGER tr_validar_stock_antes_insertar
BEFORE INSERT ON detalle_facturas
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;

    -- Obtenemos el stock actual del producto que se intenta vender
    SELECT stock INTO stock_actual 
    FROM productos 
    WHERE id_producto = NEW.id_producto;

    -- Si no hay suficiente stock, cancelamos la operación con un error
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Existencias insuficientes para realizar la venta.';
    END IF;
END //

DELIMITER ;