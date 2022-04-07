/*skuteczne tworzenie procedur*/
IF NOT EXISTS 
( SELECT 1 
	FROM sysobjects o
	WHERE	(o.[name] = 'CREATE_PROC')
		AND		(OBJECTPROPERTY(o.[ID], 'IsProcedure') = 1)
)
BEGIN
DECLARE @stmt nvarchar(256)
	SET @stmt= 'CREATE PROCEDURE dbo.CREATE_PROC AS'
	EXEC sp_sqlexec @stmt /* wykonaj polecenie */
END
GO

ALTER PROCEDURE dbo.CREATE_PROC( @name nvarchar(256) )
AS
	IF NOT EXISTS 
	( SELECT 1 
		FROM sysobjects o
		WHERE	(o.[name] = @name)
		AND		(OBJECTPROPERTY(o.[ID], 'IsProcedure') = 1)
	)	
	BEGIN
	DECLARE @stmt nvarchar(256)
	SET @stmt= 'CREATE PROCEDURE dbo.' + LTRIM(@name) + ' AS'
	EXEC sp_sqlexec @stmt /* wykonaj polecenie */
	END
GO
/*CW 1 - 1.	Napisaæ procedurê, która kasuje tabelê jak istnieje. 
Przerobiæ swój pierwszy skrypt. Mo¿na zrobiæ jak ja i wtedy parametrem OBJECTPROPERTY bêdzie ‘IsuserTable’. 
Taka procedura nie dzia³a dla #temp czyli TYMCZASOWYCH
a.	Ma te¿ kasowaæ a wczeœniej rozpoznawaæ czy tabela tymczasowa
i.	Mo¿ecie rozpoznawaæ czy nazwa tabeli to tymczasowa @nazwa LIKE ‘#%’ i wtedy inaczej j¹ sprawdzaæ
ii.	Wskazówka – tabele tymczasowe mieszkaj¹ w bazie tempdb, próbujcie ich szukaæ tam */


EXEC CREATE_PROC @name =  'PROC_DELETE_TABLE'
GO 

ALTER PROCEDURE dbo.PROC_DELETE_TABLE( @table nvarchar(256) ) 
AS
	/* proœciej zacz¹æ w ten sposób, ni¿ od tabeli bez wzorca nazwy, który mo¿emy podaæ w warunku */
	IF ( @table LIKE '#%' )  /* najpierw sprawdzam czy to tabela tymczasowa */
	BEGIN
		IF OBJECT_ID('tempdb..' + @table) IS NOT NULL  -- bez tego nie znajdziemy tabeli tymczasowej 
		BEGIN
			DECLARE @stmt1 nvarchar(256)
			SET @stmt1 = 'DROP TABLE ' + @table
			EXEC sp_sqlexec @stmt1 
		END
	END
	ELSE 
		IF OBJECT_ID('dbo.' + @table) IS NOT NULL 
		BEGIN
			DECLARE @stmt2 nvarchar(256)
			SET @stmt2 = 'DROP TABLE ' + @table 
			EXEC sp_sqlexec @stmt2
		END
GO

/*skrypt wykonuje siê bez b³êdu, zarówno dla zwyk³ych tabel, jak równie¿ dla tabel tymczasowych*/

CREATE TABLE #MP(ID INT NOT NULL)
GO
EXEC PROC_DELETE_TABLE @table = '#MP'
EXEC PROC_DELETE_TABLE @table = 'ETATY'
EXEC PROC_DELETE_TABLE @table = 'FIRMY'
EXEC PROC_DELETE_TABLE @table = 'OSOBY'
EXEC PROC_DELETE_TABLE @table = 'MIASTA'
EXEC PROC_DELETE_TABLE @table = 'WOJ'

----------------------------------DALSZA CZÊŒÆ ÆWICZENIA PO TREŒCI SKRYPTU PIERWSZEGO-----------
----------------------------------PIERWSZY SKRYPT (KONIEC OKO£O LINII 470)----------------------


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


/* sprawdzenie zawartoœci wszystkich tabel */
SELECT * FROM woj 
/* 
KOD_WOJ    NAZWA
---------- ----------------------------------------
LOD        £ódzkie
MAL        Ma³opolska
MAZ        Mazowieckie
POD        Podlaskie
POM        Pomorskie
*/

