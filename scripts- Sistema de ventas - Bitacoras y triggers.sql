-- ============================================================
-- 1. TABLA BITÁCORA 
-- ============================================================

CREATE TABLE IF NOT EXISTS Bitacora (
    BitacoraID INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único de cada registro en la bitácora
    NombreTabla VARCHAR(50),                   -- Nombre de la tabla afectada (PRODUCTO, INVENTARIO, etc.)
    Operacion VARCHAR(10),                     -- Tipo de operación realizada: INSERT, UPDATE o DELETE
    RegistroID INT,                            -- ID del registro afectado en la tabla original
    DatosAnteriores TEXT,                      -- Datos antes del cambio (OLD)
    DatosNuevos TEXT,                          -- Datos después del cambio (NEW)
    DireccionIP VARCHAR(50),                   -- IP o servidor desde donde se ejecuta la acción
    FechaHora DATETIME DEFAULT NOW(),          -- Fecha y hora automática del evento
    Usuario VARCHAR(100) -- Usuario que ejecutó la operación
) ENGINE=InnoDB;

-- ============================================================
-- 2. LOG AUDITORÍA PARA PRODUCTO 
-- ============================================================

DELIMITER //
-- ------------------------------------------------------------
-- TRIGGER: INSERT EN PRODUCTO (AUDITORÍA)
-- Se ejecuta después de insertar un producto
-- Registra los datos nuevos en la bitácora
-- ------------------------------------------------------------
CREATE TRIGGER trg_Producto_Insert 
AFTER INSERT ON PRODUCTO 
FOR EACH ROW  
BEGIN
    INSERT INTO Bitacora (
        NombreTabla, 
        Operacion, 
        RegistroID, 
        DatosAnteriores, 
        DatosNuevos, 
        DireccionIP
    )
    VALUES (
        'PRODUCTO',                  -- Tabla afectada
        'INSERT',                   -- Tipo de operación
         NEW.id_producto,            -- ID del nuevo producto
         NULL,                       -- No hay datos anteriores
         JSON_OBJECT(                -- Datos nuevos en formato JSON
            'id', NEW.id_producto, 
            'nombre', NEW.nombre,
            'precio', NEW.precio
        ), 
        SUBSTRING_INDEX(USER(), '@', -1) -- Obtiene el host/servidor desde donde se ejecuta la operación
    );
END //
DELIMITER ;

-- ------------------------------------------------------------
-- TRIGGER: UPDATE EN PRODUCTO (AUDITORÍA)
-- Se ejecuta después de actualizar un producto
-- Guarda valores antes (OLD) y después (NEW)
-- ------------------------------------------------------------
DELIMITER //

CREATE TRIGGER trg_Producto_Update 
AFTER UPDATE ON PRODUCTO 
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (
        NombreTabla, 
        Operacion, 
        RegistroID, 
        DatosAnteriores, 
        DatosNuevos, 
        DireccionIP
    )
    VALUES (
        'PRODUCTO',
        'UPDATE',
        NEW.id_producto,
        JSON_OBJECT(                -- Datos antes del cambio
            'id', OLD.id_producto, 
            'nombre', OLD.nombre, 
            'precio', OLD.precio
        ), 
        JSON_OBJECT(                -- Datos después del cambio
            'id', NEW.id_producto, 
            'nombre', NEW.nombre, 
            'precio', NEW.precio
        ),
        SUBSTRING_INDEX(USER(), '@', -1)
    );
END //
DELIMITER ;
-- ------------------------------------------------------------
-- TRIGGER: DELETE EN PRODUCTO (AUDITORÍA)
-- Se ejecuta después de eliminar un producto
-- Guarda los datos eliminados
-- ------------------------------------------------------------
DELIMITER //
CREATE TRIGGER trg_Producto_Delete 
AFTER DELETE ON PRODUCTO 
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (
        NombreTabla, 
        Operacion, 
        RegistroID, 
        DatosAnteriores, 
        DatosNuevos, 
        DireccionIP
    )
    VALUES (
        'PRODUCTO',
        'DELETE',                  -- Tipo de operación corregido
        OLD.id_producto,
        JSON_OBJECT(               -- Datos antes de eliminar
            'id', OLD.id_producto, 
            'nombre', OLD.nombre, 
            'precio', OLD.precio
        ), 
        NULL,                      -- No hay datos nuevos
        SUBSTRING_INDEX(USER(), '@', -1)
    );
