'use strict';

var _express = require('express');

var _express2 = _interopRequireDefault(_express);

var _postgraphql = require('postgraphql');

var _postgraphql2 = _interopRequireDefault(_postgraphql);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var app = (0, _express2.default)();

app.use((0, _postgraphql2.default)('postgres://localhost:5432/flingapp-dev'));

app.get('/', function (req, res) {
  res.send('Hello World!');
});

app.listen(3000);