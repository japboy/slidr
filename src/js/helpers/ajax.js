'use strict';

var Q = require('q');
var _ = require('underscore');

var d = global.document;

/**
 * Promise object for JSONP
 */
function jsonp (uri) {
  var dfr = Q.defer(), script = d.createElement('script');
  global.___jsonp = function (data) { dfr.resolve(data); };
  script.setAttribute('src', uri + '&callback=___jsonp');
  d.getElementsByTagName('head')[0].appendChild(script);
  return dfr.promise;
}

/**
 * Promise object for XHR
 */
function xhr (method, uri, data_) {
  var dfr = Q.defer(), req = new global.XMLHttpRequest(), data = data_ ? data_ : null;
  req.addEventListener('readystatechange', function (ev) {
    if (4 === ev.target.readyState && 200 === ev.target.status) {
      dfr.resolve(global.JSON.parse(ev.target.responseText));
    }
  });
  req.open(method, uri, true);
  req.send(data);
  return dfr.promise;
}

/**
 * Promise object for WebSocket
 */
function ws (uri) {
  var dfr = Q.defer(), sock = new global.WebSocket(uri);
  sock.addEventListener('open', function open (ev) {
    ev.target.removeEventListener(ev.type, open);
    dfr.resolve(sock);
  }, false);
  sock.addEventListener('error', function error (ev) {
    ev.target.removeEventListener(ev.type, error);
    dfr.reject(new Error('ws error'));
  }, false);
  return dfr.promise;
}

// export
module.exports = {
  jsonp: jsonp,
  xhr: xhr,
  ws: ws
};
