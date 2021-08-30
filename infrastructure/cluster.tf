resource aws_rds_cluster default {
  cluster_identifier      = "aurora-cluster-proxysql"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.03.2"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  database_name           = "sbtest"
  master_username         = "sbtest"
  master_password         = "sbtestsbtest"
  backup_retention_period = 1
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.default.id]
}