SELECT * FROM miasta 
/*
ID_MIASTA   KOD_WOJ    NAZWA
----------- ---------- ----------------------------------------
1           MAL        Kraków
2           MAL        Tarnów
3           MAZ        Weso³a
4           POM        Starogard
5           POM        Gdañsk
6           MAL        Czêstochowa
7           POM        Bydgoszcz
8           MAZ        Zielona Góra
9           POM        Poznañ
10          POM        £ódŸ
11          POM        Opole
12          MAZ        Dêblin 
*/

 SELECT * FROM osoby
 /*
(1 row affected)
ID_OSOBY    ID_MIASTA   IMIE                                     NAZWISKO                                 IMIE_I_NAZWISKO
----------- ----------- ---------------------------------------- ---------------------------------------- --------------------------------------------------------------------------------
1           1           Ji-sung                                  Park                                     Ji-sung Park
2           2           Tae-in                                   Moon                                     Tae-in Moon
3           3           John                                     Seo                                      John Seo
4           4           Lee                                      Taeyong                                  Lee Taeyong
5           5           Yuta                                     Nakamoto                                 Yuta Nakamoto
6           12          Quiab                                    Kun                                      Quiab Kun
7           7           Dong-young                               Kim                                      Dong-young Kim
8           8           Chittaphon                               Leechaiyaponkul                          Chittaphon Leechaiyaponkul
9           1           Yoon-oh                                  Jung                                     Yoon-oh Jung
10          2           Sicheng                                  Dong                                     Sicheng Dong
11          3           Kim                                      Jung-woo                                 Kim Jung-woo
12          4           Yuk-hei                                  Wong                                     Yuk-hei Wong
13          5           Mark                                     Lee                                      Mark Lee
14          12          Xiao                                     De Jun                                   Xiao De Jun
15          7           Kunhang                                  Wong                                     Kunhang Wong
16          8           Ren Jun                                  Huang                                    Ren Jun Huang
17          1           Je-no                                    Lee                                      Je-no Lee
18          2           Dong-hyuk                                Lee                                      Dong-hyuk Lee
19          3           Jae-min                                  Na                                       Jae-min Na
20          4           Yangyang                                 Liu                                      Yangyang Liu
21          5           Chenle                                   Zong                                     Chenle Zong
*/


SELECT * FROM firmy
/*
NAZWA_SKR  ID_MIASTA   NAZWA                                    KOD_POCZTOWY ULICA
---------- ----------- ---------------------------------------- ------------ ----------------------------------------
BH         4           Big Hit Entertainment                    PL30 3PA     Francuska
JYP        8           JYP Entertainment                        PL9 7LW      Wschodnia
SM         1           SM Entertainment                         PL9 8FD      Lisia
TM         7           Top Media                                PL15 9TP     Ho¿a
YG         3           YG Entertainment                         PL16 0LD     £¹kowa

*/

