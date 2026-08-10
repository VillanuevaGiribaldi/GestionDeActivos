
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
    
    IF exists (select 1 from ComposicionTipos ct where ct.idTipoComponente=vIdTipoComponente) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo ya es componente';
        LEAVE SALIR;
    end if;
    
    IF exists (select 1 from ComposicionTipos ct where ct.idTipoComponente=vIdTipoPadre) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un tipo no puede ser componenete de sus componentes';
        LEAVE SALIR;
    end if;
    
    insert into ComposicionTipos(idTipoPadre,idTipoComponente,Obligatorio) values (vIdTipoPadre,vIdTipoComponente,COALESCE(Obligatorio,false));

END//

DELIMITER ;


-- =========================================== NUEVO ACTIVO
DELIMITER //

CREATE PROCEDURE sp_nuevoActivo(
    IN pIdUsuario INT, -- Para historial
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

    -- Verificar que se ingresa el usuario que hace el nuevo activo
    IF pIdUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o es inválido';
    END IF;

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
        JSON_OBJECT(
			'Marca', pNombreMarca,
			'Ubicacion', pNombreUbicacion,
			'Tipo', pNombreTipo,
			'Estado', pNombreEstado,
			'Factura', pidFactura,
			'Persona', pidPersona,
			'Compone', pidCompone,
			'Nombre', pNombre,
			'AtributosExtra', pAtributosExtra,
			'PrecioUnitario', pPrecioUnitario,
			'NumeroSerie', pNumeroSerie,
			'Modelo', pModelo
		)
    );

    -- Confirmar los cambios
    COMMIT;

END//

DELIMITER ;
-- =========================================== MODIFICAR ACTIVO

DROP PROCEDURE IF EXISTS sp_modificarActivo;
DELIMITER //

