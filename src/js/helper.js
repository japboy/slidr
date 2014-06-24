'use strict';

var _ = require('underscore');

require('./helpers/prefixed');
require('./helpers/socials');

var functions = [
  require('./helpers/ajax'),
  require('./helpers/clock.coffee'),
  require('./helpers/css'),
  require('./helpers/dom'),
  //require('./helpers/eval'),
  require('./helpers/frame.coffee'),
  require('./helpers/mixin.coffee'),
  require('./helpers/promise'),
  require('./helpers/transform'),
  //require('./helpers/vector')
];

var helper = {};

_.map(functions, function (mod) {
  for (var func in mod) helper[func] = mod[func];
});

module.exports = helper;
