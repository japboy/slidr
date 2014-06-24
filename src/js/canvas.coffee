'use strict'

{EventEmitter} = require 'events'

helper = require './helper'

d = global.document

vertex = """
attribute vec2 aPosition;
attribute vec2 aTexCoord;
attribute vec4 aColor;
uniform vec2 uResolution;
varying vec4 vColor;
varying vec2 vTexCoord;
void main () {
  vec2 zeroToOne = aPosition / uResolution;
  vec2 zeroToTwo = zeroToOne * 2.0;
  vec2 clipSpace = zeroToTwo - 1.0;
  gl_Position = vec4(clipSpace * vec2(1, -1), 0, 1);
  vColor = aColor;
  vTexCoord = aTexCoord;
}
"""

pixel = """
precision mediump float;

uniform sampler2D uImage;
uniform vec2 uTextureSize;
uniform float uAlpha;
uniform float uKernel[9];

varying vec4 vColor;
varying vec2 vTexCoord;

void main () {
  vec2 onePixel = vec2(1.0, 1.0) / uTextureSize;

  vec4 colorSum =
    texture2D(uImage, vTexCoord + onePixel * vec2(-1, -1)) * uKernel[0] +
    texture2D(uImage, vTexCoord + onePixel * vec2( 0, -1)) * uKernel[1] +
    texture2D(uImage, vTexCoord + onePixel * vec2( 1, -1)) * uKernel[2] +
    texture2D(uImage, vTexCoord + onePixel * vec2(-1,  0)) * uKernel[3] +
    texture2D(uImage, vTexCoord + onePixel * vec2( 0,  0)) * uKernel[4] +
    texture2D(uImage, vTexCoord + onePixel * vec2( 1,  0)) * uKernel[5] +
    texture2D(uImage, vTexCoord + onePixel * vec2(-1,  1)) * uKernel[6] +
    texture2D(uImage, vTexCoord + onePixel * vec2( 0,  1)) * uKernel[7] +
    texture2D(uImage, vTexCoord + onePixel * vec2( 1,  1)) * uKernel[8];

  float kernelWeight =
    uKernel[0] +
    uKernel[1] +
    uKernel[2] +
    uKernel[3] +
    uKernel[4] +
    uKernel[5] +
    uKernel[6] +
    uKernel[7] +
    uKernel[8];

  if (0.0 >= kernelWeight) {
    kernelWeight = 1.0;
  }

  //gl_FragColor = vColor;
  //gl_FragColor = texture2D(uImage, vTexCoord).bgra;
  //gl_FragColor = texture2D(uImage, vTexCoord);
  gl_FragColor = vec4((colorSum / kernelWeight).rgb, uAlpha);
}
"""

