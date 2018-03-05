-- BEGIN: JOBS
--
-- An asynchronous job queue schema for ACID compliant job creation through
-- triggers/functions/etc.
--
-- Worker code: worker.js
--
-- Author: Benjie Gillam <code@benjiegillam.com>
-- License: MIT
-- URL: https://gist.github.com/benjie/839740697f5a1c46ee8da98a1efac218
-- Donations: https://www.paypal.me/benjie

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;




-- modifications by Gregory Orton @ortonomy

-- set some variables
\set flingadmin 'flingapp_admin'

-- use our db
\connect fling

-- set to admin role
SET ROLE :flingadmin;




CREATE SCHEMA IF NOT EXISTS flingapp_jobs;

CREATE TABLE flingapp_jobs.job_queues (
  queue_name varchar NOT NULL PRIMARY KEY,
  job_count int DEFAULT 0 NOT NULL,
  locked_at timestamp with time zone,
  locked_by varchar
);
ALTER TABLE flingapp_jobs.job_queues ENABLE ROW LEVEL SECURITY;

CREATE TABLE flingapp_jobs.jobs (
  id serial PRIMARY KEY,
  queue_name varchar DEFAULT (public.gen_random_uuid())::varchar NOT NULL,
  task_identifier varchar NOT NULL,
  payload json DEFAULT '{}'::json NOT NULL,
  priority int DEFAULT 0 NOT NULL,
  run_at timestamp with time zone DEFAULT now() NOT NULL,
  attempts int DEFAULT 0 NOT NULL,
  last_error varchar,
  created_at timestamp with time zone NOT NULL DEFAULT NOW(),
  updated_at timestamp with time zone NOT NULL DEFAULT NOW()
);
ALTER TABLE flingapp_jobs.job_queues ENABLE ROW LEVEL SECURITY;

CREATE FUNCTION flingapp_jobs.do_notify() RETURNS trigger AS $$
BEGIN
  PERFORM pg_notify(TG_ARGV[0], '');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION flingapp_jobs.update_timestamps() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_at = NOW();
    NEW.updated_at = NOW();
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.created_at = OLD.created_at;
    NEW.updated_at = GREATEST(NOW(), OLD.updated_at + INTERVAL '1 millisecond');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION flingapp_jobs.jobs__decrease_job_queue_count() RETURNS trigger AS $$
BEGIN
  UPDATE flingapp_jobs.job_queues
    SET job_count = job_queues.job_count - 1
    WHERE queue_name = OLD.queue_name
    AND job_queues.job_count > 1;

  IF NOT FOUND THEN
    DELETE FROM flingapp_jobs.job_queues WHERE queue_name = OLD.queue_name;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION flingapp_jobs.jobs__increase_job_queue_count() RETURNS trigger AS $$
BEGIN
  INSERT INTO flingapp_jobs.job_queues(queue_name, job_count)
    VALUES(NEW.queue_name, 1)
    ON CONFLICT (queue_name) DO UPDATE SET job_count = job_queues.job_count + 1;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER _100_timestamps BEFORE INSERT OR UPDATE ON flingapp_jobs.jobs FOR EACH ROW EXECUTE PROCEDURE flingapp_jobs.update_timestamps();
CREATE TRIGGER _500_increase_job_queue_count AFTER INSERT ON flingapp_jobs.jobs FOR EACH ROW EXECUTE PROCEDURE flingapp_jobs.jobs__increase_job_queue_count();
CREATE TRIGGER _500_decrease_job_queue_count BEFORE DELETE ON flingapp_jobs.jobs FOR EACH ROW EXECUTE PROCEDURE flingapp_jobs.jobs__decrease_job_queue_count();
CREATE TRIGGER _900_notify_worker AFTER INSERT ON flingapp_jobs.jobs FOR EACH STATEMENT EXECUTE PROCEDURE flingapp_jobs.do_notify('jobs:insert');

