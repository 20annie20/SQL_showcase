/*A)	Szukamy MAX pensje osoby z miasta o nazwie na W (mo¿e byæ dowolna literka dla której macie najwiêcej danych)
a.	Pokazujemy kto i w jakiej firmie ma takow¹ pensjê i w jakim mieœcie mieszka */

--na pocz¹tek sprawdzam jakie firmy s¹ w mieœcie na W, chcê siê upewniæ czy max pensja bedzie dobrze pokazana
SELECT m.NAZWA, f.NAZWA FROM firmy f
	join MIASTA m ON (m.ID_MIASTA = f.ID_MIASTA)
--¿eby by³o ciekawiej, zmieniam po³o¿enie jakiejœ firmy, aby by³y dwie w mieœcie
UPDATE firmy SET id_miasta = 3
	WHERE nazwa_skr = 'BH'
GO
--wyszukujê pensje wszystkich osób w tym mieœcie
SELECT e.ID_OSOBY, e.ID_FIRMY, f.ID_MIASTA, e.pensja
	FROM ETATY e
	join FIRMY f ON (e.ID_FIRMY = f.NAZWA_SKR)
	WHERE f.ID_MIASTA = 3
/* jak widaæ jest teraz tych osób ca³kiem sporo
ID_OSOBY    ID_FIRMY   ID_MIASTA   pensja
----------- ---------- ----------- ---------------------
1           BH         3           11000,00
3           YG         3           10000,00
6           BH         3           8000,00
8           YG         3           7950,00
11          BH         3           5985,00
13          YG         3           12000,00
16          BH         3           11390,00
18          YG         3           10100,00
21          BH         3           5500,00
2           YG         3           13000,00
5           BH         3           8500,00 */

--znajdujê maksymalne pensje w firmach, dla pewnoœci
DECLARE @id_firmy nchar(10)

DECLARE CC INSENSITIVE /* read only */ CURSOR FOR
	SELECT f.nazwa_skr FROM firmy f ORDER BY 1
OPEN CC
FETCH NEXT FROM CC INTO @id_firmy
 	
WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT T.[najwiêksza pensja]
	, f.nazwa_skr
	, f.nazwa
	, o.nazwisko 
	, CONVERT(nchar(6), e.do, 112) AS do_YYYMM
	FROM etaty e
	join osoby o ON (e.id_osoby = o.id_osoby)
	join firmy f ON (f.nazwa_skr = e.id_firmy)
	join (select MAX(eW.Pensja) AS [najwiêksza pensja] 
			FROM etaty eW
			WHERE	(eW.do is NULL)
			AND		(eW.id_firmy  = @id_firmy)
		) T ON	(T.[najwiêksza pensja] 
				= e.pensja)
		WHERE	(e.do is NULL)
		AND		(e.id_firmy  = @id_firmy)
	FETCH NEXT FROM CC INTO @id_firmy
END 

CLOSE CC /* zamykamy kursor */
DEALLOCATE CC /* niszczymy - zamkniety mozna otworzyc */

/* te, które nas interesuj¹:

najwiêksza pensja     nazwa_skr  nazwa                                    nazwisko                                 do_YYYMM
--------------------- ---------- ---------------------------------------- ---------------------------------------- --------
13000,00              YG         YG Entertainment                         Moon                                     NULL

najwiêksza pensja     nazwa_skr  nazwa                                    nazwisko                                 do_YYYMM
--------------------- ---------- ---------------------------------------- ---------------------------------------- --------
11390,00              BH         Big Hit Entertainment                    Huang                                    NULL */



--utrudniam jeszcze bardziej, zmieniê pensjê osoby w drugiej firmie równie¿ na równie wysok¹ co  MAX
UPDATE etaty SET pensja = 13000
	WHERE ID_OSOBY = '16'
