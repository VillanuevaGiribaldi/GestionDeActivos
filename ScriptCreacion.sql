-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema GestionDeActivos
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema GestionDeActivos
-- -----------------------------------------------------
DROP SCHEMA if EXISTS GestionDeActivos;
CREATE SCHEMA IF NOT EXISTS `GestionDeActivos` DEFAULT CHARACTER SET utf8 ;
USE `GestionDeActivos` ;

-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Ubicaciones`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Ubicaciones` (
  `idUbicacion` INT NOT NULL AUTO_INCREMENT,
  `idUbicacionPadre` INT NULL,
  `nombre` VARCHAR(45) NOT NULL,
  `descripcion` VARCHAR(100) NULL,
  `estado` CHAR(1) NOT NULL,
  PRIMARY KEY (`idUbicacion`),
  INDEX `fk_Ubicaciones_Ubicaciones1_idx` (`idUbicacionPadre` ASC) VISIBLE,
  UNIQUE INDEX `nombre_UNIQUE` (`nombre` ASC) VISIBLE,
  CONSTRAINT `fk_Ubicaciones_Ubicaciones1`
    FOREIGN KEY (`idUbicacionPadre`)
    REFERENCES `GestionDeActivos`.`Ubicaciones` (`idUbicacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Marcas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Marcas` (
  `idMarca` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `estado` CHAR(1) NOT NULL,
  `descripcion` VARCHAR(45) NULL,
  PRIMARY KEY (`idMarca`),
  UNIQUE INDEX `nombre_UNIQUE` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Estados`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Estados` (
  `idEstado` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `descripcion` VARCHAR(200) NULL,
  PRIMARY KEY (`idEstado`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Personas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Personas` (
  `idPersona` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `apellido` VARCHAR(45) NOT NULL,
  `dni` VARCHAR(45) NULL,
  `cargo` VARCHAR(100) NOT NULL,
  `estado` CHAR(1) NOT NULL,
  PRIMARY KEY (`idPersona`),
  UNIQUE INDEX `dni_UNIQUE` (`dni` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Tipos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Tipos` (
  `idTipo` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(45) NOT NULL,
  `estado` CHAR(1) NOT NULL,
  `descripcion` VARCHAR(100) NULL,
  PRIMARY KEY (`idTipo`),
  UNIQUE INDEX `Nombre_UNIQUE` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Proveedores`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Proveedores` (
  `idProveedor` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `estado` CHAR(1) NOT NULL DEFAULT('A'),
  `direccion` VARCHAR(100) NULL,
  `telefono` VARCHAR(45) NULL,
  `mail` VARCHAR(150) NULL,
  `descripcion` VARCHAR(200) NULL,
  PRIMARY KEY (`idProveedor`),
  UNIQUE INDEX `nombre_UNIQUE` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Facturas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Facturas` (
  `idFactura` INT NOT NULL AUTO_INCREMENT,
  `idProveedor` INT NULL,
  `fecha` DATETIME NOT NULL,
  `monto` DECIMAL(12,2) NOT NULL,
  `moneda` VARCHAR(3) NOT NULL,
  `numero` VARCHAR(45) NOT NULL,
  `ruta` VARCHAR(255) NOT NULL,
  `estado` CHAR(1) NOT NULL,
  PRIMARY KEY (`idFactura`),
  INDEX `fk_Facturas_Proveedores1_idx` (`idProveedor` ASC) VISIBLE,
  CONSTRAINT `fk_Facturas_Proveedores1`
    FOREIGN KEY (`idProveedor`)
    REFERENCES `GestionDeActivos`.`Proveedores` (`idProveedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Activos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Activos` (
  `idActivo` INT NOT NULL AUTO_INCREMENT,
  `idMarca` INT NOT NULL,
  `idUbicacion` INT NOT NULL,
  `idTipo` INT NOT NULL,
  `idEstado` INT NOT NULL,
  `idFactura` INT NULL,
  `idPersona` INT NULL,
  `compone` INT NULL,
  `nombre` VARCHAR(45) NULL,
  `fechaRegistro` DATETIME NULL,
  `atributosExtra` JSON NULL,
  `precioUnitario` DECIMAL(12,2) NULL,
  `numeroSerie` VARCHAR(100) NULL,
  `modelo` VARCHAR(50) NULL,
  PRIMARY KEY (`idActivo`),
  INDEX `fk_Activos_Activos1_idx` (`compone` ASC) VISIBLE,
  INDEX `fk_Activos_Ubicaciones1_idx` (`idUbicacion` ASC) VISIBLE,
  INDEX `fk_Activos_Marcas1_idx` (`idMarca` ASC) VISIBLE,
  INDEX `fk_Activos_Estado1_idx` (`idEstado` ASC) VISIBLE,
  INDEX `fk_Activos_Personas1_idx` (`idPersona` ASC) VISIBLE,
  INDEX `fk_Activos_Tipos1_idx` (`idTipo` ASC) VISIBLE,
  INDEX `fk_Activos_Facturas1_idx` (`idFactura` ASC) VISIBLE,
  UNIQUE INDEX `numeroSerie_UNIQUE` (`numeroSerie` ASC) VISIBLE,
  CONSTRAINT `fk_Activos_Activos1`
    FOREIGN KEY (`compone`)
    REFERENCES `GestionDeActivos`.`Activos` (`idActivo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Activos_Ubicaciones1`
    FOREIGN KEY (`idUbicacion`)
    REFERENCES `GestionDeActivos`.`Ubicaciones` (`idUbicacion`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Activos_Marcas1`
    FOREIGN KEY (`idMarca`)
    REFERENCES `GestionDeActivos`.`Marcas` (`idMarca`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Activos_Estado1`
    FOREIGN KEY (`idEstado`)
    REFERENCES `GestionDeActivos`.`Estados` (`idEstado`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Activos_Personas1`
    FOREIGN KEY (`idPersona`)
    REFERENCES `GestionDeActivos`.`Personas` (`idPersona`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Activos_Tipos1`
    FOREIGN KEY (`idTipo`)
    REFERENCES `GestionDeActivos`.`Tipos` (`idTipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Activos_Facturas1`
    FOREIGN KEY (`idFactura`)
    REFERENCES `GestionDeActivos`.`Facturas` (`idFactura`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Atributos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Atributos` (
  `idAtributo` INT NOT NULL AUTO_INCREMENT,
  `idTipo` INT NOT NULL,
  `porDefecto` VARCHAR(100) NULL,
  `nombre` VARCHAR(45) NULL,
  `obligatorio` BOOL NULL,
  PRIMARY KEY (`idAtributo`),
  UNIQUE INDEX `UX_tipoNombre` (`idTipo` ASC, `nombre` ASC) VISIBLE,
  CONSTRAINT `fk_Atributos_Tipos1`
    FOREIGN KEY (`idTipo`)
    REFERENCES `GestionDeActivos`.`Tipos` (`idTipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`ComposicionTipos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`ComposicionTipos` (
  `idTipoPadre` INT NOT NULL,
  `idTipoComponente` INT NOT NULL,
  `cantidadComponentesMaxima` INT NULL,
  PRIMARY KEY (`idTipoPadre`, `idTipoComponente`),
  INDEX `fk_ComposicionTipos_Tipos1_idx` (`idTipoPadre` ASC) VISIBLE,
  INDEX `fk_ComposicionTipos_Tipos2_idx` (`idTipoComponente` ASC) VISIBLE,
  CONSTRAINT `fk_ComposicionTipos_Tipos1`
    FOREIGN KEY (`idTipoPadre`)
    REFERENCES `GestionDeActivos`.`Tipos` (`idTipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ComposicionTipos_Tipos2`
    FOREIGN KEY (`idTipoComponente`)
    REFERENCES `GestionDeActivos`.`Tipos` (`idTipo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Usuarios`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Usuarios` (
  `idUsuario` INT NOT NULL AUTO_INCREMENT,
  `idPersona` INT NOT NULL,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `rol` VARCHAR(45) NOT NULL,
  `estado` CHAR(1) NOT NULL,
  PRIMARY KEY (`idUsuario`),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC) VISIBLE,
  INDEX `fk_Usuarios_Personas1_idx` (`idPersona` ASC) VISIBLE,
  CONSTRAINT `fk_Usuarios_Personas1`
    FOREIGN KEY (`idPersona`)
    REFERENCES `GestionDeActivos`.`Personas` (`idPersona`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Historial`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Historial` (
  `idHistorial` INT NOT NULL AUTO_INCREMENT,
  `idUsuario` INT NOT NULL,
  `idActivo` INT NOT NULL,
  `fecha` DATETIME NOT NULL,
  `comentario` VARCHAR(200) NULL,
  `tipo` CHAR(1) NULL,
  `estadoAnterior` JSON NULL,
  `estadoNuevo` JSON NULL,
  PRIMARY KEY (`idHistorial`),
  INDEX `fk_Historial_Usuarios1_idx` (`idUsuario` ASC) VISIBLE,
  INDEX `fk_Historial_Activos1_idx` (`idActivo` ASC) VISIBLE,
  CONSTRAINT `fk_Historial_Usuarios1`
    FOREIGN KEY (`idUsuario`)
    REFERENCES `GestionDeActivos`.`Usuarios` (`idUsuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Historial_Activos1`
    FOREIGN KEY (`idActivo`)
    REFERENCES `GestionDeActivos`.`Activos` (`idActivo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Imagenes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Imagenes` (
  `idImagen` INT NOT NULL AUTO_INCREMENT,
  `idActivo` INT NOT NULL,
  `ruta` VARCHAR(255) NOT NULL,
  `estado` CHAR(1) NOT NULL,
  `fecha` DATETIME NULL,
  `descripcion` VARCHAR(100) NULL,
  PRIMARY KEY (`idImagen`),
  INDEX `fk_Imagenes_Activos1_idx` (`idActivo` ASC) VISIBLE,
  CONSTRAINT `fk_Imagenes_Activos1`
    FOREIGN KEY (`idActivo`)
    REFERENCES `GestionDeActivos`.`Activos` (`idActivo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `GestionDeActivos`.`Mantenimientos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `GestionDeActivos`.`Mantenimientos` (
  `idMantenimiento` INT NOT NULL AUTO_INCREMENT,
  `idActivo` INT NOT NULL,
  `idProveedor` INT NOT NULL,
  `fallaReportada` VARCHAR(200) NULL,
  `reparacionRealizada` VARCHAR(200) NULL,
  `fechaEnvio` DATE NULL,
  `fechaDevolucion` DATE NULL,
  `costoTotal` DECIMAL(12,2) NULL,
  PRIMARY KEY (`idMantenimiento`),
  INDEX `fk_Mantenimientos_Activos1_idx` (`idActivo` ASC) VISIBLE,
  INDEX `fk_Mantenimientos_Proveedores1_idx` (`idProveedor` ASC) VISIBLE,
  CONSTRAINT `fk_Mantenimientos_Activos1`
    FOREIGN KEY (`idActivo`)
    REFERENCES `GestionDeActivos`.`Activos` (`idActivo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Mantenimientos_Proveedores1`
    FOREIGN KEY (`idProveedor`)
    REFERENCES `GestionDeActivos`.`Proveedores` (`idProveedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