SELECT * FROM ETATY
/*
ID_ETATU    ID_OSOBY    ID_FIRMY   STANOWISKO           PENSJA                OD                      DO
----------- ----------- ---------- -------------------- --------------------- ----------------------- -----------------------
1           1           BH         producent            11000,00              2010-09-13 00:00:00.000 2015-10-20 00:00:00.000
2           2           SM         kompozytor           9000,00               2009-01-12 00:00:00.000 2012-02-13 00:00:00.000
3           3           YG         kompozytor           10000,00              2014-10-10 00:00:00.000 2020-01-03 00:00:00.000
4           4           TM         dyrektor kreatywny   20500,00              2009-02-12 00:00:00.000 2015-08-12 00:00:00.000
5           5           JYP        asystent finansowy   7000,00               2015-04-15 00:00:00.000 2019-03-21 00:00:00.000
6           6           BH         producent            8000,00               2013-04-12 00:00:00.000 NULL
7           7           SM         producent            8500,00               2017-08-15 00:00:00.000 NULL
8           8           YG         dŸwiêkowiec          7950,00               2016-01-15 00:00:00.000 NULL
9           9           TM         technik              6700,00               2018-02-02 00:00:00.000 NULL
10          10          JYP        technik              7100,00               2017-05-25 00:00:00.000 NULL
11          11          BH         technik              5985,00               2016-09-30 00:00:00.000 NULL
12          12          SM         technik              7050,00               2012-11-11 00:00:00.000 NULL
13          13          YG         menad¿er             12000,00              2017-12-03 00:00:00.000 NULL
14          14          TM         menad¿er             13500,00              2017-03-15 00:00:00.000 NULL
15          15          JYP        menad¿er             14200,00              2018-01-15 00:00:00.000 NULL
16          16          BH         menad¿er             11390,00              2017-09-21 00:00:00.000 NULL
17          17          SM         menad¿er             12540,00              2016-06-01 00:00:00.000 NULL
18          18          YG         menad¿er             10100,00              2015-01-05 00:00:00.000 NULL
19          19          TM         menad¿er             14230,00              2020-02-12 00:00:00.000 NULL
20          20          JYP        menad¿er             12345,00              2018-02-26 00:00:00.000 NULL
21          21          BH         asystent finansowy   5500,00               2019-04-06 00:00:00.000 NULL
22          1           SM         producent            14000,00              2015-11-20 00:00:00.000 NULL
23          2           YG         kompozytor           13000,00              2012-02-17 00:00:00.000 NULL
24          3           TM         kompozytor           15000,00              2020-01-10 00:00:00.000 NULL
25          4           JYP        menad¿er             23400,00              2015-09-22 00:00:00.000 NULL
26          5           BH         sekretarz            8500,00               2019-04-21 00:00:00.000 NULL
*/

-- PRÓBA WSTAWIENIA REKORDU DO ETATÓW OSOBY NIEISTNIEJ¥CEJ 

--INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (@o23, 'BH','sekretarz', 8500,  CONVERT(datetime, '20190421', 112))
/*
Msg 137, Level 15, State 2, Line 365
Must declare the scalar variable "@o23".
*/

-- **************TESTY PRAWID£OWOŒCI POWI¥ZAÑ**************


-- USUN OSOBE, KTORA JEST WCIAGNIETA W ETATY 

--DELETE FROM osoby WHERE id_osoby = 1
/*
Msg 547, Level 16, State 0, Line 351
The DELETE statement conflicted with the REFERENCE constraint "FK_ETATY_OSOBY". The conflict occurred in database "b_307393", table "dbo.ETATY", column 'ID_OSOBY'.
*/

-- KASOWANIE REKORDU NP Z WOJ - CZY SIE DA, JESLI SA MIASTA 

--DELETE FROM woj WHERE kod_woj = 'MAZ'
/*
Msg 547, Level 16, State 0, Line 359
The DELETE statement conflicted with the REFERENCE constraint "FK_MIASTA__WOJ". The conflict occurred in database "b_307393", table "dbo.MIASTA", column 'KOD_WOJ'. */

-- UWAGA - JESLI DANE WOJEWODZTWA NIE ZOSTA£Y U¯YTE DO UTWORZENIA REKORDÓW W INNYCH TABELACH, MO¯NA GO SKASOWAÆ, np:
--DELETE FROM WOJ WHERE KOD_WOJ = 'POD'

-- KASOWANIE REKORDU Z TABELI FIRM, JESLI JEST ONA POWIAZANA Z TABEL¥ ETATÓW 

--DELETE FROM FIRMY WHERE NAZWA_SKR = 'BH'
/*
Msg 547, Level 16, State 0, Line 374
The DELETE statement conflicted with the REFERENCE constraint "FK_ETATY_FIRMY". The conflict occurred in database "b_307393", table "dbo.ETATY", column 'ID_FIRMY'. 
 */

-- KASOWANIE REKORDU Z TABELI MIAST 

 --DELETE FROM MIASTA WHERE ID_MIASTA = 1
 /*
 Msg 547, Level 16, State 0, Line 387
The DELETE statement conflicted with the REFERENCE constraint "FK_OSOBY_MIASTA". The conflict occurred in database "b_307393", table "dbo.OSOBY", column 'ID_MIASTA'. */

