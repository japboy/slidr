'use strict';

var _, Q, TWEEN, d3;

_ = require('underscore');
Q = require('q');
TWEEN = require('tween');
d3 = require('d3');

var helper = require('./helper');
var tumblr_ = require('./tumblr.coffee');
var canvas_ = require('./canvas.coffee');

var d = global.document;

var CONSUMER_KEY = '';

var clock = helper.clock.create(10000);
var frame = helper.frame.create();

var ws, tumblr, context;

function load (data) {
  var dfr, loader, loaderMask, loaderIcon, title, search;
  dfr = Q.defer();
  ws = data[1];
  loader = d3.select('.loader');
  loaderMask = loader.select('.loader__mask');
  loaderIcon = loaderMask.select('.loader__icon');
  title = d3.select('header > .title');
  search = d3.select('nav > .search');
  loaderIcon.on(helper.transitionend(), function (d, i) {
    loader.remove();
    title.classed({ 'fade--out': false, 'fade--in': 'true' });
  });
  title.on(helper.transitionend(), function (d, i) {
    search.classed({ 'fade--out': false, 'fade--in': true });
    dfr.resolve();
  });
  loaderIcon.classed({ 'fade--in': false, 'fade--out': true });
  return dfr.promise;
}

function message () {
  var dfr, sock;
  dfr = Q.defer();
  sock = d3.select(ws);
  sock.on('message', function (d, i) {
    var data = ('' === d3.event.data) ? {} : global.JSON.parse(d3.event.data);
    if (data.slidr) {
      sock.on('message', null);
      dfr.resolve(data.slidr);
    }
  });
  return dfr.promise;
}

