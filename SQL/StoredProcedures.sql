-- =====================================================
-- TIPOS
-- =====================================================
-- ======================================== Nuevo Tipos
DROP PROCEDURE IF EXISTS sp_nuevoTipo;
DELIMITER //

CREATE PROCEDURE sp_nuevoTipo(
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(100),
    IN pEstado CHAR(1),
    OUT pIdTipo INT
)
BEGIN
    -- 1. Sanitización de entradas
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pDescripcion IS NOT NULL THEN SET pDescripcion = TRIM(pDescripcion); END IF;
    IF pEstado IS NOT NULL THEN SET pEstado = TRIM(pEstado); END IF;

    -- 2. Validación de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del tipo de activo es obligatorio';
    END IF;

    -- 3. Validación de duplicados (UNIQUE INDEX en 'nombre')
    IF EXISTS (SELECT 1 FROM Tipos WHERE nombre = pNombre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del tipo ingresado ya existe en el sistema';
    END IF;

    -- 4. Estado por defecto
    IF pEstado IS NULL OR pEstado = '' THEN
        SET pEstado = 'A'; -- 'A' representa Activo
    END IF;

    -- 5. Inserción del registro
    INSERT INTO Tipos (nombre, descripcion, estado)
    VALUES (pNombre, pDescripcion, pEstado);

    -- 6. Retorno del ID autogenerado (Fundamental para insertar luego sus atributos)
    SET pIdTipo = LAST_INSERT_ID();

END//
DELIMITER ;

-- ======================================== Modificar Tipos
DROP PROCEDURE IF EXISTS sp_modificarTipo;
DELIMITER //

CREATE PROCEDURE sp_modificarTipo(
    IN pIdTipo INT,
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(100)
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pDescripcion IS NOT NULL THEN SET pDescripcion = TRIM(pDescripcion); END IF;

    -- 2. Validaciones iniciales
    IF pIdTipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el tipo de activo a modificar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Tipos WHERE idTipo = pIdTipo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de activo indicado no existe en el sistema';
    END IF;

    -- 3. Validación de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del tipo de activo es obligatorio';
    END IF;

    -- 4. Validación de Nombre duplicado (Excluyendo el tipo actual)
    IF EXISTS (SELECT 1 FROM Tipos WHERE nombre = pNombre AND idTipo != pIdTipo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre ingresado ya pertenece a otro tipo de activo registrado';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 5. Actualización con Reemplazo Total
    UPDATE Tipos 
    SET 
        nombre = pNombre,
        descripcion = pDescripcion
    WHERE idTipo = pIdTipo;

    COMMIT;

END//
DELIMITER ;
-- ======================================== Baja Tipos
DROP PROCEDURE IF EXISTS sp_bajaTipo;
DELIMITER //

CREATE PROCEDURE sp_bajaTipo(
    IN pIdTipo INT
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones iniciales
    IF pIdTipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el tipo a dar de baja';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Tipos WHERE idTipo = pIdTipo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo indicado no existe en el sistema';
    END IF;

    -- 2. REGLA CRÍTICA: Control de activos asociados
    -- Validamos si existen activos en el sistema que usen este tipo
    IF EXISTS (SELECT 1 FROM Activos WHERE idTipo = pIdTipo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede dar de baja el tipo porque existen activos vinculados a él. Debe reclasificarlos primero.';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 3. Baja Lógica
    UPDATE Tipos 
    SET estado = 'I' -- 'I' representa Inactivo/Baja
    WHERE idTipo = pIdTipo;

    COMMIT;

END//
DELIMITER ;

-- ======================================== Alta Tipos
DROP PROCEDURE IF EXISTS sp_altaTipo;
DELIMITER //
CREATE PROCEDURE sp_altaTipo(IN pIdTipo INT)
BEGIN
    IF pIdTipo IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el tipo a dar de alta'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Tipos WHERE idTipo = pIdTipo) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo indicado no existe'; END IF;
    UPDATE Tipos SET estado = 'A' WHERE idTipo = pIdTipo;
END//
DELIMITER ;

-- =====================================================
-- ATRIBUTOS
-- =====================================================
-- ======================================== Nuevo Atributo
DROP PROCEDURE IF EXISTS sp_nuevoAtributo;
DELIMITER //

CREATE PROCEDURE sp_nuevoAtributo(
    IN pIdTipo INT,
    IN pNombre VARCHAR(45),
    IN pPorDefecto VARCHAR(100),
    IN pObligatorio BOOLEAN,
    OUT pIdAtributo INT
)
BEGIN
    DECLARE vEstadoTipo CHAR(1);

    -- 1. Sanitización de entradas
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pPorDefecto IS NOT NULL THEN SET pPorDefecto = TRIM(pPorDefecto); END IF;

    -- 2. Validaciones de campos obligatorios
    IF pIdTipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar a qué tipo de activo pertenece el atributo';
    END IF;

    -- Aunque en la BD permite NULL, por regla de negocio un atributo debe tener nombre
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del atributo es obligatorio';
    END IF;

    -- 3. Validación de integridad del Tipo (Padre)
    SELECT estado INTO vEstadoTipo FROM Tipos WHERE idTipo = pIdTipo;
    
    IF vEstadoTipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de activo indicado no existe en el sistema';
    ELSEIF vEstadoTipo = 'I' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden agregar atributos a un tipo de activo que se encuentra dado de baja';
    END IF;

    -- 4. Validación de Duplicados en la misma plantilla (UX_tipoNombre)
    IF EXISTS (SELECT 1 FROM Atributos WHERE idTipo = pIdTipo AND nombre = pNombre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este tipo de activo ya posee un atributo registrado con ese mismo nombre';
    END IF;

    -- 5. Manejo de valores por defecto lógicos
    IF pObligatorio IS NULL THEN
        SET pObligatorio = FALSE; -- 0 en MySQL
    END IF;

    -- 6. Inserción del registro
    INSERT INTO Atributos (idTipo, nombre, porDefecto, obligatorio)
    VALUES (pIdTipo, pNombre, pPorDefecto, pObligatorio);

    -- 7. Retorno del ID autogenerado
    SET pIdAtributo = LAST_INSERT_ID();

END//
DELIMITER ;

-- ======================================== Modificar Atributos
DROP PROCEDURE IF EXISTS sp_modificarAtributo;
DELIMITER //

CREATE PROCEDURE sp_modificarAtributo(
    IN pIdAtributo INT,
    IN pIdTipo INT,
    IN pNombre VARCHAR(45),
    IN pPorDefecto VARCHAR(100),
    IN pObligatorio BOOLEAN
)
BEGIN
    DECLARE vEstadoTipo CHAR(1);
    DECLARE vIdTipoOld INT;

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pPorDefecto IS NOT NULL THEN SET pPorDefecto = TRIM(pPorDefecto); END IF;

    -- 2. Validaciones iniciales de existencia
    IF pIdAtributo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el ID del atributo a modificar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Atributos WHERE idAtributo = pIdAtributo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El atributo indicado no existe en el sistema';
    END IF;

    -- 3. Validaciones de campos obligatorios
    IF pIdTipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar a qué tipo de activo pertenece el atributo';
    END IF;

    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del atributo es obligatorio';
    END IF;

    -- 4. Validación de integridad del Tipo Padre
    SELECT estado INTO vEstadoTipo FROM Tipos WHERE idTipo = pIdTipo;
    
    IF vEstadoTipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de activo asignado no existe en el sistema';
    ELSEIF vEstadoTipo = 'I' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede asignar el atributo a un tipo de activo que se encuentra dado de baja';
    END IF;

    -- 5. Validación de Duplicados en la plantilla (UX_tipoNombre) excluyendo a sí mismo
    IF EXISTS (
        SELECT 1 FROM Atributos 
        WHERE idTipo = pIdTipo 
        AND nombre = pNombre 
        AND idAtributo != pIdAtributo
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este tipo de activo ya posee otro atributo registrado con ese mismo nombre';
    END IF;
    
    SELECT idTipo INTO vIdTipoOld FROM `Tipos`t
    INNER join `Atributos` a ON a.`idTipo`=t.`idTipo`
    where a.`idAtributo`= pIdAtributo;

    IF EXISTS (SELECT 1 FROM `Valores` WHERE `idAtributo` = pIdAtributo) and pIdTipo <> vIdTipoOld THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el atributo porque existen activos utilizando este atributo.';
    END IF;

    -- 6. Manejo seguro del valor lógico
    IF pObligatorio IS NULL THEN
        SET pObligatorio = FALSE; -- 0 en MySQL
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 7. Actualización con Reemplazo Total
    UPDATE Atributos
    SET 
        idTipo = pIdTipo,
        nombre = pNombre,
        porDefecto = pPorDefecto,
        obligatorio = pObligatorio
    WHERE idAtributo = pIdAtributo;

    COMMIT;

END//
DELIMITER ;

-- ======================================== Eliminar Atributos
DROP PROCEDURE IF EXISTS sp_eliminarAtributo;
DELIMITER //

CREATE PROCEDURE sp_eliminarAtributo(
    IN pIdAtributo INT
)
BEGIN
    DECLARE vIdTipo INT;

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones iniciales
    IF pIdAtributo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el atributo a eliminar';
    END IF;

    -- Obtener el Tipo Padre para validaciones posteriores
    SELECT idTipo INTO vIdTipo 
    FROM Atributos 
    WHERE idAtributo = pIdAtributo;

    IF vIdTipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El atributo indicado no existe en el sistema';
    END IF;

    -- 2. REGLA CRÍTICA: Proteger la integridad de los JSON en los Activos
    -- Si ya hay equipos de este Tipo registrados, no podemos alterar su plantilla base
    IF EXISTS (SELECT 1 FROM `Valores` WHERE `idAtributo` = pIdAtributo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el atributo porque existen activos utilizando este atributo.';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 3. Borrado físico (Hard Delete)
    DELETE FROM Atributos 
    WHERE idAtributo = pIdAtributo;

    COMMIT;

END//
DELIMITER ;

-- =========================================== COMPONER TIPOS 
DROP PROCEDURE IF EXISTS sp_nuevaComposicionTipo;
DELIMITER //

CREATE PROCEDURE sp_nuevaComposicionTipo(
    IN pNombreTipoPadre VARCHAR(45),
    IN pNombreTipoComponente VARCHAR(45),
    IN pMax INT
)
BEGIN
    DECLARE vIdTipoPadre INT;
    DECLARE vIdTipoComponente INT;

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pNombreTipoPadre IS NOT NULL THEN SET pNombreTipoPadre = TRIM(pNombreTipoPadre); END IF;
    IF pNombreTipoComponente IS NOT NULL THEN SET pNombreTipoComponente = TRIM(pNombreTipoComponente); END IF;

    -- 2. Validaciones iniciales
    IF pNombreTipoPadre IS NULL OR pNombreTipoPadre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el nombre del tipo padre';
    END IF;

    IF pNombreTipoComponente IS NULL OR pNombreTipoComponente = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el nombre del tipo componente';
    END IF;

    -- 3. Obtener IDs y validar existencia/estado de ambos Tipos
    SELECT idTipo INTO vIdTipoPadre FROM Tipos WHERE nombre = pNombreTipoPadre AND estado = 'A';
    IF vIdTipoPadre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo padre indicado no existe o se encuentra dado de baja';
    END IF;

    SELECT idTipo INTO vIdTipoComponente FROM Tipos WHERE nombre = pNombreTipoComponente AND estado = 'A';
    IF vIdTipoComponente IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo componente indicado no existe o se encuentra dado de baja';
    END IF;

    -- 4. Validar Reglas de Negocio Básicas
    IF vIdTipoPadre = vIdTipoComponente THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un tipo de activo no puede componerse a si mismo';
    END IF;

    IF pMax IS NOT NULL AND pMax < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad máxima de componentes no puede ser menor a 1';
    END IF;

    IF EXISTS (SELECT 1 FROM ComposicionTipos WHERE idTipoPadre = vIdTipoPadre AND idTipoComponente = vIdTipoComponente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta composición ya existe en el sistema';
    END IF;

    -- 5. Validación de lazos de jerarquía (CTE Recursiva)
    IF EXISTS (
        WITH RECURSIVE Descendientes AS (
            SELECT idTipoComponente, idTipoPadre 
            FROM ComposicionTipos
            WHERE idTipoPadre = vIdTipoComponente
            
            UNION ALL

            SELECT ct.idTipoComponente, ct.idTipoPadre
            FROM ComposicionTipos ct
            INNER JOIN Descendientes d ON ct.idTipoPadre = d.idTipoComponente
        ) 
        SELECT 1 FROM Descendientes WHERE idTipoComponente = vIdTipoPadre
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puede asignarse este componente porque generaría un lazo infinito en la jerarquía de hardware';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 6. Inserción
    INSERT INTO ComposicionTipos (idTipoPadre, idTipoComponente, cantidadComponentesMaxima) 
    VALUES (vIdTipoPadre, vIdTipoComponente, pMax);

    COMMIT;
END//
DELIMITER ;

-- =========================================== ELIMINAR COMPOSICION TIPO
DROP PROCEDURE IF EXISTS sp_eliminarComposicionTipo;
DELIMITER //

CREATE PROCEDURE sp_eliminarComposicionTipo(
    IN pIdTipoPadre INT,
    IN pIdTipoComponente INT
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones de parámetros obligatorios
    IF pIdTipoPadre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el tipo padre de la composición';
    END IF;

    IF pIdTipoComponente IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el tipo componente de la composición';
    END IF;

    -- 2. Validación de existencia de ambos Tipos
    IF NOT EXISTS (SELECT 1 FROM Tipos WHERE idTipo = pIdTipoPadre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo padre indicado no existe en el sistema';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Tipos WHERE idTipo = pIdTipoComponente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo componente indicado no existe en el sistema';
    END IF;

    -- 3. Validación de existencia de la composición
    IF NOT EXISTS (
        SELECT 1 FROM ComposicionTipos 
        WHERE idTipoPadre = pIdTipoPadre AND idTipoComponente = pIdTipoComponente
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La composición indicada no existe en el sistema';
    END IF;

    -- 4. REGLA CRÍTICA: Control de activos que actualmente usan esta composición
    -- Verificamos si existe algún activo del Tipo componente que esté vinculado (compone)
    -- a un activo cuyo Tipo sea el Tipo padre de la composición
    IF EXISTS (
        SELECT 1
        FROM Activos hijo
        INNER JOIN Activos padre ON hijo.compone = padre.idActivo
        WHERE hijo.idTipo = pIdTipoComponente
          AND padre.idTipo = pIdTipoPadre
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar la composición porque existen activos que actualmente la utilizan. Debe desvincularlos primero.';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 5. Borrado físico de la composición
    DELETE FROM ComposicionTipos 
    WHERE idTipoPadre = pIdTipoPadre AND idTipoComponente = pIdTipoComponente;

    COMMIT;

END//
DELIMITER ;

-- =====================================================
-- ACTIVOS
-- =====================================================
-- =========================================== NUEVO ACTIVO
DROP PROCEDURE IF EXISTS sp_nuevoActivo;
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
			'Marca', pNombreMarca,
			'Ubicacion', pNombreUbicacion,
			'Tipo', pNombreTipo,
			'Estado', pNombreEstado,
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
-- =========================================== MODIFICAR ACTIVO

DROP PROCEDURE IF EXISTS sp_modificarActivo;
DELIMITER //

CREATE procedure sp_modificarActivo(
	-- Obligatorios Para historial y poder modificar
	IN pidActivo INT,
    IN pIdUsuario INT, -- 
    -- No pueden ser NULL
	IN pNombreMarca VARCHAR(45),
    IN pNombreUbicacion VARCHAR(45),
    IN pNombreTipo VARCHAR(45),
    IN pNombreEstado VARCHAR(45),
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

    
    -- Manejador de errores: Si algo falla, deshace los cambios (Rollback)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; -- Re-lanza el error para que tu backend lo detecte
    END;
    -- TRIM de los parametros
    SET pNombreMarca = TRIM(pNombreMarca);
    SET pNombreUbicacion = TRIM(pNombreUbicacion);
    SET pNombreTipo = TRIM(pNombreTipo);
    SET pNombreEstado = TRIM(pNombreEstado);
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
        IF pNombreMarca IS NULL  OR pNombreMarca = '' THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar una marca';
        END IF;

        IF pNombreUbicacion IS NULL  OR pNombreUbicacion = '' THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar una ubicación';
        END IF;

        IF pNombreTipo IS NULL   OR pNombreTipo = '' THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar un tipo'; 
        END IF;
        IF pNombreEstado IS NULL  OR pNombreEstado = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Se debe ingresar un estado'; 
        END IF;
    
    SELECT idMarca INTO vIdMarca FROM Marcas WHERE nombre = pNombreMarca LIMIT 1;
	SELECT idUbicacion INTO vIdUbicacion FROM Ubicaciones WHERE nombre = pNombreUbicacion LIMIT 1;
	SELECT idTipo INTO vIdTipo FROM Tipos WHERE nombre = pNombreTipo LIMIT 1;
	SELECT idEstado INTO vIdEstado FROM Estados WHERE nombre = pNombreEstado LIMIT 1;

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
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Marca', pNombreMarca);
        END IF;

        IF vIdUbicacion <> oldIdUbicacion THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Ubicacion', oldNombreUbicacion);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Ubicacion', pNombreUbicacion);
        END IF;

        IF vIdTipo <> oldIdTipo THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Tipo', oldNombreTipo);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Tipo', pNombreTipo);
        END IF;

        IF vIdEstado <> oldIdEstado THEN
            SET vEstadoViejo = JSON_SET(vEstadoViejo, '$.Estado', oldNombreEstado);
            SET vEstadoNuevo = JSON_SET(vEstadoNuevo, '$.Estado', pNombreEstado);
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

DELIMITER ;

-- =========================================== BAJA ACTIVO
DROP PROCEDURE IF EXISTS sp_bajaActivo;
DELIMITER //

CREATE PROCEDURE sp_bajaActivo(
    IN pIdActivo INT,
    IN pIdEstadoBaja INT, 
    IN pIdUsuario INT,
    IN pComentario VARCHAR(200)
)
BEGIN
    DECLARE vViejoIdEstado INT;
    DECLARE vViejoIdUbicacion INT;

    -- Para el historial:
    DECLARE vNombreEstadoViejo VARCHAR(45);
    DECLARE vNombreEstadoNuevo VARCHAR(45);

    -- Manejador de errores para asegurar transacciones ACID
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones de parámetros obligatorios
    IF pIdActivo IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el activo a dar de baja'; 
    END IF;
    IF pIdEstadoBaja IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el estado de baja (ej. Descartado, Roto, etc.)'; 
    END IF;
    IF pIdUsuario IS NULL THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario es obligatorio para el registro del historial'; 
    END IF;

    -- 2. Validación de existencia en catálogos (Claves Foráneas)
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario indicado no existe o es inválido';
    END IF;

    SELECT nombre INTO vNombreEstadoNuevo FROM Estados WHERE idEstado = pIdEstadoBaja;

    IF  (vNombreEstadoNuevo) IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado de baja indicado no existe en el sistema';
    END IF;

    -- 3. Obtener el estado actual del activo
    SELECT a.idEstado, idUbicacion,e.nombre INTO vViejoIdEstado, vViejoIdUbicacion,vNombreEstadoViejo
    FROM Activos a 
    INNER JOIN Estados e on e.`idEstado`= a.`idEstado`
    WHERE idActivo = pIdActivo;

    IF vViejoIdEstado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo que desea dar de baja no existe';
    END IF;

    -- 4. Verificar que no esté ya dado de baja con ese mismo estado
    IF vViejoIdEstado = pIdEstadoBaja THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo ya se encuentra en el estado indicado';
    END IF;

    -- 5. Control de componentes hijos (NUEVO: Integridad de hardware)
    IF EXISTS (SELECT 1 FROM Activos WHERE compone = pIdActivo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo posee componentes vinculados. Debe desvincularlos antes de dar de baja el equipo principal.';
    END IF;

    
    -- =========================================================================
    -- INICIO DE TRANSACCIÓN (Activo + Historial)
    -- =========================================================================
    START TRANSACTION;

    -- 6. Actualizar el activo (Se cambia el estado y se liberan las asignaciones)
    UPDATE Activos
    SET 
        idEstado = pIdEstadoBaja,
        idPersona = NULL, -- Al darse de baja, se retira al empleado asignado
        compone = NULL    -- Se retira de cualquier equipo del que formaba parte
    WHERE idActivo = pIdActivo;

    -- 7. Registrar la baja en el Historial para la auditoría
   CALL `sp_registrarHistorial`(
        pIdUsuario, 
        pIdActivo, 
        'Baja del activo',
        'B',
        JSON_OBJECT('estado', vNombreEstadoViejo),
        JSON_OBJECT('estado', vNombreEstadoNuevo)
        ); 

    COMMIT;
END//
DELIMITER ;

-- =====================================================
-- VALORES
-- =====================================================
-- ======================================== Nuevo Valor
DROP PROCEDURE IF EXISTS sp_nuevoValor;
DELIMITER //

CREATE PROCEDURE sp_nuevoValor(
    IN pIdUsuario INT,
    IN pIdActivo INT,
    IN pIdAtributo INT,
    IN pValor VARCHAR(100)
)
BEGIN
    DECLARE vIdTipoActivo INT;
    DECLARE vIdTipoAtributo INT;
    DECLARE vNombreAtributo VARCHAR(45);
    DECLARE vObligatorio TINYINT;

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pValor IS NOT NULL THEN SET pValor = TRIM(pValor); END IF;

    -- 2. Validaciones iniciales
    IF pIdUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o es inválido';
    END IF;

    IF pIdActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el activo al que pertenece el valor';
    END IF;

    IF pIdAtributo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el atributo al que pertenece el valor';
    END IF;

    -- 3. Validar existencia del Activo y obtener su Tipo
    SELECT idTipo INTO vIdTipoActivo FROM Activos WHERE idActivo = pIdActivo;
    IF vIdTipoActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo indicado no existe';
    END IF;

    -- 4. Validar existencia del Atributo y obtener sus datos
    SELECT idTipo, nombre, obligatorio INTO vIdTipoAtributo, vNombreAtributo, vObligatorio
    FROM Atributos WHERE idAtributo = pIdAtributo;

    IF vIdTipoAtributo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El atributo indicado no existe';
    END IF;

    -- 5. Validar que el atributo pertenezca al Tipo del Activo
    IF vIdTipoAtributo <> vIdTipoActivo THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El atributo indicado no pertenece al tipo de este activo';
    END IF;

    -- 6. Validar que no exista ya un valor cargado para ese Activo/Atributo
    IF EXISTS (SELECT 1 FROM Valores WHERE idActivo = pIdActivo AND idAtributo = pIdAtributo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un valor cargado para este atributo en este activo. Utilice la modificación';
    END IF;

    -- 7. Si el atributo es obligatorio, no puede venir NULL o vacío
    IF vObligatorio = 1 AND (pValor IS NULL or pValor='') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este atributo es obligatorio, no puede dejarse vacío o nulo';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN (Valor + Historial)
    -- =========================================================================
    START TRANSACTION;

    -- 8. Inserción del valor
    INSERT INTO Valores (idActivo, idAtributo, valor)
    VALUES (pIdActivo, pIdAtributo, pValor);

    -- 9. Registrar en el Historial como modificación
    CALL sp_registrarHistorial(
        pIdUsuario,
        pIdActivo,
        'Alta de valor de atributo',
        'M',
        JSON_OBJECT(vNombreAtributo, NULL),
        JSON_OBJECT(vNombreAtributo, pValor)
    );

    COMMIT;

END//
DELIMITER ;

-- ======================================== Modificar Valor
DROP PROCEDURE IF EXISTS sp_modificarValor;
DELIMITER //

CREATE PROCEDURE sp_modificarValor(
    IN pIdUsuario INT,
    IN pIdActivo INT,
    IN pIdAtributo INT,
    IN pValor VARCHAR(100)
)
BEGIN
    DECLARE vNombreAtributo VARCHAR(45);
    DECLARE vValorViejo VARCHAR(100);

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pValor IS NOT NULL THEN SET pValor = TRIM(pValor); END IF;
    IF pValor = '' THEN SET pValor = NULL; END IF;

    -- 2. Validaciones iniciales
    IF pIdUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o es inválido';
    END IF;

    IF pIdActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el activo al que pertenece el valor';
    END IF;

    IF pIdAtributo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el atributo al que pertenece el valor';
    END IF;

    -- 3. No se puede modificar un valor a NULL o vacío (para eso está sp_eliminarValor)
    IF pValor IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar un valor a nulo o vacío. Si desea quitarlo, utilice la eliminación';
    END IF;

    -- 4. Validar existencia del valor actual y obtener nombre del atributo
    SELECT v.valor, a.nombre INTO vValorViejo, vNombreAtributo
    FROM Valores v
    INNER JOIN Atributos a ON a.idAtributo = v.idAtributo
    WHERE v.idActivo = pIdActivo AND v.idAtributo = pIdAtributo;

    IF vNombreAtributo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe un valor cargado para este atributo en este activo';
    END IF;

    -- 5. Verificar que haya algún cambio
    IF pValor <=> vValorViejo THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se realizaron cambios en el valor del atributo';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN (Valor + Historial)
    -- =========================================================================
    START TRANSACTION;

    -- 6. Actualización del valor
    UPDATE Valores
    SET valor = pValor
    WHERE idActivo = pIdActivo AND idAtributo = pIdAtributo;

    -- 7. Registrar en el Historial como modificación
    CALL sp_registrarHistorial(
        pIdUsuario,
        pIdActivo,
        'Modificación de valor de atributo',
        'M',
        JSON_OBJECT(vNombreAtributo, vValorViejo),
        JSON_OBJECT(vNombreAtributo, pValor)
    );

    COMMIT;

END//
DELIMITER ;

-- ======================================== Eliminar Valor
DROP PROCEDURE IF EXISTS sp_eliminarValor;
DELIMITER //

CREATE PROCEDURE sp_eliminarValor(
    IN pIdUsuario INT,
    IN pIdActivo INT,
    IN pIdAtributo INT
)
BEGIN
    DECLARE vNombreAtributo VARCHAR(45);
    DECLARE vValorViejo VARCHAR(100);
    DECLARE vObligatorio TINYINT;

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones iniciales
    IF pIdUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o es inválido';
    END IF;

    IF pIdActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el activo al que pertenece el valor';
    END IF;

    IF pIdAtributo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el atributo a eliminar';
    END IF;

    -- 2. Validar existencia del valor actual y obtener datos del atributo
    SELECT v.valor, a.nombre, a.obligatorio INTO vValorViejo, vNombreAtributo, vObligatorio
    FROM Valores v
    INNER JOIN Atributos a ON a.idAtributo = v.idAtributo
    WHERE v.idActivo = pIdActivo AND v.idAtributo = pIdAtributo;

    IF vNombreAtributo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe un valor cargado para este atributo en este activo';
    END IF;

    -- 3. REGLA CRÍTICA: no se puede eliminar el valor de un atributo obligatorio
    IF vObligatorio = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el valor de un atributo obligatorio';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN (Valor + Historial)
    -- =========================================================================
    START TRANSACTION;

    -- 4. Borrado físico del valor
    DELETE FROM Valores
    WHERE idActivo = pIdActivo AND idAtributo = pIdAtributo;

    -- 5. Registrar en el Historial como modificación
    CALL sp_registrarHistorial(
        pIdUsuario,
        pIdActivo,
        'Eliminación de valor de atributo',
        'M',
        JSON_OBJECT(vNombreAtributo, vValorViejo),
        JSON_OBJECT(vNombreAtributo, NULL)
    );

    COMMIT;

END//
DELIMITER ;


-- ======================================== HISTORIAL
DROP PROCEDURE IF EXISTS sp_registrarHistorial;
DELIMITER //

CREATE PROCEDURE sp_registrarHistorial(
    IN pIdUsuario INT,
    IN pIdActivo INT,
    IN pComentario VARCHAR(200),
    IN pTipo CHAR(1),
    IN pEstadoAnterior JSON,
    IN pEstadoNuevo JSON
)
BEGIN
    -- Validaciones mínimas de seguridad
    IF pIdUsuario IS NULL OR pIdActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario y Activo son obligatorios para el historial';
    END IF;
    -- Inserción centralizada
    INSERT INTO Historial (idUsuario, idActivo, fecha, comentario, tipo, estadoAnterior, estadoNuevo)
    VALUES (pIdUsuario, pIdActivo, NOW(), pComentario, pTipo, pEstadoAnterior, pEstadoNuevo);
END//
DELIMITER ;
DROP PROCEDURE IF EXISTS sp_modificarHistorial;
DELIMITER //

CREATE PROCEDURE sp_modificarHistorial(
    IN pIdHistorial INT,
    IN pComentario VARCHAR(200)
)
BEGIN
    DECLARE vFechaCreacion DATETIME;

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pComentario IS NOT NULL THEN SET pComentario = TRIM(pComentario); END IF;

    -- 2. Validaciones iniciales
    IF pIdHistorial IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el registro de historial a modificar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM `Historial` where `idHistorial`=pIdHistorial) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe ninguna entrada del historial con ese id';
    END IF;

    -- 3. Obtener la fecha de creación del registro
    SELECT fecha INTO vFechaCreacion 
    FROM Historial 
    WHERE idHistorial = pIdHistorial;

    IF vFechaCreacion IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El registro de historial indicado no existe';
    END IF;

    -- 4. Ventana de tiempo de edición
    IF vFechaCreacion < (NOW() - INTERVAL 1 HOUR) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede modificar el comentario: ya pasó más de 1 hora desde la creación del registro';
    END IF;

    -- 5. El comentario puede ser NULL (según el esquema), pero si viene vacío lo normalizamos a NULL
    IF pComentario = '' THEN
        SET pComentario = NULL;
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 6. Actualización exclusiva del comentario
    UPDATE Historial
    SET comentario = pComentario
    WHERE idHistorial = pIdHistorial;

    COMMIT;

END//
DELIMITER ;
-- =============================================
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
    IF EXISTS (SELECT 1 FROM Marcas WHERE nombre = pNombre) THEN
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

    -- todos los valores reemplazan a los actuales
    IN pNombre VARCHAR(100),
    IN pDescripcion VARCHAR(45)
)
BEGIN

    -- 1. Sanitización de entradas
    SET pNombre = TRIM(pNombre);
    SET pDescripcion = TRIM(pDescripcion);

    -- 2. Validación de parámetro obligatorio
    IF pIdMarca IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe incluir una marca a modificar';
    END IF;

    -- 3. Validación de existencia de la marca
    IF NOT EXISTS (
        SELECT 1
        FROM Marcas
        WHERE idMarca = pIdMarca
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La marca que desea modificar no existe';
    END IF;

    -- 4. Validación de nombre
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la marca no puede estar vacío';
    END IF;

    -- 5. Validación de nombre duplicado
    IF EXISTS (
        SELECT 1
        FROM Marcas
        WHERE nombre = pNombre
          AND idMarca != pIdMarca
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'El nuevo nombre ingresado ya pertenece a otra marca registrada';
    END IF;

    -- 6. Actualización mediante PUT
    UPDATE Marcas
    SET
        nombre = pNombre,
        descripcion = pDescripcion
    WHERE idMarca = pIdMarca;

END//

DELIMITER ;
-- ========================================== Baja Marca

DROP PROCEDURE IF EXISTS sp_bajaMarca;
DELIMITER //

CREATE PROCEDURE sp_bajaMarca(
    IN pIdMarca INT
)
BEGIN
    -- 1. Validaciones iniciales
    IF pIdMarca IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la marca a dar de baja';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE idMarca = pIdMarca) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La marca indicada no existe';
    END IF;

    -- 2. Baja Lógica
    UPDATE Marcas 
    SET estado = 'I' -- 'I' representa Inactivo/Baja
    WHERE idMarca = pIdMarca;

END//
DELIMITER ;

-- ========================================== Alta Marca

DROP PROCEDURE IF EXISTS sp_altaMarca;
DELIMITER //
CREATE PROCEDURE sp_altaMarca(IN pIdMarca INT)
BEGIN
    IF pIdMarca IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la marca a dar de alta'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE idMarca = pIdMarca) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La marca indicada no existe'; END IF;
    UPDATE Marcas SET estado = 'A' WHERE idMarca = pIdMarca;
END//
DELIMITER ;
-- =====================================================
-- UBICACIONES
-- =====================================================

DROP PROCEDURE IF EXISTS sp_nuevaUbicacion;
DELIMITER //

CREATE PROCEDURE sp_nuevaUbicacion(
    -- Esto ahora recibe el id (no nombre) de la ubicacion padre ya que podemos tener más de una ubicacion con el mismo nombre (Imaginate dos piso 1 de dos edificios distintos)
    IN vIdUbicacionPadre INT,
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(100),
    IN pEstado CHAR(1),
    OUT pIdUbicacion INT -- Parámetro de salida para el ID generado
)
BEGIN
    -- DECLARE vIdUbicacionPadre INT;

    -- 1. Sanitización de entradas (TRIM)
    SET pNombre = TRIM(pNombre);
    SET pDescripcion = TRIM(pDescripcion);
    SET pEstado = TRIM(pEstado);


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
    IF vIdUbicacionPadre IS NOT NULL and not exists (select 1 from `Ubicaciones` where `idUbicacion`=vIdUbicacionPadre)THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La ubicación padre indicada no existe';
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

    -- todos los valores reemplazan a los actuales
    -- Esto ahora recibe el id (no nombre) de la ubicacion padre ya que podemos tener más de una ubicacion con el mismo nombre (Imaginate dos piso 1 de dos edificios distintos)
    IN  vIdUbicacionPadre INT,
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(100)
)
SALIR: BEGIN

    -- 1. Sanitización de entradas
    SET pNombre = TRIM(pNombre);
    SET pDescripcion = TRIM(pDescripcion);

    -- 2. Validación de parámetro obligatorio
    IF pIdUbicacion IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debe incluir una ubicacion a modificar';
        LEAVE SALIR;
    END IF;

    -- 3. Validación de existencia de la ubicación
    IF NOT EXISTS (
        SELECT 1
        FROM Ubicaciones
        WHERE idUbicacion = pIdUbicacion
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La ubicacion que desea modificar no existe';
        LEAVE SALIR;
    END IF;


    -- 4. Validación del nombre
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nombre de la ubicacion no puede estar vacio';
        LEAVE SALIR;
    END IF;

    -- 5. Obtener la ubicación padre
    IF vIdUbicacionPadre IS NOT NULL THEN
        -- 6. Verificar que la ubicación padre exista
        IF NOT EXISTS (SELECT 1 FROM `Ubicaciones` WHERE `idUbicacion`=vIdUbicacionPadre) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'La ubicacion padre no existe';
            LEAVE SALIR;
        END IF;


        -- 7. Una ubicación no puede ser padre de sí misma
        IF vIdUbicacionPadre = pIdUbicacion THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'Una ubicacion no puede ser padre o contenerse a si misma';
            LEAVE SALIR;
        END IF;


        -- 8. Verificar que no se genere un ciclo
        IF EXISTS (
            WITH RECURSIVE Ancestros AS (
                SELECT idUbicacion, idUbicacionPadre
                FROM Ubicaciones
                WHERE idUbicacion = vIdUbicacionPadre

                UNION ALL

                SELECT u.idUbicacion, u.idUbicacionPadre 
                FROM Ubicaciones u INNER JOIN Ancestros a
                ON u.idUbicacion = a.idUbicacionPadre 
            )
            SELECT 1
            FROM Ancestros
            WHERE idUbicacion = pIdUbicacion
        ) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT =
                    'No puede asignarse esta ubicacion como padre porque se generaria un lazo en la jerarquia de ubicaciones';
            LEAVE SALIR;
        END IF;

    END IF;

    -- 9. Actualización mediante PUT
    UPDATE Ubicaciones
    SET
        idUbicacionPadre = vIdUbicacionPadre,
        nombre = pNombre,
        descripcion = pDescripcion
    WHERE idUbicacion = pIdUbicacion;

END//
DELIMITER ;
-- ========================================= Baja Ubicacion
DROP PROCEDURE IF EXISTS sp_bajaUbicacion;
DELIMITER //

CREATE PROCEDURE sp_bajaUbicacion(
    IN pIdUbicacion INT
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones iniciales
    IF pIdUbicacion IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la ubicación a dar de baja';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Ubicaciones WHERE idUbicacion = pIdUbicacion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ubicación indicada no existe en el sistema';
    END IF;

    -- 2. REGLA CRÍTICA 1: Control de activos asociados
    -- Validamos si existen equipos físicos actualmente en esta ubicación
    IF EXISTS (SELECT 1 FROM Activos WHERE idUbicacion = pIdUbicacion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede dar de baja la ubicación porque existen activos registrados en ella. Debe reubicarlos primero.';
    END IF;

    -- 3. REGLA CRÍTICA 2: Control de jerarquía (Sub-ubicaciones)
    -- Validamos si esta ubicación es "padre" de otras ubicaciones que sigan activas
    IF EXISTS (SELECT 1 FROM Ubicaciones WHERE idUbicacionPadre = pIdUbicacion AND estado != 'I') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede dar de baja porque contiene sub-ubicaciones activas dependientes de ella. Reasigne las ubicaciones hijas primero.';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 4. Baja Lógica
    UPDATE Ubicaciones 
    SET estado = 'I' -- 'I' representa Inactivo
    WHERE idUbicacion = pIdUbicacion;

    COMMIT;

END//
DELIMITER ;

-- ========================================== Alta Ubicacion
DROP PROCEDURE IF EXISTS sp_altaUbicacion;
DELIMITER //
CREATE PROCEDURE sp_altaUbicacion(IN pIdUbicacion INT)
BEGIN
    DECLARE vIdUbicacionPadre INT;
    DECLARE vEstadoPadre CHAR(1);

    IF pIdUbicacion IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la ubicación a dar de alta'; END IF;
    SELECT idUbicacionPadre INTO vIdUbicacionPadre FROM Ubicaciones WHERE idUbicacion = pIdUbicacion;
    
    -- Validamos jerarquía: el padre no puede estar inactivo
    IF vIdUbicacionPadre IS NOT NULL THEN
        SELECT estado INTO vEstadoPadre FROM Ubicaciones WHERE idUbicacion = vIdUbicacionPadre;
        IF vEstadoPadre = 'I' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puede reactivar esta ubicación porque la ubicación padre se encuentra dada de baja';
        END IF;
    END IF;

    UPDATE Ubicaciones SET estado = 'A' WHERE idUbicacion = pIdUbicacion;
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
    IN pDescripcion VARCHAR(200),
    OUT pIdProveedor INT 
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
-- ===================================== Modificar Proveedor
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

-- =============================================== Baja Proveedor
DROP PROCEDURE IF EXISTS sp_bajaProveedor;
DELIMITER //

CREATE PROCEDURE sp_bajaProveedor(
    IN pIdProveedor INT
)
BEGIN
    -- 1. Validación de parámetro obligatorio
    IF pIdProveedor IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el proveedor a dar de baja';
    END IF;

    -- 2. Validación de existencia
    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE idProveedor = pIdProveedor) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor indicado no existe en el sistema';
    END IF;

    -- 3. CONTROL EXTRA: Mantenimientos en curso
    -- Verifica si el proveedor tiene equipos sin devolver
    IF EXISTS (
        SELECT 1 FROM Mantenimientos 
        WHERE idProveedor = pIdProveedor 
        AND fechaDevolucion IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede dar de baja al proveedor porque actualmente posee activos en reparación (sin fecha de devolución).';
    END IF;

    -- 4. Ejecución de la Baja Lógica
    UPDATE Proveedores 
    SET estado = 'I' -- 'I' representa Inactivo / Dado de baja
    WHERE idProveedor = pIdProveedor;

END//
DELIMITER ;

-- ========================================== Alta Proveedor

DROP PROCEDURE IF EXISTS sp_altaProveedor;
DELIMITER //
CREATE PROCEDURE sp_altaProveedor(IN pIdProveedor INT)
BEGIN
    IF pIdProveedor IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el proveedor a dar de alta'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE idProveedor = pIdProveedor) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor indicado no existe'; END IF;
    UPDATE Proveedores SET estado = 'A' WHERE idProveedor = pIdProveedor;
END//
DELIMITER ;

-- =====================================================
-- PERSONAS
-- =====================================================
-- ============================================== Nueva Personas
DROP PROCEDURE IF EXISTS sp_nuevaPersona;
DELIMITER //

CREATE PROCEDURE sp_nuevaPersona(
    IN pNombre VARCHAR(45),
    IN pApellido VARCHAR(45),
    IN pDni VARCHAR(45),
    IN pCargo VARCHAR(100),
    IN pEstado CHAR(1),
    OUT pIdPersona INT
)
BEGIN
    -- 1. Sanitización de entradas
    SET pNombre = TRIM(pNombre);
    SET pApellido = TRIM(pApellido);
    IF pDni IS NOT NULL THEN SET pDni = TRIM(pDni); END IF;
    SET pCargo = TRIM(pCargo);

    -- 2. Validación de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la persona es obligatorio';
    END IF;
    
    IF pApellido IS NULL OR pApellido = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido de la persona es obligatorio';
    END IF;
    
    IF pCargo IS NULL OR pCargo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cargo de la persona es obligatorio';
    END IF;

    -- 3. Validación de DNI duplicado (UNIQUE INDEX)
    IF pDni IS NOT NULL AND pDni != '' AND EXISTS (SELECT 1 FROM Personas WHERE dni = pDni) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI ingresado ya pertenece a otra persona registrada';
    END IF;

    -- 4. Estado por defecto
    IF pEstado IS NULL OR TRIM(pEstado) = '' THEN
        SET pEstado = 'A'; -- 'A' para Activo
    END IF;

    -- 5. Inserción del registro
    INSERT INTO Personas (nombre, apellido, dni, cargo, estado)
    VALUES (pNombre, pApellido, pDni, pCargo, pEstado);

    -- 6. Retorno del ID autogenerado
    SET pIdPersona = LAST_INSERT_ID();

END//
DELIMITER ;

-- ============================================== Modificar Persona
DROP PROCEDURE IF EXISTS sp_modificarPersona;
DELIMITER //

CREATE PROCEDURE sp_modificarPersona(
    IN pIdPersona INT,
    IN pNombre VARCHAR(45),
    IN pApellido VARCHAR(45),
    IN pDni VARCHAR(45),
    IN pCargo VARCHAR(100)

)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pApellido IS NOT NULL THEN SET pApellido = TRIM(pApellido); END IF;
    IF pDni IS NOT NULL THEN SET pDni = TRIM(pDni); END IF;
    IF pCargo IS NOT NULL THEN SET pCargo = TRIM(pCargo); END IF;
   

    -- 2. Validaciones iniciales
    IF pIdPersona IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la persona a modificar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Personas WHERE idPersona = pIdPersona) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona indicada no existe en el sistema';
    END IF;

    -- 3. Validación de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la persona es obligatorio';
    END IF;
    
    IF pApellido IS NULL OR pApellido = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El apellido de la persona es obligatorio';
    END IF;
    
    IF pCargo IS NULL OR pCargo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cargo de la persona es obligatorio';
    END IF;


    -- 4. Validación de DNI duplicado (Excluyendo a la persona actual)
    IF pDni IS NOT NULL AND pDni != '' AND EXISTS (SELECT 1 FROM Personas WHERE dni = pDni AND idPersona != pIdPersona) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI ingresado ya pertenece a otra persona registrada';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 5. Actualización con Reemplazo Total
    UPDATE Personas 
    SET 
        nombre = pNombre,
        apellido = pApellido,
        dni = pDni,
        cargo = pCargo
    WHERE idPersona = pIdPersona;

    COMMIT;

END//
DELIMITER ;

-- ============================================== Baja Persona
DROP PROCEDURE IF EXISTS sp_bajaPersona;
DELIMITER //

CREATE PROCEDURE sp_bajaPersona(
    IN pIdPersona INT
)
BEGIN
    -- Manejador de errores para asegurar la transacción
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones iniciales
    IF pIdPersona IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la persona a dar de baja';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Personas WHERE idPersona = pIdPersona) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona indicada no existe';
    END IF;

    -- INICIO DE TRANSACCIÓN
    START TRANSACTION;

    -- 2. Baja Lógica de la Persona
    UPDATE Personas 
    SET estado = 'I' -- 'I' representa Inactivo
    WHERE idPersona = pIdPersona;

    -- 3. Baja Lógica en cascada del Usuario asociado (Seguridad)
    -- Si la persona no tiene usuario, este UPDATE simplemente no afectará filas, lo cual es seguro.
    UPDATE Usuarios 
    SET estado = 'I' 
    WHERE idPersona = pIdPersona;

    COMMIT;
END//
DELIMITER ;

-- ========================================== Alta Persona
DROP PROCEDURE IF EXISTS sp_altaPersona;
DELIMITER //
CREATE PROCEDURE sp_altaPersona(IN pIdPersona INT)
BEGIN
    IF pIdPersona IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la persona a dar de alta'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE idPersona = pIdPersona) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona indicada no existe'; END IF;
    UPDATE Personas SET estado = 'A' WHERE idPersona = pIdPersona;
END//
DELIMITER ;

-- =====================================================
-- USUARIOS
-- =====================================================
-- ============================================== Nuevo Usuario
DROP PROCEDURE IF EXISTS sp_nuevoUsuario;
DELIMITER //

CREATE PROCEDURE sp_nuevoUsuario(
    IN pIdPersona INT,
    IN pUsername VARCHAR(45),
    IN pPassword VARCHAR(255),
    IN pRol VARCHAR(45),
    IN pEstado CHAR(1),
    OUT pIdUsuario INT
)
BEGIN
    DECLARE vEstadoPersona CHAR(1);

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pUsername IS NOT NULL THEN SET pUsername = TRIM(pUsername); END IF;
    IF pRol IS NOT NULL THEN SET pRol = TRIM(pRol); END IF;
    IF pEstado IS NOT NULL THEN SET pEstado = TRIM(pEstado); END IF;

    -- 2. Validación de campos obligatorios
    IF pIdPersona IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la persona a la que pertenece el usuario';
    END IF;

    IF pUsername IS NULL OR pUsername = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de usuario es obligatorio';
    END IF;

    IF pPassword IS NULL OR pPassword = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña es obligatoria';
    END IF;

    IF pRol IS NULL OR pRol = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol del usuario es obligatorio';
    END IF;

    -- 3. Validación de integridad de la Persona (debe existir y estar activa)
    SELECT estado INTO vEstadoPersona FROM Personas WHERE idPersona = pIdPersona;

    IF vEstadoPersona IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona indicada no existe en el sistema';
    ELSEIF vEstadoPersona = 'I' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede crear un usuario para una persona dada de baja';
    END IF;

    -- 4. Validación de duplicados (UNIQUE INDEX en 'username')
    IF EXISTS (SELECT 1 FROM Usuarios WHERE username = pUsername) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de usuario ingresado ya existe en el sistema';
    END IF;

    -- 5. REGLA DE NEGOCIO: Evitar que una misma persona tenga más de un usuario activo
    IF EXISTS (SELECT 1 FROM Usuarios WHERE idPersona = pIdPersona AND estado = 'A') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona indicada ya posee un usuario activo en el sistema';
    END IF;

    -- 6. Estado por defecto
    IF pEstado IS NULL OR pEstado = '' THEN
        SET pEstado = 'A'; -- 'A' representa Activo
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 7. Inserción del registro
    INSERT INTO Usuarios (idPersona, username, password, rol, estado)
    VALUES (pIdPersona, pUsername, pPassword, pRol, pEstado);

    -- 8. Retorno del ID autogenerado
    SET pIdUsuario = LAST_INSERT_ID();

    COMMIT;

END//
DELIMITER ;

-- ============================================== Modificar Usuario
DROP PROCEDURE IF EXISTS sp_modificarUsuario;
DELIMITER //

CREATE PROCEDURE sp_modificarUsuario(
    IN pIdUsuario INT,
    IN pIdPersona INT,
    IN pUsername VARCHAR(45),
    IN pPassword VARCHAR(255),
    IN pRol VARCHAR(45)
)
BEGIN
    DECLARE vEstadoPersona CHAR(1);

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pUsername IS NOT NULL THEN SET pUsername = TRIM(pUsername); END IF;
    IF pRol IS NOT NULL THEN SET pRol = TRIM(pRol); END IF;


    -- 2. Validaciones iniciales de existencia del Usuario
    IF pIdUsuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el usuario a modificar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario indicado no existe en el sistema';
    END IF;

    -- 3. Validación de campos obligatorios
    IF pIdPersona IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la persona a la que pertenece el usuario';
    END IF;

    IF pUsername IS NULL OR pUsername = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de usuario es obligatorio';
    END IF;

    IF pPassword IS NULL OR pPassword = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña es obligatoria';
    END IF;

    IF pRol IS NULL OR pRol = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol del usuario es obligatorio';
    END IF;

--
--    IF pEstado = 'A' AND pEstado <> select estado from `Usuarios` where `idUsuario`=pIdUsuario THEN
--        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Use la función dar de baja';
--    END IF;
--
    -- 4. Validación de integridad de la Persona (debe existir y estar activa)
    SELECT estado INTO vEstadoPersona FROM Personas WHERE idPersona = pIdPersona;

    IF vEstadoPersona IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona indicada no existe en el sistema';
    ELSEIF vEstadoPersona = 'I' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede asignar el usuario a una persona dada de baja';
    END IF;

    -- 5. Validación de nombre de usuario duplicado (Excluyendo el usuario actual)
    IF EXISTS (SELECT 1 FROM Usuarios WHERE username = pUsername AND idUsuario != pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de usuario ingresado ya pertenece a otro usuario registrado';
    END IF;

    -- 6. REGLA DE NEGOCIO: Evitar que una misma persona tenga más de un usuario activo
    IF pEstado = 'A' AND EXISTS (
        SELECT 1 FROM Usuarios 
        WHERE idPersona = pIdPersona AND estado = 'A' AND idUsuario != pIdUsuario
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona indicada ya posee otro usuario activo en el sistema';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 7. Actualización con Reemplazo Total
    UPDATE Usuarios
    SET 
        idPersona = pIdPersona,
        username = pUsername,
        password = pPassword,
        rol = pRol,
        estado = pEstado
    WHERE idUsuario = pIdUsuario;

    COMMIT;

END//
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_bajaUsuario;
DELIMITER //

CREATE PROCEDURE sp_bajaUsuario(
    IN pIdUsuario INT
)
BEGIN
    -- 1. Validaciones iniciales
    IF pIdUsuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el usuario a dar de baja';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario indicado no existe';
    END IF;

    -- 2. Baja Lógica del Usuario
    UPDATE Usuarios 
    SET estado = 'I' -- Le quita el acceso al sistema
    WHERE idUsuario = pIdUsuario;

END//
DELIMITER ;

-- ========================================== Alta Usuario

DROP PROCEDURE IF EXISTS sp_altaUsuario;
DELIMITER //
CREATE PROCEDURE sp_altaUsuario(
    IN pIdUsuario INT
)
BEGIN
    DECLARE vEstadoUsuario CHAR(1);
    DECLARE vIdPersona INT;

    SELECT estado, idPersona INTO vEstadoUsuario, vIdPersona
    FROM Usuarios WHERE idUsuario = pIdUsuario;

    IF vEstadoUsuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario indicado no existe';
    END IF;
    IF vEstadoUsuario = 'A' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario ya se encuentra activo';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Personas WHERE idPersona = vIdPersona AND estado = 'A') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede reactivar el usuario porque su persona está dada de baja';
    END IF;
    IF EXISTS (SELECT 1 FROM Usuarios WHERE idPersona = vIdPersona AND estado = 'A') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La persona ya posee otro usuario activo';
    END IF;

    UPDATE Usuarios SET estado = 'A' WHERE idUsuario = pIdUsuario;

END//
DELIMITER ;
-- =====================================================
-- MANTENIMIENTOS
-- =====================================================
-- Nuevo mantenimiento
DROP PROCEDURE IF EXISTS sp_nuevoMantenimiento;
DELIMITER //

CREATE PROCEDURE sp_nuevoMantenimiento(
    -- Datos del Mantenimiento
    IN pIdActivo INT,
    IN pIdProveedor INT,
    IN pFallaReportada VARCHAR(200),
    IN pFechaEnvio DATE,
    
    -- Datos para la automatización del estado del Activo
    IN pIdEstadoEnReparacion INT, 
    IN pIdUsuario INT, 
    
    -- Parámetro de salida
    OUT pIdMantenimiento INT
)
BEGIN
    DECLARE vViejoIdEstado INT;
    DECLARE vViejoIdUbicacion INT;
    DECLARE vEstadoProveedor CHAR(1);

    -- PARA EL HISTORIAL
    DECLARE vNombreEstadoViejo VARCHAR(45);
    DECLARE vNombreEstadoNuevo VARCHAR(45);

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización
    IF pFallaReportada IS NOT NULL THEN 
        SET pFallaReportada = TRIM(pFallaReportada); 
    END IF;

    -- 2. Validaciones de campos obligatorios
    IF pIdActivo IS NULL OR pIdProveedor IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo y el proveedor son obligatorios';
    END IF;
    
    IF pIdEstadoEnReparacion IS NULL OR pIdUsuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el usuario responsable y el nuevo estado del activo (Ej. En Reparación)';
    END IF;

    -- Si no se envía fecha de envío, se asume el día de hoy
    IF pFechaEnvio IS NULL THEN
        SET pFechaEnvio = CURDATE();
    END IF;

    -- 3. Validar existencia y estado del Proveedor
    SELECT estado INTO vEstadoProveedor FROM Proveedores WHERE idProveedor = pIdProveedor;
    
    IF vEstadoProveedor IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor indicado no existe';
    ELSEIF vEstadoProveedor = 'I' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede derivar un mantenimiento a un proveedor dado de baja';
    END IF;

    -- 4. Validar el Activo y su disponibilidad
    SELECT idEstado, idUbicacion INTO vViejoIdEstado, vViejoIdUbicacion 
    FROM Activos WHERE idActivo = pIdActivo;

    IF vViejoIdEstado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo indicado no existe';
    END IF;

    -- Verificar que el activo no esté ya en reparación
    IF EXISTS (SELECT 1 FROM Mantenimientos WHERE idActivo = pIdActivo AND fechaDevolucion IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo indicado ya se encuentra en un mantenimiento en curso';
    END IF;

    -- Validar Usuario (para el historial)
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario indicado no existe o es inválido';
    END IF;


    SELECT e.nombre INTO vNombreEstadoViejo FROM `Activos` a
        INNER JOIN Estados e on e.`idEstado`=a.`idEstado`
        WHERE  a.`idActivo`=pIdActivo;
    SELECT nombre INTO vNombreEstadoNuevo FROM `Estados` WHERE `idEstado`= pIdEstadoEnReparacion;


    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 5. Insertar el registro base del mantenimiento (sin costo ni reparación realizada aún)
    INSERT INTO Mantenimientos (idActivo, idProveedor, fallaReportada, fechaEnvio)
    VALUES (pIdActivo, pIdProveedor, pFallaReportada, pFechaEnvio);

    -- Capturar el ID generado
    SET pIdMantenimiento = LAST_INSERT_ID();
    -- 6. Actualizar el estado del Activo si es que cambia
    IF vViejoIdEstado != pIdEstadoEnReparacion THEN
        UPDATE Activos 
        SET idEstado = pIdEstadoEnReparacion 
        WHERE idActivo = pIdActivo;        
    END IF;
    -- 7. Registrar el movimiento en el Historial del Activo
    -- Insertar el registro de Creacion en el Historial    
    CALL `sp_registrarHistorial`(
        pIdUsuario, 
        pIdActivo, 
        CONCAT('Enviado a soporte técnico. Falla: ',  
            COALESCE(pFallaReportada, 'No especificada'),   -- 
                ' | id del mantenimiento: ',pIdMantenimiento),  --
        'R', -- Modificación de estado
        JSON_OBJECT('Estado', vNombreEstadoViejo),
        JSON_OBJECT('Estado', vNombreEstadoNuevo)
        ); 

    COMMIT;
END//
DELIMITER ;

-- Fin mantenimiento
DROP PROCEDURE IF EXISTS sp_finMantenimiento;
DELIMITER //

CREATE PROCEDURE sp_finMantenimiento(
    -- Datos para cerrar el Mantenimiento
    IN pIdMantenimiento INT,
    IN pReparacionRealizada VARCHAR(200),
    IN pFechaDevolucion DATE,
    IN pCostoTotal DECIMAL(12,2),
    
    -- Datos para la automatización del Activo y Auditoría
    IN pIdEstadoPostReparacion INT, -- Ej. ID del estado "En Stock" o "Operativo"
    IN pIdUsuario INT
)
BEGIN
    -- Variables internas
    DECLARE vIdActivo INT;
    DECLARE vViejoIdEstado INT;
    DECLARE vViejoIdUbicacion INT;
    DECLARE vFechaEnvio DATE;
    DECLARE vFechaDevolucionExistente DATE;

    -- PARA EL HISTORIAL
    DECLARE vNombreEstadoViejo VARCHAR(45);
    DECLARE vNombreEstadoNuevo VARCHAR(45);

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de textos
    IF pReparacionRealizada IS NOT NULL THEN 
        SET pReparacionRealizada = TRIM(pReparacionRealizada);
    END IF;

    -- 2. Validaciones de campos obligatorios
    IF pIdMantenimiento IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el ID del mantenimiento a finalizar';
    END IF;

    IF pIdEstadoPostReparacion IS NULL OR pIdUsuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el usuario responsable y el nuevo estado del activo post-reparación';
    END IF;

    -- 3. Obtener datos del mantenimiento y verificar su estado
    SELECT idActivo, fechaEnvio, fechaDevolucion 
    INTO vIdActivo, vFechaEnvio, vFechaDevolucionExistente
    FROM Mantenimientos 
    WHERE idMantenimiento = pIdMantenimiento;

    IF vIdActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El registro de mantenimiento indicado no existe';
    END IF;

    -- Regla de Negocio: Evitar cerrar un mantenimiento ya cerrado
    IF vFechaDevolucionExistente IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este mantenimiento ya fue finalizado anteriormente (ya posee fecha de devolución)';
    END IF;

    -- 4. Validaciones Temporales
    -- Si no se envía fecha de devolución desde el frontend, se asume el día de hoy
    IF pFechaDevolucion IS NULL THEN
        SET pFechaDevolucion = CURDATE();
    END IF;

    -- Regla de Negocio: La devolución no puede ser antes del envío
    IF pFechaDevolucion < vFechaEnvio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de devolución no puede ser anterior a la fecha de envío al proveedor';
    END IF;

    -- 5. Validar Usuario y Estado Nuevo en Catálogos
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = pIdUsuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario indicado no existe o es inválido';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Estados WHERE idEstado = pIdEstadoPostReparacion) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado post-reparación indicado no existe en el sistema';
    END IF;

    -- Obtener estado y ubicación actual del activo (para guardarlos en el JSON del Historial)
    
    SELECT e.nombre,a.`idEstado` INTO vNombreEstadoViejo, vViejoIdEstado FROM `Activos` a
        INNER JOIN Estados e on e.`idEstado`=a.`idEstado`
        WHERE  a.`idActivo`=vIdActivo;
    SELECT nombre INTO vNombreEstadoNuevo FROM `Estados` WHERE `idEstado`= pIdEstadoPostReparacion;


    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 6. Actualizar el registro del mantenimiento (cerrar el ticket)
    UPDATE Mantenimientos 
    SET 
        reparacionRealizada = pReparacionRealizada,
        fechaDevolucion = pFechaDevolucion,
        costoTotal = pCostoTotal
    WHERE idMantenimiento = pIdMantenimiento;

    -- 7. Actualizar el estado del Activo (Ej. vuelve a "En Stock")
    IF vViejoIdEstado != pIdEstadoPostReparacion THEN
        UPDATE Activos 
        SET idEstado = pIdEstadoPostReparacion 
        WHERE idActivo = vIdActivo;
    END IF;
    -- 8. Registrar el movimiento en el Historial del Activo

    CALL `sp_registrarHistorial`(
        pIdUsuario, 
        vIdActivo, 
        CONCAT('Retorno de soporte técnico. Reparacion realizada: ', 
            COALESCE(pReparacionRealizada, 'No especificada'),
            ' | id del mantenimiento: ',pIdMantenimiento), 
        'D', -- Modificación de estado
        JSON_OBJECT('Estado', vNombreEstadoViejo),
        JSON_OBJECT('Estado', vNombreEstadoNuevo)
        );
    COMMIT;
    
END//
DELIMITER ;

-- Modificar Mantenimiento
DROP PROCEDURE IF EXISTS sp_modificarMantenimiento;
DELIMITER //

CREATE PROCEDURE sp_modificarMantenimiento(
    IN pIdMantenimiento INT,
    
    -- El idActivo NO se incluye como parámetro porque es inmutable en este contexto.
    
    IN pIdProveedor INT,
    IN pFallaReportada VARCHAR(200),
    IN pFechaEnvio DATE,
    
    -- Campos que pueden ser nulos si el mantenimiento aún está en curso
    IN pReparacionRealizada VARCHAR(200),
    IN pFechaDevolucion DATE,
    IN pCostoTotal DECIMAL(12,2)
)
BEGIN
    DECLARE vIdProveedorActual INT;
    DECLARE vEstadoProveedor CHAR(1);

    -- Manejador de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización
    IF pFallaReportada IS NOT NULL THEN SET pFallaReportada = TRIM(pFallaReportada); END IF;
    IF pReparacionRealizada IS NOT NULL THEN SET pReparacionRealizada = TRIM(pReparacionRealizada); END IF;

    -- 2. Validaciones iniciales
    IF pIdMantenimiento IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el mantenimiento a modificar';
    END IF;

    IF pIdProveedor IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor es obligatorio';
    END IF;

    IF pFechaEnvio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de envío es obligatoria';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Mantenimientos WHERE idMantenimiento = pIdMantenimiento) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El registro de mantenimiento indicado no existe';
    END IF;

    -- 3. Validación de Fechas (Coherencia temporal)
    IF pFechaDevolucion IS NOT NULL AND pFechaDevolucion < pFechaEnvio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de devolución no puede ser anterior a la fecha de envío';
    END IF;

    -- 4. Validación del Proveedor (Si el usuario decide cambiarlo)
    SELECT idProveedor INTO vIdProveedorActual FROM Mantenimientos WHERE idMantenimiento = pIdMantenimiento;

    IF vIdProveedorActual != pIdProveedor THEN
        SELECT estado INTO vEstadoProveedor FROM Proveedores WHERE idProveedor = pIdProveedor;
        
        IF vEstadoProveedor IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nuevo proveedor indicado no existe';
        ELSEIF vEstadoProveedor = 'I' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede derivar el mantenimiento a un proveedor dado de baja';
        END IF;
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;
    -- 5. Actualización con Reemplazo Total
    UPDATE Mantenimientos
    SET 
        idProveedor = pIdProveedor,
        fallaReportada = pFallaReportada,
        fechaEnvio = pFechaEnvio,
        reparacionRealizada = pReparacionRealizada,
        fechaDevolucion = pFechaDevolucion,
        costoTotal = pCostoTotal
    WHERE idMantenimiento = pIdMantenimiento;

    COMMIT;

END//
DELIMITER ;
-- =====================================================
-- FACTURAS
-- =====================================================
-- ======================================== Nueva Factura
DROP PROCEDURE IF EXISTS sp_nuevaFactura;
DELIMITER //

CREATE PROCEDURE sp_nuevaFactura(
    IN pIdProveedor INT,
    IN pFecha DATETIME,
    IN pMonto DECIMAL(12,2),
    IN pMoneda VARCHAR(3),
    IN pNumero VARCHAR(45),
    IN pRuta VARCHAR(255),
    IN pEstado  CHAR(1),
    OUT pIdFactura INT
)
BEGIN
    DECLARE vEstadoProveedor CHAR(1);

    -- 1. Sanitización y Estandarización
    IF pMoneda IS NOT NULL THEN 
        SET pMoneda = TRIM(UPPER(pMoneda)); -- Fuerza mayúsculas (ej. 'ars' -> 'ARS')
    END IF;
    IF pNumero IS NOT NULL THEN SET pNumero = TRIM(pNumero); END IF;
    IF pRuta IS NOT NULL THEN SET pRuta = TRIM(pRuta); END IF;

    -- 2. Validaciones de campos obligatorios (basadas en los NOT NULL del esquema)
    IF pFecha IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de la factura es obligatoria';
    END IF;

    IF pMonto IS NULL OR pMonto <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto de la factura debe ser mayor a cero';
    END IF;

    IF pMoneda IS NULL OR pMoneda = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La moneda de la factura es obligatoria (Ej. ARS, USD)';
    END IF;

    IF pNumero IS NULL OR pNumero = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de comprobante es obligatorio';
    END IF;

    IF pRuta IS NULL OR pRuta = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ruta del archivo físico/digital de la factura es obligatoria';
    END IF;
    IF pEstado IS NULL OR pEstado NOT IN ('A', 'I') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no es valido';
    END IF;

    -- 3. Validación de Reglas de Negocio asociadas al Proveedor
    -- Nota: idProveedor=NULL para compras anónimas o menores
    IF pIdProveedor IS NOT NULL THEN
        -- A. Validar existencia y estado del proveedor
        SELECT estado INTO vEstadoProveedor FROM Proveedores WHERE idProveedor = pIdProveedor;
        
        IF vEstadoProveedor IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor indicado no existe en el sistema';
        ELSEIF vEstadoProveedor = 'I' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede registrar una factura de un proveedor dado de baja';
        END IF;

        -- B. Prevención de facturas duplicadas para el mismo proveedor
        IF EXISTS (SELECT 1 FROM Facturas WHERE idProveedor = pIdProveedor AND numero = pNumero) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una factura registrada con ese número para este proveedor';
        END IF;
    END IF;

    -- 4. Inserción del registro
    INSERT INTO Facturas (idProveedor, fecha, monto, moneda, numero, ruta, estado)
    VALUES (pIdProveedor, pFecha, pMonto, pMoneda, pNumero, pRuta, pEstado);

    -- 5. Retorno del ID autogenerado
    SET pIdFactura = LAST_INSERT_ID();

END//
DELIMITER ;

-- ======================================== Modificar Factura
DROP PROCEDURE IF EXISTS sp_modificarFactura;
DELIMITER //

CREATE PROCEDURE sp_modificarFactura(
    IN pIdFactura INT,
    IN pIdProveedor INT,
    IN pFecha DATETIME,
    IN pMonto DECIMAL(12,2),
    IN pMoneda VARCHAR(3),
    IN pNumero VARCHAR(45),
    IN pRuta VARCHAR(255)
)
BEGIN
    DECLARE vEstadoProveedor CHAR(1);

    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización y Estandarización
    IF pMoneda IS NOT NULL THEN 
        SET pMoneda = TRIM(UPPER(pMoneda)); -- Fuerza mayúsculas (ej. 'usd' -> 'USD')
    END IF;
    IF pNumero IS NOT NULL THEN SET pNumero = TRIM(pNumero); END IF;
    IF pRuta IS NOT NULL THEN SET pRuta = TRIM(pRuta); END IF;

    -- 2. Validaciones iniciales
    IF pIdFactura IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la factura a modificar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Facturas WHERE idFactura = pIdFactura) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La factura indicada no existe';
    END IF;

    -- 3. Validación de campos obligatorios
    IF pFecha IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de la factura es obligatoria';
    END IF;

    IF pMonto IS NULL OR pMonto <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto de la factura debe ser mayor a cero';
    END IF;

    IF pMoneda IS NULL OR pMoneda = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La moneda de la factura es obligatoria (Ej. ARS, USD)';
    END IF;

    IF pNumero IS NULL OR pNumero = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de comprobante es obligatorio';
    END IF;

    IF pRuta IS NULL OR pRuta = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ruta del archivo físico/digital de la factura es obligatoria';
    END IF;

    -- 4. Validación de Reglas de Negocio (Proveedor y Duplicados)
    IF pIdProveedor IS NOT NULL THEN
        -- A. Validar existencia y estado del proveedor
        SELECT estado INTO vEstadoProveedor FROM Proveedores WHERE idProveedor = pIdProveedor;
        
        IF vEstadoProveedor IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El proveedor indicado no existe en el sistema';
        ELSEIF vEstadoProveedor = 'I' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede asignar la factura a un proveedor dado de baja';
        END IF;

        -- B. Prevención de facturas duplicadas para el mismo proveedor (Excluyendo la factura que estamos editando)
        IF EXISTS (SELECT 1 FROM Facturas WHERE idProveedor = pIdProveedor AND numero = pNumero AND idFactura != pIdFactura) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otra factura registrada con ese número para este proveedor';
        END IF;
    ELSE
        -- Si la factura no tiene proveedor (compra menor/anónima), verificamos que no haya duplicados sin proveedor
        IF EXISTS (SELECT 1 FROM Facturas WHERE idProveedor IS NULL AND numero = pNumero AND idFactura != pIdFactura) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe otra factura sin proveedor registrada con este número';
        END IF;
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 5. Actualización con Reemplazo Total
    UPDATE Facturas
    SET 
        idProveedor = pIdProveedor,
        fecha = pFecha,
        monto = pMonto,
        moneda = pMoneda,
        numero = pNumero,
        ruta = pRuta
    WHERE idFactura = pIdFactura;

    COMMIT;

END//
DELIMITER ;
-- ======================================== Baja Factura
DROP PROCEDURE IF EXISTS sp_bajaFactura;
DELIMITER //

CREATE PROCEDURE sp_bajaFactura(
    IN pIdFactura INT
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones iniciales
    IF pIdFactura IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el ID de la factura a dar de baja';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Facturas WHERE idFactura = pIdFactura) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La factura indicada no existe en el sistema';
    END IF;

    -- 2. REGLA CRÍTICA: Control de activos vinculados
    -- Aunque sea borrado lógico, no podemos ocultar una factura si hay equipos que dependen de ella financieramente
    IF EXISTS (SELECT 1 FROM Activos WHERE idFactura = pIdFactura) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede dar de baja la factura porque existen activos vinculados a ella. Desvincule los activos antes de proceder.';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 3. Baja Lógica (Soft Delete) del registro erróneo
    UPDATE Facturas 
    SET estado = 'I' -- 'I' representa Inactiva / Anulada
    WHERE idFactura = pIdFactura;

    COMMIT;

END//
DELIMITER ;

-- ========================================== Alta Factura
DROP PROCEDURE IF EXISTS sp_altaFactura;
DELIMITER //
CREATE PROCEDURE sp_altaFactura(IN pIdFactura INT)
BEGIN
    IF pIdFactura IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la factura a dar de alta'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Facturas WHERE idFactura = pIdFactura) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La factura indicada no existe'; END IF;
    UPDATE Facturas SET estado = 'A' WHERE idFactura = pIdFactura;
END//
DELIMITER ;

-- =====================================================
-- ESTADOS	
-- =====================================================
-- ======================================== Nuevo Estado
DROP PROCEDURE IF EXISTS sp_nuevoEstado;
DELIMITER //

CREATE PROCEDURE sp_nuevoEstado(
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(200),
    IN pEstado CHAR(1),
    OUT pIdEstado INT
)
BEGIN
    -- 1. Sanitización de entradas
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pDescripcion IS NOT NULL THEN SET pDescripcion = TRIM(pDescripcion); END IF;
    IF pEstado IS NOT NULL THEN SET pEstado = TRIM(pEstado); END IF;

    -- 2. Validación de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del estado es obligatorio';
    END IF;

    -- 3. Validación de duplicados (Aprovechando el UNIQUE INDEX)
    IF EXISTS (SELECT 1 FROM Estados WHERE nombre = pNombre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del estado ingresado ya existe en el sistema';
    END IF;

    -- 4. Estado por defecto
    IF pEstado IS NULL OR pEstado = '' THEN
        SET pEstado = 'A'; -- 'A' representa Activo
    END IF;

    -- 5. Inserción del registro
    INSERT INTO Estados (nombre, descripcion, estado)
    VALUES (pNombre, pDescripcion, pEstado);

    -- 6. Retorno del ID autogenerado
    SET pIdEstado = LAST_INSERT_ID();

END//
DELIMITER ;
-- ======================================== Modificar Estado
DROP PROCEDURE IF EXISTS sp_modificarEstado;
DELIMITER //

CREATE PROCEDURE sp_modificarEstado(
    IN pIdEstado INT,
    IN pNombre VARCHAR(45),
    IN pDescripcion VARCHAR(200)
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pNombre IS NOT NULL THEN SET pNombre = TRIM(pNombre); END IF;
    IF pDescripcion IS NOT NULL THEN SET pDescripcion = TRIM(pDescripcion); END IF;

    -- 2. Validaciones iniciales
    IF pIdEstado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el estado a modificar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Estados WHERE idEstado = pIdEstado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe en el sistema';
    END IF;

    -- 3. Validación de campos obligatorios
    IF pNombre IS NULL OR pNombre = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del estado es obligatorio';
    END IF;

    -- 4. Validación de Nombre duplicado (Excluyendo el estado actual)
    IF EXISTS (SELECT 1 FROM Estados WHERE nombre = pNombre AND idEstado != pIdEstado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre ingresado ya pertenece a otro estado registrado';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 5. Actualización con Reemplazo Total
    UPDATE Estados 
    SET 
        nombre = pNombre,
        descripcion = pDescripcion
    WHERE idEstado = pIdEstado;

    COMMIT;

END//
DELIMITER ;
-- ======================================== Baja Estado
DROP PROCEDURE IF EXISTS sp_bajaEstado;
DELIMITER //

CREATE PROCEDURE sp_bajaEstado(
    IN pIdEstado INT
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones iniciales
    IF pIdEstado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el estado a dar de baja';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Estados WHERE idEstado = pIdEstado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe en el sistema';
    END IF;

    -- 2. REGLA CRÍTICA: Control de activos asociados
    -- Evitamos dar de baja un estado si actualmente hay equipos físicos catalogados bajo el mismo
    IF EXISTS (SELECT 1 FROM Activos WHERE idEstado = pIdEstado) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede dar de baja este estado porque existen activos físicos que lo poseen actualmente. Reclasifíquelos primero.';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 3. Baja Lógica
    UPDATE Estados 
    SET estado = 'I' -- 'I' representa Inactivo/Baja
    WHERE idEstado = pIdEstado;

    COMMIT;

END//
DELIMITER ;

-- ========================================== Alta Estado
DROP PROCEDURE IF EXISTS sp_altaEstado;
DELIMITER //
CREATE PROCEDURE sp_altaEstado(IN pIdEstado INT)
BEGIN
    IF pIdEstado IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el estado a dar de alta'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Estados WHERE idEstado = pIdEstado) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado indicado no existe'; END IF;
    UPDATE Estados SET estado = 'A' WHERE idEstado = pIdEstado;
END//
DELIMITER ;

-- =====================================================
-- IMAGENES
-- =====================================================
-- ======================================== Nueva Imagen
DROP PROCEDURE IF EXISTS sp_nuevaImagen;
DELIMITER //

CREATE PROCEDURE sp_nuevaImagen(
    IN pIdActivo INT,
    IN pRuta VARCHAR(255),
    IN pDescripcion VARCHAR(100),
    IN pEstado CHAR(1),
    IN pFecha DATETIME,
    OUT pIdImagen INT
)
BEGIN
    -- 1. Sanitización de entradas
    IF pRuta IS NOT NULL THEN SET pRuta = TRIM(pRuta); END IF;
    IF pDescripcion IS NOT NULL THEN SET pDescripcion = TRIM(pDescripcion); END IF;
    IF pEstado IS NOT NULL THEN SET pEstado = TRIM(pEstado); END IF;

    -- 2. Validación de campos obligatorios
    IF pIdActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar a qué activo pertenece la imagen';
    END IF;

    IF pRuta IS NULL OR pRuta = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ruta de la imagen es obligatoria';
    END IF;

    -- 3. Validación de Integridad (Existencia del Activo Padre)
    IF NOT EXISTS (SELECT 1 FROM Activos WHERE idActivo = pIdActivo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo indicado no existe en el sistema';
    END IF;

    -- 4. Manejo de valores por defecto lógicos
    IF pEstado IS NULL OR pEstado = '' THEN
        SET pEstado = 'A'; -- 'A' representa Activa
    END IF;

    IF pFecha IS NULL THEN
        SET pFecha = NOW(); -- Si no mandan fecha, registramos el momento exacto de la subida
    END IF;

    -- 5. Inserción del registro
    INSERT INTO Imagenes (idActivo, ruta, estado, fecha, descripcion)
    VALUES (pIdActivo, pRuta, pEstado, pFecha, pDescripcion);

    -- 6. Retorno del ID autogenerado
    SET pIdImagen = LAST_INSERT_ID();

END//
DELIMITER ;

-- ======================================== Modificar Imagen
DROP PROCEDURE IF EXISTS sp_modificarImagen;
DELIMITER //

CREATE PROCEDURE sp_modificarImagen(
    IN pIdImagen INT,
    IN pIdActivo INT,
    IN pRuta VARCHAR(255),
    IN pDescripcion VARCHAR(100),
    IN pFecha DATETIME
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Sanitización de entradas
    IF pRuta IS NOT NULL THEN SET pRuta = TRIM(pRuta); END IF;
    IF pDescripcion IS NOT NULL THEN SET pDescripcion = TRIM(pDescripcion); END IF;

    -- 2. Validaciones iniciales de existencia de la imagen
    IF pIdImagen IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar el ID de la imagen a modificar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Imagenes WHERE idImagen = pIdImagen) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La imagen indicada no existe en el sistema';
    END IF;

    -- 3. Validaciones de campos obligatorios
    IF pIdActivo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar a qué activo pertenece la imagen';
    END IF;

    IF pRuta IS NULL OR pRuta = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ruta de la imagen es obligatoria';
    END IF;

    -- 4. Validación de Integridad (Existencia del Activo asignado)
    IF NOT EXISTS (SELECT 1 FROM Activos WHERE idActivo = pIdActivo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El activo asignado no existe en el sistema';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 5. Actualización con Reemplazo Total
    UPDATE Imagenes 
    SET 
        idActivo = pIdActivo,
        ruta = pRuta,
        descripcion = pDescripcion,
        estado = pEstado,
        fecha = pFecha
    WHERE idImagen = pIdImagen;

    COMMIT;

END//
DELIMITER ;
-- ======================================== Baja Imagen
DROP PROCEDURE IF EXISTS sp_bajaImagen;
DELIMITER //

CREATE PROCEDURE sp_bajaImagen(
    IN pIdImagen INT
)
BEGIN
    -- Manejador de errores (Transacciones ACID)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1. Validaciones iniciales
    IF pIdImagen IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la imagen a dar de baja';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Imagenes WHERE idImagen = pIdImagen) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La imagen indicada no existe en el sistema';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN 
    -- =========================================================================
    START TRANSACTION;

    -- 2. Baja Lógica (Soft Delete)
    UPDATE Imagenes 
    SET estado = 'I' -- 'I' representa Inactiva / Baja
    WHERE idImagen = pIdImagen;

    COMMIT;

END//
DELIMITER ;

-- ========================================== Alta Imagen
DROP PROCEDURE IF EXISTS sp_altaImagen;
DELIMITER //
CREATE PROCEDURE sp_altaImagen(IN pIdImagen INT)
BEGIN
    IF pIdImagen IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe indicar la imagen a dar de alta'; END IF;
    IF NOT EXISTS (SELECT 1 FROM Imagenes WHERE idImagen = pIdImagen) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La imagen indicada no existe'; END IF;
    UPDATE Imagenes SET estado = 'A' WHERE idImagen = pIdImagen;
END//
DELIMITER ;