-- DODAWANIE DANYCH Z NIEISTNIEJ¥CYMI KLUCZAMI OBCYMI - WSZYSTKIE POWI¥ZANIA DZIA£AJ¥ PRAWID£OWO

--INSERT INTO MIASTA (kod_woj, nazwa) VALUES ('POL', 'Bydgoszcz')

--Msg 547, Level 16, State 0, Line 393
--The INSERT statement conflicted with the FOREIGN KEY constraint "FK_MIASTA__WOJ". The conflict occurred in database "b_307393", table "dbo.WOJ", column 'KOD_WOJ'. 

--INSERT INTO OSOBY ( id_miasta, imie, nazwisko) VALUES (25, 'Ji-sung','Park') 
-- Msg 547, Level 16, State 0, Line 398
--The INSERT statement conflicted with the FOREIGN KEY constraint "FK_OSOBY_MIASTA". The conflict occurred in database "b_307393", table "dbo.MIASTA", column 'ID_MIASTA'. 

--INSERT INTO FIRMY (NAZWA_SKR, ID_MIASTA, NAZWA, KOD_POCZTOWY, ULICA ) VALUES ('DM', 25, 'SM Entertainment', 'PL9 8FD', 'Lisia')
--Msg 547, Level 16, State 0, Line 402
--The INSERT statement conflicted with the FOREIGN KEY constraint "FK_FIRMY_MIASTA". The conflict occurred in database "b_307393", table "dbo.MIASTA", column 'ID_MIASTA'. 

--INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD) VALUES (301, 'BH','sekretarz', 8500,  CONVERT(datetime, '20190421', 112))
--Msg 547, Level 16, State 0, Line 406
--The INSERT statement conflicted with the FOREIGN KEY constraint "FK_ETATY_OSOBY". The conflict occurred in database "b_307393", table "dbo.OSOBY", column 'ID_OSOBY'. */


-- DODAWANIE DANYCH O ISTNIEJ¥CYCH WARTOŒCIACH - SPRAWDZENIE WYMUSZENIA CONSTRAINT

--INSERT INTO FIRMY (NAZWA_SKR, ID_MIASTA, NAZWA, KOD_POCZTOWY, ULICA ) VALUES ('SM', @K, 'SM Entertainment', 'PL9 8FD', 'Lisia')
--Msg 2627, Level 14, State 1, Line 411
--Violation of PRIMARY KEY constraint 'PK_FIRMY'. Cannot insert duplicate key in object 'dbo.FIRMY'. The duplicate key value is (SM        ). */





-----------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------ZADANIE Z PROCEDURAMI C.D. ---------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------



/* 2.	Napisaæ procedurê do pokazywania aut maj¹cych zadane wyposa¿enia 
		a.	Dowolnoœæ przekazywania parametrow – mo¿e byæ jak w moim przyk³adzie przez tabelê tymczasow¹ */


EXEC PROC_DELETE_TABLE @table = '#wypas'
CREATE TABLE #wypas (WYP nchar(4) NOT NULL )
INSERT INTO #wypas (wyp) VALUES ('4x4'), ('AC')
SELECT * FROM #wypas

EXEC CREATE_PROC @name =  'PROC_CARS_WITH_CERT_EQUIP'
GO 

ALTER PROCEDURE dbo.PROC_CARS_WITH_CERT_EQUIP
AS
	DECLARE @n int
	SELECT @n = COUNT(DISTINCT w.WYP) from #wypas w

	SELECT a.id_auta, a.marka, a.model
		FROM auta a
		join (SELECT wA.id_auta, COUNT(DISTINCT	wA.wyp) AS zgodnoœæ
			FROM WYPAS wA
			join #wypas w ON (w.WYP = wA.WYP)
			GROUP BY wA.id_auta
			HAVING COUNT(DISTINCT wA.wyp) = @n
		) T ON (T.id_auta = a.id_auta)
GO

EXEC PROC_CARS_WITH_CERT_EQUIP
/* rezultatem jest: 
id_auta     marka                model
----------- -------------------- --------------------
2           Tesla                Roadster */

