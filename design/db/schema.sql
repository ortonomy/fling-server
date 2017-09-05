-- set some variables for our new users
\set flinguser 'flingapp'

-- create our database account and give it privileges
DROP ROLE IF EXISTS :flinguser;
CREATE ROLE :flinguser WITH LOGIN PASSWORD 'FlingAppMakesItEasy';
ALTER ROLE :flinguser CREATEDB;

-- drop the app databse if it already exists
DROP DATABASE IF EXISTS fling;
-- create our awesome app db
CREATE DATABASE fling WITH OWNER :flinguser;
GRANT ALL PRIVILEGES ON DATABASE fling TO :flinguser;

\connect fling
DROP SCHEMA IF EXISTS flingapp;

-- create the app schema and then create tables
begin;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS flingapp AUTHORIZATION flingapp;

/* our core app users */
CREATE TABLE flingapp.users(
   id UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
   firstName TEXT DEFAULT 'Jane',
   lastName TEXT DEFAULT 'Doe',
   email TEXT DEFAULT 'name@example.com' UNIQUE,
   password TEXT NOT NULL,
   admin BOOLEAN DEFAULT false
);

/* an organization that is using flingapp */
CREATE TABLE flingapp.organizations(
   id UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
   name TEXT NOT NULL DEFAULT 'Unknown',
   admin UUID REFERENCES flingapp.users(id) ON DELETE RESTRICT,
   domain TEXT NOT NULL UNIQUE
);

/* many-to-many mapping of organization to users */
CREATE TABLE flingapp.user_org_map(
   id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
   organization UUID NOT NULL REFERENCES flingapp.organizations(id),
   _user UUID NOT NULL REFERENCES flingapp.users(id),
   PRIMARY KEY(organization, _user)
);

/* freelancer location */
CREATE TABLE flingapp.country(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   country TEXT NOT NULL UNIQUE
);

/* languages that the freelancer can deploy */
CREATE TABLE flingapp.languages(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   language TEXT NOT NULL UNIQUE
);

/* core freelancer entity */
CREATE TABLE flingapp.freelancers(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   firstName TEXT DEFAULT 'John',
   lastName TEXT DEFAULT 'Doe',
   isNS BOOLEAN NOT NULL DEFAULT true,
   location TEXT REFERENCES flingapp.country(country),
   timezone TEXT NOT NULL DEFAULT 'CST',
   primaryLanguage TEXT NOT NULL REFERENCES flingapp.languages(language)
);

/* roles for any freelancers within your organization */
CREATE TABLE flingapp.freelancer_roles(
   id UUID UNIQUE DEFAULT gen_random_uuid(),
   role TEXT NOT NULL UNIQUE
);

/* many-to-many mapping between freelancers and roles within your org */
CREATE TABLE flingapp.freelancer_role_map(
   id UUID DEFAULT gen_random_uuid(),
   role UUID NOT NULL REFERENCES flingapp.freelancer_roles(id),
   freelancer UUID NOT NULL REFERENCES flingapp.freelancers(id),
   PRIMARY KEY(role, freelancer)
);

/* many-to-many mapping between languages and freelancers */
CREATE TABLE flingapp.freelancer_languages_map(
   id UUID DEFAULT gen_random_uuid(),
   language UUID NOT NULL REFERENCES flingapp.languages(id),
   freelancer UUID NOT NULL REFERENCES flingapp.freelancers(id),
   PRIMARY KEY(language, freelancer)
);

/* freelancer employment status */
CREATE TABLE flingapp.employment_status(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   status TEXT NOT NULL UNIQUE
);


/* many-to-many mapping of freelancer and employment status */
CREATE TABLE flingapp.freelancer_employment_status_map(
   id UUID DEFAULT gen_random_uuid(),
   status TEXT NOT NULL REFERENCES flingapp.employment_status(status),
   freelancer UUID NOT NULL REFERENCES flingapp.freelancers(id),
   PRIMARY KEY(status, freelancer)
);

/* core file store */
CREATE TABLE flingapp.file_store(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   fileData BYTEA NOT NULL,
   fileName TEXT NOT NULL,
   insertDate DATE NOT NULL,
   updateDate DATE,
   owner UUID NOT NULL REFERENCES flingapp.users(id)
);

/* many-to-many mapping of files to freelancers */
CREATE TABLE flingapp.freelancer_file_store_map(
   id UUID DEFAULT gen_random_uuid(),
   file UUID NOT NULL REFERENCES flingapp.file_store(id),
   freelancer UUID NOT NULL REFERENCES flingapp.freelancers(id),
   docType TEXT NOT NULL,
   PRIMARY KEY (file, freelancer)
);

/* core project store */
CREATE TABLE flingapp.projects(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   name TEXT NOT NULL DEFAULT 'Unknown Project',
   startDate DATE,
   endDate DATE,
   description TEXT
);

