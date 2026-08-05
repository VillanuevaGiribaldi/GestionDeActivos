
DROP PROCEDURE IF EXISTS sp_componerTipos;
DELIMITER //

CREATE procedure sp_componerTipos(
	IN NombreTipoPadre VARCHAR(45),
    IN NombreTipoComponente VARCHAR(45),
    IN Obligatorio BOOLEAN    
)
SALIR:BEGIN
	DECLARE vIdTipoPadre INT;
	DECLARE vIdTipoComponente INT;
    
	SELECT idTipo
	INTO vIdTipoPadre
	FROM Tipos
	WHERE nombre = NombreTipoPadre;
    
    IF vIdTipoPadre IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo padre no existe';
	END IF;


	SELECT idTipo
	INTO vIdTipoComponente
	FROM Tipos
	WHERE nombre = NombreTipoComponente;
    
    IF vIdTipoComponente IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo componente no existe';
	END IF;

	IF vIdTipoPadre = vIdTipoComponente THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un tipo de activo no puede componerse a si mismo';
        LEAVE SALIR;
    end if;
    
    IF (select idTipoPadre from ComposicionTipos ct where ct.idTipoComponente=vIdTipoComponente) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo ya es componente';
        LEAVE SALIR;
    end if;
    
    IF (select idTipoComponente from ComposicionTipos ct where ct.idTipoComponente=vIdTipoPadre) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un tipo no puede ser componenete de sus componentes';
        LEAVE SALIR;
    end if;
    
    insert into ComposicionTipos(idTipoPadre,idTipoComponente,Obligatorio) values (vIdTipoPadre,vIdTipoComponente,COALESCE(Obligatorio,false));

END//

DELIMITER ;



DROP PROCEDURE IF EXISTS sp_nuevoActivo;
DELIMITER //

CREATE procedure sp_nuevoActivo(
	IN pNombreMarca VARCHAR(45),
    IN pNombreUbicacion VARCHAR(45),
    IN pNombreTipo VARCHAR(45),
    IN pNombreEstado VARCHAR(45),
    IN pidFactura INT,
    IN pidPersona INT,
    IN pidCompone INT,
    IN pNombre VARCHAR(45),
    IN pAtributosExtra JSON,
    IN pPrecioUnitario DECIMAL(12,2),
    IN pNumeroSerie VARCHAR(100),
    IN pModelo VARCHAR(50)
)
SALIR:BEGIN
	-- Actualmente no se realiza ninguna verificación del JSON pAtributosExtra
    DECLARE vIdMarca INT;
	DECLARE vIdUbicacion INT;
	DECLARE vIdTipo INT;
	DECLARE vIdEstado INT;

	SELECT idMarca INTO vIdMarca FROM Marcas WHERE nombre LIKE pNombreMarca;
	SELECT idUbicacion INTO vIdUbicacion FROM Ubicaciones WHERE nombre LIKE pNombreUbicacion;
	SELECT idTipo INTO vIdTipo FROM Tipos WHERE nombre LIKE pNombreTipo;
	SELECT idEstado INTO vIdEstado FROM Estados WHERE nombre LIKE pNombreEstado;


	IF vIdMarca IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La marca no existe';
	END IF;

	IF vIdUbicacion IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La ubicacion no existe';
	END IF;

	IF vIdTipo IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo no existe';
	END IF;

	IF vIdEstado IS NULL THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El estado no existe';
	END IF;

	IF pNombre IS NULL OR TRIM(pNombre) = '' THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre del activo es obligatorio';
	END IF;

	IF pidPersona IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Personas
		WHERE idPersona = pidPersona
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La persona no existe';
	END IF;

	IF pidFactura IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Facturas
		WHERE idFactura = pidFactura
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'La factura no existe';
	END IF;

	IF pidCompone IS NOT NULL AND NOT EXISTS (
		SELECT 1
		FROM Activos
		WHERE idActivo = pidCompone
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El activo padre no existe';
	END IF;
    
    IF pidCompone IS NOT NULL AND NOT EXISTS (
		SELECT 1
        FROM Activos a 
        inner join ComposicionTipos ct on a.idTipo=ct.idTipoPadre
		where a.idActivo = pidCompone and ct.idTipoComponente = vIdTipo
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El tipo del activo a crear no se corresponde con un componente valido del activo que se indicó';
	END IF;
    INSERT INTO Activos(
  `idMarca`, `idUbicacion`, `idTipo`, `idEstado`, `idFactura`, `idPersona`, `compone`,
  `nombre`, `fechaRegistro`, `atributosExtra`, `precioUnitario`, `numeroSerie`, `modelo`
)Values(
	vIdMarca, vIdUbicacion, vIdTipo, vIdEstado, pidFactura, pidPersona, pidCompone,
    pNombre,NOW(), pAtributosExtra, pPrecioUnitario, pNumeroSerie, pModelo
);

END//

DELIMITER ;


