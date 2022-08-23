# Example Django Project for partitioning an existing postgres table

An example application to test out partitioning an existing PostgreSQL table
## Setup 
Install the requirements into your virtualenv.
Initialise the db with

    make reset-db

Install pg_partman following the instructions [here](https://github.com/pgpartman/pg_partman#installation), 
remember to add the background worker to your postgresql.conf file. Adding 

    pg_partman_bgw.dbname = 'partition_example'

to your postgresql.conf file will enable the background worker to run on this database.
See the pg_partman docs for more information, 
ensure you add the partman schema and extention to the `partition_example` database.

Generate some testing data with:

    python manage.py setup_test_data

## Partitioning

Follow the instructions in partition_commands.sql file - note you cannot execute this file directly as the commands require some customisation.
It may be beneficial to read along with [this guide](https://github.com/pgpartman/pg_partman/blob/master/doc/pg_partman_howto_native.md#online-partitioning)
 in the pg_partman documentation at the same time.
