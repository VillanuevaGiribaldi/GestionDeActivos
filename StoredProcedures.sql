
DROP PROCEDURE IF EXISTS sp_;
DELIMITER //

DROP PROCEDURE IF EXISTS sp_componerTipos;
DELIMITER //

CREATE procedure sp_componerTipos(
	IN NombreTipoPadre VARCHAR(45),
    IN NombreTipoComponente VARCHAR(45),
    IN Obligatorio BOOLEAN    
)
SALIR:BEGIN
	DECLARE vIdTipoPadre INT;
	DECLARE vIdTipoComponente INT;
    
	SELECT idTipo
	INTO vIdTipoPadre
	FROM Tipos
	WHERE nombre = NombreTipoPadre;
    
    IF vIdTipoPadre IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo padre no existe';
	END IF;


	SELECT idTipo
	INTO vIdTipoComponente
	FROM Tipos
	WHERE nombre = NombreTipoComponente;
    
    IF vIdTipoComponente IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo componente no existe';
	END IF;

	IF vIdTipoPadre = vIdTipoComponente THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un tipo de activo no puede componerse a si mismo';
        LEAVE SALIR;
    end if;
    
    IF (select idTipoPadre from ComposicionTipos ct where ct.idTipoComponente=vIdTipoComponente) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo ya es componente';
        LEAVE SALIR;
    end if;
    
    IF (select idTipoComponente from ComposicionTipos ct where ct.idTipoComponente=vIdTipoPadre) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un tipo no puede ser componenete de sus componentes';
        LEAVE SALIR;
    end if;
    
    insert into ComposicionTipos(idTipoPadre,idTipoComponente,Obligatorio) values (vIdTipoPadre,vIdTipoComponente,COALESCE(Obligatorio,false));

END//

DELIMITER ;



DROP PROCEDURE IF EXISTS sp_nuevoActivo;
DELIMITER //

