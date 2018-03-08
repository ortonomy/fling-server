<p align="center">
  <img src="full_title_compact@2x.png" />
</p>

# flingapp-backend

Fling-server is an express app running on node.js & postgraphql backend for a flingapp front-end -- available [here](https://github.com/ortonomy/flingapp-frontend)

For now, this server is only suitable for *DEVELOPMENT* purposes. Do not use in production!

## Run development server with test data 

IMPORTANT: 

````
./INSTALL [flingapp_admin_pass] [flingapp_postgraphql_pass]
npm install -g pm2
npm install
ADMINPASS=[flingapp_admin_pass] npm start
````

## Install Notes
- You must have postgreSQL running before running the install script.
- If you use ``pg_ctl`` instead of ``homebrew install postgresql`` to initialise your postgreSQL server, you need to make sure that there is a default DB called ``postgres`` and that there is a superuser for your ``currentuser`` before running the install script. (postgreSQL on Homebrew for OSX creates a ``postgres`` db and sets your logged in user as a superuser.)
- you need to pass the passwords you will use for the admin and postgraphql user to the install script, and also pass the password to npm start as environment variable ``ADMINPASS``
- API server runs on port ``3001``. 
- You'll need to open a port on your server firewall ``3001`` using ``ufw`` or put the server behind a reverse proxy.
- You'll need a ``.env`` file with the sparkpost API key. Without it, emailing from queue jobs will not work

## App logs
Use ``pm2`` CLI to monitor the app performance
``pm2 logs worker`` to see the queue output including emails
``pm2 logs main`` to see logs from graphql server

## Kill app
``npm run kill-dev`` will kill the daemon and all of the running processes


## API endpoints

``/graphql`` for all graphql queries
``/graphiql`` for self-documenting API reference


## This repository

The master branch is protected and the default branch is set to ``development``. 
