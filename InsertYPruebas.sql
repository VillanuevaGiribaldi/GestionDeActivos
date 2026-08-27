USE `GestionDeActivos` ;

-- ==========================================
-- FASE 1: Marcas, Estados y Tipos
-- ==========================================
 -- =====================================================
-- ESTADOS
-- =====================================================
CALL sp_nuevoEstado('Operativo', 'El activo funciona correctamente', 'A', @idEstado);
CALL sp_nuevoEstado('En Reparación', 'El activo está en mantenimiento', 'A', @idEstado);
CALL sp_nuevoEstado('Baja', 'El activo fue dado de baja', 'A', @idEstado);
CALL sp_nuevoEstado('Almacenado', 'El activo está guardado sin uso', 'A', @idEstado);

-- =====================================================
-- MARCAS
-- =====================================================
CALL sp_nuevaMarca('Dell', 'Marca de equipos informáticos', 'A', @idMarca);
CALL sp_nuevaMarca('Lenovo', 'Marca de equipos informáticos', 'A', @idMarca);
CALL sp_nuevaMarca('Logitech', 'Marca de periféricos', 'A', @idMarca);
CALL sp_nuevaMarca('HP', 'Marca de equipos informáticos', 'A', @idMarca);
CALL sp_nuevaMarca('Samsung', 'Marca de electrónica', 'A', @idMarca);
CALL sp_nuevaMarca('Kingston', 'Marca de memorias y almacenamiento', 'A', @idMarca);
CALL sp_nuevaMarca('Intel', 'Marca de procesadores', 'A', @idMarca);
CALL sp_nuevaMarca('AMD', 'Marca de procesadores', 'A', @idMarca);
CALL sp_nuevaMarca('Corsair', 'Marca de componentes de PC', 'A', @idMarca);
CALL sp_nuevaMarca('Western Digital', 'Marca de almacenamiento', 'A', @idMarca);
CALL sp_nuevaMarca('Seagate', 'Marca de almacenamiento', 'A', @idMarca);
CALL sp_nuevaMarca('Apple', 'Marca de equipos informáticos', 'A', @idMarca);
CALL sp_nuevaMarca('Motorola', 'Marca de celulares', 'A', @idMarca);
CALL sp_nuevaMarca('Xiaomi', 'Marca de celulares y electrónica', 'A', @idMarca);

-- =====================================================
-- TIPOS
-- =====================================================
CALL sp_nuevoTipo('Notebook', 'Computadora portátil', 'A', @idTipo);
CALL sp_nuevoTipo('Monitor', 'Pantalla de visualización', 'A', @idTipo);
CALL sp_nuevoTipo('Mouse', 'Periférico de entrada', 'A', @idTipo);
CALL sp_nuevoTipo('PC', 'Computadora de escritorio', 'A', @idTipo);
CALL sp_nuevoTipo('RAM', 'Memoria de acceso aleatorio', 'A', @idTipo);
CALL sp_nuevoTipo('CPU', 'Procesador', 'A', @idTipo);
CALL sp_nuevoTipo('Fuente', 'Fuente de alimentación', 'A', @idTipo);
CALL sp_nuevoTipo('Disco', 'Unidad de almacenamiento', 'A', @idTipo);
CALL sp_nuevoTipo('SIM', 'Tarjeta SIM', 'A', @idTipo);
CALL sp_nuevoTipo('Celular', 'Teléfono móvil', 'A', @idTipo);
-- ==========================================
-- FASE 2: Composicion de tipos
-- ==========================================

CALL sp_nuevaComposicionTipo('PC', 'CPU', 1);
CALL sp_nuevaComposicionTipo('PC', 'RAM', 2);
CALL sp_nuevaComposicionTipo('PC', 'Fuente', 1);
CALL sp_nuevaComposicionTipo('PC', 'Disco', 4);
CALL sp_nuevaComposicionTipo('Celular', 'SIM', 2);

USE GestionDeActivos;

-- ==========================================
-- FASE 3: ATRIBUTOS
-- (Cada CALL guarda su idAtributo en una variable propia,
--  porque después se necesita para armar el JSON con
--  formato idAtributo:"valor")
-- ==========================================

SET @idTipoNotebook = (SELECT idTipo FROM Tipos WHERE nombre = 'Notebook');
CALL sp_nuevoAtributo(@idTipoNotebook, 'RAM', NULL, TRUE, @idAtrNB_RAM);
CALL sp_nuevoAtributo(@idTipoNotebook, 'Almacenamiento', NULL, TRUE, @idAtrNB_Almacenamiento);