CREATE procedure sp_nuevoActivo(
	IN pNombreMarca VARCHAR(45),
    IN pNombreUbicacion VARCHAR(45),
    IN pNombreTipo VARCHAR(45),
    IN pNombreEstado VARCHAR(45),
    IN pidFactura INT,
    IN pidPersona INT,
    IN pidCompone INT,
    IN pNombre VARCHAR(45),
    IN pAtributosExtra JSON,
    IN pPrecioUnitario DECIMAL(12,2),
    IN pNumeroSerie VARCHAR(100),
    IN pModelo VARCHAR(50)
)
SALIR:BEGIN
	-- Actualmente no se realiza ninguna verificación del JSON pAtributosExtra
    DECLARE vIdMarca INT;
	DECLARE vIdUbicacion INT;
	DECLARE vIdTipo INT;
	DECLARE vIdEstado INT;

	SELECT idMarca INTO vIdMarca FROM Marcas WHERE nombre LIKE pNombreMarca;
	SELECT idUbicacion INTO vIdUbicacion FROM Ubicaciones WHERE nombre LIKE pNombreUbicacion;
	SELECT idTipo INTO vIdTipo FROM Tipos WHERE nombre LIKE pNombreTipo;
	SELECT idEstado INTO vIdEstado FROM Estados WHERE nombre LIKE pNombreEstado;


	IF vIdMarca IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La marca no existe';
	END IF;

	IF vIdUbicacion IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La ubicacion no existe';
	END IF;

	IF vIdTipo IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo no existe';
	END IF;

	IF vIdEstado IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El estado no existe';
	END IF;

	IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre del activo es obligatorio';
	END IF;

	IF pidPersona IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Personas
		WHERE idPersona = pidPersona
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La persona no existe';
	END IF;

	IF pidFactura IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Facturas
		WHERE idFactura = pidFactura
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La factura no existe';
	END IF;

	IF pidCompone IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Activos
		WHERE idActivo = pidCompone
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El activo padre no existe';
	END IF;
    
    IF pidCompone IS NOT NULL AND NOT EXISTS (
		SELECT 1
        FROM Activos a 
        inner join ComposicionTipos ct on a.idTipo=ct.idTipoPadre
		where a.idActivo = pidCompone and ct.idTipoComponente = vIdTipo
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo del activo a crear no se corresponde con un componente valido del activo que se indicó';
	END IF;
    INSERT INTO Activos(
  `idMarca`, `idUbicacion`, `idTipo`, `idEstado`, `idFactura`, `idPersona`, `compone`,
  `nombre`, `fechaRegistro`, `atributosExtra`, `precioUnitario`, `numeroSerie`, `modelo`
)Values(
	vIdMarca, vIdUbicacion, vIdTipo, vIdEstado, pidFactura, pidPersona, pidCompone,
    pNombre,NOW(), pAtributosExtra, pPrecioUnitario, pNumeroSerie, pModelo
);

END//

DELIMITER ;

-- VERSION 2 DE sp_nuevoActivo()
DELIMITER //

CREATE PROCEDURE sp_nuevoActivo(
    IN pNombreMarca VARCHAR(45),
    IN pNombreUbicacion VARCHAR(45),
    IN pNombreTipo VARCHAR(45),
    IN pNombreEstado VARCHAR(45),
    IN pidFactura INT,
    IN pidPersona INT,
    IN pidCompone INT,
    IN pNombre VARCHAR(45),
    IN pAtributosExtra JSON,
    IN pPrecioUnitario DECIMAL(12,2),
    IN pNumeroSerie VARCHAR(100),
    IN pModelo VARCHAR(50),
    IN pIdUsuario INT -- NUEVO: Requerido para asentar el Historial
)
SALIR:BEGIN
    -- Declaración de variables
    DECLARE vIdMarca INT;
    DECLARE vIdUbicacion INT;
    DECLARE vIdTipo INT;
    DECLARE vIdEstado INT;
    DECLARE vIdActivo INT; -- NUEVO: Para guardar el ID del Activo creado

    -- Manejador de errores: Si algo falla, deshace los cambios (Rollback)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; -- Re-lanza el error para que tu backend lo detecte
    END;

    -- 1. Búsqueda de IDs (Usamos '=' en lugar de 'LIKE' para búsquedas exactas)
    SELECT idMarca INTO vIdMarca FROM Marcas WHERE nombre = pNombreMarca LIMIT 1;
    SELECT idUbicacion INTO vIdUbicacion FROM Ubicaciones WHERE nombre = pNombreUbicacion LIMIT 1;
    SELECT idTipo INTO vIdTipo FROM Tipos WHERE nombre = pNombreTipo LIMIT 1;
    SELECT idEstado INTO vIdEstado FROM Estados WHERE nombre = pNombreEstado LIMIT 1;

    -- 2. Validaciones de existencia de catálogos
    IF vIdMarca IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La marca no existe';
    END IF;

    IF vIdUbicacion IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ubicacion no existe';
    END IF;

    IF vIdTipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo no existe';
    END IF;

    IF vIdEstado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado no existe';
    END IF;

    -- 3. Validaciones de campos obligatorios y de formato
    IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del activo es obligatorio';
    END IF;

    -- NUEVO: Verificación de Usuario para el Historial
    IF pIdUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o es inválido';
    END IF;

    -- NUEVO: Verificación de Número de Serie Único
    IF pNumeroSerie IS NOT NULL AND EXISTS (SELECT 1 FROM Activos WHERE numeroSerie = pNumeroSerie) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de serie ingresado ya se encuentra registrado';
    END IF;

    -- NUEVO: Validación del formato JSON
    IF pAtributosExtra IS NOT NULL AND NOT JSON_VALID(pAtributosExtra) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los atributos extra no tienen un formato JSON válido';
    END IF;

    -- 4. Validaciones de Claves Foráneas
    IF pidPersona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Personas WHERE idPersona = pidPersona) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona no existe';
    END IF;

    IF pidFactura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Facturas WHERE idFactura = pidFactura) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La factura no existe';
    END IF;

    IF pidCompone IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Activos WHERE idActivo = pidCompone) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo padre no existe';
    END IF;
    
    IF pidCompone IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM Activos a 
        INNER JOIN ComposicionTipos ct ON a.idTipo = ct.idTipoPadre
        WHERE a.idActivo = pidCompone AND ct.idTipoComponente = vIdTipo
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo del activo a crear no se corresponde con un componente valido del activo que se indicó';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN (Activo + Historial)
    -- =========================================================================
    START TRANSACTION;

    -- Insertar el Activo
    INSERT INTO Activos(
        `idMarca`, `idUbicacion`, `idTipo`, `idEstado`, `idFactura`, `idPersona`, `compone`,
        `nombre`, `fechaRegistro`, `atributosExtra`, `precioUnitario`, `numeroSerie`, `modelo`
    ) VALUES (
        vIdMarca, vIdUbicacion, vIdTipo, vIdEstado, pidFactura, pidPersona, pidCompone,
        pNombre, NOW(), pAtributosExtra, pPrecioUnitario, pNumeroSerie, pModelo
    );

    -- Obtener el ID que se le acaba de asignar al Activo
    SET vIdActivo = LAST_INSERT_ID();

    -- Insertar el registro de Alta en el Historial
    INSERT INTO Historial (
        idUsuario, idActivo, fecha, comentario, tipo, estadoNuevo
    ) VALUES (
        pIdUsuario, 
        vIdActivo, 
        NOW(), 
        'Alta inicial del activo', 
        'A', 
        JSON_OBJECT('idEstado', vIdEstado, 'idUbicacion', vIdUbicacion)
    );

    -- Confirmar los cambios
    COMMIT;

