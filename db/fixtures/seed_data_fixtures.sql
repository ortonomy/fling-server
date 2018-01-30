-- connect to the DB
\set flingadmin 'flingapp_admin'



\connect fling



SET ROLE :flingadmin;




DO $$
DECLARE  
   user1 flingapp.registered_user;
   org1 uuid;
   freelancer1 flingapp.freelancer;
   freelancer2 flingapp.freelancer;
   freelancer3 flingapp.freelancer;
   role1 flingapp.freelancer_role;
   role2 flingapp.freelancer_role;
   role3 flingapp.freelancer_role;
BEGIN  
  -- register a user
  SELECT * INTO user1 FROM flingapp.usr_register_user(first_name:='Gregory',last_name:= 'Orton', email:='dev@ortonomy.co', password:='12345678');
  RAISE NOTICE 'New user is: %', user1;
  RAISE NOTICE 'New user ID: % ', user1.user_id;
  



  -- create a new organization
  INSERT INTO flingapp.organization(
    org_name,
    org_admin,
    org_domain
  )
  VALUES (
    'ORTONOMY',
    user1.user_id,
    'ortonomy.com'
  )
  RETURNING org_id INTO org1;
  RAISE NOTICE 'New org ID is: %', org1;




  UPDATE flingapp_custom.user
  SET 
    user_org = org1
  WHERE flingapp_custom.user.user_id = user1.user_id;




  -- create a bunch of freelancers
  -- 1. 
  INSERT INTO flingapp.freelancer(
    fl_first_name,
    fl_last_name,
    fl_is_native_speaker,
    fl_assessment_submitted,
    fl_assessment_passed,
    fl_location,
    fl_timezone,
    fl_primary_language,
    fl_employment_status
  )
  VALUES
  (
    'James',
    'W.',
    false,
    true,
    true,
    'China',
    'Asia/Shanghai +08:00 (+08:00)',
    'English (US)',
    'full-time fixed schedule'
  )
  RETURNING * INTO freelancer1;
  -- 2. 
  INSERT INTO flingapp.freelancer(
    fl_first_name,
    fl_last_name,
    fl_is_native_speaker,
    fl_assessment_submitted,
    fl_assessment_passed,
    fl_location,
    fl_timezone,
    fl_primary_language,
    fl_employment_status
  )
  VALUES
  (
    'Aisi',
    'Y.',
    false,
    true,
    true,
    'China',
    'Asia/Shanghai +08:00 (+08:00)',
    'English (US)',
    'full-time fixed schedule'
  )
  RETURNING * INTO freelancer2;
  -- 3. 
  INSERT INTO flingapp.freelancer(
    fl_first_name,
    fl_last_name,
    fl_is_native_speaker,
    fl_assessment_submitted,
    fl_assessment_passed,
    fl_location,
    fl_timezone,
    fl_primary_language,
    fl_employment_status
  )
  VALUES
  (
    'Frank',
    'R.',
    true,
    true,
    true,
    'China',
    'Asia/Shanghai +08:00 (+08:00)',
    'English (US)',
    'full-time fixed schedule'
  )
  RETURNING * INTO freelancer3;
  RAISE NOTICE 'New freelancers #1 is: %', freelancer1;
  RAISE NOTICE 'New freelancers #2 is: %', freelancer2;
  RAISE NOTICE 'New freelancers #3 is: %', freelancer3;




  -- insert a bunch of freelancer roles
  -- 1.
  INSERT INTO flingapp.freelancer_role (
    fl_role
  )
  VALUES
  ( 'Academic lead' )
  RETURNING * INTO role1;
  -- 2.
  INSERT INTO flingapp.freelancer_role (
    fl_role
  )
  VALUES
  ( 'Chief editor' )
  RETURNING * INTO role2;
  -- 3.
  INSERT INTO flingapp.freelancer_role (
    fl_role
  )
  VALUES
  ( 'Writer' )
  RETURNING * INTO role3;
  RAISE NOTICE 'New role #1 is: %', role1;
  RAISE NOTICE 'New role #2 is: %', role2;
  RAISE NOTICE 'New role #3 is: %', role3;




  -- create a bunch of roles to freelancer maps
  INSERT INTO flingapp.freelancer_role_map (
    fl_role_map_freelancer,
    fl_role_map_role
  )
  VALUES
  (
    freelancer1.fl_id,
    role1.fl_role_id
  ),
  (
    freelancer1.fl_id,
    role2.fl_role_id
  ),
  (
    freelancer2.fl_id,
    role3.fl_role_id
  ),
  (
    freelancer3.fl_id,
    role2.fl_role_id
  ),
  (
    freelancer3.fl_id,
    role3.fl_role_id
  );




  -- map the freelancers to the org
  INSERT INTO flingapp.freelancer_org_map (
    freelancer_org_map_org,
    freelancer_org_map_freelancer
  )
  VALUES 
  (
    org1,
    freelancer1.fl_id
  ),
  (
    org1,
    freelancer2.fl_id
  ),
  (
    org1,
    freelancer3.fl_id
  );

END $$;



