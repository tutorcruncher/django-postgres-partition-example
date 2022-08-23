# django-postgres-partition-example

An example application to test out partitioning an existing PostgreSQL table

Install pg_partman following the instructions [here](https://github.com/pgpartman/pg_partman#installation), 
remember to add the background worker to your postgresql.conf file. Adding 

    pg_partman_bgw.dbname = 'partition_example'

to your postgresql.conf file will enable the background worker to run on this database.
See the pg_partman docs for more information.

Initialise the db with

    make reset-db

Generate some testing data with:

    python manage.py setup_test_data

## Paritiioning

