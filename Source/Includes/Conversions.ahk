; these functions handle database conversion

SetDbVersion(dBVersion = 1)
{
	global g_WordListDB
	g_WordListDB.Query("INSERT OR REPLACE INTO LastState VALUES ('databaseVersion', '" . dBVersion . "', NULL);")
}


; returns true if we need to rebuild the whole database
MaybeConvertDatabase()
{
	global g_WordListDB
	
	databaseVersionRows := g_WordListDB.Query("SELECT lastStateNumber FROM LastState WHERE lastStateItem = 'databaseVersion';")
	
	if (databaseVersionRows) {
		for each, row in databaseVersionRows.Rows
		{
			databaseVersion := row[1]
		}
	}
	
	if (!databaseVersion) {
		   tableConverted := g_WordListDB.Query("SELECT tableconverted FROM LastState;")
	} else {
		tableConverted := g_WordListDB.Query("SELECT lastStateNumber FROM LastState WHERE lastStateItem = 'tableConverted';")
	}
   
	if (tableConverted) {
		for each, row in tableConverted.Rows
		{
			WordlistConverted := row[1]
		}
	}
	
	IfNotEqual, WordlistConverted, 1
	{
		RebuildDatabase()		
		return, true
	}
	
	if (!databaseVersion) {
		RunConversionOne(WordlistConverted)
	}
	
	return, false
}


; Rebuilds the Database from scratch as we have to redo the wordlist anyway.
RebuildDatabase()
{
	global g_WordListDB
	g_WordListDB.Query("DROP TABLE Words;")
	g_WordListDB.Query("DROP INDEX WordIndex;")
	g_WordListDB.Query("DROP TABLE LastState;")
	
	IF not g_WordListDB.Query("CREATE TABLE Words (wordindexed TEXT, word TEXT PRIMARY KEY, count INTEGER, worddescription TEXT);")
	{
		msgbox Cannot Create Words Table - fatal error...
		ExitApp
	}

	IF not g_WordListDB.Query("CREATE INDEX WordIndex ON Words (wordindexed);")
	{
		msgbox Cannot Create WordIndex Index - fatal error...
		ExitApp
	}
	
	CreateLastStateTable()
	
	SetDbVersion()
		
}

;Runs the first conversion
RunConversionOne(WordlistConverted)
{
	global g_WordListDB
	
	g_WordListDB.Query("ALTER TABLE LastState RENAME TO OldLastState;")
	IF not g_WordListDB.Query("CREATE TABLE LastState (lastStateItem TEXT PRIMARY KEY, lastStateNumber INTEGER, otherInfo TEXT) WITHOUT ROWID;")
	{
		MsgBox Cannot Create LastState Table - fatal error...
		ExitApp
	}
	g_WordListDB.Query("DROP TABLE OldLastState;")
	g_WordListDB.Query("INSERT OR REPLACE INTO LastState VALUES ('tableConverted', '" . WordlistConverted . "', NULL);")
	
	g_WordListDB.Query("ALTER TABLE Words ADD COLUMN worddescription TEXT;")
	
	SetDbVersion(1)
	
}

CreateLastStateTable()
{
	global g_WordListDB

	IF not g_WordListDB.Query("CREATE TABLE LastState (lastStateItem TEXT PRIMARY KEY, lastStateNumber INTEGER, otherInfo TEXT) WITHOUT ROWID;")
	{
		MsgBox Cannot Create LastState Table - fatal error...
		ExitApp
	}
}