/* usuwanie tabel w odwrotnej kolejnosci do ich tworzenia */
IF OBJECT_ID('dbo.ETATY') IS NOT NULL
BEGIN
    DROP TABLE ETATY
END
GO

IF OBJECT_ID('dbo.OSOBY') IS NOT NULL
BEGIN
	DROP TABLE OSOBY
END
GO

IF OBJECT_ID('dbo.FIRMY') IS NOT NULL
BEGIN
    DROP TABLE FIRMY
END
GO

IF OBJECT_ID('dbo.MIASTA') IS NOT NULL
BEGIN
	DROP TABLE MIASTA
END
GO

IF OBJECT_ID('dbo.WOJ') IS NOT NULL
BEGIN
	DROP TABLE WOJ
END
GO

/*tworzenie tabeli dla wojewodztw */
CREATE TABLE dbo.WOJ
(	KOD_WOJ NCHAR(10) NOT NULL
	/* CONSTRAINT Nazwa TYP [ew parametry] */
		CONSTRAINT PK_WOJ PRIMARY KEY
,	NAZWA NVARCHAR(40) NOT NULL
)
GO

/*tworzenie tabeli dla miast */
CREATE TABLE dbo.MIASTA
(	ID_MIASTA INT NOT NULL IDENTITY /*samonum*/ CONSTRAINT PK_MIASTA PRIMARY KEY
,	KOD_WOJ NCHAR(10) NOT NULL
		CONSTRAINT FK_MIASTA__WOJ FOREIGN KEY
		REFERENCES WOJ(KOD_WOJ)
,	NAZWA NVARCHAR(40)	NOT NULL
)
GO

/*tworzenie tabeli dla osob */
CREATE TABLE dbo.OSOBY
(
    /* primary key id_osoby, id_miasta, imie, nazwisko, imie_i_nazwisko */
    ID_OSOBY INT NOT NULL IDENTITY CONSTRAINT PK_OSOBY PRIMARY KEY
,   ID_MIASTA INT NOT NULL
        CONSTRAINT FK_OSOBY_MIASTA FOREIGN KEY
        REFERENCES MIASTA(ID_MIASTA)
,   IMIE NVARCHAR(40) NOT NULL
,   NAZWISKO NVARCHAR(40) NOT NULL
,   IMIE_I_NAZWISKO as CONVERT(NVARCHAR(80), IMIE + ' ' + NAZWISKO)
)
GO

/*tworzenie tabeli dla firm */
CREATE TABLE dbo.FIRMY
(
/* nazwa_skr(PK), id_miasta(FK), nazwa, kod_pocztowy,  ulica */
    NAZWA_SKR NCHAR(10) NOT NULL CONSTRAINT PK_FIRMY PRIMARY KEY
,   ID_MIASTA INT NOT NULL
        CONSTRAINT FK_FIRMY_MIASTA FOREIGN KEY
        REFERENCES MIASTA(ID_MIASTA)
,   NAZWA NVARCHAR(40) NOT NULL
,   KOD_POCZTOWY NCHAR(10) NOT NULL
,   ULICA NVARCHAR(40) NOT NULL
)
GO

/*tworzenie tabeli dla etatow */
CREATE TABLE dbo.ETATY
(
/* id_osoby(FK), id_firmy, stanowisko, pensja, od, do, id_etatu(PK) */
    ID_ETATU INT NOT NULL IDENTITY CONSTRAINT PK_ETATY PRIMARY KEY
,   ID_OSOBY INT NOT NULL
        CONSTRAINT FK_ETATY_OSOBY FOREIGN KEY
        REFERENCES OSOBY(ID_OSOBY)
,	ID_FIRMY NCHAR(10) NOT NULL
		CONSTRAINT FK_ETATY_FIRMY FOREIGN KEY
		REFERENCES FIRMY(NAZWA_SKR)
,   STANOWISKO NCHAR(20) NOT NULL
,   PENSJA MONEY NOT NULL
,   OD DATETIME NOT NULL
,   DO DATETIME NULL
)
GO

