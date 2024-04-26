-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Mar 01, 2023 alle 19:50
-- Versione del server: 10.4.27-MariaDB
-- Versione PHP: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `community_videogiochi`
--

DELIMITER $$
--
-- Procedure
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Acquisto_software` (INOUT `id_utenteIN` INT(16), INOUT `id_softwareIN` INT(16))   BEGIN
declare s float;
declare c float;

SELECT utente.saldo INTO s 
FROM utente
WHERE utente.id_utente=id_utenteIN;

SELECT software.costo INTO c 
FROM software
WHERE software.id_software=id_softwareIN;

IF(c<=s) THEN 
UPDATE utente
SET utente.saldo=s-c
WHERE utente.id_utente=id_utenteIN;

INSERT INTO libreria (id_utente,id_software,tempo_utilizzo) VALUES (id_utenteIN,id_softwareIN,0);
UPDATE utente SET nsoftware=nsoftware+1 WHERE utente.id_utente=id_utenteIN;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `aggiungiamico` (IN `id1` INT(16), IN `id2` INT(16))   IF (id1<>id2) THEN 
INSERT INTO lista_amici VALUES (id1,id2),(id2,id1);
END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Aggiunta_Software` (IN `NomeIN` VARCHAR(20), IN `CostoIN` FLOAT, IN `SviluppatoreIN` VARCHAR(30), IN `GenereIN` VARCHAR(30), IN `DescrizioneIN` VARCHAR(30))   BEGIN
IF (TRIM(GenereIN) ='' AND TRIM(DescrizioneIN)!='') THEN

INSERT INTO software (nome,costo,sviluppatore,descrizione)
VALUES (NomeIN,CostoIN,SviluppatoreIN,DescrizioneIN);

ELSE IF (TRIM(GenereIN) !='' AND TRIM(DescrizioneIN)='') THEN

INSERT INTO software (nome,costo,sviluppatore,genere)
VALUES (NomeIN,CostoIN,SviluppatoreIN,GenereIN);

END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Aggiunta_trofeo` (IN `id_utenteIN` INT(16), IN `id_trofeoIN ` INT(16))   INSERT INTO trofei_sbloccati VALUES (id_trofeoIN,id_utenteIN)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Calcolo_Numero_Software` (IN `id_utenteIN` INT(16))   SELECT utente.nsoftware
FROM utente
WHERE utente.id_utente=id_utenteIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Calcolo_Ore_Totali` (IN `id_utenteIN` INT(16))   SELECT libreria.id_utente, SEC_TO_TIME(SUM(TIME_TO_SEC(libreria.tempo_utilizzo)))AS 'tempo totale'
FROM libreria
WHERE id_utente=id_utenteIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Creazione_discussione` (IN `id_creatoreIN` INT(16), IN `Oggetto_chatIN` VARCHAR(20))   INSERT INTO discussione (id_creatore,oggetto_chat,data_creazione) VALUES (id_creatoreIN,Oggetto_chatIN,CURRENT_DATE)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Incrementa_Tempo_Utilizzo_Software` (IN `idutenteIN` INT(16), IN `idsoftwareIN` INT(16))   UPDATE libreria
SET tempo_utilizzo = ADDTIME(tempo_utilizzo, '00:30:00')
WHERE id_utente = idutenteIN AND id_software = idsoftwareIN$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Inserimento_commento` (IN `ContenutoIN` TEXT, IN `id_utenteIN` INT(16), IN `id_discussioneIN` INT(16))   BEGIN
INSERT INTO commento VALUES (ContenutoIN,CURRENT_TIMESTAMP,id_utenteIN,id_discussioneIN);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Registrazione_nuovo_utente` (IN `Nome_utenteIN` VARCHAR(20), IN `emailIN` VARCHAR(30), IN `passwIN` VARCHAR(20))   INSERT INTO utente (Nome_utente,email,passW) VALUES (Nome_utenteIN,emailIN,passwIN)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sblocca_trofeo` (IN `id_utenteIN` INT(16), IN `id_trofeoIN` INT(16))   BEGIN
IF EXISTS (
SELECT *
    FROM libreria
    WHERE libreria.id_utente=id_utenteIN AND libreria.id_software = (
    SELECT trofeo.id_software
        FROM trofeo
        WHERE trofeo.id_trofeo=id_trofeoIN
    )

)
THEN
INSERT INTO trofei_sbloccati (id_trofeo, id_utente) VALUES (id_trofeoIN, id_utenteIN);
END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `commento`
--

