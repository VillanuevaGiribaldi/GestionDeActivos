USE `GestionDeActivos`;

-- ==========================================
-- FASE 1: Marcas, Estados y Tipos
-- (Cada registro se guarda en su propia variable)
-- ==========================================

-- ESTADOS
CALL sp_nuevoEstado('Operativo', 'El activo funciona correctamente', 'A', @idEstOperativo);
CALL sp_nuevoEstado('En Reparación', 'El activo está en mantenimiento', 'A', @idEstEnReparacion);
CALL sp_nuevoEstado('Baja', 'El activo fue dado de baja', 'A', @idEstBaja);
CALL sp_nuevoEstado('Almacenado', 'El activo está guardado sin uso', 'A', @idEstAlmacenado);

-- MARCAS
CALL sp_nuevaMarca('Dell', 'Marca de equipos informáticos', 'A', @idMarcaDell);
CALL sp_nuevaMarca('Lenovo', 'Marca de equipos informáticos', 'A', @idMarcaLenovo);
CALL sp_nuevaMarca('Logitech', 'Marca de periféricos', 'A', @idMarcaLogitech);
CALL sp_nuevaMarca('HP', 'Marca de equipos informáticos', 'A', @idMarcaHP);
CALL sp_nuevaMarca('Samsung', 'Marca de electrónica', 'A', @idMarcaSamsung);
CALL sp_nuevaMarca('Kingston', 'Marca de memorias y almacenamiento', 'A', @idMarcaKingston);
CALL sp_nuevaMarca('Intel', 'Marca de procesadores', 'A', @idMarcaIntel);
CALL sp_nuevaMarca('AMD', 'Marca de procesadores', 'A', @idMarcaAMD);
CALL sp_nuevaMarca('Corsair', 'Marca de componentes de PC', 'A', @idMarcaCorsair);
CALL sp_nuevaMarca('Western Digital', 'Marca de almacenamiento', 'A', @idMarcaWD);
CALL sp_nuevaMarca('Seagate', 'Marca de almacenamiento', 'A', @idMarcaSeagate);
CALL sp_nuevaMarca('Apple', 'Marca de equipos informáticos', 'A', @idMarcaApple);
CALL sp_nuevaMarca('Motorola', 'Marca de celulares', 'A', @idMarcaMotorola);
CALL sp_nuevaMarca('Xiaomi', 'Marca de celulares y electrónica', 'A', @idMarcaXiaomi);

-- TIPOS
CALL sp_nuevoTipo('Notebook', 'Computadora portátil', 'A', @idTipoNotebook);
CALL sp_nuevoTipo('Monitor', 'Pantalla de visualización', 'A', @idTipoMonitor);
CALL sp_nuevoTipo('Mouse', 'Periférico de entrada', 'A', @idTipoMouse);
CALL sp_nuevoTipo('PC', 'Computadora de escritorio', 'A', @idTipoPC);
CALL sp_nuevoTipo('RAM', 'Memoria de acceso aleatorio', 'A', @idTipoRAM);
CALL sp_nuevoTipo('CPU', 'Procesador', 'A', @idTipoCPU);
CALL sp_nuevoTipo('Fuente', 'Fuente de alimentación', 'A', @idTipoFuente);
CALL sp_nuevoTipo('Disco', 'Unidad de almacenamiento', 'A', @idTipoDisco);
CALL sp_nuevoTipo('SIM', 'Tarjeta SIM', 'A', @idTipoSIM);
CALL sp_nuevoTipo('Celular', 'Teléfono móvil', 'A', @idTipoCelular);

-- ==========================================
-- FASE 2: Composicion de tipos
-- ==========================================
CALL sp_nuevaComposicionTipo('PC', 'CPU', 1);
CALL sp_nuevaComposicionTipo('PC', 'RAM', 2);
CALL sp_nuevaComposicionTipo('PC', 'Fuente', 1);
CALL sp_nuevaComposicionTipo('PC', 'Disco', 4);
CALL sp_nuevaComposicionTipo('Celular', 'SIM', 2);

-- ==========================================
-- FASE 3: ATRIBUTOS
-- ==========================================
CALL sp_nuevoAtributo(@idTipoNotebook, 'RAM', NULL, TRUE, @idAtrNB_RAM);
CALL sp_nuevoAtributo(@idTipoNotebook, 'Almacenamiento', NULL, TRUE, @idAtrNB_Almacenamiento);

