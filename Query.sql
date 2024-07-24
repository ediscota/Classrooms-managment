-- QUERY 1
INSERT INTO aula (nome, Luogo, edificio, piano, capienza, prese_elettriche, prese_rete, note, email_responsabile)
VALUES ('A1.7', 'Università', 'Coppito 0', 1, 100, 10, 5, NULL, 'guido.proietti@univaq.it');

-- QUERY 2 inserimento di un evento singolo e di un evento ricorrente
drop procedure AddEvent;
DELIMITER //

CREATE PROCEDURE AddEvent(
    IN p_nome VARCHAR(255),
    IN p_tipologia VARCHAR(255),
    IN p_data DATE,
    IN p_ora_inizio TIME,
    IN p_ora_fine TIME,
    IN p_IDmaster INT,
    IN p_tipo_periodicita VARCHAR(255),
    IN p_data_fine DATE,
    IN p_email_responsabile VARCHAR(255),
    IN p_idaula INT
)
BEGIN
    DECLARE current_date1 DATE;
    DECLARE end_date DATE;
    
    -- Inserisci primo evento
    INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
    VALUES (p_nome, p_tipologia, p_data, p_ora_inizio, p_ora_fine, p_IDmaster, p_tipo_periodicita, p_data_fine, p_email_responsabile,p_idaula);
    
    SET current_date1 = p_data;
    SET end_date = p_data_fine;

    -- Genera eventi ripetuti
    WHILE current_date1 < end_date DO        
		IF p_tipo_periodicita = 'giornaliero' THEN
			SET current_date1 = DATE_ADD(current_date1, INTERVAL 1 DAY);
		ELSEIF p_tipo_periodicita = 'settimanale' THEN
			SET current_date1 = DATE_ADD(current_date1, INTERVAL 1 WEEK);
		ELSEIF p_tipo_periodicita = 'mensile' THEN
			SET current_date1 = DATE_ADD(current_date1, INTERVAL 1 MONTH);
		END IF;
        
        IF current_date1 <= end_date THEN
            INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
            VALUES (p_nome, p_tipologia, current_date1, p_ora_inizio, p_ora_fine, p_IDmaster, p_tipo_periodicita, p_data_fine, p_email_responsabile, p_idaula);
        END IF;
    END WHILE;
END //

DELIMITER ;

-- evento singolo
CALL AddEvent(
           'Ai', 
           'lezione', 
           '2024-10-13',  
           '8:30',
           '10:30', 
           NULL , 
           NULL, 
           NULL,  
           'guido.proietti@univaq.it',
           1
        );
        
/* in alternativa: INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES (' AI', 'parziale', '2024-10-13', '8:30', '10:30', NULL, NULL, NULL,  'guido.proietti@univaq.it', 1);*/

-- evento ripetuto
CALL AddEvent(
           'Algoritmi e strutture dati', 
           'lezione', 
           '2024-1-10',  
           '8:30',
           '10:30', 
           100 , 
           'settimanale', 
           '2024-1-20',  
           'guido.proietti@univaq.it',
           1
        );
    -- la procedura addEvent garantisce una corretta gestione della logica degli eventi periodici
SET SQL_SAFE_UPDATES = 0;
-- QUERY 3 modifica di un evento ricorrente
UPDATE evento 
SET ora_inizio = '09:30', ora_fine = '11:30', 
	ID_aula = 1
WHERE IDmaster = 100;

-- QUERY 4 eliminazione di un evento ricorrente
DELETE FROM evento WHERE IDmaster=100;


-- QUERY 5 associazione di un'attrezzatura a un aula
SELECT aula.ID as ID_aula, Aula.nome AS Nome_Aula, Aula.edificio AS Edificio,
		attrezzatura.ID AS ID_attrezzatura, attrezzatura.tipo AS Attrezzatura 
FROM aula 
JOIN attrezzatura ON aula.ID = attrezzatura.ID_aula
WHERE Aula.ID = 1; 

-- QUERY 6 estrazione lista degli eventi associati a una specifica aula in una determinata settimana
SELECT 
    Evento.ID AS Evento_ID, Evento.nome AS Nome_Evento, Evento.tipologia AS Tipologia_Evento,
    Evento.data AS Data_Evento, Evento.ora_inizio AS Ora_Inizio_Evento, Evento.ora_fine AS Ora_Fine_Evento,
    Evento.email_responsabile AS Responsabile_Evento, Aula.nome AS Aula, aula.edificio AS Edificio
