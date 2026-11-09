/* ============================================================================
   FAILSAFE IT - INFRASTRUKTUR- OCH BEHÖRIGHETSREGISTER
   STARTSKRIPT FÖR LEKTION 3: Datamodellering, ER-diagram & Normalisering
   ============================================================================ */

USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'FailSafe_Lektion3')
BEGIN
    ALTER DATABASE FailSafe_Lektion3 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FailSafe_Lektion3;
END
GO

CREATE DATABASE FailSafe_Lektion3;
GO

USE FailSafe_Lektion3;
GO



PRINT 'FailSafeIT-databasen är skapad och preparerad för Lektion 3!';