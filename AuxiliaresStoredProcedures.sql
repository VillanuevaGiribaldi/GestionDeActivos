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