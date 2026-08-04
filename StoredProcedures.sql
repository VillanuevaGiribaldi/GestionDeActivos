
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

