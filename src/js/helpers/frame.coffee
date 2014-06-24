'use strict'

###
# Frame manager
###

_ = require 'underscore'

mixin = require './mixin.coffee'


class Frame extends mixin.Base

  constructor: ->
    super()
    @started_ = false
    @funcs_ = []

  add: (func) =>
    funcs = @get 'funcs'
    funcs.push func
    @set 'funcs', funcs

  remove: (func) =>
    return @set('funcs', []) unless func
    funcs = _.without @get('funcs'), func
    @set 'funcs', funcs

  start: =>
    @set 'started', true

  stop: =>
    @set 'started', false

  run: =>
    return unless @get('started')
    func() for func in @get('funcs')

create =  ->
  frame = new Frame()
  return frame

# export
module.exports.frame =
  create: create
