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

SET @idMantenimiento = NULL;

CALL sp_altaMantenimiento(
    1,
    1,
    'El equipo no enciende',
    CURDATE(),
    3,
    1,
    @idMantenimiento
);
CALL `sp_finMantenimiento`(
    @idMantenimiento,
    'Se enchufo el equipo otra vez',
    CURRENT_DATE(),
    5.00,
    3,
    1
);

SELECT @idMantenimiento;
select * from `Mantenimientos`;
SELECt * FROM `Historial`;
select * from `Activos`;
SELECT * FROM `ComposicionTipos`; 
SELECT * FROM `Tipos`; 
INSERT INTO `Tipos`(nombre, estado, descripcion) VALUES ('Microchip','A','Chip de memoria'),('Compuerta','A','Copuerta logica'),('Transistor','A','transistor tipo mosfet');

CALL `sp_componerTipos`('RAM','Microchip',null);
CALL `sp_componerTipos`('Microchip','Compuerta',null);
CALL `sp_componerTipos`('Compuerta','Transistor',null);

CALL `sp_componerTipos`('Compuerta','RAM',null);

DELETE from `ComposicionTipos`where `idTipoPadre`=5;

SELECT * FROM `Tipos`;
SELECT * FROM `Atributos` where `idTipo`=4;

set @idAtributo = NULL;
CALL `sp_nuevoAtributo`(4,'ip','0:0:0:0',0,@idAtributo)

set @JSONtest = '{"SO":"windows 11","IP":"192.168.1.10","MAC":null,"Brazos":5}';
set @resultado = NULL;
CALL `sp_verificarAtributos`(4,@JSONtest,@resultado);
set @JSONtest = '{"SO":"","IP":"192.168.1.10","MAC":null}';
CALL `sp_verificarAtributos`(4,@JSONtest,@resultado);

set @JSONtest = '{"SO":"Windows 11","IP":"192.168.1.10","MAC":null}';
CALL `sp_verificarAtributos`(4,@JSONtest,@resultado);

select @JSONtest;
CALL sp_nuevoActivo(
     /* idUsuario     */ 1,
    /* pNombreMarca     */ 'Dell',
    /* pNombreUbicacion */ 'Sede Central',
    /* pNombreTipo      */ 'PC',
    /* pNombreEstado    */ 'Operativo',
    /* pidFactura       */ NULL,
    /* pidPersona       */ 1,
    /* pidCompone       */ NULL,
    /* pNombre          */ 'RAM1',
    /* pAtributosExtra  */ '{"Tamaño":"(8 GB)"}',
    /* pPrecioUnitario  */ 200000.00,
    /* pNumeroSerie     */ 'PCJSON001',
    /* pModelo          */ 'PCJSON'
);
CALL sp_nuevoActivo(
     /* idUsuario     */ 1,
    /* pNombreMarca     */ 'Dell',
    /* pNombreUbicacion */ 'Sede Central',
    /* pNombreTipo      */ 'PC',
    /* pNombreEstado    */ 'Operativo',
    /* pidFactura       */ NULL,
    /* pidPersona       */ 1,
    /* pidCompone       */ NULL,
    /* pNombre          */ 'RAM1',
    /* pAtributosExtra  */ '{"SO":" ","IP":"192.168.1.10","MAC":null}',
    /* pPrecioUnitario  */ 200000.00,
    /* pNumeroSerie     */ 'PCJSON001',
    /* pModelo          */ 'PCJSON'
);
CALL sp_nuevoActivo(
     /* idUsuario     */ 1,
    /* pNombreMarca     */ 'Dell',
    /* pNombreUbicacion */ 'Sede Central',
    /* pNombreTipo      */ 'PC',
    /* pNombreEstado    */ 'Operativo',
    /* pidFactura       */ NULL,
    /* pidPersona       */ 1,
    /* pidCompone       */ NULL,
    /* pNombre          */ 'RAM1',
    /* pAtributosExtra  */ '{"SO":"Windows 11","IP":"192.168.1.10","MAC":null}',
    /* pPrecioUnitario  */ 200000.00,
    /* pNumeroSerie     */ 'PCJSON001',
    /* pModelo          */ 'PCJSON'
);
select * from `Activos`;

CALL sp_modificarActivo(
    /* idActivo */ 4,
     /* idUsuario     */ 1,
    /* pNombreMarca     */ 'Dell',
    /* pNombreUbicacion */ 'Sede Central',
    /* pNombreTipo      */ 'PC',
    /* pNombreEstado    */ 'Operativo',
    /* pidFactura       */ NULL,
    /* pidPersona       */ 1,
    /* pidCompone       */ NULL,
    /* pNombre          */ 'PCJSON001',
    /* pAtributosExtra  */ '{"SO":" ","IP":"192.168.1.10","MAC":null}',
    /* pPrecioUnitario  */ 200000.00,
    /* pNumeroSerie     */ 'PCJSON001',
    /* pModelo          */ 'PCJSON'
);
CALL sp_modificarActivo(
    /* idActivo         */  4,
     /* idUsuario       */  1,
    /* pNombreMarca     */ 'Dell',
    /* pNombreUbicacion */ 'Sede Central',
    /* pNombreTipo      */ 'PC',
    /* pNombreEstado    */ 'Operativo',
    /* pidFactura       */ NULL,
    /* pidPersona       */ 1,
    /* pidCompone       */ NULL,
    /* pNombre          */ 'PCJSON001',
    /* pAtributosExtra  */ '{"SO":"Windows 10","IP":"192.168.1.10","MAC":null}',
    /* pPrecioUnitario  */ 200000.00,
    /* pNumeroSerie     */ 'PCJSON001',
    /* pModelo          */ 'PCJSON'
);

select * from `Activos`;
SELECT * FROM `Historial`;
