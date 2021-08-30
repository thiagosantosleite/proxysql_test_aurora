init:
	test -f terraform || wget -O terraform.zip https://releases.hashicorp.com/terraform/1.0.5/terraform_1.0.5_linux_amd64.zip 
	test -f terraform || (unzip terraform.zip && chmod +x terraform && rm terraform.zip)
	docker build -t sysbench -f docker/Dockerfile-sysbench docker/
	docker build -t proxysql -f docker/Dockerfile-proxysql docker/

up:
	./terraform -chdir=infrastructure/ init  && ./terraform -chdir=infrastructure/ apply -auto-approve
	docker-compose up -d

setup:
	ENDPOINT=$$(./terraform -chdir=infrastructure/ output -raw cluster) && \
    DOMAIN=$$(echo "$$ENDPOINT" | sed -e "s/aurora-cluster-proxysql.cluster-//") && \
    cp config/proxysql.sql.template config/proxysql.sql && \
    sed -i "s/AURORA_ENDPOINT/$$ENDPOINT/g" config/proxysql.sql && \
    sed -i "s/AURORA_DOMAIN/$$DOMAIN/g" config/proxysql.sql && \
	mysql -uradmin -pradmin -P6032 --protocol=TCP --host=127.0.0.1 < config/proxysql.sql && \
	mysql -usbtest -psbtestsbtest --host=$$ENDPOINT -e "create user if not exists monitor identified with mysql_native_password by 'monitor'; grant replication client on *.* to monitor;"

clean:
	./terraform -chdir=infrastructure/ destroy -auto-approve
	docker-compose stop && docker-compose rm -sf
	rm -rf terraform.tfstate
	rm -rf terraform.tfstate 
	rm -rf /infrastructure/local-state
	sudo rm -rf volumes/
	rm terraform

sb-prepare:
	docker exec sysbench sysbench --report-interval=2 --mysql-host=proxysql01 --mysql-port=6033 --mysql-user=sbtest --mysql-password=sbtestsbtest --mysql-db=sbtest --table_size=20000 --tables=4 --threads=4 --skip_trx=on --db-ps-mode=disable oltp_read_only prepare

sb-run:
	docker exec sysbench sysbench --report-interval=2 --mysql-host=proxysql01 --mysql-port=6033 --mysql-user=sbtest --mysql-password=sbtestsbtest --mysql-db=sbtest --table_size=20000 --tables=4 --time=600 --threads=4 --skip_trx=on --mysql-ignore-errors=2013 --db-ps-mode=disable oltp_read_only run

sb-clean:	
	docker exec sysbench sysbench --report-interval=2 --mysql-host=proxysql01 --mysql-port=6033 --mysql-user=sbtest --mysql-password=sbtestsbtest --mysql-db=sbtest --tables=4 oltp_read_only cleanup

failover:
	aws rds failover-db-cluster --db-cluster-identifier aurora-cluster-proxysql

delete-reader:
	READER=$$( aws rds describe-db-clusters --db-cluster-identifier aurora-cluster-proxysql | jq -r '.DBClusters[0].DBClusterMembers[] | select(.IsClusterWriter==false) | .DBInstanceIdentifier' | head -n1  ) && \
	aws rds delete-db-instance --db-instance-identifier $$READER

watch:
	mysql -uradmin -pradmin -P6032 --protocol=TCP -e "select hostgroup_id, hostname, status from runtime_mysql_servers order by 1" && echo "\n------------------------------------------------------------------------------------------------------------------" && docker logs proxysql01 2>&1 | tail -n 10 
