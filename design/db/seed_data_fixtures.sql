-- connect to the DB
\connect fling

-- insert test user into private
DECLARE
  u_id UUID;

BEGIN
INSERT INTO flingapp_private.user_account(email, password_hash) VALUES ('john.doe@example.com',crypt('12345678', gen_salt('bf', 8))) RETURNING user_acc_id INTO u_id;
COMMIT;
