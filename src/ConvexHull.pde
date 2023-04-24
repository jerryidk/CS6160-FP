

void findExtrema(ArrayList<Point> pnts, Point a, Point b, ArrayList<Point> results) {
  
  // Find left side of line ab
  ArrayList<Point> lhs = new ArrayList<Point>();
  for(Point p: pnts) {
    PVector ap = a.to(p);
    PVector ab = a.to(b);
    if(!p.isEqual(a) && !p.isEqual(b) && ap.cross(ab).z > 0)
      lhs.add(p);
  }
  
  if(lhs.size() == 0)
    return;
  
  // Find extrema
  Point extrema = null;
  float max_so_far = 0.0;
  for(Point p: lhs) {
    // Compute distance a, b , p = || ap cross ab || / || ab ||   
    PVector ap = a.to(p);
    PVector ab = a.to(b);
    float distance = ap.cross(ab).mag() / (ab.mag());    
    if(distance > max_so_far) {
      max_so_far = distance;
      extrema = p;
    }
  }
  
  if(extrema == null) {
    println("ERROR: didn't find extrema!"); 
    return;
  }
  
  int idx_a = results.indexOf(a);
  int idx_b = results.indexOf(b);
  if( idx_a < 0 || idx_b < 0) {
    println("ERROR: point not found");
    return;
  }
  
  results.add(idx_a+1, extrema);
  // recruse
  findExtrema(lhs, a, extrema, results);
  findExtrema(lhs, extrema, b, results);
}

Polygon ConvexHullQuickHull( ArrayList<Point> points ){
  Polygon cHull = new Polygon();
  if( points.size() < 3) {
    return cHull; 
  }
    
  ArrayList<Point> cp = new ArrayList<Point>(points);
  // sort points from left to right.
  Collections.sort(cp, new Comparator<Point>(){
    public int compare( Point p1, Point p2 ){
     
     float x1 = p1.x();
     float x2 = p2.x();
     if (x1 > x2)
       return 1; 
     if (x1 < x2)
       return -1;
     float y1 = p1.y();
     float y2 = p2.y();
     if (y1 > y2)
       return -1; 
     if (y1 < y2)
       return 1;
    
     return 0;
    }
  }); 
  
  Point a = cp.get(0); 
  Point b = cp.get(points.size()-1);
  ArrayList<Point> results = new ArrayList<Point>();
  results.add(a);
  results.add(b);
  findExtrema(cp, a, b, results);
  findExtrema(cp, b, a, results);
  
  for(Point r: results)
    cHull.addPoint(r);
  return cHull;
}

Polygon ConvexHullGraham( ArrayList<Point> points ){
  Polygon cHull = new Polygon();
  if( points.size() < 3) {
    return cHull; 
  }
  
  ArrayList<Point> cp = new ArrayList<Point>(points);
  
  // get start point
  Point miny = cp.get(0);
  for (Point pnt: cp) {
    if(pnt.getY() < miny.getY() ||
      ( pnt.getY() == miny.getY() && 
        pnt.getX() < miny.getX())){
      miny = pnt;
    }
  }
  

  final Point start = miny;
  
  // Sort base on angles 
  Collections.sort(cp, new Comparator<Point>(){
    public int compare( Point p1, Point p2 ){
     float angle1 = start.getAngle(p1);                      
     float angle2 = start.getAngle(p2); 
     if(angle1 > angle2)
       return 1;
     
     if(angle1 < angle2) 
       return -1;
     
     float distance1 = p1.distance(start);
     float distance2 = p2.distance(start); 
     if (distance1 > distance2)
       return -1; 
     
     if (distance1 < distance2)
       return 1;
     
     return 0;
    }
  }); 
  

  
  // remove points have same angle to start and only keep the longest distance one.
  ArrayList<Point> repeats = new ArrayList<Point>();
  for(int i=0; i<cp.size()-1; i++){ 
    float angle = start.getAngle(cp.get(i));
    for(int j=i+1; j<cp.size(); j++){
      if(angle == start.getAngle(cp.get(j))) {
        repeats.add(cp.get(j));
      }else {
        i = j; //<>// //<>//
        break;
      }
    } 
  }
  
  for(Point p: repeats){
    cp.remove(p);
  }
  
  if(!start.isEqual(cp.get(0))) {
    cp.add(0,start);
  }
  
  // Actual algorithm
  ArrayList<Point> stack = new ArrayList<Point>();
  stack.add(cp.get(0));
  stack.add(cp.get(1));
  stack.add(cp.get(2));
  
  if(!cp.get(0).isEqual(start)) {
      println("ERROR first element is not start");
  }
  
  for(int i=3; i<cp.size(); i++) {
    Point pnt_i = cp.get(i);
    while(stack.size() > 1){
      Point stack_top = stack.get(stack.size()-1);
      Point stack_next_top = stack.get(stack.size()-2); //<>// //<>//
      PVector a = stack_next_top.to(stack_top);
      PVector b = stack_next_top.to(pnt_i);
      // check if pnt_i is left of stacktop to stack_nexttop
      if( (a.x * b.y - a.y * b.x) > 0 ){
        break;
      } 
      stack.remove(stack.size()-1); 
    }    
    stack.add(pnt_i);
  }
  
  
  for(Point p: stack) {
    cHull.addPoint(p);
  }
  
  return cHull;
}

Polygon ConvexHullGiftWrap( ArrayList<Point> points ){
  Polygon cHull = new Polygon();
  if( points.size() < 3) {
    return cHull; 
  }
  
  ArrayList<Point> cp = new ArrayList<Point>(points);
  
  Point min_p = cp.get(0);
  for(Point p: cp ){
    if (p.x() < min_p.x()) {
      min_p = p; 
    }
  }

  final Point start = min_p;
  
  Point c = start;                                  // current left most point
  Point l = new Point(start.x(), start.y() - 1.0);  // previous left most point 
  while(true) {
    
    cHull.addPoint(c);
    // obtain left most point for current left most point
    float min_angle = PI;
    Point n = null; // next left most point from current
    PVector a = l.to(c);   //<>//
    float amag = a.mag();
    PVector b = null;
    for(Point r: cp) { 
      if (!r.isEqual(c)) {
        b = c.to(r);
        float angle = acos( PVector.dot(a, b) / (amag * b.mag())); 
        if (angle < min_angle ||
           (angle == min_angle && n != null && c.distance(n) < c.distance(r))) {
            n = r;
            min_angle = angle;
        }
      }
    }
    
    if( n == null ){
      println("ERROR, didn't find left most point");
      break; 
    }
    cp.remove(n);
    if( n.isEqual(start) )
      break;
     
    l = c;
    c = n;   
  }
  
  return cHull;
}
