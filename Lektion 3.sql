/* ============================================================================
   FAILSAFE IT - INCIDENT- OCH BACKUP-REGISTER
   SLUTSKRIPT FÖR LEKTION 3: Datamodellering, ER-diagram & Normalisering
   ============================================================================ */

-- Rensa bort eventuell gammal databas och skapa den på nytt.
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

/*
	BLOCK 1. Här normaliserar vi en kaostabell till 3NF
	Vi går via 1NF och 2NF, för tydlighets skull
*/
-- Steg 0: UNF-kaos
create table Legacy_Incident_Chaos(
	ServerName NVARCHAR(100),
	Incident_And_Date NVARCHAR(250),
	InvestigatedByTechs NVARCHAR(MAX)
);
insert into Legacy_Incident_Chaos
values
	('Prod-Web-01', 'DDoS:2026-11-05', 'Erik Nilsson, Lina Berg'),
	('Prod-Web-01', 'SQLi-Attempt:2026-11-06', 'Lina Berg'),
	('Dev-Db-01', 'UnauthorizedAccess:2026-11-07', 'Erik Nilsson, Anna Stark'),
	('Test-App-04', 'None:2026-11-08', 'Kalle Blomqvist');
GO

-- Steg 1: Transformera till 1NF
create table Incident_1NF(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	ServerName nvarchar(100),
	IncidentType nvarchar(100),
	IncidentDate DATETIME2,
	TechName nvarchar(150)
);
insert into Incident_1NF values
	('Prod-Web-01', 'DDoS', '2026-11-05', 'Erik Nilsson'),
	('Prod-Web-01', 'DDoS', '2026-11-06', 'Erik Nilsson'),
	('Prod-Web-01', 'DDoS', '2026-11-05', 'Lina Berg');
go

-- Steg 2: Tranformera till 2NF
create table IncidentServers_2NF(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	ServerName nvarchar(100)
);

create table Incidents_and_Techs_2NF(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	IncidentType nvarchar(100),
	IncidentDate DATETIME2,
	TechName nvarchar(150)
);

insert into IncidentServers_2NF values
	('Prod-Web-01');
insert into Incidents_and_Techs_2NF values
	('DDoS', '2026-11-05', 'Erik Nilsson'),
	('DDoS', '2026-11-06', 'Erik Nilsson'),
	('DDoS', '2026-11-05', 'Lina Berg');
go

-- Steg 3: Transformera till 3NF & Upplöst M:M
create table IncidentServers(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	ServerName nvarchar(100) not null unique
);

create table SecurityTechs(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	TechName nvarchar(150) not null unique
);

create table Incidents (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	IncidentType nvarchar(100) not null,
	IncidentDate DATETIME2 not null default getdate(),
	ServerId int foreign key references IncidentServers(Id)
);

create table IncidentAssignments(
	IncidentId int not null,
	TechId int not null,
	constraint PK_IncidentAssignments primary key (IncidentId, TechId),
	constraint FK_Assignment_Incident foreign key (IncidentId) 
		references Incidents(Id),
	constraint FK_Assignment_Tech foreign key (TechId)
		references SecurityTechs(Id)
);

insert into IncidentServers values
	('Prod-Web-01'),
	('Dev-Db-01'),
	('Test-App-04');
insert into SecurityTechs values 
	('Erik Nilsson'),
	('Lina Berg'),
	('Anna Stark'), 
	('Kalle Blomqvist');
insert into Incidents (IncidentType, IncidentDate, ServerId) values
	('DDoS', '2026-11-05', 1),
	('DDoS', '2026-11-06', 1),
	('SQLi-Attempt', '2026-11-06',1),
	('UnauthorizedAccess', '2026-11-07',2),
	('None', '2026-11-08', 3);
insert into IncidentAssignments (IncidentId, TechId) values
	(1,1),
	(1,2),
	(2, 3), 
	(2, 2), 
	(3, 1), 
	(3, 3), 
	(4, 4);
go

-- Steg 4: Verifiera att det funkar
-- Återskapa ursprunglig kaosdata via joins ---
select * from Legacy_Incident_Chaos;
select
	s.ServerName,
	i.IncidentType + ':' + convert(varchar, i.IncidentDate, 23) as Incident_and_Date,
	t.TechName as InvestigatedByTech
from incidents i
inner join IncidentServers s on i.ServerId = s.Id
inner join IncidentAssignments a on i.Id = a.IncidentId
inner join SecurityTechs t on a.TechId = t.Id;
go

/*
	BLOCK 2. Här genererar vi en datamodell utifrån kundkrav
	Vi bygger modellen i Lucidchart
	Vi skapar testdata i Mockaroo
*/
-- Steg 1: skapa tabellerna. Detta kommer från Lucidchart
CREATE TABLE [BackupServers] (
  [Id] INT IDENTITY(1,1) PRIMARY KEY,
  [ServerName] NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE [BackupPolicies] (
  [Id] INT IDENTITY(1,1) PRIMARY KEY,
  [PolicyName] NVARCHAR(100) NOT NULL UNIQUE,
  [IntervalHours] INT NOT NULL DEFAULT 24
);

CREATE TABLE [ServerPolicyMaps] (
  [ServerId] INT NOT NULL,
  [PolicyId] INT NOT NULL,
  [IsActive] BIT DEFAULT 1,
  CONSTRAINT PK_ServerPolicyMaps PRIMARY KEY ([ServerId], [PolicyId]),
  CONSTRAINT [FK_ServerPolicyMaps_ServerId]
    FOREIGN KEY ([ServerId])
      REFERENCES [BackupServers]([Id]),
  CONSTRAINT [FK_ServerPolicyMaps_PolicyId]
    FOREIGN KEY ([PolicyId])
      REFERENCES [BackupPolicies]([Id])
);
GO

-- Steg 2: fyll i med testdata från Mockaroo
set identity_insert BackupServers on;
insert into BackupServers (id, ServerName) values (1, 'Prod-Web-01');
insert into BackupServers (id, ServerName) values (2, 'Dev-Db-01');
insert into BackupServers (id, ServerName) values (3, 'Test-App-04');
set identity_insert BackupServers off;
go

set identity_insert BackupPolicies on;
insert into BackupPolicies (id, PolicyName) values (1, 'Full');
insert into BackupPolicies (id, PolicyName) values (2, 'Incremental');
set identity_insert BackupPolicies off;
go

insert into ServerPolicyMaps (ServerId, PolicyId) values (1, 2);
insert into ServerPolicyMaps (ServerId, PolicyId) values (2, 2);
insert into ServerPolicyMaps (ServerId, PolicyId) values (3, 1);
--insert into ServerPolicyMaps (ServerId, PolicyId) values (2, 2);	-- Blir fel!
insert into ServerPolicyMaps (ServerId, PolicyId) values (2, 1);	-- Blir inte fel
go

-- Verifiera att det gick bra
print 'Verifierar data från Block 2'
select * from BackupServers
select * from BackupPolicies
select * from ServerPolicyMaps
go