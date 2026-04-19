-- Eliminamos los triggers anteriores para actualizarlos
DROP TRIGGER IF EXISTS trg_Productos_Insert;
DROP TRIGGER IF EXISTS trg_Productos_Update;
DROP TRIGGER IF EXISTS trg_Productos_Delete;

DELIMITER //

-- TRIGGER DE INSERCIÓN
CREATE TRIGGER trg_Productos_Insert
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora_auditoria (NombreTabla, Operacion, id_registro, datos_nuevos, Usuario, FechaHora)
    VALUES (
        'productos',
        'INSERT',
        NEW.id_producto,
        JSON_OBJECT('nombre', NEW.nombre, 'precio', NEW.precio, 'stock', NEW.stock),
        USER(), 
        NOW()
    );
END //

-- TRIGGER DE ACTUALIZACIÓN (El más importante para auditoría)
CREATE TRIGGER trg_Productos_Update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora_auditoria (NombreTabla, Operacion, id_registro, datos_anteriores, datos_nuevos, Usuario, FechaHora)
    VALUES (
        'productos',
        'UPDATE',
        OLD.id_producto,
        JSON_OBJECT('nombre', OLD.nombre, 'precio', OLD.precio, 'stock', OLD.stock),
        JSON_OBJECT('nombre', NEW.nombre, 'precio', NEW.precio, 'stock', NEW.stock),
        USER(), 
        NOW()
    );
END //

-- TRIGGER DE ELIMINACIÓN
CREATE TRIGGER trg_Productos_Delete
AFTER DELETE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora_auditoria (NombreTabla, Operacion, id_registro, datos_anteriores, Usuario, FechaHora)
    VALUES (
        'productos',
        'DELETE',
        OLD.id_producto,
        JSON_OBJECT('id', OLD.id_producto, 'nombre', OLD.nombre, 'precio', OLD.precio, 'stock', OLD.stock),
        USER(),
        NOW()
    );
END //

DELIMITER ;