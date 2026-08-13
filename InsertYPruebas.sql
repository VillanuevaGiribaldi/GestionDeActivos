USE `GestionDeActivos` ;

-- ==========================================
-- FASE 1: Marcas, Ubicaciones, Estados y Tipos
-- ==========================================
-- 1. Insertar Estados (Ciclo de vida del hardware)
INSERT INTO `Estados` (`nombre`, `descripcion`) VALUES 
('Operativo', 'El equipo funciona correctamente y está en uso o stock'),
('En Reparación', 'El equipo presenta fallas y está siendo revisado'),
('Baja', 'El equipo fue descartado o vendido');

-- 2. Insertar Marcas
INSERT INTO `Marcas` (`nombre`, `descripcion`, `estado`) VALUES 
('Dell', 'Equipos Dell empresariales', 'A'),
('Lenovo', 'Línea ThinkPad y servidores', 'A'),
('Logitech', 'Periféricos', 'A');

-- 3. Insertar Tipos de Activos
INSERT INTO `Tipos` (`nombre`, `descripcion`, `estado`) VALUES 
('Notebook', 'Computadora portátil', 'A'),
('Monitor', 'Pantalla externa', 'A'),
('Mouse', 'Mouse inalámbrico o cableado', 'A'),
('PC', 'Computadoras de escritorio', 'A'),
('RAM', 'Memoria RAM', 'A'),
('CPU', 'Procesador', 'A'),
('Fuente', 'Fuente de alimentación', 'A'),
('Disco', 'Disco de almacenamiento', 'A'),
('SIM', 'Tarjeta SIM', 'A');

-- Componer los tipos
call sp_componerTipos('PC','CPU',1);
call sp_componerTipos('PC','ram',2);
call sp_componerTipos('PC','Fuente',1);

-- 4. Insertar Ubicaciones (Probando la relación Padre-Hijo)
-- Primero creamos la Sede Principal (No tiene padre, idUbicacionPadre es NULL)
INSERT INTO `Ubicaciones` (`idUbicacionPadre`, `nombre`, `descripcion`, `estado`) VALUES 
(NULL, 'Sede Central', 'Edificio principal', 'A');

-- Ahora creamos oficinas dentro de la Sede Central (asumiendo que Sede Central tomó el ID 1)
INSERT INTO `Ubicaciones` (`idUbicacionPadre`, `nombre`, `descripcion`, `estado`) VALUES 
(1, 'Oficina IT', 'Área de sistemas y servidores', 'A'),
(1, 'Oficina Ventas', 'Piso 2 - Ventas', 'A');
INSERT INTO `Ubicaciones` (`idUbicacionPadre`, `nombre`, `descripcion`, `estado`) VALUES 
(3, 'Caja 1', 'Piso 2 - Ventas', 'A');
INSERT INTO `Ubicaciones` (`idUbicacionPadre`, `nombre`, `descripcion`, `estado`) VALUES 
(4, 'Cajon 1', 'Piso 2 - Ventas', 'A');

SELECT * FROM Ubicaciones;

-- ==========================================
-- FASE 2: Personas y Usuarios
-- ==========================================
-- Creamos dos empleados (Uno de IT y uno de Ventas)
INSERT INTO `Personas` (`nombre`, `apellido`, `dni`, `cargo`, `estado`) VALUES 
('Juan', 'Pérez', '35123456', 'Soporte IT', 'A'),
('María', 'Gómez', '32987654', 'Gerente de Ventas', 'A');

-- Le creamos un usuario con acceso al sistema al empleado de IT (Juan, asumiendo que tomó el ID 1)
INSERT INTO `Usuarios` (`idPersona`, `username`, `password`, `rol`, `estado`) VALUES 
(1, 'jperez', 'hash_simulado_123', 'ADMIN_IT', 'A');

-- ==========================================
-- FASE 3: Proveedores y Facturas
-- ==========================================
INSERT INTO `Proveedores` (`nombre`, `direccion`, `telefono`, `mail`, `descripcion`, estado) VALUES 
('TechStore Arg', 'Av. Corrientes 1234', '11-4567-8900', 'ventas@techstore.com', 'Proveedor principal de hardware','A');

-- Simulamos una factura de compra (Asumiendo que el proveedor tomó el ID 1)
INSERT INTO `Facturas` (`idProveedor`, `fecha`, `monto`, `moneda`, `numero`, `ruta`) VALUES 
(1, '2026-08-01 10:30:00', 1500000.00, 'ARS', 'FC-A-0001-00001234', '/docs/facturas/fc-1234.pdf');

