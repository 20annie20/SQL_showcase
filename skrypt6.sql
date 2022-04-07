IF OBJECT_ID('dbo.WYPAS') IS NOT NULL
BEGIN
    DROP TABLE WYPAS
END
GO

IF OBJECT_ID('dbo.WYP_AUTA') IS NOT NULL
BEGIN
    DROP TABLE WYP_AUTA
END
GO

IF OBJECT_ID('dbo.AUTA') IS NOT NULL
BEGIN
    DROP TABLE AUTA
END
GO

/*tworzenie tabeli*/
CREATE TABLE dbo.AUTA
(	ID_AUTA int NOT NULL IDENTITY CONSTRAINT PK_AUTA PRIMARY KEY
,	MARKA nvarchar(20) NOT NULL
,	MODEL nvarchar(20) NOT NULL
)
GO

/*wype³niam tabelê moimi ulubionymi modelami aut (chocia¿ ogólnie wolê motory) */ 
INSERT INTO auta (marka, model) VALUES ('Ford', 'Mustang')
INSERT INTO auta (marka, model) VALUES ('Tesla', 'Roadster')
INSERT INTO auta (marka, model) VALUES ('BMW', 'i8')
INSERT INTO auta (marka, model) VALUES ('Lamborghini', 'Huracan')
INSERT INTO auta (marka, model) VALUES ('Tesla', 'Cybertruck')

CREATE TABLE dbo.WYP_AUTA
(	WYP nchar(4) NOT NULL CONSTRAINT PK_WYP_AUTA PRIMARY KEY
,	OPIS nvarchar(40)
)

INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('AC', 'Ubezpieczenie autocasco')
INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('ABS', 'System antyblokuj¹cego hamowania')
INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('NAVI', 'System nawigacji satelitarnej')
INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('4x4', 'Napêd na przedni¹ i tyln¹ oœ')
INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('LEAT', 'Poszycie skórzane siedzeñ')
INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('HEAT','ogrzewane siedzenia')
INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('ESP', 'elektroniczny program stabilizacji')
INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('ASR', 'System kontroli trakcji')
INSERT INTO WYP_AUTA(WYP, OPIS) VALUES ('DECO', 'Pasy stylizacyjne ')

CREATE TABLE dbo.WYPAS
(	ID_AUTA int NOT NULL CONSTRAINT FK_AUTA__WYPAS FOREIGN KEY REFERENCES AUTA (ID_AUTA)
,	WYP nchar(4) NOT NULL CONSTRAINT FK_WYP_AUTA__WYPAS FOREIGN KEY REFERENCES WYP_AUTA (WYP)
,	CONSTRAINT PK_WYPAS PRIMARY KEY (ID_AUTA, WYP)
)

INSERT INTO WYPAS(ID_AUTA, WYP) VALUES ('1', 'DECO')
INSERT INTO WYPAS(ID_AUTA, WYP) VALUES ('1', 'AC')
INSERT INTO WYPAS(ID_AUTA, WYP) VALUES ('1', 'NAVI ')

INSERT INTO WYPAS(ID_AUTA, WYP) VALUES ('2', 'AC')
INSERT INTO WYPAS(ID_AUTA, WYP) VALUES ('2', '4x4')


/*auta bez ¿adnego wyposa¿enia*/
SELECT a.ID_AUTA
,		a.MARKA
,		a.MODEL
,		CONVERT(nvarchar, null) AS [wyposazenie]
	FROM auta a
	WHERE
		NOT EXISTS
			(SELECT 1
				FROM WYPAS w
				WHERE (w.ID_AUTA = a.ID_AUTA)
				AND (w.WYP IS NOT NULL) /*czyli szukamy czy nie posiada wyposa¿enia*/
			)
/*
ID_AUTA     MARKA                MODEL                wyposazenie
----------- -------------------- -------------------- ------------------------------
3           BMW                  i8                   NULL
4           Lamborghini          Huracan              NULL
5           Tesla                Cybertruck           NULL*/


/* auta bez AC - czyli trzecie, czwarte i pi¹te w mojej bazie
**to sobie szybko sprawdzam patrz¹c na skrypt wczeœniej		
**mo¿naby siê pokusiæ o sprawdzenie poprzez
**wypisanie wszystkich wyposa¿eñ, ale w tak ma³ej
**bazie chyba nie ma sensu traciæ na to czasu, skoro 
**widzieliœmy to dodane chwilê temu - przy wiêkszej iloœci 
**rekordów zrobi³abym raczej coœ podobnego 				*/

