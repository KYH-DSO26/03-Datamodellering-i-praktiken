CREATE TABLE [BackupServers] (
  [Id] INT IDENTITY(1,1) PRIMARY KEY,
  [ServerName] NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE [BackupPolicies] (
  [Id] INT IDENTITY(1,1) PRIMARY KEY,
  [PolicyName] NVARCHAR(100) NOT NULL UNIQUE,
  [IntervalHours] INT NOT NULL
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

