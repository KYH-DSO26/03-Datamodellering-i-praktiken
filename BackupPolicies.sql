set identity_insert BackupServers on;
insert into BackupPolicies (id, PolicyName) values (1, 'Full');
insert into BackupPolicies (id, PolicyName) values (2, 'Incremental');
set identity_insert BackupServers off;
go