CREATE procedure sp_modificarActivo(
	-- Obligatorios Para historial
	IN pidActivo INT,
    IN pIdUsuario INT, -- 
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
    
    -- Variables para el update
    DECLARE vIdMarca INT;
	DECLARE vIdUbicacion INT;
	DECLARE vIdTipo INT;
	DECLARE vIdEstado INT;
    DECLARE vIdActivo INT;

    -- Variables para el historial

    DECLARE vEstadoViejo JSON;
    DECLARE vEstadoNuevo JSON;

    DECLARE oldIdMarca INT;
    DECLARE oldIdUbicacion INT;
    DECLARE oldIdTipo INT;
    DECLARE oldIdEstado INT;
    DECLARE oldNombreMarca VARCHAR(45);
    DECLARE oldNombreUbicacion VARCHAR(45);
    DECLARE oldNombreTipo VARCHAR(45);
    DECLARE oldNombreEstado VARCHAR(45);
    DECLARE oldIdFactura INT;
    DECLARE oldIdPersona INT;
    DECLARE oldIdCompone INT;
    DECLARE oldNombre VARCHAR(45);
    DECLARE oldAtributosExtra JSON;
    DECLARE oldPrecioUnitario DECIMAL(12,2);
    DECLARE oldNumeroSerie VARCHAR(100);
    DECLARE oldModelo VARCHAR(50);

    -- Manejador de errores: Si algo falla, deshace los cambios (Rollback)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; -- Re-lanza el error para que tu backend lo detecte
    END;

    -- Verificar que se ingresa el usuario que hace el nuevo activo
    IF pIdUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o es inválido';
    END IF;

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

-- ------------------------------------------------------------------------------ 
--  verificar que los Nombres de marca, ubicacion, tipo y estado dados se correspondan a uno existente
-- ------------------------------------------------------------------------------
    SELECT idMarca INTO vIdMarca FROM Marcas WHERE nombre = pNombreMarca LIMIT 1;
	SELECT idUbicacion INTO vIdUbicacion FROM Ubicaciones WHERE nombre = pNombreUbicacion LIMIT 1;
	SELECT idTipo INTO vIdTipo FROM Tipos WHERE nombre = pNombreTipo LIMIT 1;
	SELECT idEstado INTO vIdEstado FROM Estados WHERE nombre = pNombreEstado LIMIT 1;

        IF pNombreMarca  IS NOT NULL and vIdMarca IS NULL THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La marca no existe';
        END IF;

        IF pNombreUbicacion  IS NOT NULL and vIdUbicacion IS NULL THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ubicación no existe';
        END IF;

        IF pNombreTipo  IS NOT NULL and vIdTipo IS NULL THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo no existe'; 
        END IF;

        IF pNombreEstado IS NOT NULL and vIdEstado IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado no existe'; 
        END IF;

-- ------------------------------------------------------------------------------ 
--  verificar que los ids de Persona, factura y Activo que compone dados se correspondan a uno existente
-- ------------------------------------------------------------------------------    
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

     -- Copiamos los valores viejos en las variables old, esto es usado principalmente para el JSON
     -- Pero tambien sirve para la verificación siguiente:
        SELECT   a.idMarca, a.idUbicacion, a.idTipo, a.idEstado,m.nombre, u.nombre, t.nombre, e.nombre, a.idFactura, a.idPersona, a.compone, a.nombre, a.atributosExtra, a.precioUnitario, a.numeroSerie, a.modelo
        INTO oldIdMarca, oldIdUbicacion, oldIdTipo, oldIdEstado, oldNombreMarca, oldNombreUbicacion, oldNombreTipo, oldNombreEstado, oldIdFactura, oldIdPersona, oldIdCompone, oldNombre, oldAtributosExtra, oldPrecioUnitario, oldNumeroSerie, oldModelo
        FROM Activos a
        JOIN Marcas m ON m.idMarca = a.idMarca
        JOIN Ubicaciones u ON u.idUbicacion = a.idUbicacion
        JOIN Tipos t ON t.idTipo = a.idTipo
        JOIN Estados e ON e.idEstado = a.idEstado
        WHERE a.idActivo = pidActivo;
    
    IF pidCompone IS NOT NULL AND NOT EXISTS (
		SELECT 1
        FROM Activos a 
        inner join ComposicionTipos ct on a.idTipo=ct.idTipoPadre
        -- Como vIdTipo puede ser nulo, si es que no voy a modificarlo, hago coalesce con el tipo viejo
		where a.idActivo = pidCompone  and (ct.idTipoComponente = COALESCE(vIdTipo,oldIdTipo) )
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo del activo a modificar no se corresponde con un componente valido del activo que se indicó';
	END IF;

        
    -- Validar formato JSON
    IF pAtributosExtra IS NOT NULL AND NOT JSON_VALID(pAtributosExtra) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los atributos extra no tienen un formato JSON válido';
    END IF;

    -- Validar número de serie único excluyendo el activo actual
    IF pNumeroSerie IS NOT NULL AND EXISTS (SELECT 1 FROM Activos WHERE numeroSerie = pNumeroSerie AND idActivo != pidActivo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de serie ingresado ya pertenece a otro activo';
    END IF;

    -- Validar nombre asignado al dispositivo único excluyendo el activo actual
    IF pNombre IS NOT NULL AND EXISTS (SELECT 1 FROM Activos WHERE nombre = pNombre AND idActivo != pidActivo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre ingresado ya pertenece a otro activo';
    END IF;

     -- Verificar que el precio unitario sea mayor a cero
    IF pNombre IS NOT NULL AND pPrecioUnitario<0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio ingresado tiene que ser mayor a cero';
    END IF;
    
    -- =========================================================================
    -- Armar JSONs
    -- =========================================================================

        -- Depues armamos el JSON para los valores modificados

        SET vEstadoViejo = JSON_OBJECT();
        SET vEstadoNuevo = JSON_OBJECT();
        IF vIdMarca IS NOT NULL AND vIdMarca <> oldIdMarca THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Marca', oldNombreMarca);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Marca', pNombreMarca);
        END IF;

        IF vIdUbicacion IS NOT NULL AND vIdUbicacion <> oldIdUbicacion THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Ubicacion', oldNombreUbicacion);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Ubicacion', pNombreUbicacion);
        END IF;

        IF vIdTipo IS NOT NULL AND vIdTipo <> oldIdTipo THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Tipo', oldNombreTipo);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Tipo', pNombreTipo);
        END IF;

        IF vIdEstado IS NOT NULL AND vIdEstado <> oldIdEstado THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Estado', oldNombreEstado);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Estado', pNombreEstado);
        END IF;

        IF pidFactura IS NOT NULL AND pidFactura <> oldIdFactura THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Factura', oldIdFactura);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Factura', pidFactura);
        END IF;

        IF pidPersona IS NOT NULL AND pidPersona <> oldIdPersona THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Persona', oldIdPersona);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Persona', pidPersona);
        END IF;

        IF pidCompone IS NOT NULL AND pidCompone <> oldIdCompone THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Compone', oldIdCompone);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Compone', pidCompone);
        END IF;

        IF pNombre IS NOT NULL AND pNombre <> oldNombre THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Nombre', oldNombre);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Nombre', pNombre);
        END IF;

        IF pAtributosExtra IS NOT NULL AND pAtributosExtra <> oldAtributosExtra THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.AtributosExtra', oldAtributosExtra);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.AtributosExtra', pAtributosExtra);
        END IF;

        IF pPrecioUnitario IS NOT NULL AND pPrecioUnitario <> oldPrecioUnitario THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.PrecioUnitario', oldPrecioUnitario);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.PrecioUnitario', pPrecioUnitario);
        END IF;

        IF pNumeroSerie IS NOT NULL AND pNumeroSerie <> oldNumeroSerie THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.NumeroSerie', oldNumeroSerie);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.NumeroSerie', pNumeroSerie);
        END IF;

        IF pModelo IS NOT NULL AND pModelo <> oldModelo THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Modelo', oldModelo);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Modelo', pModelo);
        END IF;
    -- =========================================================================
    -- Verificar que haya algún cambio
    -- ========================================================================
    IF JSON_LENGTH(vEstadoNuevo) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se realizaron cambios en el activo';
    END IF;
    -- =========================================================================
    -- INICIO DE TRANSACCIÓN (Activo + Historial)
    -- =========================================================================
    START TRANSACTION;

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
        
        


    -- Insertar el registro de Alta en el Historial
    INSERT INTO Historial (
        idUsuario, idActivo, fecha, comentario, tipo, estadoNuevo, estadoAnterior
    ) VALUES (
        pIdUsuario, 
        pIdActivo, 
        NOW(), 
        'Modificación del Activo', 
        'M', 
        vEstadoNuevo,
         vEstadoViejo
        
    );

    -- Confirmar los cambios
    COMMIT;