/* many-to-many mapping of project freelancer   */
CREATE TABLE flingapp.project_freelancer_map(
   id UUID NOT NULL DEFAULT gen_random_uuid(),
   freelancer UUID NOT NULL UNIQUE REFERENCES flingapp.freelancers(id),
   project UUID NOT NULL REFERENCES flingapp.projects(id)
);


/* many-to-many mapping of files to projects */
CREATE TABLE flingapp.project_file_store_map(
   id UUID DEFAULT gen_random_uuid(),
   file UUID NOT NULL REFERENCES flingapp.file_store(id),
   project UUID NOT NULL REFERENCES flingapp.projects(id),
   docType TEXT NOT NULL,
   PRIMARY KEY (file, project)
);

/* many-to-many mapping of roles to projects */
CREATE TABLE flingapp.project_role_map(
   id UUID DEFAULT gen_random_uuid(),
   role UUID UNIQUE NOT NULL REFERENCES flingapp.freelancer_roles(id),
   project UUID UNIQUE NOT NULL REFERENCES flingapp.projects(id),
   PRIMARY KEY (role, project)
);

/* core workItem types for project */
CREATE TABLE flingapp.workItemTypes(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   workItemType TEXT NOT NULL
);

/* many-to-many mapping of workItems to projects */
CREATE TABLE flingapp.project_workitem_map(
   id UUID DEFAULT gen_random_uuid(),
   workItem UUID NOT NULL REFERENCES flingapp.workItemTypes(id),
   project UUID NOT NULL REFERENCES flingapp.projects(id),
   PRIMARY KEY (workItem, project)
);

/* many-to-many mapping of freelancers to projects */
CREATE TABLE flingapp.workhistory(
   id UUID UNIQUE DEFAULT gen_random_uuid(),
   freelancer UUID NOT NULL REFERENCES flingapp.freelancers(id),
   project UUID NOT NULL REFERENCES flingapp.projects(id),
   paymentCurrency TEXT NOT NULL default 'USD',
   paymentRate NUMERIC NOT NULL DEFAULT 0.00,
   mainWorkType UUID NOT NULL REFERENCES flingapp.workItemTypes(id),
   startDate DATE NOT NULL,
   finishDate DATE NOT NULL,
   performance SMALLINT NOT NULL,
   didComplete BOOLEAN NOT NULL DEFAULT false,
   reasonForDropOut TEXT,
   PRIMARY KEY (freelancer, project)
);

/* many to many mapping of freelancers's projects to roles taken in the project*/
CREATE TABLE flingapp.workhistory_role_map(
   id UUID DEFAULT gen_random_uuid(),
   experience UUID NOT NULL REFERENCES flingapp.workhistory(id),
   role UUID NOT NULL REFERENCES flingapp.project_role_map(role),
   PRIMARY KEY (experience, role)
);

/* many-to-many mapping of files to projects */
CREATE TABLE flingapp.workhistory_file_store_map(
   id UUID DEFAULT gen_random_uuid(),
   file UUID NOT NULL REFERENCES flingapp.file_store(id),
   experience UUID NOT NULL REFERENCES flingapp.workhistory(id),
   docType TEXT NOT NULL,
   PRIMARY KEY (file, experience)
);

/* core tag / note store */
CREATE TABLE flingapp.notestags(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   tag TEXT NOT NULL,
   type TEXT NOT NULL,
   createdBy UUID NOT NULL REFERENCES flingapp.users(id)
);

/* many-to-many mapping of freelancers to tags */
CREATE TABLE flingapp.freelancer_note_tag_map(
   id UUID DEFAULT gen_random_uuid(),
   freelancer UUID NOT NULL REFERENCES flingapp.freelancers(id),
   notetag UUID NOT NULL REFERENCES flingapp.notestags(id),
   PRIMARY KEY (freelancer, notetag)
);

/* many-to-many mapping of projects to tags */
CREATE TABLE flingapp.project_note_tag_map(
   id UUID DEFAULT gen_random_uuid(),
   project UUID NOT NULL REFERENCES flingapp.projects(id),
   notetag UUID NOT NULL REFERENCES flingapp.notestags(id),
   PRIMARY KEY (project, notetag)
);

/* many-to-many mapping of experience to tags */
CREATE TABLE flingapp.workhistory_note_tag_map(
   id UUID DEFAULT gen_random_uuid(),
   experience UUID NOT NULL REFERENCES flingapp.workhistory(id),
   notetag UUID NOT NULL REFERENCES flingapp.notestags(id),
   PRIMARY KEY (experience, notetag)
);

/* many-to-many mapping of work relationships */
CREATE TABLE flingapp.workhistory_relationship_map(
   id UUID DEFAULT gen_random_uuid(),
   experience UUID NOT NULL REFERENCES flingapp.workhistory(id),
   workedWith UUID NOT NULL REFERENCES flingapp.project_freelancer_map(freelancer),
   PRIMARY KEY (experience, workedWith)
);
commit;