SET @idTipoMonitor = (SELECT idTipo FROM Tipos WHERE nombre = 'Monitor');
CALL sp_nuevoAtributo(@idTipoMonitor, 'Resolucion', '1920x1080', FALSE, @idAtrMON_Resolucion);
CALL sp_nuevoAtributo(@idTipoMonitor, 'Pulgadas', NULL, FALSE, @idAtrMON_Pulgadas);

SET @idTipoMouse = (SELECT idTipo FROM Tipos WHERE nombre = 'Mouse');
CALL sp_nuevoAtributo(@idTipoMouse, 'Conexion', 'USB', FALSE, @idAtrMOU_Conexion);

SET @idTipoPC = (SELECT idTipo FROM Tipos WHERE nombre = 'PC');
CALL sp_nuevoAtributo(@idTipoPC, 'SO', 'Windows 10', TRUE, @idAtrPC_SO);
CALL sp_nuevoAtributo(@idTipoPC, 'IP', NULL, FALSE, @idAtrPC_IP);

SET @idTipoRAM = (SELECT idTipo FROM Tipos WHERE nombre = 'RAM');
CALL sp_nuevoAtributo(@idTipoRAM, 'Tamaño', NULL, TRUE, @idAtrRAM_Tamano);
CALL sp_nuevoAtributo(@idTipoRAM, 'TipoMemoria', 'DDR4', FALSE, @idAtrRAM_TipoMemoria);

SET @idTipoCPU = (SELECT idTipo FROM Tipos WHERE nombre = 'CPU');
CALL sp_nuevoAtributo(@idTipoCPU, 'Modelo', NULL, TRUE, @idAtrCPU_Modelo);
CALL sp_nuevoAtributo(@idTipoCPU, 'Nucleos', NULL, FALSE, @idAtrCPU_Nucleos);

SET @idTipoFuente = (SELECT idTipo FROM Tipos WHERE nombre = 'Fuente');
CALL sp_nuevoAtributo(@idTipoFuente, 'Potencia', NULL, TRUE, @idAtrFUE_Potencia);
CALL sp_nuevoAtributo(@idTipoFuente, 'Certificacion', NULL, FALSE, @idAtrFUE_Certificacion);

SET @idTipoDisco = (SELECT idTipo FROM Tipos WHERE nombre = 'Disco');
CALL sp_nuevoAtributo(@idTipoDisco, 'Capacidad', NULL, TRUE, @idAtrDIS_Capacidad);
CALL sp_nuevoAtributo(@idTipoDisco, 'Tecnologia', 'SSD', FALSE, @idAtrDIS_Tecnologia);

SET @idTipoSIM = (SELECT idTipo FROM Tipos WHERE nombre = 'SIM');
CALL sp_nuevoAtributo(@idTipoSIM, 'Numero', NULL, TRUE, @idAtrSIM_Numero);
CALL sp_nuevoAtributo(@idTipoSIM, 'Operador', NULL, FALSE, @idAtrSIM_Operador);

SET @idTipoCelular = (SELECT idTipo FROM Tipos WHERE nombre = 'Celular');
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
CALL sp_nuevaUbicacion( @servidores, 'Rack1', 'rack con un servidor', 'A',@rack1);
CALL sp_nuevaUbicacion( @servidores, 'Rack2', 'rack con un nvr', 'A',@rack2);
-- ==========================================
-- FASE 5: PERSONAS
-- ==========================================

-- Personas que tendrán usuario

CALL sp_nuevaPersona(
    'Juan',
    'Pérez',
    '35123456',
    'Soporte IT',
    'A',
    @idJuan
);

CALL sp_nuevaPersona(
    'María',
    'Gómez',
    '32987654',
    'Gerente de Ventas',
    'A',
    @idMaria
);

-- Personas sin usuario

CALL sp_nuevaPersona(
    'Carlos',
    'Rodríguez',
    '30111222',
    'Técnico de Mantenimiento',
    'A',
    @idCarlos
);

CALL sp_nuevaPersona(
    'Ana',
    'López',
    '31222333',
    'Administración',
    'A',
    @idAna
);

CALL sp_nuevaPersona(
    'Diego',
    'Fernández',
    '33444555',
    'Soporte de Infraestructura',
    'A',
    @idDiego
);

-- ==========================================
-- FASE 6: USUARIOS
-- ==========================================

