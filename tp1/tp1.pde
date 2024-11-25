//variables
//We provided more detailed explanations about variables below in the code
final int n_points = 1024;//number of points used to draw cake walls(one's in yellow)
final int external_radius = 200;//radius of the external wall of the cake
final int internal_radius = 190;//internal wall of the cake
final int z_height = 100;//height of the wall
final int z_floor = -120;//bottom points of the cake's walls(-120 to make it look as much as possibe as the one provided on eCampus).
final int sphere_z_translation = 30;//to place the sphere in the right place
final int sphere_rad = 190;//sphere_radius, this variable is used a lot of times
final int lagrange_count = 10;//this is for choclate generating, 10 represents the n in Langrange polynome related to (x1, x2, ..., xn), brifly, it's the number of points to use to generate the lagtrange polynome
final float radial_speed = 5 * PI * 4 / n_points;//radial speed is used to draw the small circles, it is choosen wisely so that to make the 4 sides of the space (x, -x, y, -y) point to the highest point of the small circle (not importante detail);

PVector lagrange_polynom_array[] = new PVector[lagrange_count];//this array will containt the 10 randomly generated points"lagrange_count", they will be used to generate the Lagrange polynome


//functions
PVector lagrange_polynom(float x) {
  //Funciton that takes x as parameter and returns the corresponding y coordintes of lagrange polynome assiciated to the 20 points of the array "lagrange_polynom_array"
  //We use this funciton to draw the white creame on the cake.
  float sum = 0;
  for (int b = 0; b < lagrange_count; b++) {
    float li = 1;
    for (int j = 0; j < lagrange_count; j++) 
      if (j != b) 
        li *= (x - lagrange_polynom_array[j].x) / (lagrange_polynom_array[b].x - lagrange_polynom_array[j].x);
    
    sum += li * lagrange_polynom_array[b].y;
  }
  return new PVector(x, sum, sqrt(sphere_rad * sphere_rad - x * x - sum * sum));
}

void setup() {
  size(800, 600, P3D);
  noLoop();
}

void draw() {
  //setting environement
  translate(width/2, height/2);
  rotateX(PI/3.2);
  background(255, 192, 255);
  stroke(243, 171, 102);
  strokeWeight(1);
  noStroke();

  //frawing the internal side of the cake's box
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= n_points; i++) {
    //we devise the circle to 'n_points' parts where 'n_points' is the number of points that will build that internal wall.
    float angle = 2 * PI * i / n_points;
    fill(145, 67, 0);
    //the variaition of the radius goes like 'internal_radius' + 20*cos(f(i)) where internal_radius is the radius value of the internal wall and f(i) is a funciton that depends on
    //i and the radial speed we use to draw the small circles
    //each iteration we draw two points, one in the bottom and the other on top, each two iterations we formulate a QUAD
    
    vertex((internal_radius + 20 * abs(cos(radial_speed * i))) * cos(angle), (internal_radius + 20 * abs(cos(radial_speed * i))) * sin(angle), z_floor);//z_floor is the Z value of a point that belongs to internal wall
    fill(254, 185, 113);
    vertex((internal_radius + 20 * abs(cos(radial_speed * i))) * cos(angle), (internal_radius + 20 * abs(cos(radial_speed * i))) * sin(angle), z_height);
  }
  endShape();

  fill(203, 125, 47);
  //building the roof between the two walls of the cake.
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= n_points; i++) {
    float angle = 2 * PI * i / n_points;
    vertex((external_radius + 20 * abs(cos(radial_speed * i))) * cos(angle), (external_radius + 20 * abs(cos(radial_speed * i))) * sin(angle), z_height);
    vertex((internal_radius + 20 * abs(cos(radial_speed * i))) * cos(angle), (internal_radius + 20 * abs(cos(radial_speed * i))) * sin(angle), z_height);
  }
  endShape();
  
  //Building the external wall of the cake's box
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= n_points; i++) {
    float angle = 2 * PI * i / n_points;
    fill(254, 185, 113);
    vertex((external_radius + 20 * abs(cos(radial_speed * i))) * cos(angle), (external_radius + 20 * abs(cos(radial_speed * i))) * sin(angle), z_height);
    fill(145, 67, 0);
    vertex((external_radius + 20 * abs(cos(radial_speed * i))) * cos(angle), (external_radius + 20 * abs(cos(radial_speed * i))) * sin(angle), z_floor);
  }
  endShape();
  
  //Building the floor of the cake's box TRIANGLE_FAN
  beginShape(TRIANGLE_FAN);
  fill(254, 185, 113);
  vertex(0, 0, 0);
  fill(145, 67, 0);
  for (int i = 0; i <= n_points; i++) {
    //same formla applied here
    float angle = 2 * PI * i / n_points;
    vertex((internal_radius + 20 * abs(cos(radial_speed * i))) * cos(angle), (internal_radius + 20 * abs(cos(radial_speed * i))) * sin(angle), z_floor);
  }
  endShape();
  
  translate(0, 0, sphere_z_translation);//this is for ensring a perfect placing of the sphere
  noStroke();
  fill(69, 30, 0);
  sphere(sphere_rad);
  
   // Adding white chocolate with Lagrange interpolation polynomial
   
   //the idea is : we select 'lagrange_count' points from the field (0<y<sphere_radius;  -sphere_radius<x<sphere_radius) randomly then we find the Lagrange polynome that passes 
   //from these points, by that, we form a polynom on the 2D plan (xy), after that we project each point of the polynom oon the sphere with beginShape()/endShape(), 
   //in this case we drew '500points to make it dense and looks like real chocolate.
  stroke(255,255, 255);
  strokeWeight(5);
  
  
  //Selecting 'lagrange_count' random points and storing them in 'lagrange_polynom_array'
  float x = -sphere_rad;
  for (int i = 0; i < lagrange_count; i++) {
    float limits=sqrt(sphere_rad * sphere_rad - x*x);
    float y = random(limits/2, limits);
    lagrange_polynom_array[i] = new PVector(x, y);
    x += 2 * sphere_rad / (lagrange_count-1);
  }


  //forming the Lagrange polynom with 500 points distributed equaly then projecting the graph on the sphere (making it 3D and creating the effect of tchoclate on the sirface of the cake)
  //we duplicate the polynome  and for each copy we put it above the other (of course we should always make it look like and it's on the surface)
  beginShape(POINTS);
  for (int i = 0; i < 500; i++) {
    float x_count = -sphere_rad + 2 * sphere_rad * i / 500;
    PVector v = lagrange_polynom(x_count);
    //building the base polynome
    vertex(v.x, v.y, v.z);
    for(int j = 0; j < 5; j++){
      //duplicating
      float tx = v.x-j*v.x/5, ty = v.y-j*v.y/5;
     vertex(tx, ty, sqrt(sphere_rad*sphere_rad - tx*tx - ty*ty)); 
    }
  }
  endShape();
}
