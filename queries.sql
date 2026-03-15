
-- 1. ABBONAMENTI IN SCADENZA NEI PROSSIMI 30 GIORNI
SELECT 
    i.Nome, 
    i.Cognome, 
    i.Telefono, 
    a.Tipologia, 
    a.Scad AS Data_Scadenza
FROM ISCRITTO i
JOIN ABBONAMENTO a ON i.CF = a.CF_Iscritto
WHERE a.Scad BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
ORDER BY a.Scad ASC;

-- 2. CORSI PIÙ FREQUENTATI (CLASSIFICA)

SELECT 
    c.Nome AS Nome_Corso, 
    s.Tipo AS Categoria_Sala,
    COUNT(f.CF) AS Totale_Presenze
FROM CORSO c
JOIN SALA s ON c.Sala = s.Nome
JOIN REGISTRO r ON c.CodC = r.CodC
JOIN FREQUENTARE f ON r.CodReg = f.CodReg
GROUP BY c.Nome, s.Tipo
ORDER BY Totale_Presenze DESC;

-- 3. ESTRAZIONE DELLA SCHEDA DI ALLENAMENTO DI UN UTENTE SPECIFICO

SELECT 
    i.Nome, 
    i.Cognome,
    ist.Cognome AS Istruttore_Assegnato,
    e.Nome AS Esercizio, 
    co.Serie, 
    co.Ripetizione, 
    s.Durata AS Durata_Totale_Minuti
FROM ISCRITTO i
JOIN SCHEDA s ON i.CF = s.CF_Iscritto
JOIN ISTRUTTORE ist ON s.Istruttore = ist.CF
JOIN CONTIENE co ON s.CodSc = co.CodSc
JOIN ESERCIZIO e ON co.CodEs = e.CodEs
WHERE i.Nome = 'Gianluca' AND i.Cognome = 'Ferrari';



-- 4. REPORT INCASSI PER TIPOLOGIA DI ABBONAMENTO

SELECT 
    t.Nome AS Tipo_Abbonamento, 
    COUNT(a.CodAbb) AS Numero_Sottoscrizioni,
    SUM(a.Prezzo) AS Incasso_Totale
FROM TIPOLOGIA t
JOIN ABBONAMENTO a ON t.Nome = a.Tipologia
GROUP BY t.Nome
ORDER BY Incasso_Totale DESC;