<p align="center">
  <img src="full_title_compact@2x.png" />
</p>

# flingapp-backend

Fling-server is an express app running on node.js & postgraphql backend for a flingapp front-end -- available [here](https://github.com/ortonomy/flingapp-frontend)

For now, this server is only suitable for *DEVELOPMENT* purposes. Do not use in production!

## Run development server with test data 

````
psql -f design/db/setup.sql
psql -f design/db/seed-data-fixtures.sql
npm install
npm start
````

Note, Server runs on port ``3001``. 

N.B. You'll need to open a port on your server firewall ``3001`` using ``ufw`` or put the server behind a reverse proxy.

## API endpoints

``/graphql`` for all graphql queries
``/register`` will send an email with registration details if the graphql mutation ``userRegisterUser`` is sent in body of a request. You'll need the .env file for this with SparkPost API key.

## This GIT repository
The master branch is protected and the default branch is set to ``development``. 
