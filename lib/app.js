// libraries
import dotenv from 'dotenv';
import express from 'express';
import postgraphql from 'postgraphql';
import cors from 'cors';
import proxy from 'http-proxy-middleware';
import axios from 'axios';
import SparkPost from 'sparkpost';

// constants
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

app.use(postgraphql(`postgres://${ENV.PGQLUSER}:${ENV.PGQLPASS}@localhost:5432/fling`,'flingapp',{
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

app.post('/register', proxy({
  target: 'http://localhost:3001', 
  changeOrigin: true, // remove need for CORS
  pathRewrite: {
    '^/register' : '/graphql' // rewrite path 
  },
  onProxyRes: (proxyRes, req, res) => {
    proxyRes.on('data', data  => { // check the proxy response data
      debuglog(JSON.parse(data.toString()));
      if ( (JSON.parse(data.toString())).hasOwnProperty('errors') ) { // check for errors and return
        debuglog('There\'s an error in the response');
        return;
      }
      const parsedData = JSON.parse(data.toString());
      const response = parsedData.data.usrRegisterUser ? parsedData.data.usrRegisterUser.registeredUser : null; // check to make sure it's the right request
      // else send an activation email
      if ( response ) {
        spClient.transmissions.send({
          content: {
            from: 'noreply@api.fling.work',
            subject: 'Activate your fling.work account',
            html: appStrings.activateEmail(response.firstName, response.accountSelector, response.accountVerifier,ENV.HOST)
          },
          recipients: [
            {address: `${ response.email }`}
          ]
        })
        .then(data => {
          debuglog('Email sent. Results follow: ');
          debuglog(data);
        })
        .catch(err => {
          debuglog('Whoops! Something went wrong');
          debuglog(err);
        });
      }
    })
  }
}));

// trying to load by get
app.get('*', (req, res) => {
  res.send('<p>This API will not respond to get requests.</p>');
})


// set up app to listen on 3000 or env.
app.listen(PORT, () => console.log(`Express app listening on ${PORT}`));
