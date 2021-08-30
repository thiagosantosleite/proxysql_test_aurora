resource aws_security_group default {
  name        = "aurora-sg-proxysql"
  description = "Allow inbound to aurora"
}

resource aws_security_group_rule default-egress {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}


resource aws_security_group_rule default-ingress {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "TCP"
  cidr_blocks              = ["${data.http.publicip.body}/32"]
  security_group_id        = aws_security_group.default.id
}