CALL sp_nuevoAtributo(@idTipoMonitor, 'Resolucion', '1920x1080', FALSE, @idAtrMON_Resolucion);
CALL sp_nuevoAtributo(@idTipoMonitor, 'Pulgadas', NULL, FALSE, @idAtrMON_Pulgadas);

CALL sp_nuevoAtributo(@idTipoMouse, 'Conexion', 'USB', FALSE, @idAtrMOU_Conexion);

CALL sp_nuevoAtributo(@idTipoPC, 'SO', 'Windows 10', TRUE, @idAtrPC_SO);
CALL sp_nuevoAtributo(@idTipoPC, 'IP', NULL, FALSE, @idAtrPC_IP);

CALL sp_nuevoAtributo(@idTipoRAM, 'Tamaño', NULL, TRUE, @idAtrRAM_Tamano);
CALL sp_nuevoAtributo(@idTipoRAM, 'TipoMemoria', 'DDR4', FALSE, @idAtrRAM_TipoMemoria);

CALL sp_nuevoAtributo(@idTipoCPU, 'Modelo', NULL, TRUE, @idAtrCPU_Modelo);
CALL sp_nuevoAtributo(@idTipoCPU, 'Nucleos', NULL, FALSE, @idAtrCPU_Nucleos);

CALL sp_nuevoAtributo(@idTipoFuente, 'Potencia', NULL, TRUE, @idAtrFUE_Potencia);
CALL sp_nuevoAtributo(@idTipoFuente, 'Certificacion', NULL, FALSE, @idAtrFUE_Certificacion);

CALL sp_nuevoAtributo(@idTipoDisco, 'Capacidad', NULL, TRUE, @idAtrDIS_Capacidad);
CALL sp_nuevoAtributo(@idTipoDisco, 'Tecnologia', 'SSD', FALSE, @idAtrDIS_Tecnologia);

CALL sp_nuevoAtributo(@idTipoSIM, 'Numero', NULL, TRUE, @idAtrSIM_Numero);
CALL sp_nuevoAtributo(@idTipoSIM, 'Operador', NULL, FALSE, @idAtrSIM_Operador);

CALL sp_nuevoAtributo(@idTipoCelular, 'SistemaOperativo', 'Android', TRUE, @idAtrCEL_SO);
CALL sp_nuevoAtributo(@idTipoCelular, 'Almacenamiento', NULL, FALSE, @idAtrCEL_Almacenamiento);

-- ==========================================
-- FASE 4: UBICACIONES
-- ==========================================
CALL sp_nuevaUbicacion(NULL, 'Sede Central', 'Edificio principal', 'A', @idSedeCentral);
CALL sp_nuevaUbicacion(@idSedeCentral, 'Oficina IT', 'Área de sistemas y servidores', 'A', @idOficinaIT);
CALL sp_nuevaUbicacion(@idSedeCentral, 'Oficina Ventas', 'Área de ventas', 'A', @idOficinaVentas);
CALL sp_nuevaUbicacion(NULL, 'Sucursal Norte', 'Sucursal de atención al público', 'A', @idSucursalNorte);
CALL sp_nuevaUbicacion(NULL, 'Deposito Central', 'Depósito general de equipos', 'A', @idDepositoCentral);

CALL sp_nuevaUbicacion(@idOficinaIT, 'Sala de servidores', 'servidores', 'A', @servidores);
CALL sp_nuevaUbicacion(@servidores, 'Rack1', 'rack con un servidor', 'A', @rack1);
CALL sp_nuevaUbicacion(@servidores, 'Rack2', 'rack con un nvr', 'A', @rack2);

-- ==========================================
-- FASE 5: PERSONAS
-- ==========================================
CALL sp_nuevaPersona('Juan', 'Pérez', '35123456', 'Soporte IT', 'A', @idJuan);
CALL sp_nuevaPersona('María', 'Gómez', '32987654', 'Gerente de Ventas', 'A', @idMaria);
CALL sp_nuevaPersona('Carlos', 'Rodríguez', '30111222', 'Técnico de Mantenimiento', 'A', @idCarlos);
CALL sp_nuevaPersona('Ana', 'López', '31222333', 'Administración', 'A', @idAna);
CALL sp_nuevaPersona('Diego', 'Fernández', '33444555', 'Soporte de Infraestructura', 'A', @idDiego);

