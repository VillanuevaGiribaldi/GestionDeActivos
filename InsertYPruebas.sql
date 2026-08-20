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
-- ==========================================

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'Notebook');
CALL sp_nuevoAtributo(@idTipo, 'RAM', NULL, TRUE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'Almacenamiento', NULL, TRUE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'Monitor');
CALL sp_nuevoAtributo(@idTipo, 'Resolucion', '1920x1080', FALSE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'Pulgadas', NULL, FALSE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'Mouse');
CALL sp_nuevoAtributo(@idTipo, 'Conexion', 'USB', FALSE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'PC');
CALL sp_nuevoAtributo(@idTipo, 'SO', 'Windows 10', TRUE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'IP', NULL, FALSE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'RAM');
CALL sp_nuevoAtributo(@idTipo, 'Tamaño', NULL, TRUE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'TipoMemoria', 'DDR4', FALSE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'CPU');
CALL sp_nuevoAtributo(@idTipo, 'Modelo', NULL, TRUE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'Nucleos', NULL, FALSE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'Fuente');
CALL sp_nuevoAtributo(@idTipo, 'Potencia', NULL, TRUE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'Certificacion', NULL, FALSE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'Disco');
CALL sp_nuevoAtributo(@idTipo, 'Capacidad', NULL, TRUE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'Tecnologia', 'SSD', FALSE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'SIM');
CALL sp_nuevoAtributo(@idTipo, 'Numero', NULL, TRUE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'Operador', NULL, FALSE, @idAtributo);

SET @idTipo = (SELECT idTipo FROM Tipos WHERE nombre = 'Celular');
CALL sp_nuevoAtributo(@idTipo, 'SistemaOperativo', 'Android', TRUE, @idAtributo);
CALL sp_nuevoAtributo(@idTipo, 'Almacenamiento', NULL, FALSE, @idAtributo);

-- ==========================================
-- FASE 4: UBICACIONES
-- ==========================================

-- Ubicación principal 1
CALL sp_nuevaUbicacion(
    NULL,
    'Sede Central',
    'Edificio principal',
    'A',
    @idSedeCentral
);

-- Subdivisión 1
CALL sp_nuevaUbicacion(
    @idSedeCentral,
    'Oficina IT',
    'Área de sistemas y servidores',
    'A',
    @idOficinaIT
);

-- Subdivisión 2
CALL sp_nuevaUbicacion(
    @idSedeCentral,
    'Oficina Ventas',
    'Área de ventas',
    'A',
    @idOficinaVentas
);

-- Ubicación principal 2
CALL sp_nuevaUbicacion(
    NULL,
    'Sucursal Norte',
    'Sucursal de atención al público',
    'A',
    @idSucursalNorte
);

-- Ubicación principal 3
CALL sp_nuevaUbicacion(
    NULL,
    'Deposito Central',
    'Depósito general de equipos',
    'A',
    @idDepositoCentral
);

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
    @idUsuarioJuan,
    'Dell',
    'Oficina IT',
    'PC',
    'Operativo',
    @idFacturaPC,
    NULL,
    NULL,
    'PC-IT-001',
    '{"SO": "Windows 10", "IP": "192.168.1.101"}',
    1000.00,
    'DELL-PC-001',
    'OptiPlex 7090'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Lenovo',
    'Oficina IT',
    'PC',
    'Operativo',
    @idFacturaPC,
    NULL,
    NULL,
    'PC-IT-002',
    '{"SO": "Windows 11", "IP": "192.168.1.102"}',
    1000.00,
    'LEN-PC-002',
    'ThinkCentre M70'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'HP',
    'Oficina Ventas',
    'PC',
    'Operativo',
    @idFacturaPC,
    NULL,
    NULL,
    'PC-VT-001',
    '{"SO": "Windows 11", "IP": "192.168.1.103"}',
    1000.00,
    'HP-PC-003',
    'ProDesk 400'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Dell',
    'Oficina Ventas',
    'PC',
    'Operativo',
    @idFacturaPC,
    NULL,
    NULL,
    'PC-VT-002',
    '{"SO": "Windows 10", "IP": "192.168.1.104"}',
    1000.00,
    'DELL-PC-004',
    'OptiPlex 3080'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Lenovo',
    'Sede Central',
    'PC',
    'Operativo',
    @idFacturaPC,
    NULL,
    NULL,
    'PC-SC-001',
    '{"SO": "Windows 11", "IP": "192.168.1.105"}',
    1000.00,
    'LEN-PC-005',
    'ThinkCentre M75'
);

-- 5 Celulares de la factura @idFacturaCelulares

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Samsung',
    'Oficina Ventas',
    'Celular',
    'Operativo',
    @idFacturaCelulares,
    NULL,
    NULL,
    'CEL-VT-001',
    '{"SistemaOperativo": "Android", "Almacenamiento": "128GB"}',
    200.00,
    'SAM-CEL-001',
    'Galaxy A55'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Motorola',
    'Oficina Ventas',
    'Celular',
    'Operativo',
    @idFacturaCelulares,
    NULL,
    NULL,
    'CEL-VT-002',
    '{"SistemaOperativo": "Android", "Almacenamiento": "128GB"}',
    200.00,
    'MOT-CEL-002',
    'Moto G84'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Xiaomi',
    'Sede Central',
    'Celular',
    'Operativo',
    @idFacturaCelulares,
    NULL,
    NULL,
    'CEL-SC-001',
    '{"SistemaOperativo": "Android", "Almacenamiento": "256GB"}',
    200.00,
    'XIA-CEL-003',
    'Redmi Note 13'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Samsung',
    'Sede Central',
    'Celular',
    'Operativo',
    @idFacturaCelulares,
    NULL,
    NULL,
    'CEL-SC-002',
    '{"SistemaOperativo": "Android", "Almacenamiento": "128GB"}',
    200.00,
    'SAM-CEL-004',
    'Galaxy A35'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Apple',
    'Oficina IT',
    'Celular',
    'Operativo',
    @idFacturaCelulares,
    NULL,
    NULL,
    'CEL-IT-001',
    '{"SistemaOperativo": "iOS", "Almacenamiento": "128GB"}',
    200.00,
    'APP-CEL-005',
    'iPhone 13'
);

-- 2 Notebooks sin factura

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Dell',
    'Oficina IT',
    'Notebook',
    'Operativo',
    NULL,
    @idJuan,
    NULL,
    'NB-IT-001',
    '{"RAM": "16GB", "Almacenamiento": "512GB SSD"}',
    750.00,
    'DELL-NB-001',
    'Latitude 5420'
);

CALL sp_nuevoActivo(
    @idUsuarioJuan,
    'Lenovo',
    'Oficina Ventas',
    'Notebook',
    'Operativo',
    NULL,
    @idMaria,
    NULL,
    'NB-VT-001',
    '{"RAM": "8GB", "Almacenamiento": "256GB SSD"}',
    750.00,
    'LEN-NB-002',
    'ThinkPad E14'
);

