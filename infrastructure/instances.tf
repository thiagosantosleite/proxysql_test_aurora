resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 3
  identifier         = "aurora-cluster-proxysql-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.t3.small"
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  publicly_accessible = true
  apply_immediately = false
}