-- ==========================================
-- FASE 6: USUARIOS
-- ==========================================
CALL sp_nuevoUsuario(@idJuan, 'jperez', 'contrasenia1', 'ADMIN_IT', 'A', @idUsuarioJuan);
CALL sp_nuevoUsuario(@idMaria, 'mgomez', 'contrasenia2', 'USUARIO_VENTAS', 'A', @idUsuarioMaria);

-- ==========================================
-- FASE 7: PROVEEDORES
-- ==========================================
CALL sp_nuevoProveedor('TechStore Arg', 'Av. Corrientes 1234', '11-4567-8900', 'ventas@techstore.com', 'Venta de computadoras y notebooks', @idProveedorTechStore);
CALL sp_nuevoProveedor('Hardware Tucumán', 'Av. Mate de Luna 850', '381-4567890', 'contacto@hardwaretuc.com', 'Componentes y periféricos informáticos', @idProveedorHardware);
CALL sp_nuevoProveedor('CompuMarket', 'San Martín 650', '381-4234567', 'ventas@compumarket.com', 'Equipamiento informático y accesorios', @idProveedorCompuMarket);
CALL sp_nuevoProveedor('ElectroTec', '24 de Septiembre 420', '381-4345678', 'info@electrotec.com', 'Fuentes, discos y componentes electrónicos', @idProveedorElectroTec);
CALL sp_nuevoProveedor('MovilTech', 'Junín 780', '381-4456789', 'ventas@moviltech.com', 'Celulares, SIM y accesorios móviles', @idProveedorMovilTech);

-- ==========================================
-- FASE 8: FACTURAS
-- ==========================================
CALL sp_nuevaFactura(
    @idProveedorTechStore, '2026-08-20 10:00:00', 5000.00, 'USD',
    'FC-A-0001-00000001', '/docs/facturas/fc-pcs-0001.pdf', 'A', @idFacturaPC
);

CALL sp_nuevaFactura(
    @idProveedorMovilTech, '2026-08-20 11:00:00', 1000.00, 'USD',
    'FC-A-0001-00000002', '/docs/facturas/fc-celulares-0001.pdf', 'A', @idFacturaCelulares
);

-- ==========================================
-- FASE 9: ACTIVOS
-- ==========================================
SET @idActivoGenerado = NULL;

-- 5 PCs de la factura @idFacturaPC
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaDell, @idOficinaIT, @idTipoPC, @idEstOperativo,
    @idFacturaPC, NULL, NULL, 'PC-IT-001',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 10', CAST(@idAtrPC_IP AS CHAR), '192.168.1.101'),
    1000.00, 'DELL-PC-001', 'OptiPlex 7090', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaLenovo, @idOficinaIT, @idTipoPC, @idEstOperativo,
    @idFacturaPC, NULL, NULL, 'PC-IT-002',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 11', CAST(@idAtrPC_IP AS CHAR), '192.168.1.102'),
    1000.00, 'LEN-PC-002', 'ThinkCentre M70', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaHP, @idOficinaVentas, @idTipoPC, @idEstOperativo,
    @idFacturaPC, NULL, NULL, 'PC-VT-001',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 11', CAST(@idAtrPC_IP AS CHAR), '192.168.1.103'),
    1000.00, 'HP-PC-003', 'ProDesk 400', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaDell, @idOficinaVentas, @idTipoPC, @idEstOperativo,
    @idFacturaPC, NULL, NULL, 'PC-VT-002',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 10', CAST(@idAtrPC_IP AS CHAR), '192.168.1.104'),
    1000.00, 'DELL-PC-004', 'OptiPlex 3080', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaLenovo, @idSedeCentral, @idTipoPC, @idEstOperativo,
    @idFacturaPC, NULL, NULL, 'PC-SC-001',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 11', CAST(@idAtrPC_IP AS CHAR), '192.168.1.105'),
    1000.00, 'LEN-PC-005', 'ThinkCentre M75', @idActivoGenerado
);

