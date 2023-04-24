
// Class to hold an Axis Aligned Bounding Box
class AABB {

  float minX, maxX;
  float minY, maxY;
  
  AABB( float _minX, float _maxX, float _minY, float _maxY ){
    minX = _minX;
    maxX = _maxX;
    minY = _minY;
    maxY = _maxY;
  }
  
  boolean intersectionTest( AABB other ){
    return min(this.maxX, other.maxX) - max(this.minX, other.minX) >= 0 && 
           min(this.maxY, other.maxY) - max(this.minY, other.minY) >= 0;
  }
  
}
