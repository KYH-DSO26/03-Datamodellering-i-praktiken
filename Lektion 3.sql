-- Steg 0: UNF-kaos
create table Legacy_Incident_Chaos(
	ServerName NVARCHAR(100),
	Incident_And_Date NVARCHAR(250),
	InvestigatedByTechs NVARCHAR(MAX)
);
insert into Legacy_Incident_Chaos
values
	('Prod-Web-01','DDos:2026-11-05', 'Erik Nilsson, Lina Berg'),
	('Prod-Web-01','DDos:2026-11-06', 'Erik Nilsson');

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
	('Prod-Web-01');
insert into SecurityTechs values 
	('Erik Nilsson'),
	('Lina Berg');
insert into Incidents (IncidentType, IncidentDate, ServerId) values
	('DDoS', '2026-11-05', 1),
	('DDoS', '2026-11-06', 1);
insert into IncidentAssignments (IncidentId, TechId) values
	(1,1),
	(1,2),
	(2,1);
go