/*NIE PODOBA MI SIÊ JEDNAK NIEELASTYCZNOŒÆ TEJ PROCEDURY, CHCIA£ABYM PRZEKAZAÆ ZA KA¯DYM RAZEM TABELÊ 
JAKO PARAMETR TEJ PROCEDURY. Z ODROBIN¥ POMOCY WUJKA GOOGLE WYKOMBINOWA£AM COŒ TAKIEGO: */


/* tworzê sobie tabelê jako typ do przekazania */
IF EXISTS(
SELECT 1 FROM sys.table_types WHERE user_type_id = TYPE_ID(N'dbo.TableType')
    )
    BEGIN

    DROP TYPE TableType

    CREATE TYPE TableType AS TABLE
	(LocationName nchar(4))

   END
GO
/* WYGL¥DA NA TO ¯E DO TEJ PORY DZIA£A */

ALTER PROCEDURE dbo.PROC_CARS_WITH_CERT_EQUIP( @TableName TableType READONLY)
AS
	DECLARE @n int
	SELECT @n = COUNT(DISTINCT w.LocationName) from @TableName w

	SELECT a.id_auta, a.marka, a.model
		FROM auta a
		join (SELECT wA.id_auta, COUNT(DISTINCT	wA.wyp) AS zgodnoœæ
			FROM WYPAS wA
			join @TableName w ON (w.LocationName = wA.WYP)
			GROUP BY wA.id_auta
			HAVING COUNT(DISTINCT wA.wyp) = @n
		) T ON (T.id_auta = a.id_auta)
GO

DECLARE @wypas TableType
INSERT INTO @wypas(LocationName) VALUES('AC'), ('4x4')
EXEC PROC_CARS_WITH_CERT_EQUIP  @wypas


/* BOOM, DZIA£A! 


id_auta     marka                model
----------- -------------------- --------------------
2           Tesla                Roadster

ALE CZY TO WYGODNIEJSZE? MO¯E TROCHÊ, ZAMIAST ZMIENIAÆ TABELÊ #WYPAS, MO¯NA UTWORZYC OD
RAZU KILKA I TYLKO PODAWAÆ JE DO PROCEDURY */



/*3.	Napisaæ procedurê pokazuj¹c¹ listê firm i œredni¹ pensjê w tej firmie
	a.	Parametr id_miasta = tylko w tym miescie (jak null to wszystkich)
	b.	Drugi parametr kod_woj = tylko to WOJ. Jak NULL to wszystkie
	c.	Akt -> jak 0 to wszystkie pensje, jak 1 to tylko aktualne
	ALTER PROCEDURE dbo.PKT3 @id_miasta int=NULL, @kod_woj nchar(10) nul, @akt bit=0 */


EXEC CREATE_PROC @name = 'EXP_VAL_IN_COMPANIES'
GO

