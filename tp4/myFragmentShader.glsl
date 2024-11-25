#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec4 vertPosition;

void main() {
  gl_FragColor = vertColor;
}