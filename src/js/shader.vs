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
