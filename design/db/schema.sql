-- set some variables for our new users
\set flinguser 'flingapp'
-- drop the app databse if it already exists
DROP DATABASE IF EXISTS fling;

-- create our database account and give it privileges
DROP ROLE IF EXISTS :flinguser;
CREATE ROLE :flinguser WITH LOGIN PASSWORD 'FlingAppMakesItEasy';
ALTER ROLE :flinguser CREATEDB;

-- create our awesome app db
CREATE DATABASE fling WITH OWNER :flinguser;
GRANT ALL PRIVILEGES ON DATABASE fling TO :flinguser;

\connect fling
DROP SCHEMA IF EXISTS flingapp;

-- create the app schema and then create tables
begin;
-- must be superuser to add this extension
CREATE EXTENSION IF NOT EXISTS pgcrypto; 
CREATE SCHEMA IF NOT EXISTS flingapp AUTHORIZATION flingapp;
--  we want the flingapp user to be the role that owns the tables so postgraphql has the correct permissions
SET ROLE :flinguser;

/* our core app users */
CREATE TABLE flingapp.user(
  id UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
  firstName TEXT DEFAULT 'Jane',
  lastName TEXT DEFAULT 'Doe',
  email TEXT DEFAULT 'name@example.com' UNIQUE,
  password TEXT NOT NULL,
  admin BOOLEAN DEFAULT false
);
-- comments for postgraphQL docs
COMMENT ON TABLE flingapp.users IS 'A human user of flingapp';
COMMENT ON COLUMN flingapp.users.id IS 'The universally unique ID of a user';
COMMENT ON COLUMN flingapp.users.firstName IS 'The first, or given name, of a user';
COMMENT ON COLUMN flingapp.users.lastName IS 'The family name, or last name, of a user';
COMMENT ON COLUMN flingapp.users.email IS 'The UNIQUE email address of a user - a user cannot register with the same email twice.';
COMMENT ON COLUMN flingapp.users.password IS 'This is a salted hash of a user''s password. We never store the password directly.';
COMMENT ON COLUMN flingapp.users.admin IS 'Whether the user is an admin of their organization or not.';

/* an organization that is using flingapp */
CREATE TABLE flingapp.organization(
  id UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
  name TEXT NOT NULL DEFAULT 'Unknown',
  admin UUID REFERENCES flingapp.users(id) ON DELETE RESTRICT,
  domain TEXT NOT NULL UNIQUE
);
-- comments for postgraphQL docs
COMMENT ON TABLE flingapp.organizations IS 'An organization that freelancers and users can belong to.';
COMMENT ON COLUMN flingapp.organizations.id IS 'The universally unique ID of an organization';
COMMENT ON COLUMN flingapp.organizations.name IS 'An organization''s name';
COMMENT ON COLUMN flingapp.organizations.admin IS 'A UUID of a user who is the assigned admin of this organization. References users.';
COMMENT ON COLUMN flingapp.organizations.domain IS 'A unique FQDN used to help a user find their organization. E.g. example.com'; 

/* many-to-many mapping of organization to users */
CREATE TABLE flingapp.user_org_map(
  id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  organization UUID NOT NULL REFERENCES flingapp.organizations(id),
  _user UUID NOT NULL REFERENCES flingapp.users(id),
  PRIMARY KEY(organization, _user)
);
-- comments for postgraphQL docs
COMMENT ON TABLE flingapp.user_org_map IS 'A many-to-many mapping of users to organizations';
COMMENT ON COLUMN flingapp.user_org_map.id IS 'The universally unique ID of a user to organization map entry';
COMMENT ON COLUMN flingapp.user_org_map.organization IS 'An organization''s name - references organization table';
COMMENT ON COLUMN flingapp.user_org_map._user IS 'A UUID of a user. References users.';
 
/* freelancer location */
CREATE TABLE flingapp.country(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country TEXT NOT NULL UNIQUE
);
-- comments for postgraphQL docs
COMMENT ON TABLE flingapp.country IS 'An list of all the countries in the world';
COMMENT ON COLUMN flingapp.country.id IS 'The universally unique ID of a country';
COMMENT ON COLUMN flingapp.country.country IS 'A name of a country in the world';

/* languages that the freelancer can deploy */
CREATE TABLE flingapp.language(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  language TEXT NOT NULL UNIQUE
);
-- comments for postgraphQL docs
COMMENT ON TABLE flingapp.languages IS 'An list of all languages (within reason) that a freelancer can speak.';
COMMENT ON COLUMN flingapp.languages.id IS 'The universally unique ID of a language';
COMMENT ON COLUMN flingapp.languages.language IS 'A name of a language';

/* core freelancer entity */
CREATE TABLE flingapp.freelancer(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
   firstName TEXT DEFAULT 'John',
   lastName TEXT DEFAULT 'Doe',
   isNS BOOLEAN NOT NULL DEFAULT true,
   location TEXT REFERENCES flingapp.country(country),
   timezone TEXT NOT NULL DEFAULT 'CST',
   primaryLanguage TEXT NOT NULL REFERENCES flingapp.languages(language)
);
-- comments for postgraphQL docs
COMMENT ON TABLE flingapp.freelancers IS 'A freelancer added to fling; Can be attached to a project and workhistory.';
COMMENT ON COLUMN flingapp.freelancers.id IS 'The universally unique ID of an organization';
COMMENT ON COLUMN flingapp.freelancers.firstName IS 'A freelancer''s first, or given name';
COMMENT ON COLUMN flingapp.freelancers.lastName IS 'An freelancer''s last, or family name';
COMMENT ON COLUMN flingapp.freelancers.isNS IS 'Whether or not the freelancer is a native speaker (of English).';
COMMENT ON COLUMN flingapp.freelancers.location IS 'Where the freelancer is located. References a country.'; 
COMMENT ON COLUMN flingapp.freelancers.timezone IS 'Which timezone the freelancer is in. References a tz database (https://www.iana.org/time-zones) timezone.'; 
COMMENT ON COLUMN flingapp.freelancers.primaryLanguage IS 'Which languages a freelancer primarily communicates in. References a language.';  

/* roles for any freelancers within your organization */
CREATE TABLE flingapp.freelancer_role(
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
