reset-db:
	psql -h localhost -U postgres -c "DROP DATABASE IF EXISTS partition_example"
	psql -h localhost -U postgres -c "CREATE DATABASE partition_example"