END//

DELIMITER ;
-- ===========================================

DROP PROCEDURE IF EXISTS sp_modificarActivo;
DELIMITER //

CREATE procedure sp_modificarActivo(
	-- Obligatorios
	IN pidActivo INT,
    -- Dejar null los valores que no serán modificados
	IN pNombreMarca VARCHAR(45),
    IN pNombreUbicacion VARCHAR(45),
    IN pNombreTipo VARCHAR(45),
    IN pNombreEstado VARCHAR(45),
    IN pidFactura INT,
    IN pidPersona INT,
    IN pidCompone INT,
    IN pNombre VARCHAR(45),
    IN pAtributosExtra JSON,
    IN pPrecioUnitario DECIMAL(12,2),
    IN pNumeroSerie VARCHAR(100),
    IN pModelo VARCHAR(50)
)
SALIR:BEGIN
	-- Actualmente no se realiza ninguna verificación del JSON pAtributosExtra
    
    DECLARE vIdMarca INT;
	DECLARE vIdUbicacion INT;
	DECLARE vIdTipo INT;
	DECLARE vIdEstado INT;

	IF pidActivo IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Activos
		WHERE idActivo = pidActivo
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El activo que  desea modificar no existe';
	END IF; 
    IF pidActivo IS NULL
	THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Debe incluir un activo a modificar';
	END IF; 

	SELECT idMarca INTO vIdMarca FROM Marcas WHERE nombre LIKE pNombreMarca;
	SELECT idUbicacion INTO vIdUbicacion FROM Ubicaciones WHERE nombre LIKE pNombreUbicacion;
	SELECT idTipo INTO vIdTipo FROM Tipos WHERE nombre LIKE pNombreTipo;
	SELECT idEstado INTO vIdEstado FROM Estados WHERE nombre LIKE pNombreEstado;
	
	IF pidPersona IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Personas
		WHERE idPersona = pidPersona
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La persona no existe';
	END IF;

	IF pidFactura IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Facturas
		WHERE idFactura = pidFactura
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La factura no existe';
	END IF;

	IF pidCompone IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Activos
		WHERE idActivo = pidCompone
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El activo padre no existe';
	END IF;
    
    IF pidCompone IS NOT NULL AND NOT EXISTS (
		SELECT 1
        FROM Activos a 
        inner join ComposicionTipos ct on a.idTipo=ct.idTipoPadre
		where a.idActivo = pidCompone and ct.idTipoComponente = vIdTipo
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo del activo a modificar no se corresponde con un componente valido del activo que se indicó';
	END IF;
    UPDATE Activos a
		SET
			idMarca = COALESCE(vIdMarca, a.idMarca),
			idUbicacion = COALESCE(vIdUbicacion, a.idUbicacion),
			idTipo = COALESCE(vIdTipo, a.idTipo),
			idEstado = COALESCE(vIdEstado, a.idEstado),
			idFactura = COALESCE(pidFactura, a.idFactura),
			idPersona = COALESCE(pidPersona, a.idPersona),
			compone = COALESCE(pidCompone, a.compone),
			nombre = COALESCE(pNombre, a.nombre),
			atributosExtra = COALESCE(pAtributosExtra, a.atributosExtra),
			precioUnitario = COALESCE(pPrecioUnitario, a.precioUnitario),
			numeroSerie = COALESCE(pNumeroSerie, a.numeroSerie),
			modelo = COALESCE(pModelo, a.modelo)
		WHERE a.idActivo = pidActivo;

END//

DELIMITER ;

-- VERSION 2 DE sp_modifcarActivo()

DROP PROCEDURE IF EXISTS sp_modificarActivo;
DELIMITER //

CREATE PROCEDURE sp_modificarActivo(
    -- Obligatorios
    IN pidActivo INT,
    IN pIdUsuario INT, -- NUEVO: Requerido para asentar el Historial
    -- Dejar null los valores que no serán modificados
    IN pNombreMarca VARCHAR(45),
    IN pNombreUbicacion VARCHAR(45),
    IN pNombreTipo VARCHAR(45),
    IN pNombreEstado VARCHAR(45),
    IN pidFactura INT,
    IN pidPersona INT,
    IN pidCompone INT,
    IN pNombre VARCHAR(45),
    IN pAtributosExtra JSON,
    IN pPrecioUnitario DECIMAL(12,2),
    IN pNumeroSerie VARCHAR(100),
    IN pModelo VARCHAR(50)
)
SALIR:BEGIN
    -- Variables para nuevos IDs
    DECLARE vIdMarca INT;
    DECLARE vIdUbicacion INT;
    DECLARE vIdTipo INT;
    DECLARE vIdEstado INT;
    
    -- NUEVO: Variables para guardar el estado anterior (para el Historial y validaciones)
    DECLARE vViejoIdEstado INT;
    DECLARE vViejoIdUbicacion INT;
    DECLARE vViejoIdTipo INT;
    DECLARE vEffectiveIdTipo INT;

    -- Manejador de errores (Transacciones)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones Iniciales
    IF pidActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe incluir un activo a modificar';
    END IF;

    -- Obtener el estado actual del activo para el historial y comprobar que exista
    SELECT idEstado, idUbicacion, idTipo INTO vViejoIdEstado, vViejoIdUbicacion, vViejoIdTipo
    FROM Activos WHERE idActivo = pidActivo;

    IF vViejoIdEstado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo que desea modificar no existe';
    END IF;

    -- Validar Usuario (para Historial)
    IF pIdUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o es inválido';
    END IF;

    -- NUEVO: Validar formato JSON
    IF pAtributosExtra IS NOT NULL AND NOT JSON_VALID(pAtributosExtra) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los atributos extra no tienen un formato JSON válido';
    END IF;

    -- NUEVO: Validar número de serie único excluyendo el activo actual
    IF pNumeroSerie IS NOT NULL AND EXISTS (SELECT 1 FROM Activos WHERE numeroSerie = pNumeroSerie AND idActivo != pidActivo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de serie ingresado ya pertenece a otro activo';
    END IF;

    -- 2. Búsqueda de nuevos IDs (Solo si se proporcionaron y usando '=')
    IF pNombreMarca IS NOT NULL THEN
        SELECT idMarca INTO vIdMarca FROM Marcas WHERE nombre = pNombreMarca LIMIT 1;
        IF vIdMarca IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La marca no existe'; END IF;
    END IF;

    IF pNombreUbicacion IS NOT NULL THEN
        SELECT idUbicacion INTO vIdUbicacion FROM Ubicaciones WHERE nombre = pNombreUbicacion LIMIT 1;
        IF vIdUbicacion IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ubicación no existe'; END IF;
    END IF;

    IF pNombreTipo IS NOT NULL THEN
        SELECT idTipo INTO vIdTipo FROM Tipos WHERE nombre = pNombreTipo LIMIT 1;
        IF vIdTipo IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo no existe'; END IF;
    END IF;

    IF pNombreEstado IS NOT NULL THEN
        SELECT idEstado INTO vIdEstado FROM Estados WHERE nombre = pNombreEstado LIMIT 1;
        IF vIdEstado IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado no existe'; END IF;
    END IF;

    -- 3. Validaciones Foráneas
    IF pidPersona IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Personas WHERE idPersona = pidPersona) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona no existe';
    END IF;

    IF pidFactura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Facturas WHERE idFactura = pidFactura) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La factura no existe';
    END IF;

    IF pidCompone IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Activos WHERE idActivo = pidCompone) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo padre no existe';
    END IF;
    
    -- 4. Validación Compone (Usando el tipo nuevo o, en su defecto, el viejo)
    SET vEffectiveIdTipo = COALESCE(vIdTipo, vViejoIdTipo);
    
    IF pidCompone IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM Activos a 
        INNER JOIN ComposicionTipos ct ON a.idTipo = ct.idTipoPadre
        WHERE a.idActivo = pidCompone AND ct.idTipoComponente = vEffectiveIdTipo
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo del activo a modificar no se corresponde con un componente valido del activo que se indicó';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN
    -- =========================================================================
    START TRANSACTION;

    -- Actualizar Activos (tu lógica original con COALESCE, perfecta)
    UPDATE Activos a
    SET
        idMarca = COALESCE(vIdMarca, a.idMarca),
        idUbicacion = COALESCE(vIdUbicacion, a.idUbicacion),
        idTipo = COALESCE(vIdTipo, a.idTipo),
        idEstado = COALESCE(vIdEstado, a.idEstado),
        idFactura = COALESCE(pidFactura, a.idFactura),
        idPersona = COALESCE(pidPersona, a.idPersona),
        compone = COALESCE(pidCompone, a.compone),
        nombre = COALESCE(pNombre, a.nombre),
        atributosExtra = COALESCE(pAtributosExtra, a.atributosExtra),
        precioUnitario = COALESCE(pPrecioUnitario, a.precioUnitario),
        numeroSerie = COALESCE(pNumeroSerie, a.numeroSerie),
        modelo = COALESCE(pModelo, a.modelo)
    WHERE a.idActivo = pidActivo;

    -- NUEVO: Insertar en el Historial para auditoría
    INSERT INTO Historial (
        idUsuario, idActivo, fecha, comentario, tipo, estadoAnterior, estadoNuevo
    ) VALUES (
        pIdUsuario, 
        pidActivo, 
        NOW(), 
        'Modificación de parámetros del activo', 
        'M', 
        JSON_OBJECT('idEstado', vViejoIdEstado, 'idUbicacion', vViejoIdUbicacion),
        JSON_OBJECT('idEstado', COALESCE(vIdEstado, vViejoIdEstado), 'idUbicacion', COALESCE(vIdUbicacion, vViejoIdUbicacion))
    );

    COMMIT;