ALTER PROCEDURE dbo.EXP_VAL_IN_COMPANIES (@id_miasta int = NULL, @kod_woj nchar(10) = null, @akt bit = 0)
AS	
	IF (@kod_woj IS NULL)
	BEGIN
		IF (@id_miasta IS NULL)
			BEGIN
				SELECT f.nazwa, f.nazwa_skr, ROUND(T.[expected value],2) AS [œrednia_pensja], f.id_miasta, m.kod_woj
					FROM FIRMY f
					join MIASTA m ON (m.ID_MIASTA = f.ID_MIASTA)
					join (SELECT e.ID_FIRMY, AVG(e.PENSJA) AS [expected value]
					FROM (SELECT ew.*  							
						FROM ETATY ew
						WHERE (@akt = 0) OR ((@akt = 1) and (ew.DO is null))) e 
					GROUP BY e.ID_FIRMY
					) T ON (T.ID_FIRMY = f.NAZWA_SKR)
			END

		IF (@id_miasta IS NOT NULL)
			BEGIN
				SELECT f.nazwa, f.nazwa_skr, ROUND(T.[expected value],2) AS [œrednia_pensja], f.id_miasta, m.kod_woj
					FROM FIRMY f
					join MIASTA m ON (m.ID_MIASTA = f.ID_MIASTA)
					join (SELECT e.ID_FIRMY, AVG(e.PENSJA) AS [expected value]
						FROM (SELECT ew.*  						
							FROM ETATY ew
							WHERE (@akt = 0) OR ((@akt = 1) and (ew.DO is null))) e 
						GROUP BY e.ID_FIRMY
					) T ON (T.ID_FIRMY = f.NAZWA_SKR)
					where (f.ID_MIASTA = @id_miasta)
		END
	END

	IF (@kod_woj IS NOT NULL)
		BEGIN
			IF (@id_miasta IS NULL)
			BEGIN
				SELECT f.nazwa, f.nazwa_skr, ROUND(T.[expected value],2) AS [œrednia_pensja], f.id_miasta, m.kod_woj
					FROM FIRMY f
					join MIASTA m ON (m.ID_MIASTA = f.ID_MIASTA)
					join (SELECT e.ID_FIRMY, AVG(e.PENSJA) AS [expected value] 
						FROM (SELECT ew.*  								
							FROM ETATY ew
							WHERE (@akt = 0) OR ((@akt = 1) and (ew.DO is null))) e 
									GROUP BY e.ID_FIRMY
								 ) T ON (T.ID_FIRMY = f.NAZWA_SKR)
							WHERE (m.KOD_WOJ = @kod_woj)
			END

			IF (@id_miasta IS NOT NULL)
			BEGIN
				SELECT f.nazwa, f.nazwa_skr, ROUND(T.[expected value],2) AS [œrednia_pensja], f.id_miasta, m.kod_woj
					FROM FIRMY f
					join MIASTA m ON (m.ID_MIASTA = f.ID_MIASTA)
					join (SELECT e.ID_FIRMY, AVG(e.PENSJA) AS [expected value]
						FROM (SELECT ew.* 								
							FROM ETATY ew
								WHERE (@akt = 0) OR ((@akt = 1) and (ew.DO is null))) e 
								GROUP BY e.ID_FIRMY
							) T ON (T.ID_FIRMY = f.NAZWA_SKR)
						WHERE (f.ID_MIASTA = @id_miasta)
		END
	END

GO

EXEC EXP_VAL_IN_COMPANIES  @akt = 1
EXEC EXP_VAL_IN_COMPANIES 
EXEC EXP_VAL_IN_COMPANIES  @id_miasta = 3, @kod_woj = 'MAZ'
EXEC EXP_VAL_IN_COMPANIES  @kod_woj = 'MAL'
EXEC EXP_VAL_IN_COMPANIES  @id_miasta = 3, @kod_woj = 'MAZ', @akt = 1

/* no i wyniki :
nazwa                                    nazwa_skr  œrednia_pensja        id_miasta   kod_woj
---------------------------------------- ---------- --------------------- ----------- ----------
Big Hit Entertainment                    BH         7875,00               4           POM       
JYP Entertainment                        JYP        14261,25              8           MAZ       
SM Entertainment                         SM         10522,50              1           MAL       
Top Media                                TM         12357,50              7           POM       
YG Entertainment                         YG         10762,50              3           MAZ       

(5 rows affected)

nazwa                                    nazwa_skr  œrednia_pensja        id_miasta   kod_woj
---------------------------------------- ---------- --------------------- ----------- ----------
Big Hit Entertainment                    BH         8395,83               4           POM       
JYP Entertainment                        JYP        12809,00              8           MAZ       
SM Entertainment                         SM         10218,00              1           MAL       
Top Media                                TM         13986,00              7           POM       
YG Entertainment                         YG         10610,00              3           MAZ       

(5 rows affected)

nazwa                                    nazwa_skr  œrednia_pensja        id_miasta   kod_woj
---------------------------------------- ---------- --------------------- ----------- ----------
YG Entertainment                         YG         10610,00              3           MAZ       

(1 row affected)

nazwa                                    nazwa_skr  œrednia_pensja        id_miasta   kod_woj
---------------------------------------- ---------- --------------------- ----------- ----------
SM Entertainment                         SM         10218,00              1           MAL       

(1 row affected)

nazwa                                    nazwa_skr  œrednia_pensja        id_miasta   kod_woj
---------------------------------------- ---------- --------------------- ----------- ----------
YG Entertainment                         YG         10762,50              3           MAZ        */

