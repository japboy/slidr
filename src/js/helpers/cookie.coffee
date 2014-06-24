'use strict'

###
# Dot Notation Cookie Manager
# depends on [jquery.cookie](https://github.com/carhartl/jquery-cookie)
#
# TODO: Remove jQuery and jQuery.cookie dependencies
#
# Usage:
#
#  data = { b: 'c' }
#  cookie 'a', data
#  cookie 'a'    # -> { b: 'c' }
#  cookie 'a.b'  # -> 'c'
#  cookie 'a.b', 'X'
#  cookie()      # -> { a: { b: 'X' } }
#
###

mixin = require './mixin.coffee'


class Cookie extends mixin.Base

  constructor: (rootKey) ->
    @rootKey_ = rootKey
    $.cookie.json = true
    $.cookie @rootKey_, {}, { expires: 1, path: '/' } unless $.cookie @rootKey_
    @data_ = $.cookie @rootKey_

  update_: (data, path, val) =>
    key = path.replace /^([^.]+)\..+$/, "$1"
    left = path.replace /^[^.]+\.(.+)$/, "$1"
    return data[key] = val if -1 is path.indexOf '.'
    data[key] = {}
    @update_ data[key], left, val

  destroy: =>
    $.removeCookie @get('rootKey')
    @set 'rootKey', undefined
    @set 'data', undefined

  read: (path) =>
    data = @get 'data'
    keys = path.split '.'
    data = data[key] for key in keys
    return data

  save: (path, val) =>
    rootKey = @get 'rootKey'
    data = @get 'data'
    @update_ data, path, val
    @set 'data', data
    $.cookie rootKey, data, { expires: 1, path: '/' }

create = (rootKey) ->
  cookie = new Cookie rootKey
  return cookie

cookie_ = create +(new Date())

cookie = (path, val=undefined) ->
  return cookie_.get 'data' unless path or val
  return cookie_.read path if undefined is val
  cookie_.save path, val

# export
module.exports.cookie = cookie
