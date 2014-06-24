'use strict';

var _ = require('underscore');
var Q = require('q');

var d = global.document;

/**
 * Shorthand to create an element
 */
function createElement (name, attributes) {
  if (!_.isString(name) || !_.isObject(attributes)) return undefined;
  var el = d.createElement(name), prop;
  for (prop in attributes) el.setAttribute(prop, attributes[prop]);
  return el;
}

/**
 * Shorthand to remove an element
 */
function removeElement (el) {
  el.parentNode.removeChild(el);
}

/**
 * Shorthand to replace an attribute
 */
function replaceAttribute (el, attribute, value1, value2) {
  var value = el.getAttribute(attribute);
  el.setAttribute(attribute, value.replace(value1, value2));
}

/**
 * Shorthand to get document height
 */
function documentHeight () {
  var height = d.height ? d.height : Math.max(
    d.body.scrollHeight,
    d.body.offsetHeight,
    d.documentElement.clientHeight,
    d.documentElement.scrollHeight,
    d.documentElement.offsetHeight
  );
  return height;
}

/**
 * Shorthand to get scroll bar width
 */
function scrollbarWidth () {
  var outer = createElement('div', { style: {
    visibility: 'hidden', width: '100px', msOverflowStyle: 'scrollbar'
  } });
  d.body.appendChild(outer);
  var width1 = outer.offsetWidth;
  outer.style.overflow = 'scroll';
  var inner = createElement('div', { style: { width: '100%' } });
  outer.appendChild(inner);
  var width2 = inner.offsetWidth;
  removeElement(outer);
  return width1 - width2;
}

/**
 * Promise object for DOM
 */
function dom (name) {
  var dfr = Q.defer(), event = name ? name : 'DOMContentLoaded';
  d.addEventListener(event, function load (ev) {
    ev.target.removeEventListener(ev.type, load);
    dfr.resolve(ev.target);
  }, false);
  return dfr.promise;
}

/**
 * Promise object for Image element
 */
function img (uri) {
  var dfr = Q.defer(), img_ = d.createElement('img');
  img_.addEventListener('error', function error (ev) {
    ev.target.removeEventListener(ev.type, error);
    dfr.reject(new Error(uri));
  });
  img_.addEventListener('load', function load (ev) {
    ev.target.removeEventListener(ev.type, load);
    dfr.resolve(ev.target);
  });
  img_.crossOrigin = 'anonymous';
  img_.setAttribute('src', uri);
  return dfr.promise;
}

// export
module.exports = {
  createElement: createElement,
  removeElement: removeElement,
  replaceAttribute: replaceAttribute,
  documentHeight: documentHeight,
  scrollbarWidth: scrollbarWidth,
  dom: dom,
  img: img
};
