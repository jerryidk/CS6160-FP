

class Edge{
  
   Point p0,p1;
      
   Edge( Point _p0, Point _p1 ){
     p0 = _p0; p1 = _p1;
   }
   
   void draw(){
     line( p0.p.x, p0.p.y, 
           p1.p.x, p1.p.y );
   }
   
   void drawDotted(){
     float steps = p0.distance(p1)/6;
     for(int i=0; i<=steps; i++) {
       float x = lerp(p0.p.x, p1.p.x, i/steps);
       float y = lerp(p0.p.y, p1.p.y, i/steps);
       ellipse(x,y,3,3);
     }
  }
  
  float getLength(){
    return p0.distance(p1);
  }
   
   public String toString(){
     return "<" + p0 + "" + p1 + ">";
   }
   
   boolean isEqual(Edge _e){
     return (_e.p0.isEqual(p0) && _e.p1.isEqual(p1)) ||
            (_e.p0.isEqual(p1) && _e.p1.isEqual(p0)); 
   }
   
   boolean intersectionTest( Edge other ){
     
     if( this.isEqual(other))
       return true;
    
     PVector v1 = PVector.sub(other.p0.p, this.p0.p);
     PVector v2 = PVector.sub(other.p1.p, this.p0.p);
     PVector v3 = PVector.sub(this.p1.p, this.p0.p);
     float dir1 = v3.cross(v1).z;
     float dir2 = v3.cross(v2).z;
     
     if ((dir1 > 0 && dir2 < 0) || (dir1 < 0 && dir2 > 0)) {
       // check the other direction
       v1 = PVector.sub(this.p0.p, other.p0.p);
       v2 = PVector.sub(this.p1.p, other.p0.p);
       v3 = PVector.sub(other.p1.p, other.p0.p);
       
       dir1 = v3.cross(v1).z;
       dir2 = v3.cross(v2).z;
       
       return ((dir1 > 0 && dir2 < 0) || (dir1 < 0 && dir2 > 0));
     }
     
     
     return false;    
   }
  

   Point intersectionPoint( Edge other ){
     
     // Line is p = p0 + hat(p1 - p0) * t
     
     // Check Intersection using cross product, this should ensure that lines intercept each other.
     if (!this.intersectionTest(other)) {
       return null; 
     }
     
     PVector dir0 = PVector.sub(this.p1.p, this.p0.p);
     dir0.normalize();
     PVector dir1 = PVector.sub(other.p1.p, other.p0.p);
     dir1.normalize();
     float det = dir0.x * dir1.y - dir1.x * dir0.y;
     if (abs(det) ==0){
       return null;
     }

     PVector p0 = this.p0.p;
     PVector p1 = other.p0.p;
     float t1 = (dir1.x * p0.y - dir1.x * p1.y - dir1.y * p0.x + dir1.y * p1.x) / det; 
     return new Point(p0.x+dir0.x*t1, p0.y+dir0.y*t1);
   }
   
}
