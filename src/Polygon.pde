

class Polygon {
  
   ArrayList<Point> p = new ArrayList<Point>();
   ArrayList<Edge>  bdry = new ArrayList<Edge>();
   Polygon( ){  }
   
   void draw(){
     for( Edge e : bdry ){
       e.draw();
     }
   }
   
   void addPoint( Point _p ){ 
     p.add( _p );
     if( p.size() == 2 ){
       bdry.add( new Edge( p.get(0), p.get(1) ) );
       bdry.add( new Edge( p.get(1), p.get(0) ) );
     }
     if( p.size() > 2 ){
       bdry.set( bdry.size()-1, new Edge( p.get(p.size()-2), p.get(p.size()-1) ) );
       bdry.add( new Edge( p.get(p.size()-1), p.get(0) ) );
     }
   }
   boolean isEqual(Polygon _pl) 
   {
     if(p.size() == _pl.getPoints().size())
     {
       boolean found = false;
       for(Point pnt1: p){
         for(Point pnt2: _pl.p){
           if(pnt1.isEqual(pnt2))
             found = true;
         }
         if(!found)
           return false;
       }
       return true;
     }
           
     return false;
   }
   
   ArrayList<Point> getPoints(){
     return p; 
   }
   
   ArrayList<Edge> getEdges() {
     return bdry;  
   }
   
   boolean isClosed(){ return p.size()>=3; }   
   
   boolean collisionTest(Polygon o) 
   {
     
       float minx = o.p.get(0).x(); 
       float maxx = o.p.get(0).x(); 
       float miny = o.p.get(0).y(); 
       float maxy = o.p.get(0).y(); 
       for(Point p: o.p){
         if(p.x() < minx)
           minx = p.x();
         if(p.x() > maxx)
           maxx = p.x();
         if(p.y() < miny)
           miny = p.y();
         if(p.y() > maxy)
           maxy = p.y();
       }
       
       AABB aabbo = new AABB(minx, maxx, miny, maxy);
       
       minx = this.p.get(0).x(); 
       maxx = this.p.get(0).x(); 
       miny = this.p.get(0).y(); 
       maxy = this.p.get(0).y(); 
       for(Point p: this.p){
         if(p.x() < minx)
           minx = p.x();
         if(p.x() > maxx)
           maxx = p.x();
         if(p.y() < miny)
           miny = p.y();
         if(p.y() > maxy)
           maxy = p.y();
       }
       
       AABB aabbt = new AABB(minx, maxx, miny, maxy); 
        
       return aabbt.intersectionTest(aabbo);
   }
}