CREATE TABLE `commento` (
  `contenuto` text NOT NULL,
  `ora` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `id_utente` int(16) NOT NULL,
  `id_discussione` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `commento`
--

INSERT INTO `commento` (`contenuto`, `ora`, `id_utente`, `id_discussione`) VALUES
('A poco prezzo ti consiglio Mortal Kombat', '2023-02-17 18:40:15', 2, 3),
('Gioca molto e diventa sempre più bravo', '2023-02-17 18:40:58', 5, 2),
('Prendi il fungo all\'inizio del livello', '2023-02-17 18:41:34', 2, 1),
('A poco prezzo ti consiglio Mortal Kombat', '2023-02-28 16:23:21', 2, 3),
('Prova ad usare il fiore', '2023-03-01 17:54:15', 3, 1),
('Il livello è facillissimo!', '2023-03-01 17:54:41', 4, 1);

--
-- Trigger `commento`
--
DELIMITER $$
CREATE TRIGGER `VerificaDataCommento` BEFORE INSERT ON `commento` FOR EACH ROW IF (NEW.ora < CURRENT_TIMESTAMP || NEW.ora > CURRENT_TIMESTAMP ) THEN	
        SET NEW.ora = CURRENT_TIMESTAMP;
        END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `discussione`
--

CREATE TABLE `discussione` (
  `id_discussione` int(16) NOT NULL,
  `id_creatore` int(16) NOT NULL,
  `Oggetto_chat` varchar(100) NOT NULL,
  `Data_creazione` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `discussione`
--

INSERT INTO `discussione` (`id_discussione`, `id_creatore`, `Oggetto_chat`, `Data_creazione`) VALUES
(1, 1, 'Come superare il primo livello di super mario', '2023-02-17'),
(2, 4, 'come sbloccare più trofei', '2023-02-17'),
(3, 3, 'Quale gioco acquistare a basso prezzo?', '2023-02-17');

--
-- Trigger `discussione`
--
DELIMITER $$
CREATE TRIGGER `VerificaDataCreazioneDiscussione` BEFORE INSERT ON `discussione` FOR EACH ROW IF (NEW.Data_creazione < CURRENT_DATE || NEW.Data_creazione > CURRENT_DATE )  THEN
	SET NEW.Data_creazione = CURRENT_DATE;
    END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `libreria`
--

CREATE TABLE `libreria` (
  `id_utente` int(16) NOT NULL,
  `id_software` int(16) NOT NULL,
  `tempo_utilizzo` time NOT NULL DEFAULT '00:00:00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `libreria`
--

INSERT INTO `libreria` (`id_utente`, `id_software`, `tempo_utilizzo`) VALUES
(1, 2, '01:00:30'),
(1, 4, '00:30:00'),
(1, 5, '00:00:00'),
(2, 3, '00:00:00'),
(2, 5, '00:00:00'),
(6, 2, '00:00:00'),
(8, 2, '00:00:00'),
(8, 3, '00:00:00');

-- --------------------------------------------------------

--
-- Struttura della tabella `lista_amici`
--

CREATE TABLE `lista_amici` (
  `id_utente1` int(16) NOT NULL,
  `id_utente2` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `lista_amici`
--

INSERT INTO `lista_amici` (`id_utente1`, `id_utente2`) VALUES
(1, 2),
(2, 1),
(2, 3),
(2, 5),
(3, 2),
(3, 5),
(5, 2),
(5, 3),
(6, 7),
(7, 6);

-- --------------------------------------------------------

--
-- Struttura della tabella `software`
--

CREATE TABLE `software` (
  `id_software` int(16) NOT NULL,
  `Nome` varchar(20) NOT NULL,
  `Costo` float NOT NULL DEFAULT 0,
  `Sviluppatore` varchar(30) NOT NULL,
  `Genere` varchar(30) DEFAULT NULL,
  `Descrizione` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `software`
--

INSERT INTO `software` (`id_software`, `Nome`, `Costo`, `Sviluppatore`, `Genere`, `Descrizione`) VALUES
(1, 'Escape From Monkey I', 59.99, ' Ron Gilbert', 'Avventeura Grafica', NULL),
(2, 'PacMan', 10, 'NAMCO', 'Arcade', NULL),
(3, 'Super Mario', 39.99, 'NINTENDO', 'Platform', NULL),
(4, 'Mortal Kombat', 60, 'NetherRealm Studios', 'Combattimento', NULL),
(5, 'Word', 0, 'Microsoft', NULL, 'Software Per Scrittura');

--
-- Trigger `software`
--
DELIMITER $$
CREATE TRIGGER `VerificaCosto` BEFORE INSERT ON `software` FOR EACH ROW IF NEW.costo < 0 THEN
	SET NEW.costo=0; 
    END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `trofei_sbloccati`
--

CREATE TABLE `trofei_sbloccati` (
  `id_trofeo` int(16) NOT NULL,
  `id_utente` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `trofei_sbloccati`
--

INSERT INTO `trofei_sbloccati` (`id_trofeo`, `id_utente`) VALUES
(2, 1),
(3, 1),
(3, 6);

-- --------------------------------------------------------

--
-- Struttura della tabella `trofeo`
--

CREATE TABLE `trofeo` (
  `id_software` int(16) NOT NULL,
  `id_trofeo` int(16) NOT NULL,
  `nome` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `trofeo`
--

INSERT INTO `trofeo` (`id_software`, `id_trofeo`, `nome`) VALUES
(1, 1, 'Supera Il primo livello'),
(4, 2, 'Batti il primo sfidante'),
(2, 3, 'Fai 500 punti'),
(3, 4, 'Prendi un fungo'),
(3, 7, 'Supera il primo mondo');

-- --------------------------------------------------------

--
-- Struttura della tabella `utente`
--

CREATE TABLE `utente` (
  `id_utente` int(16) NOT NULL,
  `Nome_utente` varchar(20) NOT NULL,
  `email` varchar(30) NOT NULL,
  `passW` varchar(20) NOT NULL,
  `nsoftware` int(255) NOT NULL DEFAULT 0,
  `Saldo` float NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `utente`
--

INSERT INTO `utente` (`id_utente`, `Nome_utente`, `email`, `passW`, `nsoftware`, `Saldo`) VALUES
(1, 'marvin_2', 'maspinal2@yahoo.co.jp', 'u7eEFV3oP70', 3, 30.5),
(2, 'graved_x', 'sperrellid@360.cn', 'gPTUqdHn', 2, 17.01),
(3, 'nluker4', 'kwilles4@facebook.com', 'OJGr4l8D', 0, 20.5),
(4, 'cturnell1', 'dleates1@bravesites.com', 'JkjouN8g', 0, 25.3),
(5, 'llahrs0', 'oharbisher0@techcrunch.com', '1ZbL3BeFGdYP', 0, 500),
(6, 'deek', 'fgason8@cisco.com', 'cut16Oe', 1, 22.5),
(7, 'sjont', 'lkirsopj@i2i.jp', 'zdKiu3', 0, 25.3),
(8, 'thegamer', 'ypackef@guardian.co.uk', 'HX0LYM3xbuX', 2, 30.01),
(9, 'TheDarker', 'darker25@gmail.com', 'Ufhtga67!', 0, 0),
(10, 'Forceman25', 'thenextt@gmail.com', 'pijhakm89', 0, 0);

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `utility_software`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `utility_software` (
`id_software` int(16)
,`Nome_Videogioco` varchar(20)
,`Costo` float
,`Sviluppatore` varchar(30)
,`Genere` varchar(30)
);

-- --------------------------------------------------------

--
-- Struttura stand-in per le viste `videogiochi`
-- (Vedi sotto per la vista effettiva)
--
CREATE TABLE `videogiochi` (
`id_software` int(16)
,`Nome_Videogioco` varchar(20)
,`Costo` float
,`Sviluppatore` varchar(30)
,`Genere` varchar(30)
);

-- --------------------------------------------------------

--
-- Struttura per vista `utility_software`
--
DROP TABLE IF EXISTS `utility_software`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `utility_software`  AS SELECT `software`.`id_software` AS `id_software`, `software`.`Nome` AS `Nome_Videogioco`, `software`.`Costo` AS `Costo`, `software`.`Sviluppatore` AS `Sviluppatore`, `software`.`Genere` AS `Genere` FROM `software` WHERE `software`.`Genere` is null AND `software`.`Descrizione` is not nullnot null  ;

-- --------------------------------------------------------

--
-- Struttura per vista `videogiochi`
--
DROP TABLE IF EXISTS `videogiochi`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `videogiochi`  AS SELECT `software`.`id_software` AS `id_software`, `software`.`Nome` AS `Nome_Videogioco`, `software`.`Costo` AS `Costo`, `software`.`Sviluppatore` AS `Sviluppatore`, `software`.`Genere` AS `Genere` FROM `software` WHERE `software`.`Genere` is not null AND `software`.`Descrizione` is nullnull  ;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `commento`
--
ALTER TABLE `commento`
  ADD PRIMARY KEY (`ora`,`id_utente`,`id_discussione`),
  ADD KEY `Commento_fk0` (`id_utente`),
  ADD KEY `Commento_fk1` (`id_discussione`);

--
-- Indici per le tabelle `discussione`
--
ALTER TABLE `discussione`
  ADD PRIMARY KEY (`id_discussione`),
  ADD KEY `Discussione_fk0` (`id_creatore`);

--
-- Indici per le tabelle `libreria`
--
ALTER TABLE `libreria`
  ADD PRIMARY KEY (`id_utente`,`id_software`),
  ADD KEY `Libreria_fk1` (`id_software`);

--
-- Indici per le tabelle `lista_amici`
--
ALTER TABLE `lista_amici`
  ADD PRIMARY KEY (`id_utente1`,`id_utente2`),
  ADD KEY `Lista_Amici_fk1` (`id_utente2`);

--
-- Indici per le tabelle `software`
--
ALTER TABLE `software`
  ADD PRIMARY KEY (`id_software`);

--
-- Indici per le tabelle `trofei_sbloccati`
--
ALTER TABLE `trofei_sbloccati`
  ADD PRIMARY KEY (`id_trofeo`,`id_utente`),
  ADD KEY `Trofei_sbloccati_fk1` (`id_utente`);

--
-- Indici per le tabelle `trofeo`
--
ALTER TABLE `trofeo`
  ADD PRIMARY KEY (`id_trofeo`),
  ADD KEY `Trofeo_fk0` (`id_software`);

--
-- Indici per le tabelle `utente`
--
ALTER TABLE `utente`
  ADD PRIMARY KEY (`id_utente`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `discussione`
--
ALTER TABLE `discussione`
  MODIFY `id_discussione` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29700005;

--
-- AUTO_INCREMENT per la tabella `software`
--
ALTER TABLE `software`
  MODIFY `id_software` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT per la tabella `trofeo`
--
ALTER TABLE `trofeo`
  MODIFY `id_trofeo` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT per la tabella `utente`
--
ALTER TABLE `utente`
  MODIFY `id_utente` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `commento`
--
ALTER TABLE `commento`
  ADD CONSTRAINT `Commento_fk0` FOREIGN KEY (`id_utente`) REFERENCES `utente` (`id_utente`),
  ADD CONSTRAINT `Commento_fk1` FOREIGN KEY (`id_discussione`) REFERENCES `discussione` (`id_discussione`);

--
-- Limiti per la tabella `discussione`
--
ALTER TABLE `discussione`
  ADD CONSTRAINT `Discussione_fk0` FOREIGN KEY (`id_creatore`) REFERENCES `utente` (`id_utente`);

--
-- Limiti per la tabella `libreria`
--
ALTER TABLE `libreria`
  ADD CONSTRAINT `Libreria_fk0` FOREIGN KEY (`id_utente`) REFERENCES `utente` (`id_utente`),
  ADD CONSTRAINT `Libreria_fk1` FOREIGN KEY (`id_software`) REFERENCES `software` (`id_software`);

--
-- Limiti per la tabella `lista_amici`
--
ALTER TABLE `lista_amici`
  ADD CONSTRAINT `Lista_Amici_fk0` FOREIGN KEY (`id_utente1`) REFERENCES `utente` (`id_utente`),
  ADD CONSTRAINT `Lista_Amici_fk1` FOREIGN KEY (`id_utente2`) REFERENCES `utente` (`id_utente`);

--
-- Limiti per la tabella `trofei_sbloccati`
--
ALTER TABLE `trofei_sbloccati`
  ADD CONSTRAINT `Trofei_sbloccati_fk0` FOREIGN KEY (`id_trofeo`) REFERENCES `trofeo` (`id_trofeo`),
  ADD CONSTRAINT `Trofei_sbloccati_fk1` FOREIGN KEY (`id_utente`) REFERENCES `utente` (`id_utente`);

--
-- Limiti per la tabella `trofeo`
--
ALTER TABLE `trofeo`
  ADD CONSTRAINT `Trofeo_fk0` FOREIGN KEY (`id_software`) REFERENCES `software` (`id_software`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
