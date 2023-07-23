/* przygotowanie DB_STAT i DB_RCOUNT z wzorca skryptu, zadanie 1 zaczyna się od linii 67 */
IF NOT EXISTS (SELECT d.name 
					FROM sys.databases d 
					WHERE	(d.database_id > 4) -- systemowe mają ID poniżej 5
					AND		(d.[name] = N'DB_STAT')
)
BEGIN
	CREATE DATABASE DB_STAT
END
GO

USE DB_STAT
GO

IF NOT EXISTS 
(	SELECT 1
		from sysobjects o (NOLOCK)
		WHERE	(o.[name] = N'DB_STAT')
		AND		(OBJECTPROPERTY(o.[ID],N'IsUserTable')=1)
)
BEGIN
	/* czyszczenie jak trzeba od nowa
		DROP TABLE DB_RCOUNT
		DROP TABLE DB_FK
		DROP TABLE DB_STAT
	*/
	/*
	Tworzenie tabeli DB_STAT
	*/
	CREATE TABLE dbo.DB_STAT
	(	stat_id		int				NOT NULL IDENTITY /* samonumerująca kolumna */
			CONSTRAINT PK_DB_STAT PRIMARY KEY
	,	[db_nam]	nvarchar(20)	NOT NULL
	,	[comment]	nvarchar(20)	NOT NULL
	,	[when]		datetime		NOT NULL DEFAULT GETDATE()
	,	[usr_nam]	nvarchar(100)	NOT NULL DEFAULT USER_NAME()
	,	[host]		nvarchar(100)	NOT NULL DEFAULT HOST_NAME()
	)
END
GO

USE DB_STAT
GO

IF NOT EXISTS 
(	SELECT 1 
		from sysobjects o (NOLOCK)
		WHERE	(o.[name] = N'DB_RCOUNT')
		AND		(OBJECTPROPERTY(o.[ID], N'IsUserTable')=1)
)
BEGIN
	CREATE TABLE dbo.DB_RCOUNT
	(	stat_id		int				NOT NULL CONSTRAINT FK_DB_STAT__RCOUNT FOREIGN KEY
											REFERENCES dbo.DB_STAT(stat_id)
	,	[table]		nvarchar(100)	NOT NULL
	,	[RCOUNT]	int				NOT NULL DEFAULT 0
	,	[RDT]		datetime		NOT NULL DEFAULT GETDATE()
	)
END
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* 1. Stworzyć tabelę do przechowywania WSZYSTKICH kluczy obcych w danej bazie (połączona relacją z DB_STAT 
- dzięki relacji wiemy jaka to baza) */


/* Stworzenie tabeli DB_FK do przechowywania kluczy obcych */
USE DB_STAT
IF NOT EXISTS 
(	SELECT 1 
		from sysobjects o (NOLOCK)
		WHERE	(o.[name] = N'DB_FK')
		AND		(OBJECTPROPERTY(o.[ID], N'IsUserTable')=1)
)
BEGIN
	CREATE TABLE dbo.DB_FK
	(	fk_id		int				NOT NULL CONSTRAINT FK_DB_FK__RCOUNT FOREIGN KEY
											REFERENCES dbo.DB_STAT(stat_id)
	,	[constraint_name]	nvarchar(40)	NOT NULL
	,	[referencing_table_name]	nvarchar(40)	NOT NULL
	,	[referencing_column_name]		nvarchar(40)		NOT NULL 
	,	[referenced_table_name]	nvarchar(40)	NOT NULL 
	,	[referenced_column_name]		nvarchar(40)	NOT NULL
	)
END


/* Efekt utworzenia tabeli:
select * from DB_FK
fk_id       constraint_name                          referencing_table_name                   referencing_column_name                  referenced_table_name                    referenced_column_name
----------- ---------------------------------------- ---------------------------------------- ---------------------------------------- ---------------------------------------- ---------------------------------------- */


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


/* 2. Stworzyc procedurę do zapamiętania wszystkich kluczy obcych z wykorzystaniem tabel - patrz pkt 1 */

