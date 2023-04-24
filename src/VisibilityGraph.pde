  
class VisibilityGraph {
  
  // Input
  Point s;
  Point d;
  ArrayList<Polygon> original_obstacles;
  ArrayList<Polygon> obstacles;
  
  ArrayList<Point> path_bfs;
  ArrayList<Point> path_m;
  ArrayList<Point> path_e;
  HashMap<String, Float> scores;
  
  
  ArrayList<Point> vert;
  ArrayList<Edge>  edge;
  Polygon robot;
  boolean solved; 
  boolean nodraw;
  
  VisibilityGraph(Polygon _r, Point _d, ArrayList<Polygon> _obstacles){ 
      robot = _r;
      original_obstacles = _obstacles; 
      // find lowest point in _r as starting point
      Point c = _r.p.get(0); 
      for(Point p: _r.p) {
        if(p.y() < c.y() ||
          (p.y() == c.y() && p.x() < c.x()))
          c = p; 
      }
    
      // recompute delta for flip (x, y) for all other points centering at the s.
      ArrayList<Point> deltas = new ArrayList<Point>();
      for(Point p: _r.p){
        if(!p.isEqual(c)) 
          deltas.add(new Point(c.x() - p.x(), 
                             c.y() - p.y()));
      }
      
      // for each obstacles, and each point on obstacles, add those points, 
      // then apply convex hull to obtain a new obstacles.
      ArrayList<Polygon> new_obstacles = new ArrayList<Polygon>();
      ArrayList<Point> pnts_obstacle = new ArrayList<Point>();
      Polygon new_poly = new Polygon();
      for(Polygon g: _obstacles){
        pnts_obstacle.clear();
        for(Point p: g.p) {
          pnts_obstacle.add(p);
          for(Point d: deltas) {
            pnts_obstacle.add(new Point(p.x() + d.x(), p.y() + d.y()));
          }
        }
        new_poly = ConvexHullQuickHull(pnts_obstacle);
        
        // What if our merged new polygon overlaps other polygon, 
        // do a recursive merge till there are no overlap.
        Polygon m = checkOverlap(new_poly, new_obstacles);
        boolean overlap = (m != null);  
        while(new_obstacles.size() > 0 && overlap)
        {
          new_obstacles.remove(m);
          new_poly = merge(new_poly, m);
          m = checkOverlap(new_poly, new_obstacles);
          overlap = (m != null);
        }
 
        new_obstacles.add(new_poly);
      }
      
      // Everthing is ready! Initilize the graph. 
      init(c, _d, new_obstacles);
  }
  
  Polygon merge(Polygon a, Polygon b){
        
    ArrayList<Point> pnts = new ArrayList<Point>();
    for(Point pnt: a.p)
      pnts.add(pnt);
    for(Point pnt: b.p)
      pnts.add(pnt);
      
    return ConvexHullQuickHull(pnts);
  }
  
  Polygon checkOverlap(Polygon p, ArrayList<Polygon> l)
  {
     Polygon collide = null; 
     for(Polygon n: l)
        if(p.collisionTest(n))
           return n; 
      
     return collide;
  }
  
  
  void init(Point _s, Point _d, ArrayList<Polygon> _obstacles) {
      s = _s;
      d = _d;
      obstacles = _obstacles;
      solved = false;
      nodraw = false;
            
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
      
      path_bfs = new ArrayList<Point>(); 
      path_m = new ArrayList<Point>(); 
      path_e = new ArrayList<Point>(); 
      scores = new HashMap<String, Float>();
      scores.put("bfs", 0.0);
      scores.put("manh", 0.0);
      scores.put("euc", 0.0);
  }
  