END //

DELIMITER ;

-- ============================================================
-- 3. INVENTARIO: VALIDACIÓN Y AUDITORÍA
-- ============================================================

DELIMITER //

-- ------------------------------------------------------------
-- TRIGGER: VALIDACIÓN DE STOCK (BEFORE UPDATE)
-- Evita que el stock sea negativo
-- Se ejecuta antes de actualizar
-- ------------------------------------------------------------
CREATE TRIGGER trg_Inventario_Validar_Stock 
BEFORE UPDATE ON INVENTARIO 
FOR EACH ROW
BEGIN
    -- Si el nuevo stock es menor que 0, lanza error
    IF NEW.stock_actual < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Stock insuficiente para realizar la venta.';
    END IF;
END //
DELIMITER ;
-- ------------------------------------------------------------
-- TRIGGER: AUDITORÍA DE INVENTARIO (AFTER UPDATE)
-- Registra cambios de stock en la bitácora
-- Incluye el ID del producto para mejor trazabilidad
-- ------------------------------------------------------------
DELIMITER //
CREATE TRIGGER trg_Inventario_Audit_Update 
AFTER UPDATE ON INVENTARIO 
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (
        NombreTabla, 
        Operacion, 
        RegistroID, 
        DatosAnteriores, 
        DatosNuevos, 
        DireccionIP
    )
    VALUES (
        'INVENTARIO',
        'UPDATE',
        NEW.id_inventario,
        JSON_OBJECT(              -- Datos antes del cambio
            'producto', OLD.id_producto, 
            'stock', OLD.stock_actual
        ),
        JSON_OBJECT(              -- Datos después del cambio
            'producto', NEW.id_producto, 
            'stock', NEW.stock_actual
        ),
        SUBSTRING_INDEX(USER(), '@', -1)
    );
END //

DELIMITER ;

-- ============================================================
-- 4. AUDITORÍA DE VENTAS (FACTURA Y DETALLE)
-- ============================================================

DELIMITER //

-- ------------------------------------------------------------
-- TRIGGER: INSERT EN FACTURA (AUDITORÍA)
-- Se ejecuta cuando se registra una venta
-- Guarda información general de la factura
-- ------------------------------------------------------------
CREATE TRIGGER trg_Factura_Insert 
AFTER INSERT ON FACTURA 
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (
        NombreTabla, 
        Operacion, 
        RegistroID, 
        DatosAnteriores, 
        DatosNuevos, 
        DireccionIP
    )
    VALUES (
        'FACTURA',
        'INSERT',
        NEW.id_factura,
        NULL,
        JSON_OBJECT(             -- Datos de la venta
            'id', NEW.id_factura, 
            'cliente', NEW.id_cliente, 
            'total', NEW.total
        ),
        SUBSTRING_INDEX(USER(), '@', -1)
    );
END //
DELIMITER ;
-- ------------------------------------------------------------
-- TRIGGER: INSERT EN DETALLE_FACTURA (AUDITORÍA)
-- Se ejecuta cuando se agrega un producto a la factura
-- Permite saber qué productos se vendieron
-- ------------------------------------------------------------
DELIMITER //
CREATE TRIGGER trg_Detalle_Insert 
AFTER INSERT ON DETALLE_FACTURA 
FOR EACH ROW
BEGIN
    INSERT INTO Bitacora (
        NombreTabla, 
        Operacion, 
        RegistroID, 
        DatosAnteriores, 
        DatosNuevos, 
        DireccionIP
    )
    VALUES (
        'DETALLE_FACTURA',
        'INSERT',
        NEW.id_detalle,
        NULL,
        JSON_OBJECT(            -- Detalle de la venta
            'factura', NEW.id_factura, 
            'producto', NEW.id_producto, 
            'cantidad', NEW.cantidad, 
            'precio', NEW.precio
        ),
        SUBSTRING_INDEX(USER(), '@', -1)
    );
END //

DELIMITER ;