CALL sp_nuevoUsuario(
    @idJuan,
    'jperez',
    'contrasenia1',
    'ADMIN_IT',
    'A',
    @idUsuarioJuan
);

CALL sp_nuevoUsuario(
    @idMaria,
    'mgomez',
    'contrasenia2',
    'USUARIO_VENTAS',
    'A',
    @idUsuarioMaria
);

-- ==========================================
-- FASE 7: PROVEEDORES
-- ==========================================

CALL sp_nuevoProveedor(
    'TechStore Arg',
    'Av. Corrientes 1234',
    '11-4567-8900',
    'ventas@techstore.com',
    'Venta de computadoras y notebooks',
    @idProveedorTechStore
);

CALL sp_nuevoProveedor(
    'Hardware Tucumán',
    'Av. Mate de Luna 850',
    '381-4567890',
    'contacto@hardwaretuc.com',
    'Componentes y periféricos informáticos',
    @idProveedorHardware
);

CALL sp_nuevoProveedor(
    'CompuMarket',
    'San Martín 650',
    '381-4234567',
    'ventas@compumarket.com',
    'Equipamiento informático y accesorios',
    @idProveedorCompuMarket
);

CALL sp_nuevoProveedor(
    'ElectroTec',
    '24 de Septiembre 420',
    '381-4345678',
    'info@electrotec.com',
    'Fuentes, discos y componentes electrónicos',
    @idProveedorElectroTec
);

CALL sp_nuevoProveedor(
    'MovilTech',
    'Junín 780',
    '381-4456789',
    'ventas@moviltech.com',
    'Celulares, SIM y accesorios móviles',
    @idProveedorMovilTech
);

-- ==========================================
-- FASE 8: FACTURAS
-- ==========================================

-- Factura correspondiente a 5 PCs
CALL sp_nuevaFactura(
    @idProveedorTechStore,
    '2026-08-20 10:00:00',
    5000.00,
    'USD',
    'FC-A-0001-00000001',
    '/docs/facturas/fc-pcs-0001.pdf',
    'A',
    @idFacturaPC
);

-- Factura correspondiente a 5 celulares
CALL sp_nuevaFactura(
    @idProveedorMovilTech,
    '2026-08-20 11:00:00',
    1000.00,
    'USD',
    'FC-A-0001-00000002',
    '/docs/facturas/fc-celulares-0001.pdf',
     'A',
    @idFacturaCelulares
);
-- ==========================================
-- FASE 9: ACTIVOS
-- ==========================================

-- 5 PCs de la factura @idFacturaPC
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Dell', 'Oficina IT', 'PC', 'Operativo',
    @idFacturaPC, NULL, NULL, 'PC-IT-001',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 10', CAST(@idAtrPC_IP AS CHAR), '192.168.1.101'),
    1000.00, 'DELL-PC-001', 'OptiPlex 7090'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Lenovo', 'Oficina IT', 'PC', 'Operativo',
    @idFacturaPC, NULL, NULL, 'PC-IT-002',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 11', CAST(@idAtrPC_IP AS CHAR), '192.168.1.102'),
    1000.00, 'LEN-PC-002', 'ThinkCentre M70'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'HP', 'Oficina Ventas', 'PC', 'Operativo',
    @idFacturaPC, NULL, NULL, 'PC-VT-001',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 11', CAST(@idAtrPC_IP AS CHAR), '192.168.1.103'),
    1000.00, 'HP-PC-003', 'ProDesk 400'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Dell', 'Oficina Ventas', 'PC', 'Operativo',
    @idFacturaPC, NULL, NULL, 'PC-VT-002',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 10', CAST(@idAtrPC_IP AS CHAR), '192.168.1.104'),
    1000.00, 'DELL-PC-004', 'OptiPlex 3080'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Lenovo', 'Sede Central', 'PC', 'Operativo',
    @idFacturaPC, NULL, NULL, 'PC-SC-001',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Windows 11', CAST(@idAtrPC_IP AS CHAR), '192.168.1.105'),
    1000.00, 'LEN-PC-005', 'ThinkCentre M75'
);