/* inicjalizacja procedury */
IF NOT EXISTS 
(	SELECT 1 
		from sysobjects o (NOLOCK)
		WHERE	(o.[name] = 'DB_FK_STORE')
		AND		(OBJECTPROPERTY(o.[ID],'IsProcedure')=1)
)
BEGIN
	DECLARE @stmt nvarchar(100)
	SET @stmt = 'CREATE PROCEDURE dbo.DB_FK_STORE AS '
	EXEC sp_sqlexec @stmt
END
GO

USE DB_STAT
GO

/* edycja właściwej logiki procedury do przechowywania kluczy */
ALTER PROCEDURE dbo.DB_FK_STORE (@db nvarchar(100), @commt nvarchar(20) = '<unkn>')
AS
	DECLARE @sql nvarchar(2000) -- tu będzie polecenie SQL wstawiajace wynik do tabeli
	,		@id int -- id nadane po wstawieniu rekordu do tabeli DB_STAT 
	,		@tab nvarchar(256) -- nazwa kolejnej tabeli
	,		@cID nvarchar(20) -- skonwertowane @id na tekst
	
	SET @db = LTRIM(RTRIM(@db)) -- usuwamy spacje początkowe i koncowe z nazwy bazy

	/* wstawiamy rekord do tabeli DB_STAT i zapamiętujemy ID jakie nadano nowemu wierszowi */
	INSERT INTO DB_STAT.dbo.DB_STAT (comment, db_nam) VALUES (@commt, @db)
	SET  @id = SCOPE_IDENTITY() -- jakie ID zostało nadane wstawionemu wierszowi
	/* tekstowo ID aby ciągle nie konwertować w pętli */
	SET @cID = RTRIM(LTRIM(STR(@id,20,0)))
	/* polecenie wydobywające informacje o kluczach i wstawiające je do tabeli DB_FK */
	SET @sql = N'USE [' + @db + N']; '
						+ N' INSERT INTO DB_STAT.dbo.DB_FK (fk_id, constraint_name, referencing_table_name, referencing_column_name, referenced_table_name, referenced_column_name) SELECT '
						+ @cID 
						+ N', f.name constraint_name'
						+ N',OBJECT_NAME(f.parent_object_id) referencing_table_name'
						+ N',COL_NAME(fc.parent_object_id, fc.parent_column_id) referencing_column_name'
						+ N',OBJECT_NAME (f.referenced_object_id) referenced_table_name'
						+ N',COL_NAME(fc.referenced_object_id, fc.referenced_column_id) referenced_column_name'
						+ N'	FROM sys.foreign_keys AS f'
						+ N'	JOIN sys.foreign_key_columns AS fc'
						+ N'	ON f.[object_id] = fc.constraint_object_id'
						+ N'	ORDER BY f.name '
	EXEC sp_sqlexec @sql
GO


/* test procedury */
USE DB_STAT

EXEC DB_STAT.dbo.DB_FK_STORE @commt = 'test zapisu kluczy', @db = N'pwx_db'

SELECT * FROM DB_FK
SELECT * FROM DB_STAT

/* wynik działania procedury - z id powiązanym z db_stat
fk_id       constraint_name                          referencing_table_name                   referencing_column_name                  referenced_table_name                    referenced_column_name
----------- ---------------------------------------- ---------------------------------------- ---------------------------------------- ---------------------------------------- ----------------------------------------
1           fk_miasta__woj                           miasta                                   kod_woj                                  woj                                      kod_woj
1           fk_osoby__miasta                         osoby                                    id_miasta                                miasta                                   id_miasta
1           fk_firmy__miasta                         firmy                                    id_miasta                                miasta                                   id_miasta
1           fk_etaty__osoby                          etaty                                    id_osoby                                 osoby                                    id_osoby
1           fk_etaty__firmy                          etaty                                    id_firmy                                 firmy                                    nazwa_skr
1           FK_WARTOSCI_CECHY__CECHY                 WARTOSCI_CECH                            id_CECHY                                 CECHY                                    id_CECHY
1           FK_FIRMY_CECHY__WARTOSCI_CECH            FIRMY_CECHY                              id_wartosci                              WARTOSCI_CECH                            id_wartosci

(7 rows affected)

Widzimy rekord dla wykonanej procedury w DB_STAT
stat_id     db_nam               comment              when                    usr_nam                                                                                              host
----------- -------------------- -------------------- ----------------------- ---------------------------------------------------------------------------------------------------- ----------------------------------------------------------------------------------------------------
1           pwx_db               test zapisu kluczy   2021-10-18 21:10:50.113 dbo                                                                                                  DESKTOP-V17D6KL
 */


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* 3. Procedura do kasowania kluczy obcych - najpierw uruchamia procedure z punktu 2, a następnie kasuje klucze */ 

