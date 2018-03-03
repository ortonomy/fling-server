<p align="center">
  <img src="full_title_compact@2x.png" />
</p>

# flingapp-backend

Fling-server is an express app running on node.js & postgraphql backend for a flingapp front-end -- available [here](https://github.com/ortonomy/flingapp-frontend)

For now, this server is only suitable for *DEVELOPMENT* purposes. Do not use in production!

## Run development server with test data 

````
./INSTALL
npm install -g pm2
npm install
npm start
````

## Notes
- API server runs on port ``3001``. 
- You must have postgreSQL running before running the install script.
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
