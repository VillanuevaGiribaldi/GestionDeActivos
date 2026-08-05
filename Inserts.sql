USE GestionDeActivos;
INSERT INTO Tipos (nombre, estado, descripcion) 
VALUES ('PC', 'A', 'Computadora de escritorio'), ('Celular', 'A', 'Telefono movil'), ('Monitor', 'A', 'Monitor de computadora'), ('Teclado', 'A', 'Teclado'), ('Mouse', 'A', 'Mouse'), ('Camara', 'A', 'Camara de seguridad'), ('Impresora', 'A', 'Impresora'), ('RAM', 'A', 'Memoria RAM'), ('CPU', 'A', 'Procesador'), ('Fuente', 'A', 'Fuente de alimentacion'), ('Disco', 'A', 'Disco de almacenamiento'), ('SIM', 'A', 'Tarjeta SIM'), ('Micro SD', 'A', 'Tarjeta de memoria');

INSERT INTO ComposicionTipos (idTipoPadre, idTipoComponente, Obligatorio) 
VALUES (1, 8, 1), (1, 9, 1), (1, 10, 1), (1, 11, 1), (2, 12, 1), (2, 13, 0);

INSERT INTO Atributos (idTipo, porDefecto, nombre, obligatorio) 
VALUES (1, 'Windows 11', 'Sistema Operativo', 1), (1, NULL, 'Direccion IP', 0), (2, 'Android', 'Sistema Operativo', 1), (2, NULL, 'IMEI', 1), (3, '24', 'Pulgadas', 1), (3, '1920x1080', 'Resolucion', 1), (4, 'ES', 'Distribucion', 1), (5, 'Optico', 'Tipo Sensor', 1), (6, '1080p', 'Resolucion', 1), (6, 'Exterior', 'Ubicacion de uso', 0), (7, 'Laser', 'Tecnologia', 1), (7, 'Monocromatica', 'Color', 1), (8, '8 GB', 'Capacidad', 1), (8, 'DDR4', 'Tipo', 1), (9, NULL, 'Modelo', 1), (9, NULL, 'Frecuencia', 1), (10, '500 W', 'Potencia', 1), (11, 'SSD', 'Tecnologia', 1), (11, '512 GB', 'Capacidad', 1), (12, NULL, 'Numero', 1), (12, 'Claro', 'Operadora', 1), (13, '64 GB', 'Capacidad', 1);

INSERT INTO Marcas (nombre, descripcion, estado) 
VALUES ('Dell', 'PC y monitores', 'A'), ('HP', 'PC, impresoras y monitores', 'A'), ('Lenovo', 'PC y monitores', 'A'), ('Samsung', 'Celulares, monitores y micro SD', 'A'), ('Motorola', 'Celulares', 'A'), ('Logitech', 'Teclados y mouse', 'A'), ('Genius', 'Perifericos', 'A'), ('Hikvision', 'Camaras de seguridad', 'A'), ('Kingston', 'RAM y almacenamiento', 'A'), ('Intel', 'Procesadores', 'A'), ('AMD', 'Procesadores', 'A'), ('Corsair', 'RAM y fuentes de alimentacion', 'A'), ('Seagate', 'Discos de almacenamiento', 'A'), ('Western Digital', 'Discos de almacenamiento', 'A'), ('SanDisk', 'Micro SD y almacenamiento', 'A');

select * from Atributos;
select * from Tipos;
select * from Marcas;

INSERT INTO Personas (nombre, apellido, dni, cargo, estado) 
VALUES ('Juan', 'Perez', '30111222', 'Administrador de Sistemas', 'A'), ('Maria', 'Gomez', '28444555', 'Soporte Tecnico', 'A'), ('Carlos', 'Lopez', '32999888', 'Contador', 'A'), ('Ana', 'Rodriguez', '35666777', 'Gerente', 'A'), ('Lucas', 'Fernandez', '38999111', 'Vendedor', 'A'), ('Sofia', 'Martinez', '41222333', 'Recepcionista', 'A');

INSERT INTO Usuarios (idPersona, username, password, rol, estado) 
VALUES (1, 'jperez', '$2a$10$admin123', 'Administrador', 'A'), (2, 'mgomez', '$2a$10$tecnico123', 'Tecnico', 'A');

select * from Usuarios;
select * from Personas;

INSERT INTO Ubicaciones (idUbicacionPadre, nombre, descripcion, estado) 
VALUES (NULL, 'Sucursal Centro', 'Casa central', 'A'), (NULL, 'Sucursal Norte', 'Sucursal zona norte', 'A');

INSERT INTO Ubicaciones (idUbicacionPadre, nombre, descripcion, estado) 
VALUES (1, 'Caja 1', 'Caja de atencion 1', 'A'), (1, 'Caja 2', 'Caja de atencion 2', 'A'), (1, 'Oficina', 'Oficina administrativa', 'A'), (2, 'Caja 1', 'Caja de atencion 1', 'A'), (2, 'Caja 2', 'Caja de atencion 2', 'A'), (2, 'Oficina', 'Oficina administrativa', 'A');



select * from Ubicaciones;

INSERT INTO Estados (nombre, descripcion) 
VALUES ('Activo', 'El activo se encuentra operativo y en uso'), ('Roto', 'El activo presenta una falla y requiere reparacion'), ('Baja', 'El activo fue retirado definitivamente del inventario'), ('Obsoleto', 'El activo funciona, pero quedo desactualizado o fue reemplazado');