/* inicjalizacja procedury */
IF NOT EXISTS 
(	SELECT 1 
		from sysobjects o (NOLOCK)
		WHERE	(o.[name] = 'DB_FK_DELETE')
		AND		(OBJECTPROPERTY(o.[ID],'IsProcedure')=1)
)
BEGIN
	DECLARE @stmt nvarchar(100)
	SET @stmt = 'CREATE PROCEDURE dbo.DB_FK_DELETE AS '
	EXEC sp_sqlexec @stmt
END
GO

USE DB_STAT
GO

/* edycja właściwej logiki procedury do kasowania kluczy obcych w bazie danych */
ALTER PROCEDURE dbo.DB_FK_DELETE (@db nvarchar(100), @commt nvarchar(20) = '<unkn>')
AS
    DECLARE @sql_tab TABLE(id int NOT NULL IDENTITY, sql_exec varchar(250) NOT NULL)
	DECLARE @sql_exec nvarchar(250)
	--najpier zapisuje klucze--
	EXEC DB_STAT.dbo.DB_FK_STORE @commt = 'zapis kluczy przed skasowaniem', @db = @db

	INSERT INTO DB_STAT.dbo.DB_STAT (comment, db_nam) VALUES (@commt, @db)
	--tworzę tabelę poleceń sql do wykonania dla każdej tabeli z kluczami obcymi--
	INSERT INTO @sql_tab
	SELECT
		'
		USE ' + @db + '
		ALTER TABLE [' + referencing_table_name + ']
		DROP CONSTRAINT ' + constraint_name
	FROM
		DB_FK as f
	WHERE fk_id IN
		(SELECT MAX(o.stat_id)
		FROM DB_STAT o
		WHERE o.[db_nam] = @db
		AND EXISTS ( SELECT 1 FROM db_fk f WHERE f.fk_id = o.stat_id))

	--następnie polecenia muszą zostać rzeczywiście wykonane, posługuję się więc pętlą--
	DECLARE @Counter INT , @MaxId INT, @sql NVARCHAR(250)
	SELECT @Counter = min(id) , @MaxId = max(id) 
	FROM @sql_tab
	
	WHILE(@Counter IS NOT NULL
		  AND @Counter <= @MaxId)
	BEGIN
		SET @sql = (
		SELECT sql_exec
		FROM @sql_tab WHERE id = @Counter
	    )
		SET @Counter  = @Counter  + 1     
		EXEC sp_sqlexec @sql
	END
GO

/* test procedury */
USE DB_STAT

EXEC DB_STAT.dbo.DB_FK_DELETE @commt = 'Usuwanie kluczy obcych', @db = N'pwx_db'

