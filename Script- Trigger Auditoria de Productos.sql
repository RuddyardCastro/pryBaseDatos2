-- ============================================
-- 2. TRIGGER AUDITORIA DE PRODUCTOS
-- ============================================

-- ============================================================
-- NOMBRE: tr_Producto_Insert
-- TABLA: productos
-- TIPO: AFTER INSERT
-- ------------------------------------------------------------
-- DESCRIPCIÓN:
-- Este trigger se ejecuta después de insertar un nuevo producto.
-- Registra automáticamente en la bitácora los datos del producto
-- agregado.
--
-- FUNCIONAMIENTO:
-- 1. Captura los valores del nuevo registro (NEW).
-- 2. Inserta un registro en la tabla bitacora_auditoria.
-- 3. Guarda únicamente los datos nuevos, ya que no existen datos previos.
--
-- OBJETIVO:
-- Mantener un historial de los productos creados en el sistema.
-- ============================================================
DROP TRIGGER IF EXISTS tr_Producto_Insert;
DELIMITER //

CREATE TRIGGER tr_Producto_Insert  -- Nombre del trigger
AFTER INSERT ON productos  -- Se ejecuta DESPUÉS de insertar un producto
FOR EACH ROW
BEGIN

    -- Inserta un registro en la bitácora
    INSERT INTO bitacora_auditoria (
        NombreTabla,       -- Nombre de la tabla afectada
        Operacion,         -- Tipo de operación (INSERT)
        id_registro,       -- ID del registro afectado
        datos_anteriores,  -- Datos antes del cambio (NULL en este caso)
        datos_nuevos,      -- Datos nuevos del registro
        Usuario            -- Usuario que ejecuta la acción
    )
    VALUES (
        'productos',  -- Nombre de la tabla
        'INSERT',     -- Tipo de operación
        NEW.id_producto,  -- ID del nuevo producto
        NULL,  -- No hay datos anteriores
        JSON_OBJECT(  -- Construye un JSON con los datos nuevos
            'nombre', NEW.nombre,
            'precio', NEW.precio,
            'stock', NEW.stock
        ),
        CURRENT_USER()  -- Usuario actual de MySQL
    );

END //

DELIMITER ;

-- ============================================================
-- NOMBRE: tr_Producto_Update
-- TABLA: productos
-- TIPO: AFTER UPDATE
-- ------------------------------------------------------------
-- DESCRIPCIÓN:
-- Este trigger se ejecuta después de actualizar un producto.
-- Registra en la bitácora tanto los datos anteriores como los
-- nuevos valores del registro modificado.
--
-- FUNCIONAMIENTO:
-- 1. Captura los valores antiguos (OLD) y nuevos (NEW).
-- 2. Inserta ambos estados en la tabla bitacora_auditoria.
--
-- OBJETIVO:
-- Permitir la trazabilidad de cambios realizados en productos.
-- ============================================================
DROP TRIGGER IF EXISTS tr_Producto_Update;
DELIMITER //

CREATE TRIGGER tr_Producto_Update  -- Nombre del trigger
AFTER UPDATE ON productos  -- Se ejecuta DESPUÉS de actualizar un producto
FOR EACH ROW
BEGIN

    -- Inserta en la bitácora los cambios realizados
    INSERT INTO bitacora_auditoria (
        NombreTabla,
        Operacion,
        id_registro,
        datos_anteriores,
        datos_nuevos,
        Usuario
    )
    VALUES (
        'productos',
        'UPDATE',
        NEW.id_producto,  -- ID del producto modificado

        -- Datos anteriores (antes del cambio)
        JSON_OBJECT(
            'nombre', OLD.nombre,
            'precio', OLD.precio,
            'stock', OLD.stock
        ),

        -- Datos nuevos (después del cambio)
        JSON_OBJECT(
            'nombre', NEW.nombre,
            'precio', NEW.precio,
            'stock', NEW.stock
        ),

        CURRENT_USER()
    );

END //

DELIMITER ;

-- ============================================================
-- NOMBRE: tr_Producto_Delete
-- TABLA: productos
-- TIPO: AFTER DELETE
-- ------------------------------------------------------------
-- DESCRIPCIÓN:
-- Este trigger se ejecuta después de eliminar un producto.
-- Registra en la bitácora los datos del registro eliminado.
--
-- FUNCIONAMIENTO:
-- 1. Captura los valores anteriores del registro eliminado (OLD).
-- 2. Inserta la información en la tabla bitacora_auditoria.
-- 3. No existen datos nuevos, por lo que se guarda NULL.
--
-- OBJETIVO:
-- Mantener un historial de eliminaciones en el sistema.
-- ============================================================
DROP TRIGGER IF EXISTS tr_Producto_Delete;
DELIMITER //

CREATE TRIGGER tr_Producto_Delete  -- Nombre del trigger
AFTER DELETE ON productos  -- Se ejecuta DESPUÉS de eliminar un producto
FOR EACH ROW
BEGIN

    -- Inserta en la bitácora el registro eliminado
    INSERT INTO bitacora_auditoria (
        NombreTabla,
        Operacion,
        id_registro,
        datos_anteriores,
        datos_nuevos,
        Usuario
    )
    VALUES (
        'productos',
        'DELETE',
        OLD.id_producto,  -- ID del producto eliminado

        -- Datos anteriores (los que tenía antes de eliminarse)
        JSON_OBJECT(
            'nombre', OLD.nombre,
            'precio', OLD.precio,
            'stock', OLD.stock
        ),

        NULL,  -- No hay datos nuevos porque el registro ya no existe

        CURRENT_USER()
    );

END //

DELIMITER ;

