select * from Activos;
select * from Tipos;
select * from ComposicionTipos;
select * from Marcas;
select * from Ubicaciones;
select * from Estados;



-- Consulta usada para verificar si hay compocición al insertar un activo
-- 3 una PC
-- 7 RAM
select 1 From  Activos a 
        inner join ComposicionTipos ct on a.idTipo=ct.idTipoPadre
		where a.idActivo = 3 and ct.idTipoComponente = 7; 
        
-- Probando sp_nuevoActivo
CALL sp_nuevoActivo(
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