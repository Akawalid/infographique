PShader monProgrammeShader1, monProgrammeShader2;

void setup(){
  monProgrammeShader2 = loadShader("myFragmentShader2.glsl", 
               "myVertexShader2.glsl");//This shader will be used with the first sphere, it calculates color according to fragments and not vertexs,
               
  monProgrammeShader1 = loadShader("myFragmentShader.glsl", 
               "myVertexShader.glsl");
               
  size(800, 600, P3D);
  
  // Set material properties
  monProgrammeShader2.set("mambient", 0.2, 0.2, 0.2); // Set material ambient color to pinkish
  monProgrammeShader2.set("mdiffuse", 0.43, 0.15, 0.06); // Brownish color
  monProgrammeShader2.set("mspecular", 1.0, 1.0, 1.0); // White color

  monProgrammeShader2.set("shininess", 32.0); // Set shininess value
  
  //set light properties
  monProgrammeShader2.set("lambient", 0.2, 0.2, 0.2);
  monProgrammeShader2.set("ldiffuse", 0.6, 0.6, 0.6);
  monProgrammeShader2.set("lspecular", 1.0, 1.0, 1.0);

  float shininess = 20.0;  // Shininess
  monProgrammeShader2.set("shininess", shininess);
  
  background(0);

}

PShape sph(float r, float x, float y, float z){
  PShape sph=createShape(SPHERE, r);
  sph.translate(x, y, z);
  return sph;
}

void draw(){
  shader(monProgrammeShader2);
  //pointLight(255, 255, 255, mouseX, mouseY, 300); is replaced replaced with :
  monProgrammeShader2.set("lightPosition", mouseX, mouseY, 300, 1.0);
  translate(width/2, height/2);
  noStroke();
  fill(192, 128, 64);
  int radius=200;//radius of the big sohere
  sphere(radius);
  
  //after displaying the first sphere, we reset the shader and pass the one based on color interpolation
  resetShader();
  monProgrammeShader1.set("lightPosition", mouseX, mouseY, 300, 1.0);
  
  shader(monProgrammeShader1);
  int nb_spheres=3200;//number of small spheres to display
  fill(255*0.6, 255*0.3, 255*0.1);
  sphereDetail(10);
  for(int i=0; i<nb_spheres; i++){
     push();
     float theta=i * 40*PI/float(nb_spheres);
     float phi = i * PI / float(nb_spheres);
     float  r2 =radius*cos(PI/2.0 - phi); 
     translate(r2 * cos(theta), radius * cos(phi), r2 * sin(theta));//model matrix to trabnslate the spheres from local to world coordinates
     sphere(3);
     pop();
  }
  
}
