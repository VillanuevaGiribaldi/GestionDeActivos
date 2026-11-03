USE GestionDeActivos;

ALTER TABLE `Estados` ADD CONSTRAINT ck_estadoEstados
CHECK( estado ='A'or estado = 'I');
ALTER TABLE `Ubicaciones` ADD CONSTRAINT ck_estadoUbicaciones
CHECK( estado = 'A' or estado = 'I');

ALTER TABLE `Marcas` ADD CONSTRAINT ck_estadoMarcas
CHECK( estado = 'A' or estado = 'I');

ALTER TABLE `Personas` ADD CONSTRAINT ck_estadoPersonas
CHECK( estado = 'A' or estado = 'I');

ALTER TABLE `Tipos` ADD CONSTRAINT ck_estadoTipos
CHECK( estado = 'A' or estado = 'I');

ALTER TABLE `Proveedores` ADD CONSTRAINT ck_estadoProveedores
CHECK( estado = 'A' or estado = 'I');

ALTER TABLE `Facturas` ADD CONSTRAINT ck_estadoFacturas
CHECK( estado = 'A' or estado = 'I');

ALTER TABLE `Usuarios` ADD CONSTRAINT ck_estadoUsuarios
CHECK( estado = 'A' or estado = 'I');

ALTER TABLE `Imagenes` ADD CONSTRAINT ck_estadoImagenes
CHECK( estado = 'A' or estado = 'I');

ALTER TABLE `Facturas` ADD CONSTRAINT ck_montoFacturas
CHECK (monto > 0);

ALTER TABLE `Activos` ADD CONSTRAINT ck_precioActivos
CHECK (precioUnitario >= 0);

ALTER TABLE `Mantenimientos` ADD CONSTRAINT ck_estadoMantenimientos
CHECK( estado = 'A' or estado = 'I');
ALTER TABLE `Mantenimientos` ADD CONSTRAINT ck_costoMantenimientos
CHECK (costoTotal >= 0);

ALTER TABLE `Mantenimientos` ADD CONSTRAINT ck_fechasMantenimientos
CHECK (fechaDevolucion >= fechaEnvio);

ALTER TABLE `Historial` ADD CONSTRAINT ck_tipoHistorial
CHECK (tipo IN ('A', 'M', 'B', 'R', 'D'));

ALTER TABLE `Atributos` ADD CONSTRAINT ck_obligatorioAtributos
CHECK (obligatorio IN (0, 1));

ALTER TABLE `ComposicionTipos` ADD CONSTRAINT ck_cantidadMax
CHECK (cantidadComponentesMaxima >= 1);

DROP TRIGGER IF EXISTS trigg_up_rutaUbicacion;
DELIMITER //
CREATE TRIGGER trigg_up_rutaUbicacion
BEFORE UPDATE ON Ubicaciones
FOR EACH ROW
BEGIN
    DECLARE vRutaNueva VARCHAR(200);
    -- IF NOT (NEW.idUbicacionPadre <=> OLD.idUbicacionPadre) OR NOT (NEW.nombre <=> OLD.nombre) THEN
        CALL `sp_rutaUbicacion`(NEW.idUbicacion,NEW.nombre,vRutaNueva);
        SET NEW.ruta = vRutaNueva;
    -- END IF;
END//

