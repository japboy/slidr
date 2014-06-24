'use strict'

###
# Clock manager
###

mixin = require './mixin.coffee'


class Clock extends mixin.Base

  constructor: (millisec) ->
    super()
    @time_ = +(new Date())
    @span_ = millisec

  tick: =>
    now = +(new Date())
    @set 'time', now

  ticked: =>
    now = +(new Date())
    time = @get 'time'
    span = @get 'span'

    return false unless (now - time) > span

    @set 'time', now
    return true

create = (millisec) ->
  clock = new Clock millisec
  return clock

# export
module.exports.clock =
  create: create
