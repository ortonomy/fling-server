export const DEVELOPMENT = {
  DBHOST: 'localhost',
  DB: 'fling',
  GRAPHIQL: true,
  GRAPHQLROUTE: '/graphql',
  GRAPHIQLROUTE: '/graphiql',
  PGDEFAULTROLE: 'flingapp_anonymous',
  JWTROLE: ['role'],
  JWTSECRET: 'develop.DEVELOP',
  JWTPGTYPEIDENTIFIER: 'flingapp.jwt_token',
  WATCHPG: true,
  SHOWERRORSTACK: true,
  DISABLEQUERYLOG: false,
  PGQLUSER: 'flingapp_admin',
  PGQLPASS: 'FlingAppMakesItEasy',
  EXTENDEDERRORS: ['hint', 'detail', 'errcode'],
  HOST: 'http://localhost:3000'
};

export const PRODUCTION = {
  DBHOST: 'localhost',
  DB: 'fling',
  GRAPHIQL: false,
  GRAPHQLROUTE: '/graphql',
  GRAPHIQLROUTE: '/graphiql',
  PGDEFAULTROLE: 'flingapp_anonymous',
  JWTROLE: ['role'],
  JWTSECRET: 'production.IS.A.GREAT.place.TO.BE',
  JWTPGTYPEIDENTIFIER: 'flingapp.jwt_token',
  WATCHPG: false,
  SHOWERRORSTACK: false,
  DISABLEQUERYLOG: true,
  PGQLUSER: 'flingapp_postgraphql',
  PGQLPASS: 'YourFlingAppPassword',
  EXTENDEDERRORS: ['none'],
  HOST: 'https://fling.work'
};