GO
--sprawdzam jeszcze raz osoby:
/*
ID_OSOBY    ID_FIRMY   ID_MIASTA   pensja
----------- ---------- ----------- ---------------------
1           BH         3           11000,00
3           YG         3           10000,00
6           BH         3           8000,00
8           YG         3           7950,00
11          BH         3           5985,00
13          YG         3           12000,00
16          BH         3           13000,00
18          YG         3           10100,00
21          BH         3           5500,00
2           YG         3           13000,00
5           BH         3           8500,00		
jak widaæ, mamy dwie pensje równe max w ró¿nych firmach w tym mieœcie*/
DROP TABLE #MF
/*wyszukujê maksymalne pensje w ka¿dym mieœcie */
SELECT m.id_miasta, MAX(ew.PENSJA) AS NajwPensjaWmiescie
	INTO #MF
	FROM etaty eW
	join firmy fW ON (fW.nazwa_skr = eW.id_firmy)
	join miasta m ON (m.id_miasta = fW.id_miasta)
	WHERE eW.do is null
	GROUP BY m.id_miasta

Select * FROM #MF
/*pokazujê osoby z najwiêksz¹ pensj¹ dla firm w mieœcie na W*/
SELECT LEFT(o.nazwisko,20)	AS nazwisko
,	f.nazwa_skr 
,	LEFT(f.nazwa,20)		AS nazwa
,	STR(e.pensja,6,0)		AS pensja
,	CONVERT(nchar(6),e.do,112) AS do_YM
,	m.nazwa

	FROM etaty e
	join firmy f ON (f.nazwa_skr = e.id_firmy)
	join osoby o ON (e.id_osoby = o.id_osoby)
	join miasta m ON (m.id_miasta = f.id_miasta)
	join #MF T ON (T.NajwPensjaWmiescie = e.pensja AND m.id_miasta = 3)
	WHERE e.do is null

	/*Robimy kursor w ramach którego analizujemy firmy w 
	których pracuje osoba o ID = (ka¿dy wybiera tak¹, która ma sporo etatów w Waszej bazie). 
	Dla ka¿dej takiej firmy pokazujemy sumê pensji z etatów oraz liczbê etatów tej osoby w pokazywanej firmie*/

Select * from etaty
/*dodam dodatkowo etaty osobie z ID = 1, bo ma tylko dwa */

INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (1, 'BH','producent', 13000,  CONVERT(datetime, '20200329', 112), NULL)
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (1, 'BH','kompozytor', 9000,  CONVERT(datetime, '20200329', 112), NULL)
INSERT INTO ETATY ( ID_OSOBY,  ID_FIRMY, STANOWISKO, PENSJA, OD, DO) VALUES (1, 'JYP','producent', 10000,  CONVERT(datetime, '20180319', 112), NULL)

/* teraz ju¿ mo¿na zaj¹æ siê kursorem - firmy w których pracuje osoba z id = 1*/
DROP TABLE #EF
SELECT DISTINCT e.id_firmy INTO #EF FROM etaty e WHERE e.id_osoby = 1
SELECT * FROM #EF
--chodzimy kursorem po firmach
--w kazdej suma pensji  i ilosc etatow: aktywnych i ogó³em

DECLARE @id_firmy nchar(10)

DECLARE CC INSENSITIVE CURSOR FOR
	SELECT f.id_firmy FROM #EF f ORDER BY 1
OPEN CC
FETCH NEXT FROM CC INTO @id_firmy

WHILE @@FETCH_STATUS = 0
BEGIN
	select @id_firmy
	select count(*) AS [liczba etatow w firmie] 
,			SUM(CASE WHEN e.do IS NULL THEN 1 ELSE 0 END ) AS [liczba aktywnych etatów]
,			SUM(CASE WHEN e.do IS NULL THEN e.pensja ELSE 0 END ) AS [suma pensji]
		FROM ETATY e 
		WHERE (e.ID_OSOBY = 1)
		AND	(e.id_firmy  = @id_firmy)
	FETCH NEXT FROM CC INTO @id_firmy
END

CLOSE CC
DEALLOCATE CC

/*C)	Wykonaæ zapytanie z grupowaniem pokazuj¹ce iloœæ osób mieszkajacych 
w kazdym z województw (ma byæ woj.kod_woj, woj.nazwa, wyliczona_liczba_osob_mieszkajacych_w_tym_woj)*/

SELECT w.KOD_WOJ, w.NAZWA, COUNT(*) as [ile osob]
	FROM  woj w
	JOIN miasta m ON (m.KOD_WOJ = w.KOD_WOJ)
	JOIN osoby o ON (o.ID_MIASTA = m.ID_MIASTA) 
	GROUP BY w.KOD_WOJ, w.NAZWA