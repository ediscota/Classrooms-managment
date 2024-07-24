CREATE DATABASE IF NOT EXISTS Aule;

USE Aule;

CREATE TABLE Responsabile (
    email VARCHAR(255) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
   CONSTRAINT formattazione_email CHECK (email LIKE '%_@__%.__%')
);

CREATE TABLE Gruppo (
    nome VARCHAR(255) PRIMARY KEY,
    descrizione TEXT
);

CREATE TABLE Aula (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    luogo VARCHAR(255) NOT NULL,
    edificio VARCHAR(255) NOT NULL,
    piano INT NOT NULL ,
    capienza INT CHECK (capienza >= 0),
    prese_elettriche INT CHECK (prese_elettriche >= 0),
    prese_rete INT CHECK (prese_rete >= 0),
    note TEXT,
    email_responsabile VARCHAR(255),
   CONSTRAINT unique_nome_edificio UNIQUE (nome, edificio),
   CONSTRAINT aula_email FOREIGN KEY (email_responsabile) REFERENCES Responsabile(email) ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE TABLE Attrezzatura (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    tipo VARCHAR(255) NOT NULL,
    ID_aula INT,
   CONSTRAINT attrezzatura_aula FOREIGN KEY (ID_aula) REFERENCES Aula(ID) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Suddivisione (
    nome_gruppo VARCHAR(255),
    ID_aula INT,
    PRIMARY KEY (nome_gruppo, ID_aula),
   CONSTRAINT suddivisione_gruppo FOREIGN KEY (nome_gruppo) REFERENCES Gruppo(nome) ON DELETE CASCADE ON UPDATE CASCADE,
   CONSTRAINT suddivisione_aula FOREIGN KEY (ID_aula) REFERENCES Aula(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Evento (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    tipologia VARCHAR(255) NOT NULL,
    data DATE NOT NULL,
    ora_inizio TIME NOT NULL,
    ora_fine TIME NOT NULL,
    IDmaster INT,
    tipo_periodicita VARCHAR(255),
    data_fine DATE,
    email_responsabile VARCHAR(255),
    ID_aula INT NOT NULL,
    CONSTRAINT evento_responsabile FOREIGN KEY (email_responsabile) REFERENCES Responsabile(email) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT evento_aula FOREIGN KEY (ID_aula) REFERENCES Aula(ID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ora CHECK (ora_fine >= ora_inizio),
	CONSTRAINT data_ CHECK ((data_fine >= data) or (data_fine IS NULL)),
	CONSTRAINT periodicita CHECK (tipo_periodicita = 'giornaliero' or tipo_periodicita = 'settimanale' or tipo_periodicita = 'mensile' or tipo_periodicita IS NULL),
   CONSTRAINT ora_inizio CHECK ((ora_inizio >= '8:30' and ora_inizio < '19:30')),
   CONSTRAINT ora_fine CHECK (ora_fine <= '19:30')
);

CREATE TABLE Corso (
    nome VARCHAR(255) PRIMARY KEY
);

CREATE TABLE Appartenenza (
    nome_corso VARCHAR(255),
    ID_evento INT,
    PRIMARY KEY (nome_corso, ID_evento),
   CONSTRAINT appartenenza_corso  FOREIGN KEY (nome_corso) REFERENCES Corso(nome) ON DELETE CASCADE ON UPDATE CASCADE,
   CONSTRAINT appartenenza_evento FOREIGN KEY (ID_evento) REFERENCES Evento(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Trigger per la Validazione eventi ricorrenti
DELIMITER //
CREATE TRIGGER validazione_eventi_ricorrenti
BEFORE INSERT ON Evento
FOR EACH ROW
BEGIN
	IF NEW.tipo_periodicita IS NOT NULL AND (NEW.data_fine IS NULL OR NEW.data_fine <= NEW.data) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'data_fine must be after data'; 
    END IF;
END; //
DELIMITER;

-- Trigger per verificare disponibilità aula all'inserimento di un evento
DELIMITER //
CREATE TRIGGER disponibilita_aula
BEFORE INSERT ON Evento
FOR EACH ROW
BEGIN
	DECLARE cont INT;
    
    SELECT COUNT(*) INTO cont FROM Evento
    WHERE data = NEW.data AND NEW.ora_inizio < ora_fine AND NEW.ora_fine > ora_inizio AND ID_aula = NEW.ID_aula;
    
    IF cont > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'aula è già occupata in questo intervallo di tempo';
	END IF;
END; //
DELIMITER ;

DELIMITER //

CREATE TRIGGER UpdateRecurringEvent
BEFORE UPDATE ON Evento
FOR EACH ROW
BEGIN
    DECLARE event_count INT;

    -- Controlla se l'ora di inizio è minore dell'ora di fine
    IF NEW.ora_inizio >= NEW.ora_fine THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L\'ora di inizio deve essere minore dell\'ora di fine';
    END IF;

    -- Controlla sovrapposizioni per tutti gli eventi con lo stesso IDmaster
    SELECT COUNT(*) INTO event_count
    FROM Evento
    WHERE ID_aula = NEW.ID_aula
      AND data IN (SELECT data FROM Evento WHERE IDmaster = OLD.IDmaster) 
      AND ora_inizio < NEW.ora_fine
      AND ora_fine > NEW.ora_inizio
      AND (IDmaster <> OLD.IDmaster OR IDmaster IS NULL);

    -- Se esistono sovrapposizioni, genera un errore
    IF event_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'l\'aula è occupata in una delle date';
    END IF;

END //

DELIMITER ;

