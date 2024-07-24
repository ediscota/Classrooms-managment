INSERT INTO responsabile (email, nome) 
VALUES ('guido.proietti@univaq.it', 'Guido Proietti');

-- ESEGUIRE QUERY 1 PRIMA DI ANDARE AVANTI

INSERT INTO Attrezzatura (tipo, ID_aula)
VALUES ('proiettore', 1);
select * from attrezzatura;

-- ESEGUIRE QUERY 2 PRIMA DI ANDARE AVANTI
INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Geometria', 'lezione', '2024-10-24', '8:30', '10:30', NULL, NULL, NULL,  'guido.proietti@univaq.it', 1);

INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Geometria', 'parziale', '2024-07-15', '16:30', '18:30', NULL, NULL, NULL,  'guido.proietti@univaq.it', 1);   
-- questa insert deve contenere un evento che inizi entro le prossime tre ore

INSERT INTO Responsabile (email, nome)
VALUES ('responsabile@example.com', 'Luca Bianchi');

INSERT INTO Aula (nome, luogo, edificio, piano, capienza, prese_elettriche, prese_rete, note, email_responsabile)
VALUES ('Aula Magna', 'Campus Nord', 'Edificio A', 1, 100, 20, 10, 'Aula principale per conferenze', 'responsabile@example.com');

INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Basi', 'Conferenza', '2024-10-15', '09:00:00', '12:00:00', NULL, NULL, NULL, 'responsabile@example.com', 1);

INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Basi', 'Conferenza', '2024-07-15', '09:00:00', '11:00:00', NULL, NULL, NULL, 'responsabile@example.com', 1);

INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Basi', 'Conferenza', '2025-4-15', '09:00:00', '10:00:00', NULL, NULL, NULL, 'responsabile@example.com', 1);

INSERT INTO Gruppo (nome, descrizione)
VALUES ('disim', 'Dipartimento di Ingegneria e Scienze dell\'Informazione e Matematica');

INSERT INTO Suddivisione (nome_gruppo, ID_aula)
VALUES ('disim', 1);

INSERT INTO Aula (nome, luogo, edificio, piano, capienza, prese_elettriche, prese_rete, note, email_responsabile)
VALUES ('Aula7', 'Campus Nord', 'Edificio A', 1, 100, 20, 10, 'Aula principale per conferenze', 'responsabile@example.com');

INSERT INTO Suddivisione (nome_gruppo, ID_aula)
VALUES ('disim', 2);

INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Analisi', 'Conferenza', '2025-4-15', '09:00:00', '10:00:00', NULL, NULL, NULL, 'responsabile@example.com', 2);

INSERT INTO Aula (nome, luogo, edificio, piano, capienza, prese_elettriche, prese_rete, note, email_responsabile)
VALUES ('Aula10', 'Blocco 0', 'Edificio A', 1, 100, 20, 10, 'Aula principale per conferenze', 'responsabile@example.com');

INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Dottorato', 'Conferenza', '2024-12-25', '09:00:00', '10:00:00', NULL, NULL, NULL, 'responsabile@example.com', 4);

INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Analisi', 'Conferenza', '2024-12-25', '13:00:00', '16:00:00', NULL, NULL, NULL, 'responsabile@example.com', 4);

iNSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Scienze', 'Conferenza', '2024-11-25', '08:30:00', '19:30:00', NULL, NULL, NULL, 'responsabile@example.com', 4);

SET @percentuale_totale = 0;
CALL AddEvent(
           'Algoritmi e strutture dati',
           'lezione',
           '2026-02-01', 
           '8:30',
           '16:30',
           100 ,
           'giornaliero',
           '2026-02-25', 
           'guido.proietti@univaq.it',
           1
        );
select* from evento;
INSERT INTO Evento (nome, tipologia, data, ora_inizio, ora_fine, IDmaster, tipo_periodicita, data_fine, email_responsabile, ID_aula)
VALUES ('Analisi', 'Assemblea', '2026-2-25', '13:00:00', '16:00:00', NULL, NULL, NULL, 'responsabile@example.com', 4);

 

CALL AddEvent(
           'Algoritmi e strutture dati',
           'lezione',
           '2028-02-01', 
           '8:30',
           '19:30',
           100 ,
           'giornaliero',
           '2028-02-25', 
           'guido.proietti@univaq.it',
           1
        );