/* deklarowanie zmiennych dla osób i miast */ 
DECLARE @K int /* id miasta Kraków */
,		@T int /* id miasta Tarnów */
,		@W int /* id miasta Weso³a */
,		@S int /* id miasta Starogard */
,		@G int /* id miasta Gdañsk */
,		@R int /* id miasta Radom */
,		@C int /* id miasta Czêstochowa */
,		@B int /* id miasta Bydgoszcz */
,		@Z int /* id miasta Zielona Góra */
,		@P int /* id miasta Poznañ */
,		@£ int /* id miasta £ódŸ */
,		@O int /* id miasta Opole */
,		@D int /* id miasta Dêblin */

,		@o1 int /* id osoby 1 */
,		@o2 int /* id osoby 2 */
,		@o3 int /* id osoby 3 */
,		@o4 int /* id osoby 4 */
,		@o5 int /* id osoby 5 */
,		@o6 int /* id osoby 6 */
,		@o7 int /* id osoby 7 */
,		@o8 int /* id osoby 8 */
,		@o9 int /* id osoby 9 */
,		@o10 int /* id osoby 10 */
,		@o11 int /* id osoby 11 */
,		@o12 int /* id osoby 12 */
,		@o13 int /* id osoby 13 */
,		@o14 int /* id osoby 14 */
,		@o15 int /* id osoby 15 */
,		@o16 int /* id osoby 16 */
,		@o17 int /* id osoby 17 */
,		@o18 int /* id osoby 18 */
,		@o19 int /* id osoby 19 */
,		@o20 int /* id osoby 20 */
,		@o21 int /* id osoby 21 */

/* wstawianie rekordów województw */
INSERT INTO woj (kod_woj, nazwa) VALUES ('MAL', 'Ma³opolska')
INSERT INTO woj (kod_woj, nazwa) VALUES ('MAZ', 'Mazowieckie')
INSERT INTO woj (kod_woj, nazwa) VALUES ('POM', 'Pomorskie')
INSERT INTO woj (kod_woj, nazwa) VALUES ('POD', 'Podlaskie')
INSERT INTO woj (kod_woj, nazwa) VALUES ('LOD', '£ódzkie')


/* wstawianie rekordów miast - woj podlaskie i ³ódzkie zostaj¹ bez miast*/
INSERT INTO miasta (kod_woj, nazwa) VALUES ('MAL', 'Kraków')
SET @K = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('MAL', 'Tarnów')
SET @T = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('MAZ', 'Weso³a')
SET @W = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('POM', 'Starogard')
SET @S = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('POM', 'Gdañsk')
SET @G = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('MAL', 'Czêstochowa')
SET @C = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('POM', 'Bydgoszcz')
SET @B = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('MAZ', 'Zielona Góra')
SET @Z = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('POM', 'Poznañ')
SET @P = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('POM', '£ódŸ')
SET @£ = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('POM', 'Opole')
SET @O = SCOPE_IDENTITY()
INSERT INTO miasta (kod_woj, nazwa) VALUES ('MAZ', 'Dêblin')
SET @D = SCOPE_IDENTITY()

/*wstawianie rekordów osób w 8 miast*/
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@K, 'Ji-sung','Park')
SET @o1 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@T, 'Tae-in','Moon') 
SET @o2 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@W, 'John','Seo')
SET @o3 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@S, 'Lee','Taeyong')
SET @o4 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@G, 'Yuta','Nakamoto')
SET @o5 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@D, 'Quiab','Kun')
SET @o6 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@B, 'Dong-young','Kim')
SET @o7 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@Z, 'Chittaphon','Leechaiyaponkul')
SET @o8 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@K, 'Yoon-oh','Jung')
SET @o9 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@T, 'Sicheng','Dong')
SET @o10 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@W, 'Kim','Jung-woo')
SET @o11 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@S, 'Yuk-hei','Wong')
SET @o12 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@G, 'Mark','Lee')
SET @o13 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@D, 'Xiao','De Jun')
SET @o14 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@B, 'Kunhang','Wong')
SET @o15 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@Z, 'Ren Jun','Huang')
SET @o16 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@K, 'Je-no','Lee')
SET @o17 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@T, 'Dong-hyuk','Lee')
SET @o18 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@W, 'Jae-min','Na')
SET @o19 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@S, 'Yangyang','Liu')
SET @o20 = SCOPE_IDENTITY()
INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (@G, 'Chenle','Zong')
SET @o21 = SCOPE_IDENTITY()