END//

DELIMITER ;

-- =======================================================================

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
    IN pEstado CHAR(1),
    OUT pIdMarca INT
)
BEGIN
    -- Sanitización de entrada (quitar espacios innecesarios)
    SET pNombre = TRIM(pNombre);
    SET pDescripcion = TRIM(pDescripcion);

    -- Validación de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la marca es obligatorio';
    END IF;

    -- Validación de duplicados controlada
    IF EXISTS (SELECT 1 FROM Marcas WHERE nombre LIKE pNombre) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La marca ingresada ya existe en el sistema';
    END IF;

    -- Valor por defecto para el estado si viene nulo
    IF pEstado IS NULL OR TRIM(pEstado) = '' THEN
        SET pEstado = 'A'; -- Asumiendo que 'A' significa Activo
    END IF;

    -- Inserción
    INSERT INTO Marcas (nombre, descripcion, estado)
    VALUES (pNombre, pDescripcion, pEstado);
    
    -- Capturamos el ID de la marca recién insertada y lo asignamos al parámetro de salida
    SET pIdMarca = LAST_INSERT_ID();

END//

DELIMITER ;

-- ===================================
-- modificarMarca

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
BEGIN

    -- 1. Sanitización de entrada y control de vacíos
    IF pNombre IS NOT NULL THEN
        SET pNombre = TRIM(pNombre);
        IF pNombre = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El nombre de la marca no puede estar vacío';
        END IF;
    END IF;

    IF pDescripcion IS NOT NULL THEN
        SET pDescripcion = TRIM(pDescripcion);
    END IF;

    -- 2. Validación de parámetro obligatorio
    IF pIdMarca IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe incluir una marca a modificar';
    END IF;

    -- 3. Validación de existencia de la marca
    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE idMarca = pIdMarca) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La marca que desea modificar no existe';
    END IF;

    -- 4. Validación de nombre duplicado (excluyendo la marca actual)
    IF pNombre IS NOT NULL AND EXISTS (SELECT 1 FROM Marcas WHERE nombre = pNombre AND idMarca != pIdMarca) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nuevo nombre ingresado ya pertenece a otra marca registrada';
    END IF;

    -- 5. Actualización
    UPDATE Marcas m
        SET
            nombre = COALESCE(pNombre, m.nombre),
            descripcion = COALESCE(pDescripcion, m.descripcion),
            estado = COALESCE(pEstado, m.estado)
        WHERE m.idMarca = pIdMarca;

