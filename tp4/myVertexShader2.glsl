//for the big sphere shader, I tried to make it more realistic, 
//I followed some videos on youtub then I tried to implement what I have learnt
//In this shader, I included ambient lighthing ,diffuse and specular

uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;

uniform vec4 lightPosition;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

varying vec3 position_v;//position of the vertex in the view coordinates will be passed to FragmentShader2
varying vec3 normal_v;//Noemal vector that wil be passed to fragment file

void main() {
  gl_Position=transform*position; //output position with projection
  position_v=vec3(modelview*position);    //get the position of the vertex after translation, rotation, scaling
  normal_v=normalMatrix*normal;   //get the normal vector to the vector in view coordinates, normalMatrix=TRANSPOSE(modelViewMatrix^-1)
                                  //we can't translate the normal with the same modelview matrix, because it doesnt take in consideration vectors, 
                                  //but points, to find this matrix we need to passe through plan equautions, and linear syystems solving according 
                                  //what is mentionned in the website songho.ca

}