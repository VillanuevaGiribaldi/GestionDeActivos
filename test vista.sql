select * from Activos;
select * from Tipos;
select * from ComposicionTipos;
select * from Marcas;
select * from Ubicaciones;
select * from Estados;
select * from `Usuarios`;
    
-- Probando sp_nuevoActivo
CALL sp_nuevoActivo(
     /* idUsuario     */ 1,
    /* pNombreMarca     */ 'Dell',
    /* pNombreUbicacion */ 'Sede Central',
    /* pNombreTipo      */ 'PC',
    /* pNombreEstado    */ 'Operativo',
    /* pidFactura       */ NULL,
    /* pidPersona       */ 1,
    /* pidCompone       */ NULL,
    /* pNombre          */ 'PC-Administracion-01',
    /* pAtributosExtra  */ '{"Sistema Operativo":"Windows 11","Direccion IP":"192.168.1.10"}',
    /* pPrecioUnitario  */ 1250000.00,
    /* pNumeroSerie     */ 'DLPCA001',
    /* pModelo          */ 'OptiPlex 7010'
);


CALL sp_modificarActivo(
	/* pidActivo */			3,
    /* pidUsuario */			1,
    /* pNombreMarca     */ 'Dell',
    /* pNombreUbicacion */ 'Oficina IT',
    /* pNombreTipo      */ 'PC',
    /* pNombreEstado    */ 'Operativo',
    /* pidFactura       */ '1',
    /* pidPersona       */ 2,
    /* pidCompone       */ NULL,
    /* pNombre          */ 'Modificado 12',
    /* pAtributosExtra  */ NULL,
    /* pPrecioUnitario  */ 100,
    /* pNumeroSerie     */ 'LEN-PC-888',
    /* pModelo          */ 'ThinkPad E14'
);

call sp_listarTodo();
select * from `Historial`;

select * from `Ubicaciones`

call `sp_modificarUbicacion`(5,NULL,null,null,null);
call `sp_modificarUbicacion`(5,4,null,null,null);
call `sp_modificarUbicacion`(5,5,'Cajon 1',null,'A');
call `sp_modificarUbicacion`(5,null,'Cajon 1',null,'A');


WITH RECURSIVE Ancestros AS (
        SELECT idUbicacion, idUbicacionPadre
        FROM Ubicaciones
        WHERE idUbicacion = 5

        UNION ALL

        SELECT u.idUbicacion, u.idUbicacionPadre
        FROM Ubicaciones u
        INNER JOIN Ancestros a ON u.idUbicacion = a.idUbicacionPadre
      )
      SELECT 1 FROM Ancestros WHERE idUbicacion = 1



SELECT * FROM `Atributos`;
SELECT *
        FROM JSON_TABLE(
            JSON_KEYS('{"SO":"Windows 11","Direccion IP":"192.168.1.10"}'),
            '$[*]' COLUMNS (
                nombre VARCHAR(45) PATH '$'
            )
        ) AS j
        WHERE NOT EXISTS (
            SELECT 1
            FROM Atributos a
            WHERE a.idTipo = 4
              AND a.nombre = j.nombre
        );

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

-- ========================================
-- ATRIBUTOS DE PC
-- ========================================
INSERT INTO Atributos (idTipo, porDefecto, nombre, obligatorio)
VALUES
(4, 'Windows 10', 'SO', 1),
(4, NULL, 'IP', 0),
(4, NULL, 'MAC', 0),
(4, NULL, 'Aplicaciones', 0),
(4, NULL, 'Almacenamiento', 0); 

    SELECT 1 FROM Activos a 
    INNER JOIN ComposicionTipos ct ON a.idTipo = ct.idTipoPadre
    WHERE a.idActivo = 3 AND ct.idTipoComponente = 5;
    select * from Activos;

    CALL sp_nuevoActivo(
     /* idUsuario     */ 1,
    /* pNombreMarca     */ 'Dell',
    /* pNombreUbicacion */ 'Sede Central',
    /* pNombreTipo      */ 'RAM',
    /* pNombreEstado    */ 'Operativo',
    /* pidFactura       */ NULL,
    /* pidPersona       */ 1,
    /* pidCompone       */ 3,
    /* pNombre          */ 'RAM1',
    /* pAtributosExtra  */ '{"Tamaño":"(8 GB)"}',
    /* pPrecioUnitario  */ 200000.00,
    /* pNumeroSerie     */ 'RAM001',
    /* pModelo          */ 'RAMDDR4'
);
CALL sp_nuevoActivo(1, 'Dell', 'Sede Central', 'RAM', 'Operativo', NULL, 1, 3, 'RAM2', '{"Tamaño":"(8 GB)"}', 200000.00, 'RAM002', 'RAMDDR4');
CALL sp_nuevoActivo(1, 'Dell', 'Sede Central', 'RAM', 'Operativo', NULL, 1, 3, 'RAM3', '{"Tamaño":"(8 GB)"}', 200000.00, 'RAM0003', 'RAMDDR4');
CALL sp_modificarActivo(5,1, 'Dell', 'Sede Central', 'RAM', 'Operativo', NULL, 1, null, 'RAM3', '{"Tamaño":"(8 GB)"}', 200000.00, 'RAM003', 'RAMDDR4');
    -- idTipo = 5
    -- idCompone = 3
select count(`idTipo`) from Activos a 
    where a.compone=3 and a.`idTipo`=5
    GROUP BY `idTipo`;

IF (
    SELECT COUNT(*)
    FROM Activos
    WHERE compone = 3 AND idTipo = 5 
    GROUP BY `idTipo`
) > 2 THEN

    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El activo ya tiene 2 RAM'

END IF;

SELECT ct.cantidadComponentesMaxima from `ComposicionTipos` ct 
    inner join `Activos` a on a.`idTipo`=ct.`idTipoPadre`
    where ct.`idTipoComponente`=5 and a.`idActivo`= 3 limit 1;

DELETE FROM Activos
    WHERE idActivo IN (4, 5, 6, 7);