-- ==========================================
-- FASE 4: ¡Creamos los Activos! (El núcleo del sistema)
-- ==========================================
-- Activo 1: Una Notebook Dell para Juan (IT)
INSERT INTO `Activos` (
  `idMarca`, `idUbicacion`, `idTipo`, `idEstado`, `idFactura`, `idPersona`, 
  `nombre`, `fechaRegistro`, `atributosExtra`, `precioUnitario`, `numeroSerie`, `modelo`
) VALUES (
  1, -- Dell (ID de Marca)
  2, -- Oficina IT (ID Ubicación)
  1, -- Notebook (ID Tipo)
  1, -- Operativo (ID Estado)
  1, -- ID de la Factura de arriba
  1, -- Asignada a Juan
  'NB-IT-001', NOW(), '{"ram": "16GB", "cpu": "i7", "almacenamiento": "512GB SSD"}', 750000.00, 'DELL-SN-999', 'Latitude 5420'
);

-- Activo 2: Una Notebook Lenovo para María (Ventas)
INSERT INTO `Activos` (
  `idMarca`, `idUbicacion`, `idTipo`, `idEstado`, `idFactura`, `idPersona`, 
  `nombre`, `fechaRegistro`, `atributosExtra`, `precioUnitario`, `numeroSerie`, `modelo`
) VALUES (
  2, -- Lenovo
  3, -- Oficina Ventas
  1, -- Notebook
  1, -- Operativo
  1, -- Misma factura
  2, -- Asignada a María
  'NB-VT-001', NOW(), '{"ram": "8GB", "cpu": "i5", "almacenamiento": "256GB SSD"}', 750000.00, 'LEN-SN-888', 'ThinkPad E14'
);

-- Activo 3: Una PC para maría
INSERT INTO `Activos` (
  `idMarca`, `idUbicacion`, `idTipo`, `idEstado`, `idFactura`, `idPersona`, 
  `nombre`, `fechaRegistro`, `atributosExtra`, `precioUnitario`, `numeroSerie`, `modelo`
) VALUES (
  2, -- Lenovo
  3, -- Oficina Ventas
  4, -- Notebook
  1, -- Operativo
  null, -- sin factura
  2, -- Asignada a María
  'PC-VT-001', NOW(), '{"ram": "8GB", "cpu": "i5", "almacenamiento": "256GB SSD"}', 750000.00, 'LEN-PC-888', 'ThinkPad E14'
);


-- ===============================================================
-- 							CONSULTAS
-- ===============================================================

-- Consulta 1: El inventario completo y legible para un humano
select * from Tipos;
SELECT 
    a.nombre AS 'Nombre Equipo',
    a.numeroSerie AS 'Nro Serie',
    t.nombre AS 'Tipo',
    m.nombre AS 'Marca',
    a.modelo AS 'Modelo',
    e.nombre AS 'Estado',
    CONCAT(p.nombre, ' ', p.apellido) AS 'Asignado a',
    u.nombre AS 'Ubicación'
FROM Activos a
INNER JOIN Tipos t ON a.idTipo = t.idTipo
INNER JOIN Marcas m ON a.idMarca = m.idMarca
INNER JOIN Estados e ON a.idEstado = e.idEstado
LEFT JOIN Personas p ON a.idPersona = p.idPersona
INNER JOIN Ubicaciones u ON a.idUbicacion = u.idUbicacion;

-- Consulta 2: Buscando dentro del JSON
SELECT 
    nombre, 
    numeroSerie,
    JSON_UNQUOTE(JSON_EXTRACT(atributosExtra, '$.cpu')) AS Procesador,
    JSON_UNQUOTE(JSON_EXTRACT(atributosExtra, '$.ram')) AS Memoria_RAM
FROM Activos
WHERE JSON_EXTRACT(atributosExtra, '$.cpu') LIKE '%i7%';

-- Consulta 3: Reporte financiero de compras
SELECT 
    f.numero AS 'Nro Factura',
    prov.nombre AS 'Proveedor',
    a.nombre AS 'Equipo Comprado',
    a.precioUnitario AS 'Costo Individual',
    f.monto AS 'Monto Total Factura',
    f.moneda AS 'Moneda'
FROM Facturas f
INNER JOIN Proveedores prov ON f.idProveedor = prov.idProveedor
INNER JOIN Activos a ON f.idFactura = f.idFactura;


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
