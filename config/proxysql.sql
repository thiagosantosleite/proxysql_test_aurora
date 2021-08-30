DELETE FROM mysql_servers;
INSERT INTO mysql_servers (hostgroup_id,hostname,port,max_replication_lag, max_connections, use_ssl) VALUES (0,'aurora-cluster-proxysql.cluster-cl4jeqq2vjae.us-east-1.rds.amazonaws.com',3306,100, 1000, 1);
DELETE FROM mysql_aws_aurora_hostgroups;
INSERT INTO mysql_aws_aurora_hostgroups(writer_hostgroup, reader_hostgroup, domain_name,writer_is_also_reader) VALUES (0,1, '.cl4jeqq2vjae.us-east-1.rds.amazonaws.com',1);
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

DELETE FROM mysql_users;
INSERT INTO mysql_users (username,password,active,default_hostgroup, use_ssl) values ('sbtest','sbtestsbtest',1,0, 0);
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;

DELETE FROM mysql_query_rules;
INSERT INTO mysql_query_rules (rule_id,active,match_digest,destination_hostgroup,apply) VALUES (1,0,'^SELECT.*FOR UPDATE',0,1),(2,0,'^SELECT',1,1);
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

LOAD ADMIN VARIABLES TO RUNTIME;
SAVE ADMIN VARIABLES TO DISK;

LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;