SELECT *
	FROM auta a
		WHERE NOT EXISTS
		(
			SELECT 1
				FROM WYPAS W
				WHERE(W.ID_AUTA = A.ID_AUTA)
				AND (W.WYP = 'AC')
		)
/*
ID_AUTA     MARKA                MODEL
----------- -------------------- --------------------
3           BMW                  i8
4           Lamborghini          Huracan
5           Tesla                Cybertruck */

/* auta z AC i NAVI */
SELECT t.ID_AUTA
,	t.[ile z tego ma]
,	a.MARKA
,	a.MODEL
	FROM auta a
	join (SELECT w.ID_AUTA
			,	COUNT(DISTINCT w.WYP) AS [ile z tego ma]
		FROM wypas w
		WHERE w.WYP IN ('AC','NAVI')
		GROUP BY w.ID_AUTA
		HAVING COUNT(DISTINCT w.WYP) = 2 
		) T on (t.ID_AUTA = a.ID_AUTA)
/*
ID_AUTA     ile z tego ma MARKA                MODEL
----------- ------------- -------------------- --------------------
1           2             Ford                 Mustang
*/
	  
/*  Auta spe³niaj¹ce punkt 3 lub chocia¿ jedno z tych dwóch */
SELECT t.ID_AUTA
,	t.[ile z tego ma]
,	a.MARKA
,	a.MODEL
	FROM auta a
	join (SELECT w.ID_AUTA
			,	COUNT(DISTINCT w.WYP) AS [ile z tego ma]
		FROM wypas w
		WHERE w.WYP IN ('AC','NAVI')
		GROUP BY w.ID_AUTA
		) T on (t.ID_AUTA = a.ID_AUTA)
	ORDER BY 2 DESC
	
/*
ID_AUTA     ile z tego ma MARKA                MODEL
----------- ------------- -------------------- --------------------
1           2             Ford                 Mustang
2           1             Tesla                Roadster
*/

/*statystyki, ile ka¿dych wyposa¿eñ maj¹ nasze auta ( w tym zero) */

SELECT t.ID_AUTA
,	t.[ile z tego ma]
,	a.MARKA
,	a.MODEL
	FROM auta a
	join (SELECT w.ID_AUTA
			,	COUNT(DISTINCT w.WYP) AS [ile z tego ma]
		FROM wypas w
		WHERE w.WYP IS NOT NULL
		GROUP BY w.ID_AUTA
		) T on (t.ID_AUTA = a.ID_AUTA)

UNION ALL

SELECT A.ID_AUTA
,	CONVERT(int, 0) as [ile z tego ma]
,	a.MARKA
,	a.MODEL
	FROM auta a
	WHERE NOT EXISTS
		(
			SELECT 1
				FROM WYPAS w
				WHERE(W.ID_AUTA = A.ID_AUTA)
		)

/*
ID_AUTA     ile z tego ma MARKA                MODEL
----------- ------------- -------------------- --------------------
1           3             Ford                 Mustang
2           2             Tesla                Roadster
3           0             BMW                  i8
4           0             Lamborghini          Huracan
5           0             Tesla                Cybertruck */

/*pokazaæ najwiêksz¹ liczbê wyposa¿eñ jakie ma dane auto - który samochód tyle ma (use FA)  */
SELECT MAX(t.[ile z tego ma]) as [najwiecej wyposazen]
		into #x
		FROM wypas w
		join (SELECT wX.ID_AUTA
			,	COUNT(DISTINCT wX.WYP) AS [ile z tego ma]
				FROM wypas wX
				GROUP BY wX.id_auta) T on T.id_auta = w.id_auta 

--dowiazujê to do danych auta, ktore ma tyle samo count distinct wyp, dla wygody schowam sobie w kolejnej tabeli */
SELECT w.ID_AUTA
		,COUNT(DISTINCT w.WYP) AS [ile z tego ma]
		into #y
		FROM wypas w
		WHERE w.WYP IS NOT NULL
		GROUP BY w.ID_AUTA

SELECT a.ID_AUTA
,	a.MARKA
,	a.MODEL
,	#x.[najwiecej wyposazen]
	FROM auta a
	join #y on a.ID_AUTA = #y.ID_AUTA
	join #x on #y.[ile z tego ma] = #x.[najwiecej wyposazen]

drop table #x	
drop table #y
	
