int LAB_SIZE = 21;
char labyrinthe [][];
char sides [][][];
int BOX_SIZE = 160,//taille de cube de le grand labyrinthe
    S_BOX_SIZE=1,//Petit labyrinthe en gauche
    anim=-1;// pour l'animation des mouvements, si il est è -1 veut dire pas d'animation, 0 : fin de l'animation, 20: début animation
float cameraZ=(height/2.0) / tan(PI*60.0/360.0), lx, ly, lz;
boolean anim_rot,//pour dire s'il s'agit d'une animation de rotation gauche, droite
        half_rot,//boolean pour dire s'il s'agit d'animation de rotation 180°
        call_bot,//Boolean pour dire c'est l'utilisateur qui va trouver le chemin ou de laisser ça au bot de résolution (automatique)
        goAhead=false;

int posX=1, posY=0,//position actuelle
    dirX=1, dirY=0,//direction actuelle
    prevDX, prevDY;//direction précédentre pour l'animation de rotation
PImage txtr, txtrSol;//textures
ArrayList<Integer> l = null;//le tableau que le bot va suivre pour trouver le chemin(automatisme)

void setup() {
  frameRate(20);
  //randomSeed(2);
  size(1200, 600, P3D);
  perspective(PI/3.0, width/height, cameraZ/10.0, cameraZ*30.0);
  labyrinthe = new char[LAB_SIZE][LAB_SIZE];
  sides = new char[LAB_SIZE][LAB_SIZE][5];
  int todig = 0;
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      sides[j][i][0] = 0;
      sides[j][i][1] = 0;
      sides[j][i][2] = 0;
      sides[j][i][3] = 0;
      sides[j][i][4]=0;//non visité
      if (j%2==1 && i%2==1) {
        labyrinthe[j][i] = '.';
        todig ++;
      } else
        labyrinthe[j][i] = '#';
    }
  }
  int gx = 1;
  int gy = 1;
  while (todig>0 ) {
    int oldgx = gx;
    int oldgy = gy;
    int alea = floor(random(0, 4)); // selon un tirage aleatoire
    if      (alea==0 && gx>1)          gx -= 2; // le fantome va a gauche
    else if (alea==1 && gy>1)          gy -= 2; // le fantome va en haut
    else if (alea==2 && gx<LAB_SIZE-2) gx += 2; // .. va a droite
    else if (alea==3 && gy<LAB_SIZE-2) gy += 2; // .. va en bas

    if (labyrinthe[gy][gx] == '.') {
      todig--;
      labyrinthe[gy][gx] = ' ';
      labyrinthe[(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
    }
  }

  labyrinthe[0][1]                   = ' '; // entree
  labyrinthe[LAB_SIZE-2][LAB_SIZE-1] = ' '; // sortie

  for (int j=1; j<LAB_SIZE-1; j++) {
    for (int i=1; i<LAB_SIZE-1; i++) {
      if (labyrinthe[j][i]==' ') {
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]==' ' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]=='#')
          sides[j-1][i][0] = 1;// c'est un bout de couloir vers le haut 
        if (labyrinthe[j-1][i]==' ' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]=='#')
          sides[j+1][i][3] = 1;// c'est un bout de couloir vers le bas 
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]==' ' && labyrinthe[j][i+1]=='#')
          sides[j][i+1][1] = 1;// c'est un bout de couloir vers la droite
        if (labyrinthe[j-1][i]=='#' && labyrinthe[j+1][i]=='#' &&
          labyrinthe[j][i-1]=='#' && labyrinthe[j][i+1]==' ')
          sides[j][i-1][2] = 1;// c'est un bout de couloir vers la gauche
      }
    }
  }

  
  // un affichage texte pour vous aider a visualiser le labyrinthe en 2D
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      print(labyrinthe[j][i]);
    }
    println("");
  }
  
  sides[posY][posX][4]=1;//déja exploré, la position initiale
  txtrSol=loadImage("z.jpg");//charger les textures
  txtr=loadImage("z.jpg");
  textureMode(NORMAL);
}

void set_camera(float e1, float e2, float e3, float d1, float d2, float d3, float l1, float l2, float l3){
  //cette fonciton nous aide à définir la position de la camera en passant des paramètres simples (sans multiplication par BOX_SIZE...
  camera((e1 + 0.5) * BOX_SIZE, (e2 + 0.5) * BOX_SIZE, e3 * BOX_SIZE, (d1 + 0.5) * BOX_SIZE, (d2 + 0.5) * BOX_SIZE, d3 * BOX_SIZE, l1, l2, l3);
  
  //Pour la lumière au dessus du joueur
  lx=(e1 + 0.5) * BOX_SIZE;
  ly=(e2 + 0.5) * BOX_SIZE;
  lz=e3 * BOX_SIZE;
}

