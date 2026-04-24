-- ============================================
-- 3. TRIGGER AUDITORIA DE CLIENTES
-- ============================================

-- ============================================================
-- NOMBRE: tr_Cliente_Update
-- TABLA: clientes
-- TIPO: AFTER UPDATE
-- ------------------------------------------------------------
-- DESCRIPCIÓN:
-- Este trigger se ejecuta después de modificar un cliente.
-- Registra los cambios realizados en los datos del cliente.
--
-- FUNCIONAMIENTO:
-- 1. Captura los datos anteriores (OLD) y nuevos (NEW).
-- 2. Inserta ambos en la tabla bitacora_auditoria.
--
-- OBJETIVO:
-- Detectar modificaciones en información sensible de clientes.
-- ============================================================
DROP TRIGGER IF EXISTS tr_Cliente_Update;
DELIMITER //

CREATE TRIGGER tr_Cliente_Update  -- Nombre del trigger
AFTER UPDATE ON clientes  -- Se ejecuta DESPUÉS de modificar un cliente
FOR EACH ROW
BEGIN

    -- Inserta en la bitácora los cambios realizados en clientes
    INSERT INTO bitacora_auditoria (
        NombreTabla,
        Operacion,
        id_registro,
        datos_anteriores,
        datos_nuevos,
        Usuario
    )
    VALUES (
        'clientes',
        'UPDATE',
        NEW.id_cliente,  -- ID del cliente modificado

        -- Datos anteriores
        JSON_OBJECT(
            'nombre', OLD.nombre,
            'apellido', OLD.apellido,
            'nit', OLD.nit
        ),

        -- Datos nuevos
        JSON_OBJECT(
            'nombre', NEW.nombre,
            'apellido', NEW.apellido,
            'nit', NEW.nit
        ),

        CURRENT_USER()
    );

END //

DELIMITER ;
