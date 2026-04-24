-- ============================================
-- 1. TRIGGER VALIDACION DE STOCK
-- ============================================

-- ============================================================
-- NOMBRE: tr_Validar_Stock
-- TABLA: detalle_facturas
-- TIPO: BEFORE INSERT
-- ------------------------------------------------------------
-- DESCRIPCIÓN:
-- Este trigger se ejecuta antes de insertar un registro en la
-- tabla detalle_facturas. Su función es validar que exista
-- suficiente stock del producto antes de realizar la venta.
-- ------------------------------------------------------------
-- FUNCIONAMIENTO:
-- 1. Obtiene el stock actual del producto desde la tabla productos.
-- 2. Compara el stock disponible con la cantidad solicitada.
-- 3. Si el stock es insuficiente, se lanza un error y se cancela
--    la operación.
-- -------------------------------------------------------------
-- OBJETIVO:
-- Evitar ventas inválidas y mantener la integridad del inventario.
-- ============================================================

DROP TRIGGER IF EXISTS tr_Validar_Stock;

-- Cambia el delimitador para poder usar ; dentro del trigger
DELIMITER //  

CREATE TRIGGER tr_Validar_Stock  -- Nombre del trigger
-- Se ejecuta ANTES de insertar en la tabla detalle_facturas
BEFORE INSERT ON detalle_facturas  
-- Se ejecuta por cada fila insertada
FOR EACH ROW  
BEGIN
    -- v_stock: almacenará temporalmente el stock del producto
    -- Si el producto no existe, su valor será NULL
    DECLARE v_stock INT;  

    -- Obtener el stock actual del producto desde la tabla productos
    -- NEW hace referencia al registro que se va a insertar
    -- Limit asegura que solo se obtenga un registro
    SELECT stock INTO v_stock
    FROM productos
    WHERE id_producto = NEW.id_producto
    LIMIT 1;
    
    -- VALIDACION 1: ¿el producto existe?
    -- Verifica si el producto existe; si no, cancela la operación.
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El código de producto no existe';
    END IF;
    
    -- VALIDACION 2: ¿hay suficiente stock?
    -- Verifica si hay suficiente stock; si no, bloquea la venta.
    -- Compara stock con la cantidad solicitada
    IF v_stock < NEW.cantidad THEN
        -- Lanza un error personalizado
        SIGNAL SQLSTATE '45000'  
        -- Mensaje del error
        SET MESSAGE_TEXT = 'Error: Stock insuficiente para la venta';  
    END IF;

END //

-- Restaura el delimitador original
DELIMITER ;
