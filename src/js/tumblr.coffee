'use strict'

{EventEmitter} = require 'events'

helper = require './helper'

class Blog extends helper.mixOf helper.Base, EventEmitter

  constructor: (domain, consumerKey) ->
    super()
    @consumerKey_ = consumerKey
    @domain_ = domain
    @total_ = 20

  destroy: =>
    @removeAllListeners()

  request: (type, offset=0) =>
    consumerKey = @get 'consumerKey'
    domain = @get 'domain'
    uri = "http://api.tumblr.com/v2/blog/"
    uri += "#{domain}/posts/#{type}?api_key=#{consumerKey}&offset=#{offset}"
    done = (data) =>
      if 200 is data.meta.status
        @set 'total', data.total_posts
        return @emit 'load', data.response
      @emit 'error', new Error(data.meta.status + ' ' +  data.meta.msg)
    fail = (err) => @emit 'error', err
    helper.jsonp(uri).then(done, fail)


class Tagged extends helper.mixOf helper.Base, EventEmitter

  constructor: (tag, consumerKey) ->
    super()
    @consumerKey_ = consumerKey
    @tag_ = tag
    @total_ = 20

  destroy: =>
    @removeAllListeners()

  request: () =>
    consumerKey = @get 'consumerKey'
    tag = global.encodeURIComponent @get('tag')
    uri = "http://api.tumblr.com/v2/tagged"
    uri += "?tag=#{tag}&api_key=#{consumerKey}"
    done = (data) =>
      return @emit('load', data.response) if 200 is data.meta.status
      @emit 'error', new Error(data.meta.status + ' ' +  data.meta.msg)
    fail = (err) => @emit 'error', err
    helper.jsonp(uri).then(done, fail)


create = (keyword, consumerKey) ->
  if null is keyword.match /^([a-zA-Z0-9-]+\.)?[a-zA-Z0-9]+\.[a-zA-Z0-9]+$/
    tagged = new Tagged keyword, consumerKey
    return tagged
  else
    blog = new Blog keyword, consumerKey
    return blog

module.exports.create = create