FROM Evento
JOIN Aula ON Evento.ID_aula = Aula.ID
WHERE Aula.ID = 1 AND Evento.data BETWEEN '2024-10-10' AND '2024-10-17';

-- QUERY 7 estrazione lista degli eventi degli eventi delle prossime tre ore (cioè che inizieranno nell'arco delle prossime tre ore)
SELECT * FROM evento WHERE TIMESTAMP(data, ora_inizio) BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 3 HOUR);

-- QUERY 8 calcolo del numero di lezioni relative a un corso svoltesi in un determinato anno accademico e del corrispondente numero complessivo di ore di didattica
CALL CalcolaLezioniEdOre('Basi', 2024);

drop procedure CalcolaLezioniEdOre;
DELIMITER //

CREATE PROCEDURE CalcolaLezioniEdOre (
    IN p_nome_corso VARCHAR(255),
    IN p_anno_inizio INT
)
BEGIN
    DECLARE inizio_anno_accademico DATE;
    DECLARE fine_anno_accademico DATE;
    
    -- Calcolo delle date di inizio e fine dell'anno accademico
    SET inizio_anno_accademico = DATE(CONCAT(p_anno_inizio, '-10-01'));
    SET fine_anno_accademico = DATE(CONCAT(p_anno_inizio + 1, '-06-30'));
    
    -- Calcolo del numero di lezioni e del numero complessivo di ore
    SELECT 
        COUNT(*) AS numero_lezioni,
        SUM(TIME_TO_SEC(TIMEDIFF(ora_fine, ora_inizio))) / 3600 AS ore_didattica
    FROM 
        Evento e
    WHERE nome = p_nome_corso
        AND e.data BETWEEN inizio_anno_accademico AND fine_anno_accademico;
END //

DELIMITER ;

-- QUERY 9 estrazione di tutti gli eventi previsti nella giornata odierna nelle aule di un determinato gruppo
CALL GetEventsByDateAndGroup('2025-04-15','disim');

DELIMITER //

CREATE PROCEDURE GetEventsByDateAndGroup (
    IN p_date DATE,
    IN p_group_name VARCHAR(255)
)
BEGIN
    SELECT e.ID, e.nome, e.tipologia, e.data, e.ora_inizio, e.ora_fine, a.nome AS nome_aula, g.nome AS nome_gruppo
    FROM Evento e
    JOIN Aula a ON e.ID_aula = a.ID
    JOIN Suddivisione s ON a.ID = s.ID_aula
    JOIN Gruppo g ON s.nome_gruppo = g.nome
    WHERE e.data = p_date
    AND g.nome = p_group_name;
END //

DELIMITER ;

-- QUERY 10 calcolo della percentuale d'uso di un'aula in un determinato giorno (cioè del rapporto tra il tempo totale per cui è allocata da eventi e la durata complessiva della giornata)
CALL CalcolaPercentualeUsoAula('2024-11-25', '4');

drop procedure CalcolaPercentualeUsoAula;
DELIMITER //

CREATE PROCEDURE CalcolaPercentualeUsoAula(
    IN p_data DATE,
    IN p_id_aula VARCHAR(255)
)
BEGIN
    DECLARE v_durata_giornata_sec INT;
    DECLARE v_tempo_utilizzato_sec INT;
    DECLARE v_percentuale_uso DECIMAL(10,2);

    -- Ddurata totale della giornata in secondi
    SET v_durata_giornata_sec = 39600;

    -- Calcolo del tempo totale utilizzato dall'aula durante la giornata
    SELECT IFNULL(SUM(TIME_TO_SEC(TIMEDIFF(ora_fine, ora_inizio))), 0)
    INTO v_tempo_utilizzato_sec
    FROM Evento e
    JOIN Aula a ON e.ID_aula = a.ID
    WHERE e.data = p_data
      AND a.id = p_id_aula;

    -- Calcolo della percentuale d'uso dell'aula
    IF v_durata_giornata_sec > 0 THEN
         SET v_percentuale_uso = ROUND(v_tempo_utilizzato_sec / v_durata_giornata_sec * 100, 2);
    ELSE
         SET v_percentuale_uso = 0.00;
    END IF;

    -- Selezione dei risultati
    SELECT 
        a.nome AS nome_aula,
        v_percentuale_uso AS percentuale_uso
    FROM Aula a
    WHERE a.id = p_id_aula;

END //

DELIMITER ;

