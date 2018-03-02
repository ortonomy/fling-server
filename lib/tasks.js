import dotenv from 'dotenv';
import SparkPost from 'sparkpost';

// load public constants
import * as CONFIG from './constants/env.js';

// load secret env variables from .env
dotenv.load();

// load public environment config strings based on node env
const ENV = CONFIG[process.env.NODE_ENV];

// app strings
import * as appStrings from './assets/copy.js';

// Spark Post client
const spClient = new SparkPost(process.env.SPARKPOSTAPIKEY);


module.exports = {
  registerEmail: async ({ debug, pgPool }, job) => {
    
    // get the job payload
    const { payload } = job; 
    
    // send the email
    spClient.transmissions.send(
      {
        content: {
          from: 'noreply@api.fling.work',
          subject: 'Activate your fling.work account',
          html: appStrings.activateEmail(payload.firstName, payload.selector, payload.verifier, ENV.HOST)
        },
        recipients: [
          {address: `${ payload.email }`}
        ]
      }
    )
    .then(data => {
      console.log('Email sent. Results follow: ');
      console.log(data);
    })
    .catch(err => {
      console.error('Whoops! Something went wrong');
      console.error(err);
      return err;
    });
  },
  validationEmail: async ({ debug, pgPool }, job) => {
    
    // get the job payload
    const { payload } = job;

    // send the email
    spClient.transmissions.send(
      {
        content: {
          from: 'noreply@api.fling.work',
          subject: `Request to access your fling.work organization.`,
          html: appStrings.orgAccessEmail(payload.adminFirstName, payload.adminLastName, payload.requestorFirstName, payload.requestorLastName, payload.orgName, payload.selector, payload.verifier, ENV.HOST)
        },
        recipients: [
          {address: `${ payload.adminEmail }`}
        ]
      }
    )
    .then(data => {
      console.log('Email sent. Results follow: ');
      console.log(data);
    })
    .catch(err => {
      console.error('Whoops! Something went wrong');
      console.error(err);
      return err;
    });
  }
}