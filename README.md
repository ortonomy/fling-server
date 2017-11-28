<p align="center">
  <img src="full_title_compact@2x.png" />
</p>

# flingapp-backend

Fling-server is a node.js & postgraphql backend for a flingapp front-end -- available [here](https://github.com/ortonomy/flingapp-frontend)

For now, only the postgraphql schema is ready for development purposes.

Run 

````
psql -f design/db/setup.sql
psql -f design/db/seed-data-fixtures.sql
npm run dev
````

to get the schema imported, import test data fixtures and run the postgraphql server. 

