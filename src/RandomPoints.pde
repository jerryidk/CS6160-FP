

Point makeRandomPoint()
{
   return new Point(random(100, width-100), random(100, width-100)); 
}


Polygon makeRobot(Point c)
{
  Polygon poly = new Polygon();
  poly.addPoint(c);
  poly.addPoint(new Point(c.x() + 50, c.y()));
  poly.addPoint(new Point(c.x() + 50, c.y() + 50));
  poly.addPoint(new Point(c.x(), c.y() + 50));
  
  return poly;
}


ArrayList<Polygon> makeRandomBoxes(int n) 
{
  ArrayList<Polygon> boxes = new ArrayList<Polygon>();
  
  while(boxes.size() < n) {
     Polygon b = new Polygon();
     float startx = random(100, width-100);
     float starty = random(100, width-100);
     float w = random(20, 100);
     float h = random(20, 100);
     b.addPoint(new Point(startx, starty));
     b.addPoint(new Point(startx+w, starty));
     b.addPoint(new Point(startx+w, starty+h));
     b.addPoint(new Point(startx, starty+h));
           
     boolean collide = false;
     for(Polygon box: boxes){
   
       if(b.collisionTest(box)){
         collide = true; 
         break;
       }
     }
     
     if(!collide)
       boxes.add(b);
  }
  
  return boxes;
}



ArrayList<Polygon> makeRandomBoxesTest(int n, int T_w, int T_h)
{
  ArrayList<Polygon> boxes = new ArrayList<Polygon>();
  
  while(boxes.size() < n) {
     Polygon b = new Polygon();
     float startx = random(0, T_w);
     float starty = random(0, T_h);
     float w = random(20, 100);
     float h = random(20, 100);
     b.addPoint(new Point(startx, starty));
     b.addPoint(new Point(startx+w, starty));
     b.addPoint(new Point(startx+w, starty+h));
     b.addPoint(new Point(startx, starty+h));
           
     boolean collide = false;
     for(Polygon box: boxes){
   
       if(b.collisionTest(box)){
         collide = true; 
         break;
       }
     }
     
     if(!collide)
       boxes.add(b);
  }
  
  return boxes;
}