-- 5 Celulares de la factura @idFacturaCelulares
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaSamsung, @idOficinaVentas, @idTipoCelular, @idEstOperativo,
    @idFacturaCelulares, NULL, NULL, 'CEL-VT-001',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'Android', CAST(@idAtrCEL_Almacenamiento AS CHAR), '128GB'),
    200.00, 'SAM-CEL-001', 'Galaxy A55', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaMotorola, @idOficinaVentas, @idTipoCelular, @idEstOperativo,
    @idFacturaCelulares, NULL, NULL, 'CEL-VT-002',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'Android', CAST(@idAtrCEL_Almacenamiento AS CHAR), '128GB'),
    200.00, 'MOT-CEL-002', 'Moto G84', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaXiaomi, @idSedeCentral, @idTipoCelular, @idEstOperativo,
    @idFacturaCelulares, NULL, NULL, 'CEL-SC-001',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'Android', CAST(@idAtrCEL_Almacenamiento AS CHAR), '256GB'),
    200.00, 'XIA-CEL-003', 'Redmi Note 13', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaSamsung, @idSedeCentral, @idTipoCelular, @idEstOperativo,
    @idFacturaCelulares, NULL, NULL, 'CEL-SC-002',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'Android', CAST(@idAtrCEL_Almacenamiento AS CHAR), '128GB'),
    200.00, 'SAM-CEL-004', 'Galaxy A35', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaApple, @idOficinaIT, @idTipoCelular, @idEstOperativo,
    @idFacturaCelulares, NULL, NULL, 'CEL-IT-001',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'iOS', CAST(@idAtrCEL_Almacenamiento AS CHAR), '128GB'),
    200.00, 'APP-CEL-005', 'iPhone 13', @idActivoGenerado
);

-- 2 Notebooks sin factura
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaDell, @idOficinaIT, @idTipoNotebook, @idEstOperativo,
    NULL, @idJuan, NULL, 'NB-IT-001',
    JSON_OBJECT(CAST(@idAtrNB_RAM AS CHAR), '16GB', CAST(@idAtrNB_Almacenamiento AS CHAR), '512GB SSD'),
    750.00, 'DELL-NB-001', 'Latitude 5420', @idActivoGenerado
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaLenovo, @idOficinaVentas, @idTipoNotebook, @idEstOperativo,
    NULL, @idMaria, NULL, 'NB-VT-001',
    JSON_OBJECT(CAST(@idAtrNB_RAM AS CHAR), '8GB', CAST(@idAtrNB_Almacenamiento AS CHAR), '256GB SSD'),
    750.00, 'LEN-NB-002', 'ThinkPad E14', @idActivoGenerado
);

-- ==========================================
-- FASE 10: COMPONENTES DE PCs
-- ==========================================
CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idOficinaIT, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-IT-001'), 'RAM-PC001-01', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC001-01', 'ValueRAM', @idActivoGenerado);
CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idOficinaIT, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-IT-001'), 'RAM-PC001-02', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC001-02', 'ValueRAM', @idActivoGenerado);

CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idOficinaIT, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-IT-002'), 'RAM-PC002-01', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC002-01', 'ValueRAM', @idActivoGenerado);
CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idOficinaIT, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-IT-002'), 'RAM-PC002-02', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC002-02', 'ValueRAM', @idActivoGenerado);

CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idOficinaVentas, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-VT-001'), 'RAM-PC003-01', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC003-01', 'ValueRAM', @idActivoGenerado);
CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idOficinaVentas, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-VT-001'), 'RAM-PC003-02', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC003-02', 'ValueRAM', @idActivoGenerado);

CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idOficinaVentas, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-VT-002'), 'RAM-PC004-01', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC004-01', 'ValueRAM', @idActivoGenerado);
CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idOficinaVentas, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-VT-002'), 'RAM-PC004-02', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC004-02', 'ValueRAM', @idActivoGenerado);

CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idSedeCentral, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-SC-001'), 'RAM-PC005-01', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC005-01', 'ValueRAM', @idActivoGenerado);
CALL sp_nuevoActivo(@idUsuarioJuan, @idMarcaKingston, @idSedeCentral, @idTipoRAM, @idEstOperativo, NULL, NULL, (SELECT idActivo FROM Activos WHERE nombre='PC-SC-001'), 'RAM-PC005-02', JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '4GB'), 50.00, 'KIN-RAM-PC005-02', 'ValueRAM', @idActivoGenerado);

-- ==========================================
-- FASE 11: ACTIVOS PARA PRUEBA DE BUSCADOR
-- ==========================================