END//
DELIMITER ;
-- ==================================================== 

drop procedure if exists sp_listarTodo;
delimiter //
create procedure sp_listarTodo()
salir:begin
	SELECT 
		a.nombre AS 'Nombre Equipo',
		a.numeroSerie AS 'Nro Serie',
		t.nombre AS 'Tipo',
		m.nombre AS 'Marca',
		a.modelo AS 'Modelo',
		e.nombre AS 'Estado',
		CONCAT(p.nombre, ' ', p.apellido) AS 'Asignado a',
		u.nombre AS 'Ubicación'
	FROM Activos a
	INNER JOIN Tipos t ON a.idTipo = t.idTipo
	INNER JOIN Marcas m ON a.idMarca = m.idMarca
	INNER JOIN Estados e ON a.idEstado = e.idEstado
	LEFT JOIN Personas p ON a.idPersona = p.idPersona
	INNER JOIN Ubicaciones u ON a.idUbicacion = u.idUbicacion;

end//
DELIMITER ;

-- =====================================================
-- MARCAS
-- =====================================================

DROP PROCEDURE IF EXISTS sp_nuevaMarca;
DELIMITER //

CREATE PROCEDURE sp_nuevaMarca(
    IN pNombre VARCHAR(100),
    IN pDescripcion VARCHAR(45),
    IN pEstado CHAR(1)
)
SALIR:BEGIN

    IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la marca es obligatorio';
        LEAVE SALIR;
    END IF;

    INSERT INTO Marcas(nombre, descripcion, estado)
    VALUES (pNombre, pDescripcion, pEstado);

