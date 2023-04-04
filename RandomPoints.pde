

Point makeRandomPoint()
{
   return new Point(random(100, width-100), random(100, width-100)); 
}


//TODO: collision detection implementation;
ArrayList<Polygon> makeRandomBoxes(int n) 
{
  ArrayList<Polygon> boxes = new ArrayList<Polygon>();
  
  for(int i=0; i<n; i++) {
     Polygon o = new Polygon();
     float startx = random(100, width-100);
     float starty = random(100, width-100);
     float w = random(20, 100);
     float h = random(20, 100);
     o.addPoint(new Point(startx, starty));
     o.addPoint(new Point(startx+w, starty));
     o.addPoint(new Point(startx+w, starty+h));
     o.addPoint(new Point(startx, starty+h));
    
     
     boxes.add(o);
  }
  
  
  
  return boxes;
}
