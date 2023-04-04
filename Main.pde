
import java.util.*;


VisibilityGraph g;
Point s;
Point e;
ArrayList<Polygon> o; 

void init() 
{
  s = makeRandomPoint();
  e = makeRandomPoint();
  o = makeRandomBoxes(4);
  g = new VisibilityGraph(s, e, o);
}

void setup(){
  size(800,800,P3D);
  frameRate(30);
  init();
}

void draw(){
  background(255);
  translate( 0, height, 0);
  scale( 1, -1, 1 );
  g.draw();
}

void keyPressed(){
   if(key=='g') init();
}

Point sel = null;

void mousePressed(){
  int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  Point p = new Point(mouseXRHC,mouseYRHC);
  float dT = 6;
  if( p.distance(s) < dT )
    sel = s; 
  if( p.distance(e) < dT )
    sel = e;
  
}

void mouseDragged(){
  int mouseXRHC = mouseX;
  int mouseYRHC = height-mouseY;
  if( sel != null ){
    sel.p.x = mouseXRHC;   
    sel.p.y = mouseYRHC;
    g = new VisibilityGraph(s, e, o);
  }
}

void mouseReleased(){
  sel = null;
}




  