void draw(){
  background(200);//actualiser l'écrane
  if(!goAhead){
    textSize(20);
    fill(0);
    textAlign(CENTER);
    text("Cliquer sur ESPACE pour lancer le bot de résolution automatique.\nCliquer ENTRER pour commencer.\nMais il faut cliquer sur ENTRER avant, pour commencer le jeu.\nLe bot peut être lancé n'importe où dans le labyrinthe.", width/2, height/2);
   
    } else {
  
  //affichage de le petit labyrinthe en haut gauche
  camera(0, 0, 0.4 * BOX_SIZE, 0, 0, 0, 0, 1, 0);
  push();
  translate(-72 , -35, 0);
  draw_laby_box();
  pop();
  
  //pour faire varier anim entre 0 et 20 //<>//
  float scaled_anim=1 - anim/20.0;
  
  //pour dire que le type d'animation et deplacement directe(non rotatif)
  if(!anim_rot){
    if(anim > 0){
      //rendre le déplacement quadratique
      scaled_anim *= scaled_anim;
        set_camera(posX+dirX*scaled_anim, posY+dirY*scaled_anim, -0.003*(anim-10)*(anim-10)+1.3,                posX+dirX, posY+dirY, -0.003*(anim-10)*(anim-10)+1.3,            0, 0, -1);
        anim--;
    }
    else if(anim == 0) {
      //à la fin de l'animation, mis à jour les ancienes positions vers les nouvelles positions
      posX=posX+dirX;
      posY=posY+dirY;
      //rendre la case visité
      sides[posY][posX][4]=1;
      
      //on a traité la fin de l'animation, on n'execte pas ce block d eelse if dans la prochaine éxécution de draw()
      anim=-1;
    }
  }
  else {
    //animation de rotation
      if(anim > 0){
        scaled_anim = sqrt(scaled_anim);//au début la rotation soit rapide puis elle se ralenti
        if(half_rot)
        //animation quand on clique sur la touche bas du clavier, rotation de 180°
          set_camera(posX, posY, 1,                posX-dirY * sin(scaled_anim * PI) + prevDX * cos(scaled_anim * PI), posY+dirX * sin(scaled_anim * PI) + prevDY * cos(scaled_anim * PI), 1,            0, 0, -1);
        else
          set_camera(posX, posY, 1,                posX+dirX * sin(scaled_anim * PI/2.0) + prevDX * cos(scaled_anim * PI/2.0), posY+dirY * sin(scaled_anim * PI/2.0) + prevDY * cos(scaled_anim * PI/2.0), 1,            0, 0, -1);
        anim--;
      } else if(anim == 0) {
      //fin d'animation, remmetre anim à -1 pour ne pas éxecuter ce block dans les prochaines itérations
      anim=-1;
    }
  }
  if(anim == -1)
    //ce block sert à positioner la camera en cas d'immobilité, après le position de le petit labyrinthe
    set_camera(posX, posY, 1,                posX+dirX, posY+dirY, 1,            0, 0, -1);
  
  lightFalloff(1.0, 0.01, 0.0); // Increase the second parameter value to make the light more intense in the front
  pointLight(255, 255, 255, lx, ly, lz);
    
      
   //afficher les petites spheres allumantes
  int [] lum_fond = fond_du_couloir();
  if(lum_fond != null){
    lightFalloff(1.0, 0, 0);
    pointLight(255, 255, 255, (lum_fond[0] + 0.5)*BOX_SIZE, (lum_fond[1] + 0.5)*BOX_SIZE, BOX_SIZE*1.5);
    draw_light(lum_fond[0], lum_fond[1]);
  }
  
  //dessiner le grand labyrinthe 
  draw_laby();
  
  
  //cette partie c'est pour déclancher le bot pour la résolution automatique du labyrinthe
  if(call_bot){
      boolean[][] visited = new boolean[LAB_SIZE][LAB_SIZE];
      for (int j = 0; j < LAB_SIZE; j++) 
        for (int i = 0; i < LAB_SIZE; i++) 
          visited[j][i] = false;
      l = resoudre_laby(posX, posY, new ArrayList<Integer>(), visited);
      l.remove(0);
      l.remove(0);
      call_bot=false;
      half_rot=false;
  }
  
    int n_posY=0, n_posX=0;
    if (anim == -1 && l != null && !l.isEmpty()) {
      n_posY = l.remove(0);
      n_posX = l.remove(0);
      if(n_posX==posX+dirX && n_posY == dirY+posY){

        anim_rot=false;
      }
      else{
        anim_rot=true;
        prevDX=dirX;
        prevDY=dirY;
        dirX = n_posX - posX;
        dirY = n_posY - posY;
        l.add(0, n_posX);
        l.add(0, n_posY);
      }
      anim = 20;
      redraw();
    }
  }
}


