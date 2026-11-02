DROP PROCEDURE IF EXISTS sp_nuevoActivo;
DELIMITER //

CREATE PROCEDURE sp_nuevoActivo(
    IN pIdUsuario INT, -- Para historial
    IN pIdMarca INT,
    IN pIdUbicacion INT,
    IN pIdTipo INT,
    IN pIdEstado INT,
    IN pidFactura INT,
    IN pidPersona INT,
    IN pidCompone INT,
    IN pNombre VARCHAR(45),

    IN pValoresAtributos JSON,  -- ahora es un par idAtributo: valor

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
    SELECT idMarca INTO vIdMarca FROM Marcas WHERE idMarca = pIdMarca LIMIT 1;
    SELECT idUbicacion INTO vIdUbicacion FROM Ubicaciones WHERE `idUbicacion` = pIdUbicacion LIMIT 1;
    SELECT idTipo INTO vIdTipo FROM Tipos WHERE `idTipo` = pIdTipo LIMIT 1;
    SELECT idEstado INTO vIdEstado FROM Estados WHERE `idEstado` = pIdEstado LIMIT 1;

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


    IF (
        SELECT COUNT(*)
        FROM Activos
        WHERE compone = pidCompone AND idTipo = vIdTipo 
        ) >= (SELECT ct.cantidadComponentesMaxima from `ComposicionTipos` ct 
        inner join `Activos` a on a.`idTipo`=ct.`idTipoPadre`
        where ct.`idTipoComponente`=vIdTipo and a.`idActivo`= pidCompone limit 1) THEN

            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El activo ya tiene demasiados componentes de este tipo';
    END IF;

    CALL `sp_verificarValores`(vIdTipo,pValoresAtributos);

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN (Activo + Historial)
    -- =========================================================================
    START TRANSACTION;

    -- Insertar el Activo
    INSERT INTO Activos(
        `idMarca`, `idUbicacion`, `idTipo`, `idEstado`, `idFactura`, `idPersona`, `compone`,
        `nombre`, `fechaRegistro`, `precioUnitario`, `numeroSerie`, `modelo`
    ) VALUES (
        vIdMarca, vIdUbicacion, vIdTipo, vIdEstado, pidFactura, pidPersona, pidCompone,
        pNombre, NOW(), pPrecioUnitario, pNumeroSerie, pModelo
    );

    -- Obtener el ID que se le acaba de asignar al Activo
    SET vIdActivo = LAST_INSERT_ID();

    -- Insertar los Valores de los aributos
    INSERT INTO Valores(idActivo, idAtributo, valor)  
    SELECT vIdActivo, 
    jt.idAtributo,
    JSON_UNQUOTE(
        JSON_EXTRACT(pValoresAtributos, CONCAT('$."', jt.idAtributo, '"'))
        ) AS valor
            FROM JSON_TABLE(
                JSON_KEYS(pValoresAtributos),
                '$[*]' COLUMNS (idAtributo INT PATH '$')
            ) AS jt;

    -- Insertar el registro de Creacion en el Historial
    CALL `sp_registrarHistorial`(
        pIdUsuario, 
        vIdActivo, 
        'Creacion del activo',
        'A',
        NULL,
            JSON_OBJECT(
			'Marca', pIdMarca,
			'Ubicacion', pIdUbicacion,
			'Tipo', pIdTipo,
			'Estado', pIdEstado,
			'Factura', pidFactura,
			'Persona', pidPersona,
			'Compone', pidCompone,
			'Nombre', pNombre,
			'Atributos', pValoresAtributos,
			'PrecioUnitario', pPrecioUnitario,
			'NumeroSerie', pNumeroSerie,
			'Modelo', pModelo
		    )
        );
    -- Confirmar los cambios
    COMMIT;

END//

DELIMITER ;
DROP PROCEDURE IF EXISTS sp_modificarActivo;
DELIMITER //


CREATE procedure sp_modificarActivo(
	-- Obligatorios Para historial y poder modificar
	IN pidActivo INT,
    IN pIdUsuario INT, -- 
    -- No pueden ser NULL
	IN pIdMarca INT,
    IN pIdUbicacion INT,
    IN pIdTipo INT,
    IN pIdEstado INT,
    -- Pueden ser NULL
    IN pidFactura INT,
    IN pidPersona INT,
    IN pidCompone INT,
    IN pNombre VARCHAR(45),
    IN pPrecioUnitario DECIMAL(12,2),
    IN pNumeroSerie VARCHAR(100),
    IN pModelo VARCHAR(50)
)
SALIR:BEGIN
    
    -- Variables para el update
    DECLARE vIdMarca INT;
	DECLARE vIdUbicacion INT;
	DECLARE vIdTipo INT;
	DECLARE vIdEstado INT;

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
    DECLARE oldPrecioUnitario DECIMAL(12,2);
    DECLARE oldNumeroSerie VARCHAR(100);
    DECLARE oldModelo VARCHAR(50);

    DECLARE newNombreMarca VARCHAR(45);
	DECLARE newNombreUbicacion VARCHAR(45);
	DECLARE newNombreTipo VARCHAR(45);
	DECLARE newNombreEstado VARCHAR(45);


    
    -- Manejador de errores: Si algo falla, deshace los cambios (Rollback)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; -- Re-lanza el error para que tu backend lo detecte
    END;
    -- TRIM de los parametros
    SET pIdMarca = TRIM(pIdMarca);
    SET pIdUbicacion = TRIM(pIdUbicacion);
    SET pIdTipo = TRIM(pIdTipo);
    SET pIdEstado = TRIM(pIdEstado);
    SET pNombre = TRIM(pNombre);
    SET pNumeroSerie = TRIM(pNumeroSerie);
    SET pModelo = TRIM(pModelo);
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
        IF pIdMarca IS NULL  OR pIdMarca = '' THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar una marca';
        END IF;

        IF pIdUbicacion IS NULL  OR pIdUbicacion = '' THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar una ubicación';
        END IF;

        IF pIdTipo IS NULL   OR pIdTipo = '' THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar un tipo'; 
        END IF;
        IF pIdEstado IS NULL  OR pIdEstado = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar un estado'; 
        END IF;
    
    SELECT idMarca, nombre INTO vIdMarca, newNombreMarca FROM Marcas WHERE `idMarca` = pIdMarca LIMIT 1;
	SELECT idUbicacion, nombre  INTO vIdUbicacion, newNombreUbicacion FROM Ubicaciones WHERE `idUbicacion` = pIdUbicacion LIMIT 1;
	SELECT idTipo, nombre  INTO vIdTipo, newNombreTipo FROM Tipos WHERE `idTipo` = pIdTipo LIMIT 1;
	SELECT idEstado, nombre  INTO vIdEstado, newNombreEstado FROM Estados WHERE `idEstado` = pIdEstado LIMIT 1;

    IF vIdMarca IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La marca no existe';
    END IF;

    IF vIdUbicacion IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ubicación no existe';
    END IF;

    IF vIdTipo IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo no existe'; 
    END IF;

    IF vIdEstado IS NULL THEN
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
			SET MESSAGE_TEXT = 'La persona indicada no existe';
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
        SELECT   a.idMarca, a.idUbicacion, a.idTipo, a.idEstado,m.nombre, u.nombre, t.nombre, e.nombre, a.idFactura, a.idPersona, a.compone, a.nombre, a.precioUnitario, a.numeroSerie, a.modelo
        INTO oldIdMarca, oldIdUbicacion, oldIdTipo, oldIdEstado, oldNombreMarca, oldNombreUbicacion, oldNombreTipo, oldNombreEstado, oldIdFactura, oldIdPersona, oldIdCompone, oldNombre, oldPrecioUnitario, oldNumeroSerie, oldModelo
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

    -- Verificar que no se supere la cantidad max de componentes de este tipo
    IF (
        SELECT COUNT(*)
        FROM Activos
        WHERE compone = pidCompone AND idTipo = vIdTipo and idActivo <> pidActivo
        ) >= (SELECT ct.cantidadComponentesMaxima from `ComposicionTipos` ct 
        inner join `Activos` a on a.`idTipo`=ct.`idTipoPadre`
        where ct.`idTipoComponente`=vIdTipo and a.`idActivo`= pidCompone limit 1) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El activo ya tiene demasiados componentes de este tipo';
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
    IF pPrecioUnitario IS NOT NULL AND pPrecioUnitario<0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio ingresado tiene que ser mayor a cero';
    END IF;

    
    -- =========================================================================
    -- Armar JSONs
    -- =========================================================================

        -- Depues armamos el JSON para los valores modificados

        SET vEstadoViejo = JSON_OBJECT();
        SET vEstadoNuevo = JSON_OBJECT();
        -- Estos no pueden ser NULL
        IF vIdMarca <> oldIdMarca THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Marca', oldNombreMarca);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Marca', newNombreMarca);
        END IF;

        IF vIdUbicacion <> oldIdUbicacion THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Ubicacion', oldNombreUbicacion);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Ubicacion', newNombreUbicacion);
        END IF;

        IF vIdTipo <> oldIdTipo THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Tipo', oldNombreTipo);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Tipo', newNombreTipo);
        END IF;

        IF vIdEstado <> oldIdEstado THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Estado', oldNombreEstado);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Estado', newNombreEstado);
        END IF;

        -- Estos pueden ser NULL por lo que se usa <=> 
        IF NOT pidFactura <=> oldIdFactura THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Factura', oldIdFactura);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Factura', pidFactura);
        END IF;

        IF NOT pidPersona <=> oldIdPersona THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Persona', oldIdPersona);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Persona', pidPersona);
        END IF;

        IF NOT pidCompone <=> oldIdCompone THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Compone', oldIdCompone);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Compone', pidCompone);
        END IF;

        IF NOT  pNombre <=> oldNombre THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Nombre', oldNombre);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Nombre', pNombre);
        END IF;

        IF  NOT pPrecioUnitario <=> oldPrecioUnitario THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.PrecioUnitario', oldPrecioUnitario);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.PrecioUnitario', pPrecioUnitario);
        END IF;

        IF  NOT pNumeroSerie <=> oldNumeroSerie THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.NumeroSerie', oldNumeroSerie);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.NumeroSerie', pNumeroSerie);
        END IF;

        IF NOT  pModelo <=> oldModelo THEN
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
        idMarca = vIdMarca,
        idUbicacion = vIdUbicacion,
        idTipo = vIdTipo,
        idEstado = vIdEstado,
        idFactura = pidFactura,
        idPersona = pidPersona,
        compone = pidCompone,
        nombre = pNombre,
        precioUnitario = pPrecioUnitario,
        numeroSerie = pNumeroSerie,
        modelo = pModelo
    WHERE a.idActivo = pidActivo;

    -- Insertar el registro de Creacion en el Historial    
    CALL `sp_registrarHistorial`(
        pIdUsuario, 
        pidActivo, 
        'Modificación del Activo', 
        'M',
        vEstadoViejo,
        vEstadoNuevo
        );    

    -- Confirmar los cambios
    COMMIT;

END//