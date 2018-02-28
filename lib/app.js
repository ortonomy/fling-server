// libraries
import dotenv from 'dotenv';
import express from 'express';
import postgraphql from 'postgraphql';
import cors from 'cors';
import proxy from 'http-proxy-middleware';
import modifyResponse from 'node-http-proxy-json';
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
      
      // log data for debugging purposes
      debuglog(JSON.parse(data.toString())); 
      

      if ( (JSON.parse(data.toString())).hasOwnProperty('errors') ) { // check for errors and return
        debuglog('API Error: failed on query to /register');
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
            html: appStrings.activateEmail(response.firstName, response.accountSelector, response.accountVerifier, ENV.HOST)
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


      // modify response before it goes back to reduce amount of exposed data in API response
      modifyResponse(res, proxyRes, body => {
        if ( body ) {
          
          // check not null response 
          if ( ! body.data.usrRegisterUser ) {
            return body;
          }


          // copy the body
          let modified = {
            ...body
          };
          

          // delete sensitive properties
          delete modified.data.usrRegisterUser.registeredUser.accountSelector;
          delete modified.data.usrRegisterUser.registeredUser.accountVerifier;

          
          // return the modified response
          return modified;
        }
      });


    })
  }
}));

app.post('/orgaccess', proxy(
    {
      target: 'http://localhost:3001',
      pathRewrite: {
        '^/orgaccess': '/graphql'
      },
      onProxyRes: (proxyRes, req, res) => {
        // when data arrives
        proxyRes.on('data', data => {
          

          // check for errors
          if ( (JSON.parse(data.toString())).hasOwnProperty('errors') ) { // check for errors and return
            debuglog('API Error: failed on query to /orgaccess'); // log it
            return; // silently fail
          }


          // log data for debugging purposes
          debuglog(JSON.parse(data.toString())); 
          
          // get the data
          const parsedData = JSON.parse(data.toString());
          const { accessRequest } = parsedData.data.requestAccessToOrg ? parsedData.data.requestAccessToOrg : null; // check to make sure it's the right request
          

          // send email
          if ( accessRequest ) {


            spClient.transmissions.send(
              {
                content: {
                  from: 'noreply@api.fling.work',
                  subject: `Request to access your fling.work organization.`,
                  html: appStrings.orgAccessEmail(accessRequest.adminFirstName, accessRequest.adminLastName, accessRequest.requestorFirstName, accessRequest.requestorLastName, accessRequest.orgName, accessRequest.selector, accessRequest.verifier, ENV.HOST)
                },
                recipients: [
                  {address: `${ accessRequest.adminEmail }`}
                ]
              }
            )
            .then(data => {
              debuglog('Email sent. Results follow: ');
              debuglog(data);
            })
            .catch(err => {
              debuglog('Whoops! Something went wrong');
              debuglog(err);
            });


          }


        });

        // modify response before it goes back to reduce amount of exposed data in API response
        modifyResponse(res, proxyRes, body => {
          if ( body ) {
            // check not null response 
            if ( !body.data || !body.data.requestAccessToOrg ) {
              return body;
            }
            // copy the body
            let modified = {
              data: {
                requestAccessToOrg: {
                  accessRequest: {
                    reqID: body.data.requestAccessToOrg.accessRequest.reqId ? body.data.requestAccessToOrg.accessRequest.reqId : null,
                    orgId: body.data.requestAccessToOrg.accessRequest.orgId ? body.data.requestAccessToOrg.accessRequest.orgId : null,
                    orgName: body.data.requestAccessToOrg.accessRequest.orgName ? body.data.requestAccessToOrg.accessRequest.orgName : null,
                    requestorID: body.data.requestAccessToOrg.accessRequest.requestorId ? body.data.requestAccessToOrg.accessRequest.requestorId : null,
                    requestStatus: body.data.requestAccessToOrg.accessRequest.requestStatus ? body.data.requestAccessToOrg.accessRequest.requestStatus : null
                  }
                }
              }
            };
            
            // return the modified response
            return modified;
          }
        });
      }
    }
  )
);


// trying to load by get
app.get('*', (req, res) => {
  res.send('<p>This API will not respond to get requests.</p>');
})


// set up app to listen on 3000 or env.
app.listen(PORT, () => console.log(`Express app listening on ${PORT}`));