void draw_laby_box(){
  // petit labyrinthe en gauche
  push();
  stroke(50);
  for (int j = 0; j < LAB_SIZE; j++) {
    for (int i = 0; i < LAB_SIZE; i++) {
      if(labyrinthe[j][i] != '#' && sides[j][i][4]==0){
        fill(150);
        //le sol
        beginShape(QUAD);
          vertex(-S_BOX_SIZE/2.0, -S_BOX_SIZE/2.0, -S_BOX_SIZE/2.0);
          vertex(-S_BOX_SIZE/2.0, S_BOX_SIZE/2.0,  -S_BOX_SIZE/2.0);
          vertex(S_BOX_SIZE/2.0, S_BOX_SIZE/2.0, -S_BOX_SIZE/2.0);
          vertex(S_BOX_SIZE/2.0, -S_BOX_SIZE/2.0, -S_BOX_SIZE/2.0);
        endShape();
      }
      //cette conditionnel est pour effacer les cases traversé avec les voisins qu'il faut effacer, on éfface un cube de type mur si il n'est connecté vers aucune case nono traversée 
      else if(labyrinthe[j][i] != '#' &&  sides[j][i][4]==1
              || (labyrinthe[j][i] == '#' && 
              !((j-1>=0 && labyrinthe[j-1][i]!='#' && sides[j-1][i][4]==0)
              || (j+1<LAB_SIZE && labyrinthe[j+1][i]!='#' && sides[j+1][i][4]==0)
              || (i-1>=0 && labyrinthe[j][i-1]!='#' && sides[j][i-1][4]==0)
              || (i+1<LAB_SIZE && labyrinthe[j][i+1]!='#' && sides[j][i+1][4]==0)
              || ((j-1<0 || labyrinthe[j-1][i]=='#') && (j+1>=LAB_SIZE || labyrinthe[j+1][i]=='#') && (i-1<0 || labyrinthe[j][i-1]=='#') && (i+1>=LAB_SIZE || labyrinthe[j][i+1]=='#'))
              )))
              {}
      else{
        fill(255*i/LAB_SIZE, 255*j/LAB_SIZE, 255);
        box(S_BOX_SIZE);
      }  
      translate(S_BOX_SIZE, 0, 0); // Translate the box to its position
    }
    translate(-LAB_SIZE * S_BOX_SIZE, S_BOX_SIZE, 0);
  }
  noStroke();
  
  //afficher la sphere verte
  translate(posX * S_BOX_SIZE, -LAB_SIZE * S_BOX_SIZE + posY * S_BOX_SIZE , S_BOX_SIZE);
  fill(0, 255, 0);
  sphere(S_BOX_SIZE/2.0);
  pop();
  
  
  // Create the PShape object for the sphere representing the player position
 /* boule_v = createShape(SPHERE, 8); 
  boule_v.setFill(color(0, 255, 0)); // Set the color of the sphere
  boule_v.setStroke(false); // Disable stroke for the sphere
  boule_v.translate((posX+0.5) * BOX_SIZE, (posY + 0.5) * BOX_SIZE, BOX_SIZE); // Translate the sphere to its position
  petit_laby.addChild(boule_v);*/
}

boolean validDeplacement(int arrX, int arrY){
  //verifier si la case vers laquelle on veut déplacer est traversable
  if(arrX<LAB_SIZE && arrY<LAB_SIZE && arrX>=0 && arrY>=0)
    //Non accessible
    return labyrinthe[arrY][arrX]!='#';
  else
    //Non accessible
    return false;
}

