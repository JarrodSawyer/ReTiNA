SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `mydb`;

-- -----------------------------------------------------
-- Table `mydb`.`stats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`stats` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`stats` (
  `idstats` INT NOT NULL AUTO_INCREMENT ,
  `RtB` VARCHAR(45) NULL ,
  `BtR` VARCHAR(45) NULL ,
  `White` VARCHAR(45) NULL ,
  PRIMARY KEY (`idstats`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`attacks`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`attacks` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`attacks` (
  `idattacks` INT NOT NULL AUTO_INCREMENT ,
  `source` VARCHAR(45) NULL ,
  `source_team` VARCHAR(45) NULL ,
  `destination` VARCHAR(45) NULL ,
  `type` VARCHAR(45) NULL ,
  `time` VARCHAR(45) NULL ,
  PRIMARY KEY (`idattacks`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`nodestats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`nodestats` ;

CREATE  TABLE IF NOT EXISTS `mydb`.`nodestats` (
  `idnodestats` INT NOT NULL AUTO_INCREMENT ,
  `address` VARCHAR(45) NULL ,
  `team` VARCHAR(45) NULL ,
  `os` VARCHAR(45) NULL ,
  `services` VARCHAR(90) NULL ,
  PRIMARY KEY (`idnodestats`) )
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