-- 5 Celulares de la factura @idFacturaCelulares

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Samsung', 'Oficina Ventas', 'Celular', 'Operativo',
    @idFacturaCelulares, NULL, NULL, 'CEL-VT-001',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'Android', CAST(@idAtrCEL_Almacenamiento AS CHAR), '128GB'),
    200.00, 'SAM-CEL-001', 'Galaxy A55'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Motorola', 'Oficina Ventas', 'Celular', 'Operativo',
    @idFacturaCelulares, NULL, NULL, 'CEL-VT-002',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'Android', CAST(@idAtrCEL_Almacenamiento AS CHAR), '128GB'),
    200.00, 'MOT-CEL-002', 'Moto G84'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Xiaomi', 'Sede Central', 'Celular', 'Operativo',
    @idFacturaCelulares, NULL, NULL, 'CEL-SC-001',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'Android', CAST(@idAtrCEL_Almacenamiento AS CHAR), '256GB'),
    200.00, 'XIA-CEL-003', 'Redmi Note 13'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Samsung', 'Sede Central', 'Celular', 'Operativo',
    @idFacturaCelulares, NULL, NULL, 'CEL-SC-002',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'Android', CAST(@idAtrCEL_Almacenamiento AS CHAR), '128GB'),
    200.00, 'SAM-CEL-004', 'Galaxy A35'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Apple', 'Oficina IT', 'Celular', 'Operativo',
    @idFacturaCelulares, NULL, NULL, 'CEL-IT-001',
    JSON_OBJECT(CAST(@idAtrCEL_SO AS CHAR), 'iOS', CAST(@idAtrCEL_Almacenamiento AS CHAR), '128GB'),
    200.00, 'APP-CEL-005', 'iPhone 13'
);

-- 2 Notebooks sin factura

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Dell', 'Oficina IT', 'Notebook', 'Operativo',
    NULL, @idJuan, NULL, 'NB-IT-001',
    JSON_OBJECT(CAST(@idAtrNB_RAM AS CHAR), '16GB', CAST(@idAtrNB_Almacenamiento AS CHAR), '512GB SSD'),
    750.00, 'DELL-NB-001', 'Latitude 5420'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Lenovo', 'Oficina Ventas', 'Notebook', 'Operativo',
    NULL, @idMaria, NULL, 'NB-VT-001',
    JSON_OBJECT(CAST(@idAtrNB_RAM AS CHAR), '8GB', CAST(@idAtrNB_Almacenamiento AS CHAR), '256GB SSD'),
    750.00, 'LEN-NB-002', 'ThinkPad E14'
);

USE GestionDeActivos;

-- ==========================================
-- FASE 10: COMPONENTES DE PCs
-- ==========================================
CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Oficina IT','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-IT-001'),'RAM-PC001-01',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC001-01','ValueRAM');
CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Oficina IT','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-IT-001'),'RAM-PC001-02',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC001-02','ValueRAM');

CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Oficina IT','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-IT-002'),'RAM-PC002-01',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC002-01','ValueRAM');
CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Oficina IT','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-IT-002'),'RAM-PC002-02',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC002-02','ValueRAM');

CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Oficina Ventas','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-VT-001'),'RAM-PC003-01',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC003-01','ValueRAM');
CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Oficina Ventas','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-VT-001'),'RAM-PC003-02',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC003-02','ValueRAM');

CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Oficina Ventas','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-VT-002'),'RAM-PC004-01',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC004-01','ValueRAM');
CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Oficina Ventas','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-VT-002'),'RAM-PC004-02',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC004-02','ValueRAM');

CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Sede Central','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-SC-001'),'RAM-PC005-01',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC005-01','ValueRAM');
CALL sp_nuevoActivo(@idUsuarioJuan,'Kingston','Sede Central','RAM','Operativo',NULL,NULL,(SELECT idActivo FROM Activos WHERE nombre='PC-SC-001'),'RAM-PC005-02',JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR),'4GB'),50.00,'KIN-RAM-PC005-02','ValueRAM');

-- ==========================================
-- FASE 11: ACTIVOS PARA PRUEBA DE BUSCADOR
-- ==========================================

-- Recuperamos IDs necesarios por si se perdió la sesión de las variables
SET @idUsuarioJuan = (SELECT idUsuario FROM Usuarios WHERE username = 'jperez' LIMIT 1);
SET @idCarlos = (SELECT idPersona FROM Personas WHERE nombre = 'Carlos' AND apellido = 'Rodríguez' LIMIT 1);
SET @idAna = (SELECT idPersona FROM Personas WHERE nombre = 'Ana' AND apellido = 'López' LIMIT 1);
SET @idMaria = (SELECT idPersona FROM Personas WHERE nombre = 'María' AND apellido = 'Gómez' LIMIT 1);

