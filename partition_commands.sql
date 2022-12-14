-- Below are the commands used to create the existing partitions. From the django autogenerated migrations files.
-- These can be found by running python manage.py sqlmigrate <app> <migration_number> for all migration number which affect the table.

CREATE TABLE "actions_action"
(
    "id"              bigint                   NOT NULL PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    "timestamp"       timestamp with time zone NOT NULL,
    "verb"            varchar(255)             NOT NULL,
    "object_id"       integer NULL CHECK ("object_id" >= 0),
    "actor_id"        bigint                   NOT NULL,
    "content_type_id" integer NULL,
    "target_id"       bigint NULL
);
ALTER TABLE "actions_action"
    ADD CONSTRAINT "actions_action_actor_id_bdccd9e4_fk_actions_user_id" FOREIGN KEY ("actor_id") REFERENCES "actions_user" ("id") DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "actions_action"
    ADD CONSTRAINT "actions_action_content_type_id_dbe9a960_fk_django_co" FOREIGN KEY ("content_type_id") REFERENCES "django_content_type" ("id") DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "actions_action"
    ADD CONSTRAINT "actions_action_target_id_128ce21d_fk_actions_user_id" FOREIGN KEY ("target_id") REFERENCES "actions_user" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "actions_action_verb_6153a18f" ON "actions_action" ("verb");
CREATE INDEX "actions_action_verb_6153a18f_like" ON "actions_action" ("verb" varchar_pattern_ops);
CREATE INDEX "actions_action_object_id_14fdf2ea" ON "actions_action" ("object_id");
CREATE INDEX "actions_action_actor_id_bdccd9e4" ON "actions_action" ("actor_id");
CREATE INDEX "actions_action_content_type_id_dbe9a960" ON "actions_action" ("content_type_id");
CREATE INDEX "actions_action_target_id_128ce21d" ON "actions_action" ("target_id");
CREATE INDEX "actions_act_content_7060c5_idx" ON "actions_action" ("content_type_id", "object_id", "timestamp", "verb");


-- Below is the new partioned table.
BEGIN;
CREATE TABLE "new_partitioned_actions_action"
(
    "id"              bigint                   NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    "timestamp"       timestamp with time zone NOT NULL,
    "verb"            varchar(255)             NOT NULL,
    "object_id"       integer NULL CHECK ("object_id" >= 0),
    "actor_id"        bigint                   NOT NULL,
    "content_type_id" integer NULL,
    "target_id"       bigint NULL
) PARTITION BY RANGE ("timestamp");
ALTER TABLE "new_partitioned_actions_action"
    ADD CONSTRAINT "partitioned_action_actor_id_bdccd9e4_fk_actions_user_id" FOREIGN KEY ("actor_id") REFERENCES "actions_user" ("id") DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "new_partitioned_actions_action"
    ADD CONSTRAINT "partitioned_action_content_type_id_dbe9a960_fk_django_co" FOREIGN KEY ("content_type_id") REFERENCES "django_content_type" ("id") DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE "new_partitioned_actions_action"
    ADD CONSTRAINT "partitioned_action_target_id_128ce21d_fk_actions_user_id" FOREIGN KEY ("target_id") REFERENCES "actions_user" ("id") DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX "partitioned_action_verb_6153a18f" ON "new_partitioned_actions_action" ("verb");
CREATE INDEX "partitioned_action_verb_6153a18f_like" ON "new_partitioned_actions_action" ("verb" varchar_pattern_ops);
CREATE INDEX "partitioned_action_object_id_14fdf2ea" ON "new_partitioned_actions_action" ("object_id");
CREATE INDEX "partitioned_action_actor_id_bdccd9e4" ON "new_partitioned_actions_action" ("actor_id");
CREATE INDEX "partitioned_action_content_type_id_dbe9a960" ON "new_partitioned_actions_action" ("content_type_id");
CREATE INDEX "partitioned_action_target_id_128ce21d" ON "new_partitioned_actions_action" ("target_id");
CREATE INDEX "partitioned__act_content_7060c5_idx" ON "new_partitioned_actions_action" ("content_type_id", "object_id", "timestamp", "verb");