CREATE FUNCTION flingapp_jobs.add_job(identifier varchar, payload json) RETURNS flingapp_jobs.jobs AS $$
  INSERT INTO flingapp_jobs.jobs(task_identifier, payload) VALUES(identifier, payload) RETURNING *;
$$ LANGUAGE sql;

CREATE FUNCTION flingapp_jobs.add_job(identifier varchar, queue_name varchar, payload json) RETURNS flingapp_jobs.jobs AS $$
  INSERT INTO flingapp_jobs.jobs(task_identifier, queue_name, payload) VALUES(identifier, queue_name, payload) RETURNING *;
$$ LANGUAGE sql;

CREATE FUNCTION flingapp_jobs.schedule_job(identifier varchar, queue_name varchar, payload json, run_at timestamptz) RETURNS flingapp_jobs.jobs AS $$
  INSERT INTO flingapp_jobs.jobs(task_identifier, queue_name, payload, run_at) VALUES(identifier, queue_name, payload, run_at) RETURNING *;
$$ LANGUAGE sql;

CREATE FUNCTION flingapp_jobs.complete_job(worker_id varchar, job_id int) RETURNS flingapp_jobs.jobs AS $$
DECLARE
  v_row flingapp_jobs.jobs;
BEGIN
  DELETE FROM flingapp_jobs.jobs
    WHERE id = job_id
    RETURNING * INTO v_row;

  UPDATE flingapp_jobs.job_queues
    SET locked_by = null, locked_at = null
    WHERE queue_name = v_row.queue_name AND locked_by = worker_id;

  RETURN v_row;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION flingapp_jobs.fail_job(worker_id varchar, job_id int, error_message varchar) RETURNS flingapp_jobs.jobs AS $$
DECLARE
  v_row flingapp_jobs.jobs;
BEGIN
  UPDATE flingapp_jobs.jobs
    SET
      last_error = error_message,
      run_at = greatest(now(), run_at) + (exp(least(attempts, 10))::text || ' seconds')::interval
    WHERE id = job_id
    RETURNING * INTO v_row;

  UPDATE flingapp_jobs.job_queues
    SET locked_by = null, locked_at = null
    WHERE queue_name = v_row.queue_name AND locked_by = worker_id;

  RETURN v_row;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION flingapp_jobs.get_job(worker_id varchar, identifiers varchar[]) RETURNS flingapp_jobs.jobs AS $$
DECLARE
  v_job_id int;
  v_queue_name varchar;
  v_default_job_expiry text = (4 * 60 * 60)::text;
  v_default_job_maximum_attempts text = '25';
  v_row flingapp_jobs.jobs;
BEGIN
  IF worker_id IS NULL OR length(worker_id) < 10 THEN
    RAISE EXCEPTION 'Invalid worker ID';
  END IF;

  SELECT job_queues.queue_name, jobs.id INTO v_queue_name, v_job_id
    FROM flingapp_jobs.job_queues
    INNER JOIN flingapp_jobs.jobs USING (queue_name)
    WHERE (locked_at IS NULL OR locked_at < (now() - (COALESCE(current_setting('jobs.expiry', true), v_default_job_expiry) || ' seconds')::interval))
    AND run_at <= now()
    AND attempts < COALESCE(current_setting('jobs.maximum_attempts', true), v_default_job_maximum_attempts)::int
    AND (identifiers IS NULL OR task_identifier = any(identifiers))
    ORDER BY priority ASC, run_at ASC, id ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED;

  IF v_queue_name IS NULL THEN
    RETURN NULL;
  END IF;

  UPDATE flingapp_jobs.job_queues
    SET
      locked_by = worker_id,
      locked_at = now()
    WHERE job_queues.queue_name = v_queue_name;

  UPDATE flingapp_jobs.jobs
    SET attempts = attempts + 1
    WHERE id = v_job_id
    RETURNING * INTO v_row;

  RETURN v_row;
END;
$$ LANGUAGE plpgsql;

-- END: JOBS
