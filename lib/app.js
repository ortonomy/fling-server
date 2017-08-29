import express from 'express';
import postgraphql from 'postgraphql';

const PORT = process.env.PORT || 3000;

const app = express();

app.use(postgraphql('postgres://localhost:5432/flingapp-dev'));

app.get('/', function (req, res) {
  res.send('Hello World!');
})

app.listen(PORT, () => console.log(`Express app listening on ${PORT}`));