-- 1. Monitor 4K
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaSamsung, @idOficinaIT, @idTipoMonitor, @idEstOperativo, NULL, NULL, NULL,
    'MON-IT-4K',
    JSON_OBJECT(CAST(@idAtrMON_Resolucion AS CHAR), '3840x2160', CAST(@idAtrMON_Pulgadas AS CHAR), '27'),
    350.00, 'SAM-MON-4K-01', 'Odyssey G7', @idActivoGenerado
);

-- 2. Monitor estándar asignado a Ana
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaDell, @idOficinaVentas, @idTipoMonitor, @idEstOperativo, NULL, @idAna, NULL,
    'MON-VT-FHD',
    JSON_OBJECT(CAST(@idAtrMON_Resolucion AS CHAR), '1920x1080', CAST(@idAtrMON_Pulgadas AS CHAR), '24'),
    150.00, 'DEL-MON-FHD-01', 'P2419H', @idActivoGenerado
);

-- 3. MacBook en reparación
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaApple, @idSedeCentral, @idTipoNotebook, @idEstEnReparacion, NULL, @idMaria, NULL,
    'NB-SC-MAC',
    JSON_OBJECT(CAST(@idAtrNB_RAM AS CHAR), '16GB', CAST(@idAtrNB_Almacenamiento AS CHAR), '512GB SSD'),
    1500.00, 'APP-MAC-999', 'MacBook Pro M2', @idActivoGenerado
);

-- 4. PC con Linux
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaCorsair, @idOficinaIT, @idTipoPC, @idEstAlmacenado, NULL, NULL, NULL,
    'PC-LINUX-01',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Ubuntu 22.04', CAST(@idAtrPC_IP AS CHAR), '10.0.0.5'),
    2000.00, 'COR-PC-UBUNTU', 'One i300', @idActivoGenerado
);

-- 5. RAM de 32GB
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaKingston, @idDepositoCentral, @idTipoRAM, @idEstAlmacenado, NULL, NULL, NULL,
    'RAM-DEP-01',
    JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '32GB', CAST(@idAtrRAM_TipoMemoria AS CHAR), 'DDR5'),
    120.00, 'KIN-RAM-32', 'Fury Beast', @idActivoGenerado
);

-- 6. RAM de 16GB
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaCorsair, @idDepositoCentral, @idTipoRAM, @idEstAlmacenado, NULL, NULL, NULL,
    'RAM-DEP-02',
    JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '16GB', CAST(@idAtrRAM_TipoMemoria AS CHAR), 'DDR4'),
    80.00, 'COR-RAM-16', 'Vengeance LPX', @idActivoGenerado
);

-- 7. Notebook potente en Sucursal Norte
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaHP, @idSucursalNorte, @idTipoNotebook, @idEstOperativo, NULL, @idCarlos, NULL,
    'NB-SN-001',
    JSON_OBJECT(CAST(@idAtrNB_RAM AS CHAR), '32GB', CAST(@idAtrNB_Almacenamiento AS CHAR), '1TB NVMe'),
    1200.00, 'HP-NB-SN-01', 'EliteBook 840', @idActivoGenerado
);

-- 8. Mouse inalámbrico
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaLogitech, @idSucursalNorte, @idTipoMouse, @idEstOperativo, NULL, @idCarlos, NULL,
    'MOU-SN-001',
    JSON_OBJECT(CAST(@idAtrMOU_Conexion AS CHAR), 'Inalambrico'),
    50.00, 'LOG-MOU-01', 'MX Master 3', @idActivoGenerado
);

-- 9. Disco duro mecánico
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaWD, @idDepositoCentral, @idTipoDisco, @idEstAlmacenado, NULL, NULL, NULL,
    'HDD-DEP-01',
    JSON_OBJECT(CAST(@idAtrDIS_Capacidad AS CHAR), '2TB', CAST(@idAtrDIS_Tecnologia AS CHAR), 'HDD'),
    60.00, 'WD-HDD-2TB', 'Blue', @idActivoGenerado
);

-- 10. Disco sólido SSD
CALL sp_nuevoActivo(
    @idUsuarioJuan, @idMarcaSeagate, @idDepositoCentral, @idTipoDisco, @idEstAlmacenado, NULL, NULL, NULL,
    'SSD-DEP-99',
    JSON_OBJECT(CAST(@idAtrDIS_Capacidad AS CHAR), '1TB', CAST(@idAtrDIS_Tecnologia AS CHAR), 'NVMe'),
    100.00, 'SEA-SSD-1TBq', 'FireCudaq', @idActivoGenerado
);