END//

DELIMITER ;


DROP PROCEDURE IF EXISTS sp_modificarMarca;
DELIMITER //

CREATE PROCEDURE sp_modificarMarca(
    -- Obligatorio
    IN pIdMarca INT,
    -- Dejar null los valores que no serán modificados
    IN pNombre VARCHAR(100),
    IN pDescripcion VARCHAR(45),
    IN pEstado CHAR(1)
)
SALIR:BEGIN

    IF pIdMarca IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe incluir una marca a modificar';
        LEAVE SALIR;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Marcas
        WHERE idMarca = pIdMarca
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La marca que desea modificar no existe';
        LEAVE SALIR;
    END IF;

    UPDATE Marcas m
        SET
            nombre = COALESCE(pNombre, m.nombre),
            descripcion = COALESCE(pDescripcion, m.descripcion),
            estado = COALESCE(pEstado, m.estado)
        WHERE m.idMarca = pIdMarca;

END//

DELIMITER ;


-- =====================================================
-- UBICACIONES
-- =====================================================

DROP PROCEDURE IF EXISTS sp_nuevaUbicacion;
DELIMITER //

CREATE PROCEDURE sp_nuevaUbicacion(
    IN pNombreUbicacionPadre VARCHAR(45),
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(100),
    IN pEstado CHAR(1)
)
SALIR:BEGIN
    DECLARE vIdUbicacionPadre INT;

    IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la ubicacion es obligatorio';
        LEAVE SALIR;
    END IF;

    IF pEstado IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El estado de la ubicacion es obligatorio';
        LEAVE SALIR;
    END IF;

    IF pNombreUbicacionPadre IS NOT NULL THEN
        SELECT idUbicacion
        INTO vIdUbicacionPadre
        FROM Ubicaciones
        WHERE nombre LIKE pNombreUbicacionPadre;

        IF vIdUbicacionPadre IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La ubicacion padre no existe';
            LEAVE SALIR;
        END IF;
    END IF;

    INSERT INTO Ubicaciones(idUbicacionPadre, nombre, descripcion, estado)
    VALUES (vIdUbicacionPadre, pNombre, pDescripcion, pEstado);

