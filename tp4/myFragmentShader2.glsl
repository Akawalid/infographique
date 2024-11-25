#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
uniform vec4 lightPosition;
varying vec3 normal_v;//the interpolated normal vector (NOT NORMALIZED)
varying vec3 position_v;//the interpolated position (PIXEL POSITION)

uniform vec3 mambient;
uniform vec3 mdiffuse;
uniform vec3 mspecular;
uniform float shininess;
 
uniform vec3 lambient;
uniform vec3 ldiffuse;
uniform vec3 lspecular;

void main() {

  vec3 direction = normalize(lightPosition.xyz - position_v);   


  //the direction from vertex to light fragment (interpolated)
  //float dist = length(lightPosition.xyz - position_v);
  //float att = 1.0/(1.0 + 0.1*dist + 0.01*dist*dist);//when we move camera farther we get smaller light affection on surface (quadratic attenuatoin)
  //attenuation can be used with camera animation, but in this example I didn't use it because I didn't add animaitons

//=============================AMBIENT=======================================
  vec3 ambient = mambient * lambient;//ambient light is defineed by product in physics
//============================================================================



//=============================DIFFUSE=======================================
  vec3 norm = normalize(normal_v);//normlized normal vector, will be used in dot product to calculate the diffuse light
  float dCont = max(0.0, dot(norm, direction));//diffusion light contribution, it depends on the angle between normal
                                              // and direction to light vector, it's maximal when light is perpendicular and minimal when light is parallel
  vec3 diffuse = dCont * mdiffuse * ldiffuse;
//============================================================================



//=============================SPECULAR=======================================
  vec3 refl = reflect(-direction, norm);//refl is the reflected light vector, by definition it's the symetric vector of the direction to light vector 
                                        //according to the normal, the '-' is for directing it in the exact sens 
  vec3 view=normalize(-position_v);//represents the player, to be more clear it's cameraCords - ecPosition = 0 - ecPosition= -ecPosition
  float sCont = pow(max(0.0, dot(refl, view)), shininess); //contribution of speculat depends on the angle between the reflected light and the normal light
                                                          //Shininess is to make the specular gathered in one point to make it more realistic
  vec3 specular=sCont*mspecular*lspecular;
//============================================================================

  gl_FragColor = vec4(ambient+diffuse+specular, 1.0); 
}