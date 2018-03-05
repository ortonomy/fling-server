// libraries
import dotenv from 'dotenv';
import express from 'express';
import postgraphile from 'postgraphile';
import cors from 'cors';
import SparkPost from 'sparkpost';

// load public constants
import * as CONFIG from './constants/env.js';

// app strings
import * as appStrings from './assets/copy.js';

// environment settings
const PORT = process.env.PORT || 3001;
const ENV = CONFIG[process.env.NODE_ENV];
dotenv.load();

// DEBUG 
const debuglog = (message) => {
  if ( process.env.NODE_ENV === 'DEVELOPMENT' ) {
    console.log(message);
  }
  return;
};

// Spark Post client
const spClient = new SparkPost(process.env.SPARKPOSTAPIKEY);

// http server
const app = express();

app.use(cors({
  origin: 'http://localhost:3000'
}));

app.use(postgraphile(`postgres://${ENV.PGQLUSER}:${ENV.PGQLPASS}@localhost:5432/fling`,'flingapp',{
  graphiql: ENV.GRAPHIQL,
  graphqlRoute: ENV.GRAPHQLROUTE,
  graphiqlRoute: ENV.GRAPHIQLROUTE,
  pgDefaultRole: ENV.PGDEFAULTROLE,
  jwtRole: ENV.JWTROLE,
  jwtSecret: ENV.JWTSECRET,
  jwtPgTypeIdentifier: ENV.JWTPGTYPEIDENTIFIER,
  watchPg: ENV.WATCHPG,
  showErrorStack: ENV.SHOWERRORSTACK,
  disableQueryLog: ENV.DISABLEQUERYLOG,
  extendedErrors: ENV.EXTENDEDERRORS
}));

// trying to load by get
app.get('*', (req, res) => {
  res.send('<p>This API will not respond to get requests.</p>');
})


// set up app to listen on 3000 or env.
app.listen(PORT, () => console.log(`Express app listening on ${PORT}`));