/* wstawianie rekordów 5 firm - nazwa_skr(PK), id_miasta(FK), nazwa, kod_pocztowy,  ulica*/
INSERT INTO FIRMY (NAZWA_SKR, ID_MIASTA, NAZWA, KOD_POCZTOWY, ULICA ) VALUES ('SM', @K, 'SM Entertainment', 'PL9 8FD', 'Lisia')
INSERT INTO FIRMY (NAZWA_SKR, ID_MIASTA, NAZWA, KOD_POCZTOWY, ULICA ) VALUES ('BH', @S, 'Big Hit Entertainment', 'PL30 3PA', 'Francuska')
INSERT INTO FIRMY (NAZWA_SKR, ID_MIASTA, NAZWA, KOD_POCZTOWY, ULICA ) VALUES ('YG', @W, 'YG Entertainment', 'PL16 0LD', '£¹kowa')
INSERT INTO FIRMY (NAZWA_SKR, ID_MIASTA, NAZWA, KOD_POCZTOWY, ULICA ) VALUES ('TM', @B, 'Top Media', 'PL15 9TP', 'Ho¿a')
INSERT INTO FIRMY (NAZWA_SKR, ID_MIASTA, NAZWA, KOD_POCZTOWY, ULICA ) VALUES ('JYP', @Z, 'JYP Entertainment', 'PL9 7LW', 'Wschodnia')