END//

DELIMITER ;
-- ==========================================

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
-- nuevaUbicacion Version 2
DROP PROCEDURE IF EXISTS sp_nuevaUbicacion;
DELIMITER //

CREATE PROCEDURE sp_nuevaUbicacion(
    IN pNombreUbicacionPadre VARCHAR(45),
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(100),
    IN pEstado CHAR(1),
    OUT pIdUbicacion INT -- Parámetro de salida para el ID generado
)
BEGIN
    DECLARE vIdUbicacionPadre INT;

    -- 1. Sanitización de entradas (TRIM)
    SET pNombre = TRIM(pNombre);
    SET pDescripcion = TRIM(pDescripcion);
        
    IF pEstado IS NOT NULL THEN
        SET pEstado = TRIM(pEstado);
    END IF;

    -- 2. Validaciones de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la ubicación es obligatorio';
    END IF;

    -- 3. Validación de duplicados (UNIQUE INDEX en 'nombre')
    IF EXISTS (SELECT 1 FROM Ubicaciones WHERE nombre = pNombre) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La ubicación ingresada ya existe en el sistema';
    END IF;

    -- 4. Búsqueda y validación de la Ubicación Padre
    IF pNombreUbicacionPadre IS NOT NULL AND pNombreUbicacionPadre != '' THEN
        -- Usamos '=' en lugar de 'LIKE' para mayor precisión y rendimiento
        SELECT idUbicacion INTO vIdUbicacionPadre
        FROM Ubicaciones
        WHERE nombre = pNombreUbicacionPadre LIMIT 1;

        IF vIdUbicacionPadre IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La ubicación padre indicada no existe';
        END IF;
    END IF;

    
    -- 5. Inserción de la nueva ubicación
    INSERT INTO Ubicaciones(idUbicacionPadre, nombre, descripcion, estado)
    VALUES (vIdUbicacionPadre, pNombre, pDescripcion, COALESCE(pEstado,'A'));
    
    -- 6. Captura y retorno del ID autogenerado
    SET pIdUbicacion = LAST_INSERT_ID();

END//

DELIMITER ;

