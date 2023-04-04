
class VisibilityGraph {
  
  // Input
  Point s;
  Point d;
  ArrayList<Polygon> obstacles;
  ArrayList<Point> path;
  ArrayList<Point> vert;
  ArrayList<Edge>  edge;
  
  VisibilityGraph(Point _s, Point _d, ArrayList<Polygon> _obstacles){ 
      s = _s;
      d = _d;
      obstacles = _obstacles;
            
      // All vertices in the graph
      vert = new ArrayList<Point>();
      vert.add(s);
      for(Polygon pl: obstacles)
         for(Point p: pl.getPoints())
             vert.add(p);
      vert.add(d);
      
      // Generate all valid edges in the graph.
      edge = new ArrayList<Edge>();
      bruteforce();
      
      path = new ArrayList<Point>(); 
      solve();
  }
  
  // draw everything.
  void draw(){
  
      strokeWeight(3);
      
      // Draw visibility graph
      stroke(0, 0, 255);
      for(Edge e: edge) {
        e.draw();
      }
         
      // Draw solution path
      stroke(255, 0, 0);
      for(int i=0; i+1<path.size(); i++)
      {
        Point p = path.get(i);
        Point q = path.get(i+1);
        line(p.x(), p.y(), q.x(), q.y()); 
      }
      
      fill(255, 0, 0); 
      s.draw();
      
      fill(0, 255, 0);
      d.draw();
  
      noFill();
      stroke(0);
      for( Polygon pl : this.obstacles ){
        pl.draw();
      }
        
  } 
  
  
  boolean isBlocked(Edge e, ArrayList<Edge> by) {
     // check e is blocked. 
     for(Edge _e: by)
        if(e.intersectionTest(_e))
             return true; 
      
     return false; 
  }
  
  // O(n^3) algorithm.
  // construct a visibility graph - bruteforce way
  void bruteforce(){
    
    ArrayList<Point> obstacle_pnts = new ArrayList<Point>();
    ArrayList<Edge> obstacle_edges = new ArrayList<Edge>();
    for(Polygon pl: obstacles){
      for(Edge e: pl.getEdges())
        obstacle_edges.add(e);
      for(Point p: pl.getPoints())
        obstacle_pnts.add(p);
    }
    
    // an point on obstacle can reach annother point.
    for(Edge e: obstacle_edges){
       edge.add(e);
    }
    
    // source to destination
    Edge sd = new Edge(s, d);
    if(!isBlocked(sd, obstacle_edges))
        edge.add(sd);
    
    
    // source to all obstacle
    for(Point p: obstacle_pnts) {
      Edge e = new Edge(s, p);
      if(!isBlocked(e, obstacle_edges))
        edge.add(e);
    }
    
    // destination to all obstacle
    for(Point p: obstacle_pnts) {
      Edge e = new Edge(d, p);
      if(!isBlocked(e, obstacle_edges))
        edge.add(e);
    }
    
    // all obstacles
    for(int i=0; i<obstacles.size(); i++) {
      for(int j=i+1; j<obstacles.size(); j++){
        Polygon poly1 = obstacles.get(i);
        Polygon poly2 = obstacles.get(j);
        
        // for each point in each obstacle, form a edge with points in other obstacle. 
        for(Point p1: poly1.getPoints()){
          for(Point p2: poly2.getPoints()) {
            Edge e = new Edge(p1, p2);
            if(!isBlocked(e, obstacle_edges))
              edge.add(e);
          }
        }
      }
    }
   
    
  }
  
  // TODO O(n^2 logn) 
  // construct a visibility graph - rotation line sweep 
  void linesweep(){}
  
  ArrayList<Point> reachable(Point p){
    ArrayList<Point> ret = new ArrayList<Point>();
    for(Edge e: edge){
      if(e.p0.isEqual(p))
        ret.add(e.p1);
      if(e.p1.isEqual(p))
        ret.add(e.p0);
    }
    return ret;
  }
  
  
  Point findSmallest(ArrayList<Point> unvisited) 
  {
    float min = 9999999.0;
    int idx = 0;
    for(int i=0; i<unvisited.size(); i++){
      float d = unvisited.get(i).dist;
      if(d < min){
         min = d;
         idx = i; 
      }
    }
    
    return unvisited.get(idx); 
  }
   
  
  //TODO: Heuristic base approach.
  void astar(){}
  
  // O(n^2) -> though it can be optimized. Best First Search. 
  void bfs(){

    ArrayList<Point> unvisited = new ArrayList<Point>(vert);
    for(Point p: unvisited){
      p.dist = 99999.0;
    }
    unvisited.get(0).dist = 0.0;
    
    while(unvisited.size() > 0) {
      // find smallest dist from src among unvisited;
      Point curr = findSmallest(unvisited);
      unvisited.remove(curr); 
      float stoc = curr.dist;
      ArrayList<Point> neighboor = reachable(curr);
      for(Point next: neighboor) {
        if(unvisited.contains(next)){    
          float ston = next.dist;
          float cton = curr.distance(next);    
         
          if ( (stoc + cton) < ston ){
              next.dist = stoc+cton;
              next.prev = curr;
          }
        }
      }
    }  
    
    // backtrace from D to S using sol. 
    Point cur = d;
    while(!cur.isEqual(s))
    {
      path.add(cur);
      cur = cur.prev;
    }   
    
    path.add(s);
  }
  
}
