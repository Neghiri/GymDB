-- 1. TABELLE INDIPENDENTI
CREATE TABLE SALA (
    Nome VARCHAR(50) PRIMARY KEY,
    Capienza INT NOT NULL CHECK (Capienza > 0),
    Tipo VARCHAR(20) CHECK (Tipo IN ('Pesi', 'Cardio', 'Corsi', 'Altro'))
);

CREATE TABLE TIPOLOGIA (
    Nome VARCHAR(50) PRIMARY KEY,
    Descr TEXT
);

CREATE TABLE ISTRUTTORE (
    CF CHAR(16) PRIMARY KEY,
    Cognome VARCHAR(50) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Cv TEXT
);

CREATE TABLE ESERCIZIO (
    CodEs VARCHAR(10) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL
);

CREATE TABLE ISCRITTO (
    CF CHAR(16) PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL,
    Cognome VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    DataNascita DATE NOT NULL,
    Peso DECIMAL(5,2),
    Telefono VARCHAR(15),
    Altezza DECIMAL(5,2),
    Via VARCHAR(100),
    Cap CHAR(5),
    NumCiv VARCHAR(10)
);

-- 2. TABELLE CON CHIAVI ESTERNE
CREATE TABLE CORSO (
    CodC VARCHAR(10) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    MaxP INT NOT NULL,
    Sala VARCHAR(50) NOT NULL,
    FOREIGN KEY (Sala) REFERENCES SALA(Nome)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE SCHEDA (
    CodSc VARCHAR(10) PRIMARY KEY,
    Durata INT NOT NULL,
    Istruttore CHAR(16) NOT NULL,
    CF_Iscritto CHAR(16) NOT NULL,
    FOREIGN KEY (Istruttore) REFERENCES ISTRUTTORE(CF)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (CF_Iscritto) REFERENCES ISCRITTO(CF)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ABBONAMENTO (
    CodAbb VARCHAR(10) PRIMARY KEY,
    Prezzo DECIMAL(10,2) NOT NULL,
    Durata INT NOT NULL,
    Scad DATE NOT NULL,
    Tipologia VARCHAR(50) NOT NULL,
    CF_Iscritto CHAR(16) NOT NULL,
    FOREIGN KEY (Tipologia) REFERENCES TIPOLOGIA(Nome)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (CF_Iscritto) REFERENCES ISCRITTO(CF)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE REGISTRO (
    CodReg VARCHAR(10) PRIMARY KEY,
    CodC VARCHAR(10) NOT NULL, 
    Data DATE NOT NULL,
    Ora TIME NOT NULL,
    Note TEXT,
    Stato VARCHAR(20) NOT NULL,
    FOREIGN KEY (CodC) REFERENCES CORSO(CodC)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. TABELLE DI RELAZIONE 
CREATE TABLE CONTIENE (
    CodEs VARCHAR(10) NOT NULL,
    CodSc VARCHAR(10) NOT NULL,
    Serie INT NOT NULL,       
    Ripetizione INT NOT NULL, 
    PRIMARY KEY (CodEs, CodSc),
    FOREIGN KEY (CodEs) REFERENCES ESERCIZIO(CodEs)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CodSc) REFERENCES SCHEDA(CodSc)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE INSEGNARE (
    CF CHAR(16) NOT NULL,
    CodC VARCHAR(10) NOT NULL,
    PRIMARY KEY (CF, CodC),
    FOREIGN KEY (CF) REFERENCES ISTRUTTORE(CF)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CodC) REFERENCES CORSO(CodC)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE FREQUENTARE (
    CF CHAR(16) NOT NULL,
    CodReg VARCHAR(10) NOT NULL,
    OraInizio TIME NOT NULL,
    OraFine TIME NOT NULL,
    PRIMARY KEY (CF, CodReg),
    FOREIGN KEY (CF) REFERENCES ISCRITTO(CF)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CodReg) REFERENCES REGISTRO(CodReg)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 4. TRIGGERS
CREATE OR REPLACE FUNCTION controllo_max_partecipanti()
RETURNS TRIGGER AS $$
DECLARE
    numero_iscritti INTEGER;
    max_partecipanti INTEGER;
BEGIN
    SELECT COUNT(*) INTO numero_iscritti
    FROM FREQUENTARE
    WHERE CodReg = NEW.CodReg;

   
    SELECT c.MaxP INTO max_partecipanti
    FROM CORSO c
    JOIN REGISTRO r ON c.CodC = r.CodC
    WHERE r.CodReg = NEW.CodReg;

    IF numero_iscritti >= max_partecipanti THEN
        RAISE EXCEPTION 'Numero massimo partecipanti raggiunto per questa sessione';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_max_partecipanti
BEFORE INSERT ON FREQUENTARE
FOR EACH ROW
EXECUTE FUNCTION controllo_max_partecipanti();

CREATE OR REPLACE FUNCTION aggiorna_stato_registro()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Data < CURRENT_DATE THEN
        NEW.Stato := 'Concluso';
    ELSE
        NEW.Stato := 'Programmato';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_stato_registro
BEFORE INSERT OR UPDATE ON REGISTRO
FOR EACH ROW
EXECUTE FUNCTION aggiorna_stato_registro();

CREATE OR REPLACE FUNCTION calcola_scadenza()
RETURNS TRIGGER AS $$
BEGIN
    NEW.Scad := CURRENT_DATE + (NEW.Durata || ' months')::interval;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_scadenza
BEFORE INSERT ON ABBONAMENTO
FOR EACH ROW
EXECUTE FUNCTION calcola_scadenza();

-- 5. INSERIMENTO DATI 
INSERT INTO SALA (Nome, Capienza, Tipo) VALUES
('Sala Pesi A', 30, 'Pesi'),
('Sala Cardio B', 25, 'Cardio'),
('Sala Spinning', 20, 'Corsi'),
('Sala Yoga', 15, 'Corsi');

INSERT INTO TIPOLOGIA (Nome, Descr) VALUES
('Base', 'Abbonamento base con accesso alle sale'),
('Premium', 'Accesso illimitato a tutte le sale e corsi'),
('Student', 'Tariffa agevolata per studenti');

INSERT INTO ISTRUTTORE (CF, Cognome, Nome, Email, Cv) VALUES
('RSSMRA80A01H501Z', 'Rossi', 'Mario', 'mario.rossi@gym.it', 'Laurea in Scienze Motorie, 10 anni di esperienza'),
('VRDLGI85B02F205X', 'Verdi', 'Luigi', 'luigi.verdi@gym.it', 'Personal trainer certificato'),
('BNCNNA90C41L219K', 'Bianchi', 'Anna', 'anna.bianchi@gym.it', 'Specializzata in yoga e pilates');

INSERT INTO ESERCIZIO (CodEs, Nome) VALUES
('ES001', 'Panca Piana'),
('ES002', 'Squat'),
('ES003', 'Stacchi da Terra'),
('ES004', 'Curl con Manubri'),
('ES005', 'Plank');

-- Iscritti
INSERT INTO ISCRITTO (CF, Nome, Cognome, Email, DataNascita, Peso, Telefono, Altezza, Via, Cap, NumCiv) VALUES
('FRRGLC95D10H501A', 'Gianluca', 'Ferrari', 'gianluca.ferrari@email.it', '1995-04-10', 78.5, '3331234567', 1.80, 'Via Roma', '00100', '12'),
('CNTMRA98E41F205B', 'Maria', 'Conti', 'maria.conti@email.it', '1998-05-01', 60.0, '3497654321', 1.65, 'Via Napoli', '80100', '5'),
('PLLSRA00F20L219C', 'Sara', 'Palillo', 'sara.palillo@email.it', '2000-06-20', 55.5, '3201122334', 1.62, 'Via Milano', '20100', '8'),
('MRNLCA88G15H501D', 'Luca', 'Marinetti', 'luca.marinetti@email.it', '1988-07-15', 90.0, '3664433221', 1.85, 'Via Torino', '10100', '3');

-- Schede e Abbonamenti
INSERT INTO SCHEDA (CodSc, Durata, Istruttore, CF_Iscritto) VALUES
('SC001', 90, 'RSSMRA80A01H501Z', 'FRRGLC95D10H501A'),
('SC002', 60, 'VRDLGI85B02F205X', 'MRNLCA88G15H501D'),
('SC003', 45, 'BNCNNA90C41L219K', 'CNTMRA98E41F205B');

INSERT INTO ABBONAMENTO (CodAbb, Prezzo, Durata, Scad, Tipologia, CF_Iscritto) VALUES
('ABB001', 49.99, 1, CURRENT_DATE, 'Base', 'CNTMRA98E41F205B'),
('ABB002', 89.99, 3, CURRENT_DATE, 'Premium', 'FRRGLC95D10H501A'),
('ABB003', 199.99, 12, CURRENT_DATE, 'Premium', 'MRNLCA88G15H501D'),
('ABB004', 35.00, 1, CURRENT_DATE, 'Student', 'PLLSRA00F20L219C');

INSERT INTO CORSO (CodC, Nome, MaxP, Sala) VALUES
('C001', 'Spinning', 15, 'Sala Cardio B'),
('C002', 'Functional Training', 20, 'Sala Pesi A'),
('C003', 'Yoga', 12, 'Sala Yoga');

-- Registro
INSERT INTO REGISTRO (CodReg, CodC, Data, Ora, Note, Stato) VALUES
('REG001', 'C002', '2024-01-10', '09:00:00', 'Lezione regolare', 'Programmato'),
('REG002', 'C001', '2026-03-01', '11:00:00', NULL, 'Programmato'),
('REG003', 'C003', '2026-04-15', '18:00:00', 'Sessione intensiva', 'Programmato');

-- Serie e Ripetizioni 
INSERT INTO CONTIENE (CodEs, CodSc, Serie, Ripetizione) VALUES
('ES001', 'SC001', 4, 10),
('ES002', 'SC001', 4, 12),
('ES003', 'SC002', 3, 8),
('ES004', 'SC002', 3, 12),
('ES005', 'SC003', 3, 60); 

INSERT INTO INSEGNARE (CF, CodC) VALUES
('RSSMRA80A01H501Z', 'C002'),
('VRDLGI85B02F205X', 'C001'),
('BNCNNA90C41L219K', 'C003');

-- Frequentare 
INSERT INTO FREQUENTARE (CF, CodReg, OraInizio, OraFine) VALUES
('FRRGLC95D10H501A', 'REG001', '09:00:00', '10:30:00'),
('CNTMRA98E41F205B', 'REG003', '18:00:00', '19:00:00'),
('PLLSRA00F20L219C', 'REG002', '11:00:00', '12:00:00'),
('MRNLCA88G15H501D', 'REG002', '11:00:00', '12:30:00');