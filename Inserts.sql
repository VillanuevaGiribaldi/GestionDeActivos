USE GestionDeActivos;

-- Tipos de activos
INSERT INTO Tipos (Nombre, AdmiteComponentes) VALUES ('PC', 1), ('RAM', 0), ('Procesador', 0), ('Impresora', 1), ('Camara', 0),('Tarjet SIM',0),('Celular',1);

Insert into ComposicionTipos (idTipoPadre, idTipoComponente) values (1,2,0),(1,3,0),(7,6,0);

-- Atributos para PC
INSERT INTO Atributos (Nombre, idTipo, Obligatorio, `Default`) VALUES ('SO', 1, 1, 'windows 10'), ('IP', 1, 0, ''), ('MAC', 1, 0, ''), ('Aplicaciones', 1, 0, '');

-- Atributos para RAM
INSERT INTO Atributos (Nombre, idTipo, Obligatorio, `Default`) VALUES ('Tamaño', 2, 1, '');

-- Atributos para Procesador
INSERT INTO Atributos (Nombre, idTipo, Obligatorio, `Default`) VALUES ('Procesador', 3, 1, '');

-- Atributos para Impresora
INSERT INTO Atributos (Nombre, idTipo, Obligatorio, `Default`) VALUES ('TipoToner', 4, 1, 'X86'), ('IP', 4, 0, ''), ('MAC', 4, 0, ''), ('Conexion', 4, 0, 'USB'), ('Duplex', 4, 0, 'No');

-- Atributos para Cámara
INSERT INTO Atributos (Nombre, idTipo, Obligatorio, `Default`) VALUES ('Resolucion', 5, 1, '1080p'), ('VisionNocturna', 5, 0, 'Sí'), ('TipoConexion', 5, 0, 'IP'), ('IP', 5, 0, ''), ('MAC', 5, 0, '');

select * from Atributos;
select * from Tipos;
USE GestionDeActivos;

INSERT INTO Activos
(Nombre, FechaCreación, idTipo, Atributos, Compone)
VALUES
-- PCs
('PC-Administracion-01', NOW(), 1, JSON_OBJECT('SO','Windows 11','IP','192.168.1.10','MAC','00:11:22:33:44:55','Aplicaciones','Office, Chrome'), NULL),
('PC-Desarrollo-01', NOW(), 1, JSON_OBJECT('SO','Ubuntu 24.04','IP','192.168.1.20','MAC','AA:BB:CC:DD:EE:FF','Aplicaciones','VS Code, Docker'), NULL),

-- RAM de la PC 1
('RAM Kingston 8GB', NOW(), 2, JSON_OBJECT('Tamaño','8 GB'), 1),
('RAM Kingston 8GB', NOW(), 2, JSON_OBJECT('Tamaño','8 GB'), 1),
('RAM Kingston 8GB', NOW(), 2, JSON_OBJECT('Tamaño','8 GB'), 1),
('RAM Kingston 8GB', NOW(), 2, JSON_OBJECT('Tamaño','8 GB'), 1),

-- RAM de la PC 2
('RAM Corsair 16GB', NOW(), 2, JSON_OBJECT('Tamaño','16 GB'), 2),
('RAM Corsair 16GB', NOW(), 2, JSON_OBJECT('Tamaño','16 GB'), 2),

-- Procesador de la PC 1
('Intel Core i5-10400', NOW(), 3, JSON_OBJECT('Procesador','Intel Core i5-10400'), 1),

-- Procesador de la PC 2
('AMD Ryzen 5 5600G', NOW(), 3, JSON_OBJECT('Procesador','AMD Ryzen 5 5600G'), 2),

-- Celulares
('CEL01',NOW(),7,null,null),
('CEL02',NOW(),7,null,null);
insert into Activos  (Nombre, FechaCreación, idTipo, Atributos, Compone)values 


-- Tarjetas SIM
('SIM1',now(),6,null,(select idActivo from Activos a where a.Nombre='CEL01')),
('SIM2',now(),6,null,(select idActivo from Activos a where a.Nombre='CEL02'));
select * from Activos;
select * from Activos a where a.Compone is null;
select * from Tipos a where a.AdmiteComponentes = true;