END//

DELIMITER ;


DROP PROCEDURE IF EXISTS sp_modificarUbicacion;
DELIMITER //

CREATE PROCEDURE sp_modificarUbicacion(
    -- Obligatorio
    IN pIdUbicacion INT,
    -- Dejar null los valores que no serán modificados
    IN pNombreUbicacionPadre VARCHAR(45),
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(100),
    IN pEstado CHAR(1)
)
SALIR:BEGIN
    DECLARE vIdUbicacionPadre INT;

    IF pIdUbicacion IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe incluir una ubicacion a modificar';
        LEAVE SALIR;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Ubicaciones
        WHERE idUbicacion = pIdUbicacion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La ubicacion que desea modificar no existe';
        LEAVE SALIR;
    END IF;

    IF pNombreUbicacionPadre IS NOT NULL THEN
        SELECT idUbicacion
        INTO vIdUbicacionPadre
        FROM Ubicaciones
        WHERE nombre LIKE pNombreUbicacionPadre;

        IF vIdUbicacionPadre IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La ubicacion padre no existe';
            LEAVE SALIR;
        END IF;

        IF vIdUbicacionPadre = pIdUbicacion THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Una ubicacion no puede ser padre de si misma';
            LEAVE SALIR;
        END IF;
    END IF;

    UPDATE Ubicaciones u
        SET
            idUbicacionPadre = COALESCE(vIdUbicacionPadre, u.idUbicacionPadre),
            nombre = COALESCE(pNombre, u.nombre),
            descripcion = COALESCE(pDescripcion, u.descripcion),
            estado = COALESCE(pEstado, u.estado)
        WHERE u.idUbicacion = pIdUbicacion;

END//

DELIMITER ;


-- =====================================================
-- PROVEEDORES
-- =====================================================

DROP PROCEDURE IF EXISTS sp_nuevoProveedor;
DELIMITER //

CREATE PROCEDURE sp_nuevoProveedor(
    IN pNombre VARCHAR(100),
    IN pDireccion VARCHAR(100),
    IN pTelefono VARCHAR(45),
    IN pMail VARCHAR(150),
    IN pDescripcion VARCHAR(200)
)
SALIR:BEGIN

    IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre del proveedor es obligatorio';
        LEAVE SALIR;
    END IF;

    INSERT INTO Proveedores(nombre, direccion, telefono, mail, descripcion)
    VALUES (pNombre, pDireccion, pTelefono, pMail, pDescripcion);

END//

DELIMITER ;


DROP PROCEDURE IF EXISTS sp_modificarProveedor;
DELIMITER //

CREATE PROCEDURE sp_modificarProveedor(
    -- Obligatorio
    IN pIdProveedor INT,
    -- Dejar null los valores que no serán modificados
    IN pNombre VARCHAR(100),
    IN pDireccion VARCHAR(100),
    IN pTelefono VARCHAR(45),
    IN pMail VARCHAR(150),
    IN pDescripcion VARCHAR(200)
)
SALIR:BEGIN

    IF pIdProveedor IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe incluir un proveedor a modificar';
        LEAVE SALIR;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE idProveedor = pIdProveedor
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El proveedor que desea modificar no existe';
        LEAVE SALIR;
    END IF;

    UPDATE Proveedores p
        SET
            nombre = COALESCE(pNombre, p.nombre),
            direccion = COALESCE(pDireccion, p.direccion),
            telefono = COALESCE(pTelefono, p.telefono),
            mail = COALESCE(pMail, p.mail),
            descripcion = COALESCE(pDescripcion, p.descripcion)
        WHERE p.idProveedor = pIdProveedor;

END//

DELIMITER ;