final int UP_KEY=38, DOWN_KEY=40, LEFT_KEY=37, RIGHT_KEY=39, SPACE_KEY=32;
void keyPressed(){
  int arrX=posX+dirX, arrY=posY+dirY;
  //dans ces conditions on rajoute toujjours anim == -1 pour ne pas bouger le joueur s'il est en déplacement, on attend toujours la fin du déplacement pour appliquer d'autres actions
  if(anim == -1 && keyCode==UP_KEY && validDeplacement(arrX, arrY)){
    anim=20;//déclancherl'animation
    anim_rot=false;
  }
  else if(anim == -1){
    anim=20;
    anim_rot=true;
    prevDX=dirX;
    prevDY=dirY;
    if (keyCode==RIGHT_KEY){
      //multiplier V(dirX, dirY) par i
      //bot_de_resolution();
      int temp=dirY;
      dirY=dirX;
      dirX=-temp;  
      half_rot=false;
    
    }
    else if (keyCode==LEFT_KEY){
      //multiplier V(dirX, dirY) par -i
      int temp=dirY;
      dirY=-dirX;
      dirX=temp;    
      half_rot=false;
    }
    else if (keyCode==DOWN_KEY){
      dirX=-dirX;
      dirY=-dirY;
      half_rot=true;
    }
    else if(keyCode==SPACE_KEY)
      //déclancher le bot en cliquant sur espace
      call_bot=true;
    else if(keyCode==ENTER)
      goAhead=true;
    
  }
}

void draw_light(int i, int j){
  //dessiner la lumierère  de la petite sphere dans la case i, j
  push();
    translate((i+dirX*0.3 + 0.5) * BOX_SIZE, (j+dirY*0.3 + 0.5) * BOX_SIZE, BOX_SIZE * 1.7 );
    fill(255*i/LAB_SIZE, 255*j/LAB_SIZE, 255);
    noStroke();
    sphere(10);
  pop();
}

void draw_laby(){
  push();
  for (int j=0; j<LAB_SIZE; j++) {
    for (int i=0; i<LAB_SIZE; i++) {
      beginShape(QUADS);
      if(labyrinthe[j][i]=='#')
       {        
           noStroke();
           tint(255*i/LAB_SIZE, 255*j/LAB_SIZE, 255);
           texture(txtr);
          //NORD
          if (j > 0 && labyrinthe[j - 1][i] != '#' || j == 0) {
            vertex(0, 0, 0, 0, 0);
            vertex(0, 0, BOX_SIZE, 0, 1);
            vertex(BOX_SIZE, 0, BOX_SIZE, 1, 1);
            vertex(BOX_SIZE, 0, 0, 1, 0);
            
            // Additional vertices with texture coordinates
            vertex(0, 0, BOX_SIZE, 0, 0);
            vertex(0, 0, 2 * BOX_SIZE, 0, 1);
            vertex(BOX_SIZE, 0, 2 * BOX_SIZE, 1, 1);
            vertex(BOX_SIZE, 0, BOX_SIZE, 1, 0);
          }
          
          //EST
          if (i < LAB_SIZE - 1 && labyrinthe[j][i + 1] != '#' || i == LAB_SIZE - 1) {
            vertex(BOX_SIZE, 0, BOX_SIZE, 0, 0);
            vertex(BOX_SIZE, 0, 0, 0, 1);
            vertex(BOX_SIZE, BOX_SIZE, 0, 1, 1);
            vertex(BOX_SIZE, BOX_SIZE, BOX_SIZE, 1, 0);
            
            // Additional vertices with texture coordinates
            vertex(BOX_SIZE, 0, 2 * BOX_SIZE, 0, 0);
            vertex(BOX_SIZE, 0, BOX_SIZE, 0, 1);
            vertex(BOX_SIZE, BOX_SIZE, BOX_SIZE, 1, 1);
            vertex(BOX_SIZE, BOX_SIZE, 2 * BOX_SIZE, 1, 0);
          }
          
          //SUD
          if (j < LAB_SIZE - 1 && labyrinthe[j + 1][i] != '#' || j == LAB_SIZE - 1) {
            vertex(BOX_SIZE, BOX_SIZE, 0, 0, 0);
            vertex(BOX_SIZE, BOX_SIZE, BOX_SIZE, 0, 1);
            vertex(0, BOX_SIZE, BOX_SIZE, 1, 1);
            vertex(0, BOX_SIZE, 0, 1, 0);
            
            // Additional vertices with texture coordinates
            vertex(BOX_SIZE, BOX_SIZE, BOX_SIZE, 0, 0);
            vertex(BOX_SIZE, BOX_SIZE, 2 * BOX_SIZE, 0, 1);
            vertex(0, BOX_SIZE, 2 * BOX_SIZE, 1, 1);
            vertex(0, BOX_SIZE, BOX_SIZE, 1, 0);
          }
          
          //WEST
          if (i > 0 && labyrinthe[j][i - 1] != '#' || i == 0) {
            vertex(0, BOX_SIZE, BOX_SIZE, 0, 0);
            vertex(0, BOX_SIZE, 0, 0, 1);
            vertex(0, 0, 0, 1, 1);
            vertex(0, 0, BOX_SIZE, 1, 0);
          
          // Additional vertices with texture coordinates
            vertex(0, BOX_SIZE, 2 * BOX_SIZE, 0, 0);
            vertex(0, BOX_SIZE, BOX_SIZE, 0, 1);
            vertex(0, 0, BOX_SIZE, 1, 1);
            vertex(0, 0, 2 * BOX_SIZE, 1, 0);
          }
       } 
       else 
       {
        //couleur du sol
        fill(100);
        texture(txtrSol);
       }
       
       //SOL et PLAFOND 
       vertex(0, 0, 0, 0, 0);
       vertex(0, BOX_SIZE, 0, 0, 1);
       vertex(BOX_SIZE, BOX_SIZE, 0, 1, 1);
       vertex(BOX_SIZE, 0, 0, 1, 0);
       
       vertex(0, 0,  2 * BOX_SIZE);
       vertex(0, BOX_SIZE, 2 * BOX_SIZE);
       vertex(BOX_SIZE, BOX_SIZE, 2 * BOX_SIZE);
       vertex(BOX_SIZE, 0, 2 * BOX_SIZE);

       endShape();
       translate(BOX_SIZE, 0, 0);
    }
    translate(-LAB_SIZE * BOX_SIZE, BOX_SIZE, 0);
  }
  pop();
}