class WebGL extends helper.Base

  constructor: (el, ctx) ->
    super()

    @globalAlpha = 1.0

    @el_ = el
    @ctx_ = ctx
    @program_ = undefined
    @vertices_ = []
    @uniforms_ = []
    @textures_ = []
    @el_.addEventListener 'webglcontextlost', @contextlost, false
    @el_.addEventListener 'webglcontextrestored', @contextrestored, false

  contextlost: (ev) =>
    ev.preventDefault()
    console.log 'context lost.'

  contextrestored: (ev) =>
    @setup()
    console.log 'context restored.'

  createShader: (type, script) =>
    gl = @get 'ctx'
    shader = gl.createShader type
    gl.shaderSource shader, script
    gl.compileShader shader
    unless gl.getShaderParameter(shader, gl.COMPILE_STATUS)
      console.log gl.getShaderInfoLog(shader)
      gl.deleteShader shader
    return shader

  createProgram: (shaders...) =>
    gl = @get 'ctx'
    program = gl.createProgram()
    gl.attachShader program, shader for shader in shaders
    gl.linkProgram program
    unless gl.getProgramParameter(program, gl.LINK_STATUS)
      console.log gl.getProgramInfoLog(program)
      gl.deleteProgram program
    return program

  createVBO: (vertices) =>
    gl = @get 'ctx'
    data = new Float32Array vertices
    vbo = gl.createBuffer()
    gl.bindBuffer gl.ARRAY_BUFFER, vbo
    gl.bufferData gl.ARRAY_BUFFER, data, gl.STATIC_DRAW
    gl.bindBuffer gl.ARRAY_BUFFER, null
    return vbo

  bindVBO: (vbo, location, stride) =>
    gl = @get 'ctx'
    gl.bindBuffer gl.ARRAY_BUFFER, vbo
    gl.enableVertexAttribArray location
    gl.vertexAttribPointer location, stride, gl.FLOAT, false, 0, 0

  createIBO: (vertices) =>
    gl = @get 'ctx'
    data = new Int16Array vertices
    ibo = gl.createBuffer()
    gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, ibo
    gl.bufferData gl.ELEMENT_ARRAY_BUFFER, data, gl.STATIC_DRAW
    gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, null
    return ibo

  bindIBO: (ibo) =>
    gl = @get 'ctx'
    gl.bindBuffer gl.ELEMENT_ARRAY_BUFFER, ibo

  createTexture: =>
    gl = @get 'ctx'
    texture = gl.createTexture()
    gl.bindTexture gl.TEXTURE_2D, texture
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
    gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE
    return texture

  bindTexture: (texture, image) =>
    gl = @get 'ctx'
    gl.bindTexture gl.TEXTURE_2D, texture
    gl.texImage2D gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image

  createRect: (x, y, width, height) =>
    x1 = x
    x2 = x + width
    y1 = y
    y2 = y + height
    vertices = [
      x1, y1,
      x2, y1,
      x1, y2,
      x1, y2,
      x2, y1,
      x2, y2
    ]
    return vertices

  setup: =>
    gl = @get 'ctx'

    @set 'vetices', []
    @set 'uniforms', []
    @set 'textures', []

    gl.enable gl.BLEND

    vs = @createShader gl.VERTEX_SHADER, vertex
    ps = @createShader gl.FRAGMENT_SHADER, pixel

    program = @createProgram vs, ps
    @set 'program', program

    gl.useProgram program

    location = gl.getAttribLocation program, 'aPosition'
    @add 'vertices', { name: 'aPosition', ref: location, size: 2 }

    location = gl.getAttribLocation program, 'aColor'
    vertices = [
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0,
      1.0, 1.0, 1.0, 1.0
    ]
    vbo = @createVBO vertices
    @add 'vertices', { name: 'aColor', ref: location, vbo: vbo, size: 4 }

    location = gl.getAttribLocation program, 'aTexCoord'
    vertices = [
      0.0, 0.0,
      1.0, 0.0,
      0.0, 1.0,
      0.0, 1.0,
      1.0, 0.0,
      1.0, 1.0
    ]
    vbo = @createVBO vertices
    @add 'vertices', { name: 'aTexCoord', ref: location, vbo: vbo, size: 2 }

    texture = @createTexture()
    @add 'textures', { name: 'texture', texture: texture }

    location = gl.getUniformLocation program, 'uResolution'
    @add 'uniforms', { name: 'uResolution', ref: location }

  update: (width, height) =>
    gl = @get 'ctx'
    uniforms = @get 'uniforms'
    gl.viewport 0, 0, width, height
    gl.uniform2f uniforms[0].ref, width, height

  clear: (red, green, blue, alpha) =>
    gl = @get 'ctx'
    gl.clearColor (red / 255), (green / 255), (blue / 255), alpha
    gl.clearDepth 1.0
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

  drawImage: (image, sx, sy, width, height, blur=false) =>
    gl = @get 'ctx'
    program = @get 'program'
    vertices = @get 'vertices'
    textures = @get 'textures'

    vertices_ = @createRect sx, sy, width, height
    vbo = @createVBO vertices_

    @bindVBO vbo, vertices[0].ref, vertices[0].size

    @bindVBO vertices[1].vbo, vertices[1].ref, vertices[1].size
    @bindVBO vertices[2].vbo, vertices[2].ref, vertices[2].size

    @bindTexture textures[0].texture, image

    location = gl.getUniformLocation program, 'uTextureSize'
    gl.uniform2f location, width, height

    location = gl.getUniformLocation program, 'uKernel[0]'
    normal = [
      0, 0, 0,
      0, 1, 0,
      0, 0, 0
    ]
    sharpen = [
       -1, -1, -1,
       -1, 16, -1,
       -1, -1, -1
    ]
    triangleBlur = [
        0.0625, 0.125, 0.0625,
        0.125,  0.25,  0.125,
        0.0625, 0.125, 0.0625
    ]
    if blur
      gl.uniform1fv location, triangleBlur
    else
      gl.uniform1fv location, sharpen

    location = gl.getUniformLocation program, 'uAlpha'
    gl.uniform1f location, global.parseFloat(@globalAlpha)

    indexes = [
      0, 1, 2,
      1, 2, 5
    ]
    ibo = @createIBO indexes
    @bindIBO ibo

    #gl.drawArrays gl.TRIANGLES, 0, 6
    gl.drawElements gl.TRIANGLES, indexes.length, gl.UNSIGNED_SHORT, 0


class Context extends helper.mixOf helper.Base, EventEmitter

  constructor: (el, width, height) ->
    super()
    @el_ = el
    @ctx_ = el.getContext('webgl') or el.getContext('experimental-webgl')
    @img_ = undefined
    @width_ = width
    @height_ = height
    @x_ = 0
    @y_ = 0
    @alpha_ = 1
    @gl_ = new WebGL @el_, @ctx_

  resize: =>
    el = @get 'el'
    @set 'width', global.innerWidth
    @set 'height', global.innerHeight
    el.setAttribute 'width', @get('width')
    el.setAttribute 'height', @get('height')

  setup: =>
    gl = @get 'gl'
    gl.setup()

  update: =>
    gl = @get 'gl'
    img = @get 'img'
    width = @get 'width'
    height = @get 'height'

    gl.set 'img', img
    gl.set 'width', width
    gl.set 'height', height

    gl.update width, height
    gl.clear 255, 255, 255, 1

    data =
      container:
        width: width
        height: height
      actual:
        width: img.width
        height: img.height

    gl.globalAlpha = @get 'alpha'

    cover = helper.cover data
    x = (if width < cover.width then (width - cover.width) >> 1 else 0)
    y = (if height < cover.height then (height - cover.height) >> 1 else 0)
    x += @get('x')

    gl.drawImage img, x, y, cover.width, cover.height, true

    contain = helper.contain data
    x = 0
    y = (height >> 1) - (contain.height >> 1)
    x -= @get('x')

    gl.drawImage img, x, y, contain.width, contain.height

createContext = (el, w, h) ->
  context = new Context el, w, h
  context.resize()
  return context

# export
module.exports.createContext = createContext