/* wstawianie rekordów 26 etatów */
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@o1, 'BH','producent', 11000,  CONVERT(datetime, '20100913', 112), CONVERT(datetime, '20151020', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@o2, 'SM','kompozytor', 9000,  CONVERT(datetime, '20090112', 112), CONVERT(datetime, '20120213', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@o3, 'YG','kompozytor', 10000,  CONVERT(datetime, '20141010', 112), CONVERT(datetime, '20200103', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@o4, 'TM','dyrektor kreatywny', 20500,  CONVERT(datetime, '20090212', 112), CONVERT(datetime, '20150812', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (@o5, 'JYP','asystent finansowy', 7000,  CONVERT(datetime, '20150415', 112), CONVERT(datetime, '20190321', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o6, 'BH','producent', 8000,  CONVERT(datetime, '20130412', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o7, 'SM','producent', 8500,  CONVERT(datetime, '20170815', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o8, 'YG','dŸwiêkowiec', 7950,  CONVERT(datetime, '20160115', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o9, 'TM','technik', 6700,  CONVERT(datetime, '20180202', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o10, 'JYP','technik', 7100,  CONVERT(datetime, '20170525', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o11, 'BH','technik', 5985,  CONVERT(datetime, '20160930', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o12, 'SM','technik', 7050,  CONVERT(datetime, '20121111', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o13, 'YG','menad¿er', 12000,  CONVERT(datetime, '20171203', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o14, 'TM','menad¿er', 13500,  CONVERT(datetime, '20170315', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o15, 'JYP','menad¿er', 14200,  CONVERT(datetime, '20180115', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o16, 'BH','menad¿er', 11390,  CONVERT(datetime, '20170921', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o17, 'SM','menad¿er', 12540,  CONVERT(datetime, '20160601', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o18, 'YG','menad¿er', 10100,  CONVERT(datetime, '20150105', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o19, 'TM','menad¿er', 14230,  CONVERT(datetime, '20200212', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o20, 'JYP','menad¿er', 12345,  CONVERT(datetime, '20180226', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o21, 'BH','asystent finansowy', 5500,  CONVERT(datetime, '20190406', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o1, 'SM','producent', 14000,  CONVERT(datetime, '20151120', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o2, 'YG','kompozytor', 13000,  CONVERT(datetime, '20120217', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o3, 'TM','kompozytor', 15000,  CONVERT(datetime, '20200110', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o4, 'JYP','menad¿er', 23400,  CONVERT(datetime, '20150922', 112))
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o5, 'BH','sekretarz', 8500,  CONVERT(datetime, '20190421', 112))


ALTER TABLE firmy ADD data_wpisu datetime NOT NULL DEFAULT GETDATE()
GO

UPDATE firmy SET data_wpisu = CONVERT(datetime,'19990321',112 /*format YYYYMM*/)
	WHERE nazwa_skr = 'BH'
GO
UPDATE firmy SET data_wpisu = CONVERT(datetime,'20180321',112 /*format YYYYMM*/)
	WHERE nazwa_skr = 'YG'
GO

ALTER TABLE osoby ADD date_ur datetime NULL
GO

UPDATE osoby SET date_ur = CONVERT(datetime,'19890321',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '1'
UPDATE osoby SET date_ur = CONVERT(datetime,'19970901',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '2'
UPDATE osoby SET date_ur = CONVERT(datetime,'19730126',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '3'
UPDATE osoby SET date_ur = CONVERT(datetime,'19720406',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '4'
UPDATE osoby SET date_ur = CONVERT(datetime,'20000115',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '5'
UPDATE osoby SET date_ur = CONVERT(datetime,'19870321',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '6'
UPDATE osoby SET date_ur = CONVERT(datetime,'20020226',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '7'
UPDATE osoby SET date_ur = CONVERT(datetime,'19850302',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '8'
UPDATE osoby SET date_ur = CONVERT(datetime,'19840218',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '9'
UPDATE osoby SET date_ur = CONVERT(datetime,'19930309',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '10'
UPDATE osoby SET date_ur = CONVERT(datetime,'19940912',112 /*format YYYYMM*/)
	WHERE ID_OSOBY = '11'

UPDATE osoby SET id_miasta = '4' 
	WHERE ID_OSOBY = '1'

UPDATE osoby SET id_miasta = '4' 
	WHERE ID_OSOBY = '6'

UPDATE osoby SET id_miasta = '4' 
	WHERE ID_OSOBY = '11'




SELECT COUNT(*) AS [liczba Etatów == liczba wierszy w tabeli]
	FROM Etaty

/*
liczba Etatów == liczba wierszy w tabeli
----------------------------------------
26*/

SELECT	COUNT(*)					AS [liczba Etatów ID1]
,		COUNT(DISTINCT e.id_osoby)	AS [ile ró¿nych osób ??]
,		MAX(LEFT(e.pensja, 15))			AS [jaka najw pensja]
,		MIN(LEFT(e.pensja, 15))			AS [jaka najm pensja]
,		SUM(CASE WHEN e.do IS NULL THEN 1 ELSE 0 END)
									AS [liczba Akt etatów]
,		SUM(CASE WHEN e.do IS NULL THEN e.pensja  ELSE 0 END)
									AS [suma z Akt et]
	FROM Etaty e
	/* tylko etaty osoby o ID=1 */
	WHERE (e.id_osoby = 1)
/*
liczba Etatów ID1 ile ró¿nych osób ?? jaka najw pensja jaka najm pensja liczba Akt etatów suma z Akt et
----------------- ------------------- ---------------- ---------------- ----------------- ---------------------
2                 1                   14000.00         11000.00         1                 14000,00			*/

SELECT	COUNT(*)		AS [liczba wierszy]
,		SUM(e.pensja)	AS [suma pensji]
,		MAX(e.pensja)	AS [maxPensja]
	FROM etaty e
	WHERE 1 = 2 
/*
liczba wierszy suma pensji           maxPensja
-------------- --------------------- ---------------------
0              NULL                  NULL */

SELECT COUNT(*)			AS [ile etatow]
,		MAX(e.pensja)	AS [maxPensja]
	FROM etaty e
	join osoby o	ON (e.id_osoby = o.id_osoby)
	join miasta mO	ON (o.id_miasta = mO.id_miasta)
	WHERE (mO.kod_woj = 'MAZ')

/*
ile etatow  maxPensja
----------- ---------------------
6           15000,00			*/

/*SELECT	MAX(e.pensja)	AS maxPensja
	,	e.id_osoby		AS [kto najwiecej zarabia]
	FROM etaty e

Msg 8120, Level 16, State 1, Line 48
Column 'etaty.id_osoby' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.*/





SELECT MAX(e.pensja) AS maxP
	INTO #MP
	FROM etaty e
/* w tabeli #MP zapisaliœmy jaka to jest ta najwieksza pensja */

SELECT p.* FROM #MP p
/* teraz pokazujemy kto j¹ ma ³¹cz¹c #MP z ETATY */
SELECT e.id_osoby, e.id_firmy, e.pensja 
	FROM etaty e
	join #MP p ON (p.maxP = e.pensja) 
DROP TABLE #MP
GO
/*
(1 row affected)
maxP
---------------------
23400,00

(1 row affected)

id_osoby    id_firmy   pensja
----------- ---------- ---------------------
4           JYP        23400,00 */





SELECT e.id_osoby, e.pensja, e.id_firmy 
	FROM etaty e
	WHERE e.pensja = 
			/* podzapytanie które moze wybrac TYLKO jedn¹ wartoœæ */
			(SELECT MAX(eW.pensja) 
				FROM etaty eW /* aby odró¿niæ od tabeli e z zapytania g³ownego */
			)
/*
id_osoby    pensja                id_firmy
----------- --------------------- ----------
4           23400,00              JYP       */






SELECT e.id_osoby, e.pensja, e.id_firmy --e.pensja == t.mp: nie ma wiecej warunkow potrzebnych!
	FROM etaty e
	/* zamiast dodawaæ kolejn¹ tabelê, dodamy wynik zapytania */
	join (SELECT MAX(eW.pensja) AS mp
				FROM etaty eW /* aby odró¿niæ od tabeli e z zapytania g³ownego */
			) t /* tak nazwiemy wynik */
	/* podajemy warunek ³aczacy tabele/zapytania */
				ON (e.pensja = t.mp)

/*
id_osoby    pensja                id_firmy
----------- --------------------- ----------
4           23400,00              JYP   */





/* PRACA DOMOWA CZÊŒÆ DRUGA
b)	Stworzyæ zapytanie znajduj¹ce w mieœcie na literê W najwiêksz¹ pensjê. 
Proszê pokazaæ kto tyle zarabia (miasto na W z miasta gdzie OSOBA mieszka)*/

SELECT MAX(e.pensja) AS maxP
	INTO #MP
	FROM etaty e
		join osoby o	ON (e.id_osoby = o.id_osoby)
		join miasta mO	ON (o.id_miasta = mO.id_miasta)
	WHERE (mO.nazwa = 'Weso³a') 
GO

SELECT 
		e.pensja
		, convert(nchar(15),LEFT(o.IMIE_I_NAZWISKO,20) )	AS imie_i_nazwisko
		, CONVERT(nchar(10), LEFT(mO.nazwa, 10) )			AS miasto

	FROM etaty e
	join #MP p ON (p.maxP = e.pensja) 
	join osoby o ON (e.id_osoby = o.id_osoby) /* warunek z klucza obcego ³acz¹cy etaty z osoby */
	join miasta mO /* miasta zwi¹zane z osobami */
		ON (mO.id_miasta = o.id_miasta) /* miasto gdzie mieszka osoba */
DROP TABLE #MP

/*
pensja                imie_i_nazwisko miasto
--------------------- --------------- ----------
15000,00              John Seo        Weso³a   */

--kolejna metoda, przez WHERE

SELECT 
		e.pensja
		, convert(nchar(15),LEFT(o.IMIE_I_NAZWISKO,20) )	AS imie_i_nazwisko
		, CONVERT(nchar(10), LEFT(mO.nazwa, 10) )			AS miasto

	FROM etaty e
		join osoby o ON (e.id_osoby = o.id_osoby) /* warunek z klucza obcego ³acz¹cy etaty z osoby */
		join miasta mO ON (mO.id_miasta = o.id_miasta) /* miasto gdzie mieszka osoba */
	WHERE e.pensja =
			(SELECT MAX(eW.pensja) 
				FROM etaty eW /* aby odró¿niæ od tabeli e z zapytania g³ownego */
					join osoby oW	ON (eW.id_osoby = oW.id_osoby) --super wa¿ne, ¿eby dobrze powi¹zaæ tutaj!!!!!
					join miasta mOW	ON (oW.id_miasta = mOW.id_miasta)
				WHERE (mOW.nazwa = 'Weso³a')
			)
/*
pensja                imie_i_nazwisko miasto
--------------------- --------------- ----------
15000,00              John Seo        Weso³a     */

-- ostania próba, podzapytanie w FROM

SELECT 
		e.pensja
		, convert(nchar(15),LEFT(o.IMIE_I_NAZWISKO,20) )	AS imie_i_nazwisko
		, CONVERT(nchar(10), LEFT(mO.nazwa, 10) )			AS miasto

	FROM etaty e
		join osoby o ON (e.id_osoby = o.id_osoby) 
		join miasta mO ON (mO.id_miasta = o.id_miasta)
		join (SELECT MAX(eW.pensja) AS mp
			FROM etaty eW 
					join osoby oW	ON (eW.id_osoby = oW.id_osoby)
					join miasta mOW	ON (oW.id_miasta = mOW.id_miasta)
				WHERE (mOW.nazwa = 'Weso³a')
		) t ON (e.pensja = t.mp)
		WHERE (mO.nazwa = 'Weso³a') -- bardzo wa¿ne dla pkt 3!!! 


/*c)	Proszê dodaæ tak¹ sam¹ pensjê na etacie osoby mieszkaj¹cej w innym mieœcie (nie na literê W). 
Proszê sprawdziæ ponownie czy pokazujecie Pañstwo TYLKO etaty z miasta W wyniku 
(czyli szukacie MAX z miasta na W ale czy pokazujecie MAX w wyniku ju¿ tylko z tego miasta)
*/


DECLARE @max_pensja money
set @max_pensja = 
			(SELECT MAX(e.pensja)
					FROM etaty e
						join osoby o ON (e.id_osoby = o.id_osoby) 
						join miasta mO ON (mO.id_miasta = o.id_miasta)
					WHERE (mO.nazwa = 'Weso³a')
			)

INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (6, 'BH','sekretarz', @max_pensja,  CONVERT(datetime, '20190421', 112))

SELECT e.ID_OSOBY, e.PENSJA, m.NAZWA
	from ETATY e, MIASTA m, OSOBY o
	where 
		e.ID_OSOBY = o.ID_OSOBY AND o.ID_MIASTA = m.ID_MIASTA AND
		e.ID_OSOBY = 6

/*
WIDAÆ ZATEM ¯E TA OSOBA DOSTA£A KOLEJNY ETAT, Z ODPOWIEDNI¥ PENSJ¥, I NIE JEST Z WESO£EJ
UWAGA, INSERT WYKONA SIÊ ZA KA¯DYM URUCHOMIENIEM SKRYPTU - WIÊC ODPALAJ¥C TYLKO TEN SKRYPT (BEZ ODTWARZANIA TABEL OD NOWA) WIELOKTRONIE, NAMNO¯¥ SIÊ REKORDY 


ID_OSOBY    PENSJA                NAZWA
----------- --------------------- ----------------------------------------
6           8000,00               Starogard
6           15000,00              Starogard								*/


--sprawdzenie 

SELECT 
		e.pensja
		, convert(nchar(15),LEFT(o.IMIE_I_NAZWISKO,20) )	AS imie_i_nazwisko
		, CONVERT(nchar(10), LEFT(mO.nazwa, 10) )			AS miasto

	FROM etaty e
		join osoby o ON (e.id_osoby = o.id_osoby) 
		join miasta mO ON (mO.id_miasta = o.id_miasta)
		join (SELECT MAX(eW.pensja) AS mp
			FROM etaty eW 
					join osoby oW	ON (eW.id_osoby = oW.id_osoby)
					join miasta mOW	ON (oW.id_miasta = mOW.id_miasta)
				WHERE (mOW.nazwa = 'Weso³a')
		) t ON (e.pensja = t.mp)
		WHERE (mO.nazwa = 'Weso³a') 

/* 
pensja                imie_i_nazwisko miasto
--------------------- --------------- ----------
15000,00              John Seo        Weso³a    */


