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
    /* pNombreMarca     */ NULL,
    /* pNombreUbicacion */ NULL,
    /* pNombreTipo      */ NULL,
    /* pNombreEstado    */ 'Baja',
    /* pidFactura       */ NULL,
    /* pidPersona       */ NULL,
    /* pidCompone       */ NULL,
    /* pNombre          */ NULL,
    /* pAtributosExtra  */ NULL,
    /* pPrecioUnitario  */ NULL,
    /* pNumeroSerie     */ NULL,
    /* pModelo          */ NULL
);

call sp_listarTodo();
select * from `Historial`;