-- =========================================
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
            IF pNombreUbicacionPadre <> 'NULL' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'La ubicacion padre no existe';
                LEAVE SALIR;
            END IF;
                
        END IF;

        IF vIdUbicacionPadre = pIdUbicacion THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Una ubicacion no puede ser padre de si misma';
            LEAVE SALIR;
        END IF;
        IF EXISTS (
            WITH RECURSIVE Ancestros AS (
                SELECT idUbicacion, idUbicacionPadre
                FROM Ubicaciones
                WHERE idUbicacion = vIdUbicacionPadre

                UNION ALL

                SELECT u.idUbicacion, u.idUbicacionPadre
                FROM Ubicaciones u
                INNER JOIN Ancestros a ON u.idUbicacion = a.idUbicacionPadre
            )
            SELECT 1 FROM Ancestros WHERE idUbicacion = pIdUbicacion
            ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No puede asignarse a esta ubicacion como padre por que se genereraría un lazo en la jeraquia de ubicaciones';
        END IF;
    END IF;

    UPDATE Ubicaciones u
        SET
            idUbicacionPadre = vIdUbicacionPadre,
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

-- nuevoProveedor version 2
DROP PROCEDURE IF EXISTS sp_nuevoProveedor;
DELIMITER //

CREATE PROCEDURE sp_nuevoProveedor(
    IN pNombre VARCHAR(100),
    IN pDireccion VARCHAR(100),
    IN pTelefono VARCHAR(45),
    IN pMail VARCHAR(150),
    IN pDescripcion VARCHAR(200),
    OUT pIdProveedor INT -- MEJORA: Parámetro de salida para el ID
)
BEGIN
    -- 1. Sanitización de entradas (TRIM)
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pDireccion IS NOT NULL THEN SET pDireccion = TRIM(pDireccion); END IF;
    IF pTelefono IS NOT NULL THEN SET pTelefono = TRIM(pTelefono); END IF;
    IF pMail IS NOT NULL THEN SET pMail = TRIM(pMail); END IF;
    IF pDescripcion IS NOT NULL THEN SET pDescripcion = TRIM(pDescripcion); END IF;

    -- 2. Validación de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre del proveedor es obligatorio';
    END IF;

    -- 3. Validación de duplicados (UNIQUE INDEX en 'nombre')
    IF EXISTS (SELECT 1 FROM Proveedores WHERE nombre = pNombre) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El proveedor ingresado ya existe en el sistema';
    END IF;

    -- 4. Inserción
    INSERT INTO Proveedores(nombre, direccion, telefono, mail, descripcion)
    VALUES (pNombre, pDireccion, pTelefono, pMail, pDescripcion);
    
    -- 5. Captura y retorno del ID autogenerado
    SET pIdProveedor = LAST_INSERT_ID();

END//

DELIMITER ;
-- =====================================

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

-- Lo que me sugiere gemini para manejar las modificaciones que pasen a null
DROP PROCEDURE IF EXISTS sp_modificarProveedor;
DELIMITER //

CREATE PROCEDURE sp_modificarProveedor(
    -- Obligatorio
    IN pIdProveedor INT,
    IN pNombre VARCHAR(100),
    
    -- Opcionales (Si se envía NULL, el campo se vaciará en la base de datos)
    IN pDireccion VARCHAR(100),
    IN pTelefono VARCHAR(45),
    IN pMail VARCHAR(150),
    IN pDescripcion VARCHAR(200)
)
BEGIN

    -- 1. Sanitización de entradas (TRIM)
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pDireccion IS NOT NULL THEN SET pDireccion = TRIM(pDireccion); END IF;
    IF pTelefono IS NOT NULL THEN SET pTelefono = TRIM(pTelefono); END IF;
    IF pMail IS NOT NULL THEN SET pMail = TRIM(pMail); END IF;
    IF pDescripcion IS NOT NULL THEN SET pDescripcion = TRIM(pDescripcion); END IF;

    -- 2. Validaciones iniciales
    IF pIdProveedor IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe incluir un proveedor a modificar';
    END IF;

    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre del proveedor es obligatorio';
    END IF;

    -- 3. Validación de existencia del proveedor
    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE idProveedor = pIdProveedor) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El proveedor que desea modificar no existe';
    END IF;

    -- 4. Validación de nombre duplicado (UNIQUE INDEX), excluyendo el proveedor actual
    IF EXISTS (SELECT 1 FROM Proveedores WHERE nombre = pNombre AND idProveedor != pIdProveedor) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre ingresado ya pertenece a otro proveedor registrado';
    END IF;

    -- 5. Actualización con Reemplazo Total (sin COALESCE)
    UPDATE Proveedores
        SET
            nombre = pNombre,
            direccion = pDireccion,
            telefono = pTelefono,
            mail = pMail,
            descripcion = pDescripcion
        WHERE idProveedor = pIdProveedor;

END//

DELIMITER ;