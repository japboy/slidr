'use strict'

###
# Fundamental classes and functions
###

_ = require 'underscore'


class Base

  constructor: ->

  set: (prop, val) =>
    @["#{prop}_"] = val

  get: (prop) =>
    return @["#{prop}_"]

  add: (prop, val) =>
    prop_ = @get prop
    prop_ = [] unless _.isArray(prop_)
    prop_.push val
    @set prop, prop_

mixOf = (base, mixins...) ->
  class Mixed extends base
  for mixin in mixins by -1
    Mixed::[name] = method for name, method of mixin::
  return Mixed

# export
module.exports =
  Base: Base
  mixOf: mixOf