--upewnienie się, że klucze zostały zapisane przed skasowaniem, powinny być zapisane dwa razy, jeśli uruchomiłam cały skrypt na czystej DB_STAT:
/*
SELECT * FROM DB_FK

fk_id       constraint_name                          referencing_table_name                   referencing_column_name                  referenced_table_name                    referenced_column_name
----------- ---------------------------------------- ---------------------------------------- ---------------------------------------- ---------------------------------------- ----------------------------------------
1           fk_miasta__woj                           miasta                                   kod_woj                                  woj                                      kod_woj
1           fk_osoby__miasta                         osoby                                    id_miasta                                miasta                                   id_miasta
1           fk_firmy__miasta                         firmy                                    id_miasta                                miasta                                   id_miasta
1           fk_etaty__osoby                          etaty                                    id_osoby                                 osoby                                    id_osoby
1           fk_etaty__firmy                          etaty                                    id_firmy                                 firmy                                    nazwa_skr
1           FK_WARTOSCI_CECHY__CECHY                 WARTOSCI_CECH                            id_CECHY                                 CECHY                                    id_CECHY
1           FK_FIRMY_CECHY__WARTOSCI_CECH            FIRMY_CECHY                              id_wartosci                              WARTOSCI_CECH                            id_wartosci
2           fk_miasta__woj                           miasta                                   kod_woj                                  woj                                      kod_woj
2           fk_osoby__miasta                         osoby                                    id_miasta                                miasta                                   id_miasta
2           fk_firmy__miasta                         firmy                                    id_miasta                                miasta                                   id_miasta
2           fk_etaty__osoby                          etaty                                    id_osoby                                 osoby                                    id_osoby
2           fk_etaty__firmy                          etaty                                    id_firmy                                 firmy                                    nazwa_skr
2           FK_WARTOSCI_CECHY__CECHY                 WARTOSCI_CECH                            id_CECHY                                 CECHY                                    id_CECHY
2           FK_FIRMY_CECHY__WARTOSCI_CECH            FIRMY_CECHY                              id_wartosci                              WARTOSCI_CECH                            id_wartosci
*/

/* 
sprawdzenie czy operacje wpisane do DB_STAT

SELECT * FROM DB_STAT
stat_id     db_nam               comment              when                    usr_nam                                                                                              host
----------- -------------------- -------------------- ----------------------- ---------------------------------------------------------------------------------------------------- ----------------------------------------------------------------------------------------------------
1           pwx_db               test zapisu kluczy   2021-10-23 11:53:11.720 dbo                                                                                                  DESKTOP-V17D6KL
2           pwx_db               zapis kluczy przed s 2021-10-23 11:53:11.743 dbo                                                                                                  DESKTOP-V17D6KL
3           pwx_db               Usuwanie kluczy obcy 2021-10-23 11:53:11.750 dbo                                                                                                  DESKTOP-V17D6KL
*/

/* obejrzenie tabel, w których wcześniej były klucze obce */
USE PWX_DB

	SELECT
	    f.name constraint_name
	,OBJECT_NAME(f.parent_object_id) referencing_table_name
	,COL_NAME(fc.parent_object_id, fc.parent_column_id) referencing_column_name
	,OBJECT_NAME (f.referenced_object_id) referenced_table_name
	,COL_NAME(fc.referenced_object_id, fc.referenced_column_id) referenced_column_name
		FROM sys.foreign_keys AS f
		JOIN sys.foreign_key_columns AS fc
		ON f.[object_id] = fc.constraint_object_id
		ORDER BY f.name

/* wszystko skasowane, w liście w GUI MSSMS po odświeżeniu też widać, że klucze zniknęły
constraint_name                                                                                                                  referencing_table_name                                                                                                           referencing_column_name                                                                                                          referenced_table_name                                                                                                            referenced_column_name
-------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- --------------------------------------------------------------------------------------------------------------------------------

(0 rows affected)
*/

/* 4. Napisanie procedury do odtworzenia kluczy obcych ostatnio zapisanych */

/* inicjalizacja procedury */
IF NOT EXISTS 
(	SELECT 1 
		from sysobjects o (NOLOCK)
		WHERE	(o.[name] = 'DB_FK_RESTORE')
		AND		(OBJECTPROPERTY(o.[ID],'IsProcedure')=1)
)
BEGIN
	DECLARE @stmt nvarchar(100)
	SET @stmt = 'CREATE PROCEDURE dbo.DB_FK_RESTORE AS '
	EXEC sp_sqlexec @stmt
END
GO

USE DB_STAT
GO

