'use strict';

/**
 * Scale to cover like CSS
 */
function cover (data) {
  var containerRatio = data.container.height / data.container.width;
  var actualRatio = data.actual.height / data.actual.width;
  var result = {};
  if (containerRatio > actualRatio) {
    result.width = Math.round(data.container.height * actualRatio);
    result.height = data.container.height;
  } else {
    result.width = data.container.width;
    result.height = Math.round(data.container.width * actualRatio);
  }
  return result;
}

/**
 * Scale to contain like CSS
 */
function contain (data) {
  var containerRatio = data.container.width / data.container.height;
  var actualRatio = data.actual.width / data.actual.height;
  var result = {};
  if (containerRatio > actualRatio) {
    result.width = Math.round(data.container.height * actualRatio);
    result.height = data.container.height;
  } else {
    result.width = data.container.width;
    result.height = Math.round(data.container.width * actualRatio);
  }
  return result;
}

/**
 * Pad a number with leading zeros
 */
function pad (num, size) {
  if (num.toString().length >= size) return num;
  return (Math.pow(10, size) + Math.floor(num)).toString().substring(1);
}

// export
module.exports = {
  cover: cover,
  contain: contain,
  pad: pad
};
