
select count(`idTipo`) from Activos a 
    where a.compone=3 and a.`idTipo`=5
    GROUP BY `idTipo`;
SELECT ct.cantidadComponentesMaxima from `ComposicionTipos` ct 
    inner join `Activos` a on a.`idTipo`=ct.`idTipoPadre`
    where ct.`idTipoComponente`=5 and a.`idActivo`= 3 limit 1;


WITH RECURSIVE Ancestros AS (
        SELECT idUbicacion, idUbicacionPadre
        FROM Ubicaciones
        WHERE idUbicacion = 5

        UNION ALL

        SELECT u.idUbicacion, u.idUbicacionPadre
        FROM Ubicaciones u
        INNER JOIN Ancestros a ON u.idUbicacion = a.idUbicacionPadre
      )
      SELECT * FROM Ancestros


WITH RECURSIVE Descendientes AS (
    SELECT `idTipoComponente`,`idTipoPadre` 
    FROM`ComposicionTipos`
    WHERE `idTipoPadre` = 5
    
    UNION ALL

    SELECT ct.`idTipoComponente`,ct.`idTipoPadre`
    FROM `ComposicionTipos` ct
    INNER JOIN Descendientes d ON ct.`idTipoPadre`=d.`idTipoComponente`
) 
SELECT 1 FROM Descendientes d
WHERE d.`idTipoComponente`=12;

IF (
    SELECT COUNT(*)
    FROM Activos
    WHERE compone = 3 AND idTipo = 5 
    GROUP BY `idTipo`
) > 2 THEN

    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El activo ya tiene 2 RAM'

END IF;

select * from 
JSON_TABLE(JSON_KEYS('{"SO":"Windows 11","Direccion IP":"192.168.1.10"}'),
'$[*]' COLUMNS
(
                nombre VARCHAR(45) PATH '$'
            )
            ) as j;

select * from 
JSON_TABLE('{"SO":"Windows 11","Direccion IP":"192.168.1.10"}',
'$[*]' COLUMNS
(
                nombre VARCHAR(45) PATH '$'
            )
            ) as j;

SELECT * FROM `Atributos`;
SET @Resultado = null;
SELECT *
        FROM JSON_TABLE(
            JSON_KEYS('{"SO":"win","IP":"192.168.1.10","MAC":null}'),
            '$[*]' COLUMNS (
                nombre VARCHAR(45) PATH '$'
            )
        ) AS j
        WHERE EXISTS (
            SELECT 1
            FROM Atributos a
            WHERE a.idTipo = 4
              AND a.nombre = j.nombre
              AND a.obligatorio = 1
        );

SELECT * FROM `Atributos` a 
LEFT JOIN JSON_TABLE(
            JSON_KEYS('{"SO":null,"IP":"192.168.1.10","MAC":null}'),
            '$[*]' COLUMNS (
                nombre VARCHAR(45) PATH '$'
            )
        ) as j ON j.nombre=a.nombre
WHERE j.nombre is null and a.obligatorio=1;
SELECT JSON_VALUE('{"SO":null}','$.SO');
set @pAtributos = '{"IP":"192.168.1.10","MAC":null}';
SELECT *
    FROM Atributos a
    WHERE a.idTipo = 4
      AND a.obligatorio = 1
      AND (
        JSON_EXTRACT(@pAtributos, CONCAT('$."', a.nombre, '"')) IS NULL
        OR JSON_TYPE(JSON_EXTRACT(@pAtributos, CONCAT('$."', a.nombre, '"'))) = 'NULL'
        OR TRIM(JSON_UNQUOTE(JSON_EXTRACT(@pAtributos, CONCAT('$."', a.nombre, '"')))) = ''
      );

SET @faltantes = (
    SELECT JSON_OBJECTAGG(a.nombre, NULL)
    FROM Atributos a
    WHERE a.idTipo = 4
      -- AND a.obligatorio = 1   -- si querés filtrar solo obligatorios, si no dejalo comentado
      AND NOT JSON_CONTAINS_PATH(
              @pAtributos,
              'one',
              CONCAT('$."', a.nombre, '"')
          )
);
SELECT @faltantes;
-- 2) Fusionar: si no hay faltantes, @faltantes es NULL, por eso el COALESCE
SET @pAtributos = JSON_MERGE_PRESERVE(
    @pAtributos,
    COALESCE(@faltantes, JSON_OBJECT())
);
SELECT @pAtributos;


SET @valores = JSON_OBJECT('6', 'Windows 11', '7', '192.1.1.5');

CALL sp_verificarValores(4, @valores);


SELECT 
    4 AS idTipo_prueba,
    jt.idAtributo,
    JSON_UNQUOTE(JSON_EXTRACT(@valores, CONCAT('$."', jt.idAtributo, '"'))) AS valor
FROM JSON_TABLE(
    JSON_KEYS(@valores),
    '$[*]' COLUMNS (idAtributo INT PATH '$')
) AS jt;
select * from JSON_EXTRACT(@valores)
select * from `Atributos` a
inner join Tipos t on a.`idTipo`=t.`idTipo`;


SELECT * from `Ubicaciones`;
select a.`idActivo`,a.`idUbicacion` from `Activos` a
-- WHERE a.`idActivo`=25
ORDER BY  a.`idUbicacion`;   ;
select a.`idActivo`,a.`idUbicacion`, `Descendientes`.`nombre` from `Activos` a
INNER JOIN 
(
        WITH RECURSIVE Descendientes AS (
            SELECT idUbicacion, nombre 
            FROM `Ubicaciones`
            WHERE `idUbicacion`=1

            UNION 

            SELECT u.`idUbicacion`,u.nombre
            FROM `Ubicaciones` u INNER JOIN Descendientes d
            ON u.`idUbicacionPadre` = d.`idUbicacion`) 
    SELECT * FROM Descendientes 
) as Descendientes
ON a.`idUbicacion`=Descendientes.`idUbicacion`
ORDER BY  a.`idActivo`;   
SELECT * FROM `Descendientes`;

CALL `sp_modificarUbicacion`(6,2,'Sala de servidores','servidores','A');
select @servidores;
WITH RECURSIVE Descendientes AS (
            SELECT idUbicacion, nombre 
            FROM `Ubicaciones`
            WHERE `idUbicacion`=1

            UNION 

            SELECT u.`idUbicacion`,u.nombre
            FROM `Ubicaciones` u INNER JOIN Descendientes d
            ON u.`idUbicacionPadre` = d.`idUbicacion`) 
    SELECT * FROM Descendientes;

    INNER JOIN 
    (
                INNER JOIN 
    (
            WITH RECURSIVE Descendientes AS 
            (
                SELECT idUbicacion, nombre 
                FROM `Ubicaciones`
                WHERE `idUbicacion`=pIdUbicacion

                UNION 

                SELECT u.`idUbicacion`,u.nombre
                FROM `Ubicaciones` u INNER JOIN Descendientes d
                ON u.`idUbicacionPadre` = d.`idUbicacion`
            ) 
        SELECT * FROM Descendientes
    ) as UbicacionesDescendientes
        ON a.`idUbicacion` = UbicacionesDescendientes.`idUbicacion`
    ) as UbicacionesDescendientes
        ON a.`idUbicacion` = UbicacionesDescendientes.`idUbicacion`