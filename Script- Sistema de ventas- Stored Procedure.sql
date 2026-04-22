-- ============================================================
-- CREACIÓN DEL STORED PROCEDURE: REGISTRO DE VENTA INTEGRAL
-- OBJETIVO: Procesar una venta completa (Factura, Detalle e Inventario)
-- garantizando que si un paso falla, nada se guarde (Transaccionalidad).
-- ============================================================

USE SistemaVentas;
-- Esto borra el procedimiento si ya existía uno a medias, para crearlo desde cero
DROP PROCEDURE IF EXISTS sp_RegistrarVenta;

DELIMITER // -- Cambiamos el delimitador para definir el bloque del procedimiento

CREATE PROCEDURE sp_RegistrarVenta(
    IN p_id_cliente INT,
    IN p_id_empleado INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    -- 1. Declaración de variables para cálculos
    -- Definimos los contenedores para los datos que procesaremos internamente.
    DECLARE v_precio_prod DECIMAL(10,2);
    DECLARE v_stock_actual INT;
    DECLARE v_total_venta DECIMAL(10,2);
    DECLARE v_id_factura_generada INT;
    DECLARE v_error BOOLEAN DEFAULT FALSE;

    -- 2. Handler para errores (Si algo falla, marcamos error para hacer ROLLBACK)
    -- Este "sensor" se activa automáticamente ante cualquier fallo técnico de SQL.
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
         SET v_error = TRUE;

    -- 3. Iniciar la Transacción 
    -- Abrimos el bloque transaccional para asegurar la Atomicidad del proceso.
    START TRANSACTION;

    -- 4. Bloqueo de registros (Protección de Datos)
    -- Obtenemos el precio y el stock actual bloqueando la fila (FOR UPDATE)
    -- Esto evita que alguien más cambie el precio o el stock mientras operamos
    SELECT precio INTO v_precio_prod FROM PRODUCTO WHERE id_producto = p_id_producto 
    FOR UPDATE;
    SELECT stock_actual INTO v_stock_actual FROM INVENTARIO WHERE id_producto = p_id_producto 
    FOR UPDATE;

    -- 5. Validación de Negocio: ¿Hay suficiente stock?
    -- Verificación preventiva para no procesar ventas imposibles.
    -- Agregamos validación por si el producto no existe (v_stock_actual es NULL)
    IF v_stock_actual IS NULL OR v_stock_actual < p_cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No hay suficiente mercadería para esta venta.';
    END IF;
    
    IF NOT v_erro THEN

    -- 6. Cálculo del monto total de la operación
    SET v_total_venta = v_precio_prod * p_cantidad;

    -- 7. Operaciones Críticas (DML):
    
    -- A. Crear la Factura (encabezado)
    INSERT INTO FACTURA (id_cliente, id_empleado, fecha, total) 
    VALUES (p_id_cliente, p_id_empleado, NOW(), v_total_venta);
    
    -- Obtenemos el ID de la factura que acabamos de crear para relacionar el detalle
    SET v_id_factura_generada = LAST_INSERT_ID();

    -- B. Crear el Detalle (cuerpo de la factura)
    INSERT INTO DETALLE_FACTURA (id_factura, id_producto, cantidad, precio)
    VALUES (v_id_factura_generada, p_id_producto, p_cantidad, v_precio_prod);

    -- C. Descontar del Inventario (actualizacion de saldo)
    -- Esto dispara el Trigger de Auditoría de Inventario que ya hicimos)
    UPDATE INVENTARIO 
    SET stock_actual = stock_actual - p_cantidad 
    WHERE id_producto = p_id_producto;

    -- 8. Control Final de la Transacción (COMMIT o ROLLBACK)
    -- Aquí decidimos si guardamos los cambios o los borramos según el éxito del proceso.
    IF v_error THEN
        -- Si hubo un error en cualquier paso, deshacemos todo
        ROLLBACK;
        SELECT 'Error: La venta no se pudo procesar. Se revirtieron los cambios.' AS Resultado;
    ELSE
        -- Si todo salió bien, guardamos permanentemente
        COMMIT;
        SELECT 'Venta exitosa' AS Resultado, v_id_factura_generada AS NoFactura, v_total_venta AS TotalPagado;
    END IF;

END // -- fin del procedimiento

DELIMITER ; -- Restauramos el delimitador estándar