SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `ReTiNAdb` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `ReTiNAdb`;

-- -----------------------------------------------------
-- Table `ReTiNAdb`.`traffic_stats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ReTiNAdb`.`traffic_stats` ;

CREATE TABLE IF NOT EXISTS `traffic_stats` (
  `id` int(11) NOT NULL auto_increment,
  `traffic_timestamp` int(11) default '0',
  `team_name` varchar(45) default NULL,
  `incoming` bigint(11) default '0',
  `outgoing` bigint(11) default '0',
  `total_traffic` bigint(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;


-- -----------------------------------------------------
-- Table `ReTiNAdb`.`attacks`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ReTiNAdb`.`attacks` ;

CREATE TABLE IF NOT EXISTS `attacks` (
  `idattacks` int(11) NOT NULL auto_increment,
  `source` varchar(45) default NULL,
  `source_team` varchar(45) default NULL,
  `destination` varchar(45) default NULL,
  `destTeam` varchar(45) default NULL,
  `type` varchar(45) default NULL,
  `time` varchar(45) default NULL,
  `timetodie` varchar(45) default NULL,
  `assoc_timestamp` int(45) default '0',
  PRIMARY KEY  (`idattacks`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;


-- -----------------------------------------------------
-- Table `ReTiNAdb`.`nodestats`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ReTiNAdb`.`nodestats` ;


CREATE TABLE IF NOT EXISTS `nodestats` (
  `idnodestats` int(11) NOT NULL auto_increment,
  `address` varchar(45) default NULL,
  `team` varchar(45) default NULL,
  `os` varchar(45) default NULL,
  `nodeType` varchar(45) default NULL,
  `services` varchar(90) default NULL,
  PRIMARY KEY  (`idnodestats`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