/* edycja właściwej logiki procedury do odtwarzania kluczy obcych */
ALTER PROCEDURE dbo.DB_FK_RESTORE (@db nvarchar(100), @commt nvarchar(20) = '<unkn>')
AS
	INSERT INTO DB_STAT.dbo.DB_STAT (comment, db_nam) VALUES (@commt, @db)
    
	DECLARE @sql_tab TABLE(id int NOT NULL IDENTITY, sql_exec varchar(250) NOT NULL)
	DECLARE @sql_exec nvarchar(250)

	--tworzę tabelę poleceń sql do wykonania dla każdej tabeli--
	INSERT INTO @sql_tab
	SELECT
		'
		USE ' + @db + '
		ALTER TABLE [' + referencing_table_name + ']' +
		' ADD CONSTRAINT ' + constraint_name + ' FOREIGN KEY ' + '(' + referencing_column_name + ') REFERENCES ' + referenced_table_name + '('
		+ referenced_column_name + ')' 
	FROM
		DB_FK as f
	WHERE fk_id IN
		(SELECT MAX(o.stat_id)
		FROM DB_STAT o
		WHERE o.[db_nam] = @db
		AND EXISTS ( SELECT 1 FROM db_fk f WHERE f.fk_id = o.stat_id))

	--następnie polecenia muszą zostać rzeczywiście wykonane, posługuję się więc pętlą--
	DECLARE @Counter INT , @MaxId INT, @sql NVARCHAR(250)
	SELECT @Counter = min(id) , @MaxId = max(id) 
	FROM @sql_tab
	
	WHILE(@Counter IS NOT NULL
		  AND @Counter <= @MaxId)
	BEGIN
		SET @sql = (
		SELECT sql_exec
		FROM @sql_tab WHERE id = @Counter
	    )
		SET @Counter  = @Counter  + 1     
		EXEC sp_sqlexec @sql
	END
GO

/* test procedury */
USE DB_STAT

EXEC DB_STAT.dbo.DB_FK_RESTORE @commt = 'Odtwarzanie kluczy obcych', @db = N'pwx_db'


/* obejrzenie tabel, w których wcześniej były klucze obce */
USE PWX_DB

	SELECT
	    f.name constraint_name
	,OBJECT_NAME(f.parent_object_id) referencing_table_name
	,COL_NAME(fc.parent_object_id, fc.parent_column_id) referencing_column_name
	,OBJECT_NAME (f.referenced_object_id) referenced_table_name
	,COL_NAME(fc.referenced_object_id, fc.referenced_column_id) referenced_column_name
		FROM sys.foreign_keys AS f
		JOIN sys.foreign_key_columns AS fc
		ON f.[object_id] = fc.constraint_object_id
		ORDER BY f.name

/* Klucze odtworzone: 
constraint_name                                                                                                                  referencing_table_name                                                                                                           referencing_column_name                                                                                                          referenced_table_name                                                                                                            referenced_column_name
-------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- --------------------------------------------------------------------------------------------------------------------------------
fk_etaty__firmy                                                                                                                  etaty                                                                                                                            id_firmy                                                                                                                         firmy                                                                                                                            nazwa_skr
fk_etaty__osoby                                                                                                                  etaty                                                                                                                            id_osoby                                                                                                                         osoby                                                                                                                            id_osoby
fk_firmy__miasta                                                                                                                 firmy                                                                                                                            id_miasta                                                                                                                        miasta                                                                                                                           id_miasta
FK_FIRMY_CECHY__WARTOSCI_CECH                                                                                                    FIRMY_CECHY                                                                                                                      id_wartosci                                                                                                                      WARTOSCI_CECH                                                                                                                    id_wartosci
fk_miasta__woj                                                                                                                   miasta                                                                                                                           kod_woj                                                                                                                          woj                                                                                                                              kod_woj
fk_osoby__miasta                                                                                                                 osoby                                                                                                                            id_miasta                                                                                                                        miasta                                                                                                                           id_miasta
FK_WARTOSCI_CECHY__CECHY                                                                                                         WARTOSCI_CECH                                                                                                                    id_CECHY                                                                                                                         CECHY                                                                                                                            id_CECHY

(7 rows affected) */