-- 1. Un monitor 4K (Para probar búsqueda por JSON en "Resolucion")
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Samsung', 'Oficina IT', 'Monitor', 'Operativo', NULL, NULL, NULL,
    'MON-IT-4K',
    JSON_OBJECT(CAST(@idAtrMON_Resolucion AS CHAR), '3840x2160', CAST(@idAtrMON_Pulgadas AS CHAR), '27'),
    350.00, 'SAM-MON-4K-01', 'Odyssey G7'
);

-- 2. Un monitor estándar asignado a Ana
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Dell', 'Oficina Ventas', 'Monitor', 'Operativo', NULL, @idAna, NULL,
    'MON-VT-FHD',
    JSON_OBJECT(CAST(@idAtrMON_Resolucion AS CHAR), '1920x1080', CAST(@idAtrMON_Pulgadas AS CHAR), '24'),
    150.00, 'DEL-MON-FHD-01', 'P2419H'
);

-- 3. Una MacBook en reparación (Para probar búsqueda híbrida por estado o modelo)
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Apple', 'Sede Central', 'Notebook', 'En Reparación', NULL, @idMaria, NULL,
    'NB-SC-MAC',
    JSON_OBJECT(CAST(@idAtrNB_RAM AS CHAR), '16GB', CAST(@idAtrNB_Almacenamiento AS CHAR), '512GB SSD'),
    1500.00, 'APP-MAC-999', 'MacBook Pro M2'
);

-- 4. Una PC con Linux (Para probar búsqueda por JSON en "SO")
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Corsair', 'Oficina IT', 'PC', 'Almacenado', NULL, NULL, NULL,
    'PC-LINUX-01',
    JSON_OBJECT(CAST(@idAtrPC_SO AS CHAR), 'Ubuntu 22.04', CAST(@idAtrPC_IP AS CHAR), '10.0.0.5'),
    2000.00, 'COR-PC-UBUNTU', 'One i300'
);

-- 5. RAM de 32GB (Para buscar "32GB" en el JSON)
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Kingston', 'Deposito Central', 'RAM', 'Almacenado', NULL, NULL, NULL,
    'RAM-DEP-01',
    JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '32GB', CAST(@idAtrRAM_TipoMemoria AS CHAR), 'DDR5'),
    120.00, 'KIN-RAM-32', 'Fury Beast'
);

-- 6. RAM de 16GB
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Corsair', 'Deposito Central', 'RAM', 'Almacenado', NULL, NULL, NULL,
    'RAM-DEP-02',
    JSON_OBJECT(CAST(@idAtrRAM_Tamano AS CHAR), '16GB', CAST(@idAtrRAM_TipoMemoria AS CHAR), 'DDR4'),
    80.00, 'COR-RAM-16', 'Vengeance LPX'
);

-- 7. Notebook potente en Sucursal Norte (Para probar búsqueda por ubicación)
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'HP', 'Sucursal Norte', 'Notebook', 'Operativo', NULL, @idCarlos, NULL,
    'NB-SN-001',
    JSON_OBJECT(CAST(@idAtrNB_RAM AS CHAR), '32GB', CAST(@idAtrNB_Almacenamiento AS CHAR), '1TB NVMe'),
    1200.00, 'HP-NB-SN-01', 'EliteBook 840'
);

-- 8. Mouse inalámbrico
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Logitech', 'Sucursal Norte', 'Mouse', 'Operativo', NULL, @idCarlos, NULL,
    'MOU-SN-001',
    JSON_OBJECT(CAST(@idAtrMOU_Conexion AS CHAR), 'Inalambrico'),
    50.00, 'LOG-MOU-01', 'MX Master 3'
);

-- 9. Disco duro mecánico
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Western Digital', 'Deposito Central', 'Disco', 'Almacenado', NULL, NULL, NULL,
    'HDD-DEP-01',
    JSON_OBJECT(CAST(@idAtrDIS_Capacidad AS CHAR), '2TB', CAST(@idAtrDIS_Tecnologia AS CHAR), 'HDD'),
    60.00, 'WD-HDD-2TB', 'Blue'
);

-- 10. Disco sólido SSD
CALL sp_nuevoActivo(
    @idUsuarioJuan, 'Seagate', 'Deposito Central', 'Disco', 'Almacenado', NULL, NULL, NULL,
    'SSD-DEP-99',
    JSON_OBJECT(CAST(@idAtrDIS_Capacidad AS CHAR), '1TB', CAST(@idAtrDIS_Tecnologia AS CHAR), 'NVMe'),
    100.00, 'SEA-SSD-1TBq', 'FireCudaq'
);