<COMMIT; or ROLLBACK;>
-- you will need to choose new names for indexes and constraints.
-- Note that we have not set "id" as primary key.
-- This is because we cannot set a primary key constraint on a column which is not the partition key.
-- We will set this in the following table template, then pg_partman will enforce it on individual child partitions
--     -> not possible to enfore across all partitions.
-- indexes, foreign keys & tablespaces are automatically inherited from the parent table by postgres.
-- this template is just used by pg_partman to enforce unique index(primary key)s which dont include the partition key on the child tables.
-- We create a template table for pg_partman from the exisiting actions table as follows
BEGIN;
CREATE TABLE actions_table_template(LIKE actions_action);
ALTER TABLE actions_table_template ADD PRIMARY KEY ("id");
<COMMIT; or ROLLBACK;>

-- We now move to the step of setting up the partitioning with pg_partman.
-- We must ensure the first partition time period is ahead of any existing data
--     -> This is so that we can attach the existing table as the default child without postgres complaining the data is not in the correct partition.
-- We can check this by running the following query:
select min("timestamp"), max("timestamp") from actions_action;
-- The result should look like:
--partition_example=# select min("timestamp"), max("timestamp") from public.actions_action;
--               min              |              max
-- -------------------------------+-------------------------------
--  2014-08-23 10:20:34.576557+01 | 2022-08-23 10:10:06.674568+01
-- (1 row)

-- So we use a buffer of 2 months from the max -> which is just the current time since there is no data in the future
SELECT partman.create_parent('public.new_partitioned_actions_action', 'timestamp', 'native', 'monthly', p_template_table:= 'public.actions_table_template', p_premake := 1, p_start_partition := (CURRENT_TIMESTAMP+'2 months'::interval)::text);

-- We now drop the initial default table so we can attach our own.
DROP TABLE public.new_partitioned_actions_action_default;
-- We now update the part_config table to have the original table name ahead of us performing the rename transaction.
UPDATE partman.part_config SET parent_table = 'public.actions_action', premake = 4 WHERE parent_table = 'public.new_partitioned_actions_action';
-- We also reset the premake value back to default - but this can be customised depending on the use case.

-- We now perform the transaction which renames the tables and attaches the old table as the default child.
BEGIN;
LOCK TABLE public.actions_action IN ACCESS EXCLUSIVE MODE;
LOCK TABLE public.new_partitioned_actions_action IN ACCESS EXCLUSIVE MODE;

SELECT max("id") FROM public.actions_action;

ALTER TABLE public.actions_action RENAME TO actions_action_default;

-- Deals with id column
ALTER TABLE public.actions_action_default ALTER "id" DROP IDENTITY;

ALTER TABLE public.new_partitioned_actions_action RENAME TO actions_action;
--Set this to the name of the existing partitioned table, find it with \d+ new_partitioned_actions_action
ALTER TABLE public.new_partitioned_actions_action_p2022_10 RENAME TO actions_action_p2022_10;

-- Deals with id column
ALTER SEQUENCE public.new_partitioned_actions_action_id_seq RENAME TO actions_action_id_seq;

-- Deals with id column - fill value with result from SELECT max(col1) FROM public.original_table;
ALTER TABLE public.actions_action ALTER "id" RESTART WITH 1555493;

--Deals with check constraint on object_id column - you may have to rename other constraints as well
ALTER TABLE public.actions_action_default RENAME CONSTRAINT actions_action_object_id_check TO new_partitioned_actions_action_object_id_check;

ALTER TABLE public.actions_action ATTACH PARTITION public.actions_action_default DEFAULT;

<COMMIT; or ROLLBACK;>

-- Now to move the data out of the default partition and into new partitions. Smaller batch size will lock less rows
CALL partman.partition_data_proc('public.actions_action', p_batch := 200);
VACUUM ANALYZE actions_action;

-- Now run partman maintenance to check the child partitions were formed correctly and no errors occur
SELECT partman.run_maintenance('public.actions_action');

-- We can check if there is any data left in the default partition by running the following query:
SELECT * FROM partman.check_default(p_exact_count := true);
-- If there is data left, we can move them out using partition_data_proc() again.
-- If you inspect the actions_action table, by \d+ actions_action can look at the partitions
--     -> There will likely be a gap of one month since when we defined the new table we started the partitions 2 motnhs in the future
-- Fix this with
SELECT * FROM partman.partition_gap_fill('public.actions_action');
-- which should return 1 for the 1 partition it created

-- Now the partitioning is doneeeeeeeeeee
-- Make sure the maintenance commands are either being run by the pg_partman BGW or another external scheduler.






