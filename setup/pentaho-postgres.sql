-- Drop table

-- DROP TABLE pentaho_logs.channels;

CREATE TABLE channels (
  id_batch int4 NULL,
  channel_id varchar(255) NULL,
  log_date timestamp NULL,
  logging_object_type varchar(255) NULL,
  object_name varchar(255) NULL,
  object_copy varchar(255) NULL,
  repository_directory varchar(255) NULL,
  filename varchar(255) NULL,
  object_id varchar(255) NULL,
  object_revision varchar(255) NULL,
  parent_channel_id varchar(255) NULL,
  root_channel_id varchar(255) NULL
);

-- Drop table

-- DROP TABLE pentaho_logs.jobentries;

CREATE TABLE jobentries (
  channel_id varchar(255) NULL,
  lines_read int8 NULL,
  lines_written int8 NULL,
  lines_updated int8 NULL,
  lines_input int8 NULL,
  lines_output int8 NULL,
  lines_rejected int8 NULL,
  errors int8 NULL,
  log_field text NULL,
  copy_nr int4 NULL,
  "RESULT_KTL" bpchar(1) NULL,
  id_batch int4 NULL,
  transname varchar(255) NULL,
  stepname varchar(255) NULL,
  "RESULT" bpchar(1) NULL,
  nr_result_rows int8 NULL,
  nr_result_files int8 NULL,
  log_date timestamp NULL
);
CREATE INDEX idx_jobentries_1 ON pentaho_logs.jobentries USING btree (id_batch);

-- Drop table

-- DROP TABLE pentaho_logs.jobs;

CREATE TABLE jobs (
  id_job int4 NULL,
  channel_id varchar(255) NULL,
  jobname varchar(255) NULL,
  status varchar(15) NULL,
  lines_read int8 NULL,
  lines_written int8 NULL,
  lines_updated int8 NULL,
  lines_input int8 NULL,
  lines_output int8 NULL,
  lines_rejected int8 NULL,
  errors int8 NULL,
  log_field text NULL,
  executing_server varchar(255) NULL,
  client varchar(255) NULL,
  executing_user varchar(255) NULL,
  start_job_entry varchar(255) NULL,
  startdate timestamp NULL,
  enddate timestamp NULL,
  logdate timestamp NULL,
  depdate timestamp NULL,
  replaydate timestamp NULL
);
CREATE INDEX idx_jobs_1 ON pentaho_logs.jobs USING btree (id_job);
CREATE INDEX idx_jobs_2 ON pentaho_logs.jobs USING btree (errors, status, jobname);

-- Drop table

-- DROP TABLE pentaho_logs.metrics;

CREATE TABLE metrics (
  id_batch int4 NULL,
  channel_id varchar(255) NULL,
  metrics_code varchar(255) NULL,
  metrics_description varchar(255) NULL,
  metrics_subject varchar(255) NULL,
  metrics_type varchar(255) NULL,
  metrics_value int8 NULL,
  log_date timestamp NULL,
  metrics_date timestamp NULL
);

-- Drop table

-- DROP TABLE pentaho_logs.performance;

CREATE TABLE performance (
  id_batch int4 NULL,
  seq_nr int4 NULL,
  transname varchar(255) NULL,
  stepname varchar(255) NULL,
  step_copy int4 NULL,
  lines_read int8 NULL,
  lines_written int8 NULL,
  lines_updated int8 NULL,
  lines_input int8 NULL,
  lines_output int8 NULL,
  lines_rejected int8 NULL,
  errors int8 NULL,
  input_buffer_rows int8 NULL,
  output_buffer_rows int8 NULL,
  logdate timestamp NULL
);

-- Drop table

-- DROP TABLE pentaho_logs.steps;

CREATE TABLE steps (
  id_batch int4 NULL,
  channel_id varchar(255) NULL,
  transname varchar(255) NULL,
  stepname varchar(255) NULL,
  step_copy int2 NULL,
  lines_read int8 NULL,
  lines_written int8 NULL,
  lines_updated int8 NULL,
  lines_input int8 NULL,
  lines_output int8 NULL,
  lines_rejected int8 NULL,
  errors int8 NULL,
  log_date timestamp NULL
);

-- Drop table

-- DROP TABLE pentaho_logs.transformations;

CREATE TABLE transformations (
  id_batch int4 NULL,
  channel_id varchar(255) NULL,
  transname varchar(255) NULL,
  status varchar(15) NULL,
  lines_read int8 NULL,
  lines_written int8 NULL,
  lines_updated int8 NULL,
  lines_input int8 NULL,
  lines_output int8 NULL,
  lines_rejected int8 NULL,
  errors int8 NULL,
  log_field text NULL,
  executing_server varchar(255) NULL,
  executing_user varchar(255) NULL,
  client varchar(255) NULL,
  startdate timestamp NULL,
  enddate timestamp NULL,
  logdate timestamp NULL,
  depdate timestamp NULL,
  replaydate timestamp NULL
);
CREATE INDEX idx_transformations_1 ON pentaho_logs.transformations USING btree (id_batch);
CREATE INDEX idx_transformations_2 ON pentaho_logs.transformations USING btree (errors, status, transname);