int[] fond_du_couloir(){
  //cette fonction nous renvoie les cordonnées de la case ou on va afficher la petite sphere si sinon null si on peut pas mettre de spheres à la fin du couloire
  int countX=posX, countY=posY, count=0;
  int [] ret = new int[2];
  while(countX+dirX >=0 && countX+dirX <LAB_SIZE && countY+dirY >=0 && countY+dirY <LAB_SIZE && labyrinthe[countY+dirY][countX+dirX]!='#'){
    countX+=dirX;
    countY+=dirY;
    count++;
  }
  //On met une petite sohere lumineux dans la case i, j si et seulement si elle est entouré par des mures ou les limites du labyrinthe
  if(count > 0 
  && (internieur_laby(countY+dirY, countX+dirX))
  && (internieur_laby(countY+dirX, countX-dirY) && labyrinthe[countY+dirX][countX-dirY] == '#' || !internieur_laby(countY+dirX, countX-dirY)) 
  && (internieur_laby(countY-dirX, countX+dirY) && labyrinthe[countY-dirX][countX+dirY] == '#' || !internieur_laby(countY-dirX, countX+dirY))
  )
   {
     ret[0]=countX;
     ret[1]=countY;
     return ret;
   }
 
  return null;
}

boolean internieur_laby(int i, int j){
  //si les cordonnées i, j appartient à la matrice renvoyer true, elle nous permet d'écrire des conditionnelles allégées
  return i >= 0 && j >= 0 && i < LAB_SIZE && j < LAB_SIZE;
}


//cette fontion est pour résoudre le labyrinthe
ArrayList<Integer> resoudre_laby(int depX, int depY, ArrayList<Integer> arr, boolean [][] visited){
  int orX = 1, orY=0;
  if(!internieur_laby(depX, depY))
    if((depX == orX-1 ||depX == orX+1) && depY==orY || ((depY == orY+1 || depY == orY -1) && depX==orX)){
      //si c'est la rentrée
       return null;
    } else {
      //sortie
      return arr;
    }
  if(labyrinthe[depY][depX] == '#' || visited[depY][depX])
    return null;
  
  visited[depY][depX]=true;
  
  if(
  resoudre_laby(depX - 1, depY, arr, visited) == null
  && resoudre_laby(depX + 1, depY, arr, visited) == null
  && resoudre_laby(depX, depY - 1, arr, visited) == null
  && resoudre_laby(depX, depY + 1, arr, visited) == null
  )
    return null;
    
  else{
    arr.add(0, depX);
    arr.add(0, depY);
    return arr;
  }
}
