-- connect to the DB
\connect fling

INSERT INTO flingapp_private.user_account(email, password_hash) VALUES ('john.doe@example.com',crypt('12345678', gen_salt('bf', 8)));