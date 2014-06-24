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

