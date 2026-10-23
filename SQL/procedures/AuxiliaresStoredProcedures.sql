-- =========================================== VERIFICAR ATRIBUTOS
DROP PROCEDURE IF EXISTS sp_verificarAtributos;
DELIMITER //
CREATE PROCEDURE sp_verificarAtributos(
    IN pIdTipo INT,
    INOUT pAtributos JSON,
    OUT pResultado BOOLEAN
)
BEGIN
    declare vfaltantes JSON;
    set pAtributos=COALESCE(pAtributos,JSON_OBJECT());
    -- Verificar que el Tipo exista
    IF NOT EXISTS (SELECT 1 FROM Tipos WHERE idTipo = pIdTipo) THEN
        SET pResultado = FALSE;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El tipo ingresado no existe';
    END IF;

    -- Verificar que no haya claves que no pertenezcan al tipo
    IF EXISTS (
        SELECT 1
        FROM JSON_TABLE(
            JSON_KEYS(pAtributos),
            '$[*]' COLUMNS (nombre VARCHAR(45) PATH '$')
        ) AS j
        WHERE NOT EXISTS (
            SELECT 1 FROM Atributos a
            WHERE a.idTipo = pIdTipo AND a.nombre = j.nombre
        )
    ) THEN
        SET pResultado = FALSE;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hay atributos que no pertenecen al tip especificado en los atributos recibidos';
    END IF;

    -- Verificar obligatorios faltantes o vacíos
    IF EXISTS (
        SELECT 1 FROM Atributos a
        WHERE a.idTipo = pIdTipo
          AND a.obligatorio = 1
          AND (
              JSON_EXTRACT(pAtributos, CONCAT('$."', a.nombre, '"')) IS NULL
              OR JSON_TYPE(JSON_EXTRACT(pAtributos, CONCAT('$."', a.nombre, '"'))) = 'NULL'
              OR TRIM(JSON_UNQUOTE(JSON_EXTRACT(pAtributos, CONCAT('$."', a.nombre, '"')))) = ''
          )
    ) THEN
        SET pResultado = FALSE;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Se detectaron atributos obligatorios faltantes o vacios';
    END IF;

    -- Completar con NULL los atributos del tipo que no vinieron en el JSON
    SET vFaltantes = (
        SELECT JSON_OBJECTAGG(a.nombre, NULL)
        FROM Atributos a
        WHERE a.idTipo = pIdTipo
        AND NOT JSON_CONTAINS_PATH(pAtributos, 'one', CONCAT('$."', a.nombre, '"'))
    );

    SET pAtributos = JSON_MERGE_PRESERVE(pAtributos, COALESCE(vFaltantes, JSON_OBJECT()));

    SET pResultado = TRUE;
END//
DELIMITER ;


-- =========================================== VERIFICAR VALORES
DROP PROCEDURE IF EXISTS sp_verificarValores;
DELIMITER //
CREATE PROCEDURE sp_verificarValores(
    IN pIdTipo INT,
    IN pValores JSON
)
BEGIN
    SET pValores = COALESCE(pValores, JSON_OBJECT());

    -- 1. Verificar que el Tipo exista
    IF NOT EXISTS (SELECT 1 FROM Tipos WHERE idTipo = pIdTipo) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El tipo ingresado no existe';
    END IF;

    -- 2. Verificar que las claves (idAtributo) pertenezcan al tipo indicado
    IF EXISTS (
        SELECT 1
        FROM JSON_TABLE(
            JSON_KEYS(pValores),
            '$[*]' COLUMNS (idAtributo INT PATH '$')
        ) AS jt
        WHERE NOT EXISTS (
            SELECT 1 FROM Atributos a
            WHERE a.idTipo = pIdTipo AND a.idAtributo = jt.idAtributo
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Hay valores con atributos que no pertenecen al tipo indicado';
    END IF;

    -- 3. Verificar obligatorios faltantes o vacíos
    IF EXISTS (
        SELECT 1
        FROM Atributos a
        WHERE a.idTipo = pIdTipo
          AND a.obligatorio = 1
          AND (
              JSON_EXTRACT(pValores, CONCAT('$."', a.idAtributo, '"')) IS NULL
              OR JSON_TYPE(JSON_EXTRACT(pValores, CONCAT('$."', a.idAtributo, '"'))) = 'NULL'
              OR TRIM(JSON_UNQUOTE(JSON_EXTRACT(pValores, CONCAT('$."', a.idAtributo, '"')))) = ''
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Se detectaron atributos obligatorios faltantes o vacios';
    END IF;

END//
DELIMITER ;

-- ======================================== Set Valor (Alta/Modificación/Baja unificada)
DROP PROCEDURE IF EXISTS sp_setValor;
DELIMITER //

CREATE PROCEDURE sp_setValor(
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
    DECLARE vExiste INT DEFAULT 0;
    DECLARE vValorViejo VARCHAR(100);
    DECLARE vComentario VARCHAR(200);

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

    -- 6. Verificar si ya existe un valor cargado, y traer el valor viejo
    SELECT 1, valor INTO vExiste, vValorViejo
    FROM Valores
    WHERE idActivo = pIdActivo AND idAtributo = pIdAtributo;

    -- 7. REGLA CRÍTICA: no se puede dejar en NULL/vacío un atributo obligatorio
    IF pValor IS NULL AND vObligatorio = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este atributo es obligatorio, no puede dejarse vacío o nulo';
    END IF;

    -- 8. Caso sin cambios: no existía y se pide poner NULL, o existía y el valor es igual
    IF NOT vExiste AND pValor IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay ningún valor cargado para eliminar en este atributo';
    END IF;

    IF vExiste AND pValor <=> vValorViejo THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se realizaron cambios en el valor del atributo';
    END IF;

    -- =========================================================================
    -- INICIO DE TRANSACCIÓN (Valor + Historial)
    -- =========================================================================
    START TRANSACTION;

    IF NOT vExiste THEN
        -- ALTA
        INSERT INTO Valores (idActivo, idAtributo, valor)
        VALUES (pIdActivo, pIdAtributo, pValor);
        SET vComentario = 'Alta de valor de atributo';

    ELSEIF pValor IS NULL THEN
        -- BAJA (ya sabemos que no es obligatorio por la validación anterior)
        DELETE FROM Valores
        WHERE idActivo = pIdActivo AND idAtributo = pIdAtributo;
        SET vComentario = 'Eliminación de valor de atributo';

    ELSE
        -- MODIFICACIÓN
        UPDATE Valores
        SET valor = pValor
        WHERE idActivo = pIdActivo AND idAtributo = pIdAtributo;
        SET vComentario = 'Modificación de valor de atributo';
    END IF;

    -- Registrar en el Historial como modificación
    CALL sp_registrarHistorial(
        pIdUsuario,
        pIdActivo,
        vComentario,
        'M',
        JSON_OBJECT(vNombreAtributo, vValorViejo),
        JSON_OBJECT(vNombreAtributo, pValor)
    );

    COMMIT;

END//
DELIMITER ;