  // draw everything.
  void draw(){
      
      if(nodraw)
        return;
      strokeWeight(3);
      
      // Text
      pushMatrix(); 
      translate(25, 750);
      rotateX(radians(-180));
      
      stroke(255, 0, 0);
      text("BFS " + scores.get("bfs"), 40, 50); 
      line(0, 50, 25, 50);
      
      stroke(0, 255, 0);
      text("E "+ scores.get("euc"), 40, 25); 
      
      line(0, 25, 25, 25);
      
      stroke(0, 0, 255);
      text("M " + scores.get("manh"), 40, 0); 
      line(0, 0, 25, 0);
      popMatrix();
      
      
      // edges are black
      stroke(0, 0, 0);
      for(Edge e: edge) {
        e.draw();
      }
       
      // Grey obstacle
      noFill();
      stroke(100, 100, 100);
      for( Polygon pl : this.original_obstacles ){
        pl.draw();
      }
      
      // Pink Transformed obstacle
      noFill();
      stroke(227, 73, 201);
      for( Polygon pl : this.obstacles ){
        pl.draw();
      }
      
      // draw start and end
      fill(0, 0, 0); 
      stroke(255, 0, 0);
      s.draw();
      robot.draw();
      
      fill(0, 0, 0);
      stroke(0, 0, 255);
      d.draw();
      
      if(solved) {
        // Draw solution path
        stroke(255, 0, 0);
        strokeWeight(12);
        for(int i=0; i+1<path_bfs.size(); i++)
        {
          Point p = path_bfs.get(i);
          Point q = path_bfs.get(i+1);
          line(p.x(), p.y(), q.x(), q.y()); 
        }
        
        stroke(0, 255, 0);
        strokeWeight(8);
        for(int i=0; i+1<path_e.size(); i++)
        {
          Point p = path_e.get(i);
          Point q = path_e.get(i+1);
          line(p.x(), p.y(), q.x(), q.y()); 
        }
        

        stroke(0, 0, 255);
        strokeWeight(4);
        for(int i=0; i+1<path_m.size(); i++)
        {
          Point p = path_m.get(i);
          Point q = path_m.get(i+1);
          line(p.x(), p.y(), q.x(), q.y()); 
        }
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
  
  void solveall()
  {
    solve("bfs");
    solve("euc");
    solve("manh");
    compute_scores();
  }
  
  
  void solve(String mode) 
  {
    switch(mode) {
      case "bfs":
        path_bfs.clear();
        bfs();
        break;
      case "euc":
        path_e.clear();
        euc();
        break;
      case "manh":
        path_m.clear();
        manh();
        break;
      default:
        println("Not a valid method"); 
        return;
    }
    solved = true;
  }
  
  void compute_scores()
  {
    
    if(path_bfs.size() > 0)
    {
      float score = 0.0;
      for(int i=1; i<path_bfs.size(); i++) {
         Point c = path_bfs.get(i-1);
         Point n = path_bfs.get(i);
         score += c.distance(n);
      }
      
      scores.put("bfs", score); 
    }
    
    
    if(path_m.size() > 0)
    {
      float score = 0.0;
      for(int i=1; i<path_m.size(); i++) {
         Point c = path_m.get(i-1);
         Point n = path_m.get(i);
         score += c.distance(n);
      }
      
      scores.put("manh", score); 
    }
    
    if(path_e.size() > 0)
    {
      float score = 0.0;
      for(int i=1; i<path_e.size(); i++) {
         Point c = path_e.get(i-1);
         Point n = path_e.get(i);
         score += c.distance(n);
      }
      
      scores.put("euc", score); 
    }
  }
  
  // Heuristic base approach.
  void euc(){
    
    ArrayList<Point> visited = new ArrayList<Point>();
    Point curr = s;
    
    for(Point p: vert){
      p.score = 99999.0;
    }

    while(!curr.isEqual(d))
    {
      path_e.add(curr);
      visited.add(curr);
      ArrayList<Point> neighboors = reachable(curr);
      
      if(neighboors.size() == 0) {
        println("Graph is not fully connected");
        return; 
      }
      
      // Be greedy
      Point best = neighboors.get(0);
      boolean exit = true;
      for(Point n: neighboors) {
        if(visited.contains(n))
          continue;
        n.score = curr.distance(n) + n.distance(d);
        if(n.score < best.score){
          best = n;
          exit = false;
        }
      }
      curr = best;
    }
    
    path_e.add(d);
  }
  
  void manh(){
    
    ArrayList<Point> visited = new ArrayList<Point>();
    Point curr = s;
    
    for(Point p: vert){
      p.score = 99999.0;
    }

    while(!curr.isEqual(d))
    {
      path_m.add(curr);
      visited.add(curr);
      ArrayList<Point> neighboors = reachable(curr);
      
      if(neighboors.size() == 0) {
        println("Graph is not fully connected");
        return; 
      }
      
      // Be greedy
      Point best = neighboors.get(0);
      for(Point n: neighboors) {
        if(visited.contains(n))
          continue;
        n.score = curr.distance(n) + abs(d.x()-n.x()) + abs(d.y()-n.y());
        if(n.score < best.score){
          best = n;
        }
      }
      curr = best;
    }
    
    path_m.add(d);
  }
  
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
         
          if((stoc + cton) < ston) {
              next.dist = stoc+cton;
              next.prev = curr;
          }
        }
      }
    }  
    
    // backtrace from D to S using prev field. 
    Point cur = d;
    while(!cur.isEqual(s))
    {
      path_bfs.add(cur);
      cur = cur.prev;
    }   
    
    path_bfs.add(s);
    
  }
}
