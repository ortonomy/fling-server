import express from 'express';
import postgraphql from 'postgraphql';

const app = express();

app.use(postgraphql('postgres://localhost:5432/flingapp-dev'));

app.get('/', function (req, res) {
  res.send('Hello World!');
})

app.listen(3000);