-- QUERY 11 estrazione delle aule la cui percentuale media giornaliera d'uso, calcolata in un mese specificato, è minore del 70% 

drop procedure AuleConPercentualeMediaSotto70;

CALL AuleConPercentualeMediaSotto70(2028, 2);


DELIMITER //

CREATE PROCEDURE AuleConPercentualeMediaSotto70(
    IN p_anno INT,
    IN p_mese INT
)
BEGIN
    DECLARE v_tot_giorni INT;
    DECLARE v_nome_aula VARCHAR(255);
    DECLARE v_percentuale_tot DECIMAL(10,2);
    DECLARE done INT DEFAULT FALSE;
    
	-- Cursor per selezionare tutte le aule
	DECLARE cur_aule CURSOR FOR 
        SELECT nome
        FROM Aula;

    -- Variabile per iterare sul risultato del cursore
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Trova il numero totale di giorni nel mese specificato
    SET v_tot_giorni = DAY(LAST_DAY(CONCAT(p_anno, '-', LPAD(p_mese, 2, '00'), '-01')));

    OPEN cur_aule;
    aule_loop: LOOP
        FETCH cur_aule INTO v_nome_aula;
        IF done THEN
            LEAVE aule_loop;
        END IF;

        -- Calcola la somma delle percentuali di utilizzo per l'aula nel mese specificato
        SET v_percentuale_tot = 0.00;

        CALL SommaPercentualiUtilizzoAulaMese(p_anno, p_mese, v_nome_aula, v_percentuale_tot);

        -- Calcola la percentuale media giornaliera
        SET @percentuale_media = v_percentuale_tot / v_tot_giorni;

        -- Restituisci solo le aule con percentuale media giornaliera inferiore al 70%
        IF @percentuale_media < 70.00 THEN
            SELECT v_nome_aula AS nome_aula, @percentuale_media AS percentuale_media_giornaliera;
        END IF;
    END LOOP;

    CLOSE cur_aule;
END //

DELIMITER ;

SET @percentuale_totale = 0;

drop procedure SommaPercentualiUtilizzoAulaMese;

-- Definizione della procedura per calcolare la percentuale d'uso giornaliera per tutte le aule in un mese specificato
DELIMITER //
CREATE PROCEDURE SommaPercentualiUtilizzoAulaMese(
    IN p_anno INT,
    IN p_mese INT,
    IN p_nome_aula VARCHAR(255),
    OUT p_percentuale_totale DECIMAL(10,2)
)
BEGIN
    DECLARE v_totale_percentuali DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_giorno DATE;
    DECLARE v_giornata_sec INT;
    DECLARE v_tempo_utilizzato_sec INT DEFAULT 0;
    DECLARE v_percentuale_giorno DECIMAL(5,2) DEFAULT 0.00;

    -- Ciclo sui giorni del mese
    SET v_giorno = DATE_FORMAT(CONCAT(p_anno, '-', LPAD(p_mese, 2, '00'), '-01'), '%Y-%m-%d');
    SET v_giornata_sec = 39600; -- Durata totale della giornata in secondi

    WHILE MONTH(v_giorno) = p_mese DO
        -- Resetta le variabili per il giorno corrente
        SET v_tempo_utilizzato_sec = 0;
        SET v_percentuale_giorno = 0.00;

        -- Calcolo del tempo totale utilizzato dall'aula durante la giornata
        SELECT IFNULL(SUM(TIME_TO_SEC(TIMEDIFF(ora_fine, ora_inizio))), 0)
        INTO v_tempo_utilizzato_sec
        FROM Evento e
        JOIN Aula a ON e.ID_aula = a.ID
        WHERE e.data = v_giorno
          AND a.nome = p_nome_aula;

        -- Calcolo della percentuale d'uso dell'aula per il giorno corrente
        IF v_giornata_sec > 0 THEN
            SET v_percentuale_giorno = ROUND(v_tempo_utilizzato_sec / v_giornata_sec * 100, 2);
        ELSE
            SET v_percentuale_giorno = 0.00;
        END IF;

        -- Aggiunge la percentuale del giorno al totale
        SET v_totale_percentuali = v_totale_percentuali + v_percentuale_giorno;

        -- Passa al giorno successivo
        SET v_giorno = DATE_ADD(v_giorno, INTERVAL 1 DAY);
    END WHILE;

    -- Restituisce il totale delle percentuali
    SET p_percentuale_totale = v_totale_percentuali;
END //
DELIMITER ;