function hash () {
  var dfr, query;
  dfr = Q.defer();
  query = global.decodeURIComponent(global.location.hash).replace(/#\//, '');
  if ('' === hash) {
    _.defer(dfr.resolve);
  } else {
    _.defer(function () { dfr.resolve(query); });
  }
  return dfr.promise;
}

function hashchange () {
  var dfr;
  dfr = Q.defer();
  d3.select(global).on('hashchange', function (d, i) {
    var query = global.decodeURIComponent(global.location.hash).replace(/#\//, '');
    d3.select(global).on('hashchange', null);
    dfr.resolve(query);
  });
  return dfr.promise;
}

function submit (query) {
  var dfr, form, input;
  dfr = Q.defer();
  form = d3.select('.search');
  input = form.select('.search__input');

  if (query) {
    _.defer(function () {
      input.property('value', query);
      form.classed({ 'position--in': false, 'position--out': true });
      global.location.hash = '#/' + global.encodeURIComponent(query);
      dfr.resolve(query);
    });
  } else {
    form.on('submit', function (d, i) {
      var value = input.property('value');
      d3.event.preventDefault();
      form.on('submit', null);
      form.classed({ 'position--in': false, 'position--out': true });
      global.location.hash = '#/' + global.encodeURIComponent(value);
      ws.send(global.JSON.stringify({ 'slidr': value }));
      dfr.resolve(value);
    });
  }

  return dfr.promise;
}

function api () {
  var keyword, target, offset, dfr;
  keyword = _.isString(arguments[0]) ? arguments[0] : undefined;
  target = _.isObject(arguments[0]) ? arguments[0] : tumblr_.create(keyword, CONSUMER_KEY);
  tumblr = target;
  offset = _.isNumber(arguments[1]) ? arguments[1] : 0;
  dfr = Q.defer();
  target.on('load', dfr.resolve);
  target.on('error', dfr.reject);
  target.request('photo', offset);
  return dfr.promise;
}

function cache (data) {
  var dfr, posts, photos, images, uris;
  dfr = Q.defer();
  posts = data.posts ? data.posts : data;
  photos = _.flatten(_.pluck(posts, 'photos'));
  images = _.pluck(_.without(photos, undefined), 'original_size');
  uris = _.filter(_.pluck(images, 'url'), function (url) {
    return -1 === url.indexOf('31.media.tumblr.com');
  });
  if (1 > uris.length) {
    _.defer(function () { dfr.reject(new Error('Empty')); });
  } else {
    helper.cache(uris, helper.img).then(dfr.resolve, dfr.reject);
  }
  return dfr.promise;
}

function next () {
  var dfr;
  dfr = Q.defer();
  d3.select(d).on('keydown', function (d, i) {
    if (32 === d3.event.keyCode) dfr.resolve();
  });
  return dfr.promise;
}

function fail (err) {
  submit()
    .then(api, fail)
    .then(cache, fail)
    .then(show, fail);

  console.error(err.message);
}

function show (images) {
  var inc = 0, len = images.length, offset = 1;

  context.set('img', images[inc]);
  context.set('x', 100);
  context.set('alpha', 0.0);
  context.setup();

  frame.stop();
  frame.remove();
  frame.add(auto);
  frame.add(context.update);
  frame.add(TWEEN.update);
  frame.start();

  var initialFadeIn = new TWEEN.Tween({ x: 100, alpha: 0.0 })
    .to({ x: 0, alpha: 1.0 }, 500)
    .onUpdate(function () {
      context.set('x', this.x);
      context.set('alpha', this.alpha);
    })
    .onComplete(function () {
      TWEEN.remove(initialFadeIn);
    })
    .start();

  clock.tick();
  bind();

  message()
    .then(submit, fail)
    .then(api, fail)
    .then(cache, fail)
    .then(show, fail);

  hashchange()
    .then(submit, fail)
    .then(api, fail)
    .then(cache, fail)
    .then(show, fail);

  submit()
    .then(api, fail)
    .then(cache, fail)
    .then(show, fail);

  function bind () {
    next().then(slide).then(bind);
  }

  function auto () {
    if (clock.ticked()) slide();
  }

  function slide () {
    var dfr, fadeIn, fadeOut;
    dfr = Q.defer();
    clock.tick();
    fadeIn = new TWEEN.Tween({ x: 0, alpha: 1.0 })
      .to({ x: 100, alpha: 0.0 }, 500)
      .onUpdate(function () {
        context.set('x', this.x);
        context.set('alpha', this.alpha);
      })
      .onComplete(function () {
        if (0 !== offset && inc === (len >> 1)) {
          api(tumblr, (20 * offset)).then(cache).then(function (images_) {
            images = _.union(images, images_);
            len = images.length;
          }, fail);
          offset = 20 * offset >= tumblr.get('total') ? 0 : offset + 1;
        }
        inc += 1;
        if (inc >= len) inc = 0;
        context.set('img', images[inc]);

        fadeOut = new TWEEN.Tween({ x: 100, alpha: 0.0 })
          .to({ x: 0, alpha: 1.0 }, 500)
          .onUpdate(function () {
            context.set('x', this.x);
            context.set('alpha', this.alpha);
          })
          .onComplete(function () {
            TWEEN.remove(fadeIn);
            TWEEN.remove(fadeOut);
            dfr.resolve();
          })
          .start();
      })
      .start();
    return dfr.promise;
  }
}

function animate (now) {
  global.requestAnimationFrame(animate);
  frame.run();
}

function init () {
  var main, canvas;
  canvas = d3.select('#main > .view');
  context = canvas_.createContext(canvas.node(), global.innerWidth, global.innerHeight);

  global.addEventListener('resize', context.resize, false);

  context.on('lost', frame.stop);
  context.on('restored', frame.start);

  Q.all([ helper.dom(), helper.ws('wss://wss.jit.su'), helper.sleep(1500) ])
    .then(load, fail)
    .then(hash, fail)
    .then(submit, fail)
    .then(api, fail)
    .then(cache, fail)
    .then(show, fail);

  animate(+(new Date()));
}

init();
