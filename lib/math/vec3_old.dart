import 'mat33.dart';
import 'quat.dart';
import 'math.dart';
import 'dart:math' as math;

/// Class for Vec3
class Vec3{
  /// Vec3 is a vector with coordinates for 3d mapping
  /// 
  /// [x] the x coordinate
  /// 
  /// [y] the y coordinate
  /// 
  /// [z] the z coordinate
  Vec3([this.x = 0,this.y = 0,this.z = 0]);
  double x;
  double y;
  double z;
  
  /// Set a new position for this vector using x,y,z
  Vec3 set(double x, double y, double z ){
    this.x = x;
    this.y = y;
    this.z = z;
    return this;
  }

  /// Add a to this vector 
  /// 
  /// if [b] is provided add a+b
  Vec3 add (Vec3 a,[Vec3? b ]) {
    if ( b != null ) return addVectors( a, b );
    x += a.x;
    y += a.y;
    z += a.z;
    return this;
  }


  /// Add this vector to [v]
  Vec3 addEqual (Vec3 v ) {
    x += v.x;
    y += v.y;
    z += v.z;
    return this;
  }
  /// Vector subtraction
  Vec3 vsub (Vec3 vector, [Vec3? target]) {
    if (target != null) {
      target.x =  x-vector.x;
      target.y =  y-vector.y;
      target.z =  z-vector.z;
      return target;
    } else {
      return Vec3(x - vector.x, y - vector.y, z - vector.z);
    }
  }
  /// Vector addition
  Vec3 vadd(Vec3 vector, [Vec3? target]){
    if (target != null) {
      target.x = vector.x + x;
      target.y = vector.y + y;
      target.z = vector.z + z;
      return target;
    } else {
      return Vec3(x + vector.x, y + vector.y, z + vector.z);
    }
  }
  /// Subtract a from this vector or subtract [a] form [b]
  Vec3 sub (Vec3 a, [Vec3? b]) {
    if ( b != null ) return subVectors( a, b );
    x -= a.x;
    y -= a.y;
    z -= a.z;
    return this;
  }

  /// Subtract [a] from [b]
  Vec3 subVectors (Vec3 a,Vec3 b ) {
    x = a.x - b.x;
    y = a.y - b.y;
    z = a.z - b.z;
    return this;
  }

  /// Subtract this vecotor from [v]
  Vec3 subEqual (Vec3 v ) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
    return this;
  }



  /// Scale this vector by [s]
  Vec3 scaleEqual(double s ){
    x *= s;
    y *= s;
    z *= s;
    return this;
  }

  /// Multiply this vector by [v]
  Vec3 multiply(Vec3 v ){
    x *= v.x;
    y *= v.y;
    z *= v.z;
    return this;
  }

  /*scaleV( v ){
      this.x *= v.x;
      this.y *= v.y;
      this.z *= v.z;
      return this;
  }
  scaleVectorEqual( v ){
      this.x *= v.x;
      this.y *= v.y;
      this.z *= v.z;
      return this;
  }*/



  /*addTime ( v, t ) {
      this.x += v.x * t;
      this.y += v.y * t;
      this.z += v.z * t;
      return this;
  }
  
  addScale ( v, s ) {
      this.x += v.x * s;
      this.y += v.y * s;
      this.z += v.z * s;
      return this;
  }
  subScale ( v, s ) {
      this.x -= v.x * s;
      this.y -= v.y * s;
      this.z -= v.z * s;
      return this;
  }*/
  
  /// Cross [a] with this vector if [b] is provided cross [a] with [b]
  Vec3 cross(Vec3 a, [Vec3? b ]) {
    if ( b != null ) return crossVectors( a, b );

    double x = this.x, y = this.y, z = this.z;

    this.x = y * a.z - z * a.y;
    this.y = z * a.x - x * a.z;
    this.z = x * a.y - y * a.x;

    return this;
  }





  /// Invert v and set it to this vector
  Vec3 invert (Vec3 v ) {
    x=-v.x;
    y=-v.y;
    z=-v.z;
    return this;
  }



  /// Invert this vector
  Vec3 negate (Vec3 target) {
    target.x = -x;
    target.y = -y;
    target.z = -z;
    return target;
  }

  /// Get the dot product with respect to [v]
  double dot (Vec3 v ) {
    return x * v.x + y * v.y + z * v.z;
  }

  /// Add x,y,z of this vector
  double addition () {
    return x + y + z;
  }

  /// Add the squares of the position e.g(x^2+y^2+z^2)
  double lengthSq () {
    return x * x + y * y + z * z;
  }

  /// Add the lenght of the positions e.g(sqrt(x^2+y^2+z^2))
  double length () {
    return math.sqrt( x * x + y * y + z * z);
  }

  /// Copy V to this vector
  Vec3 copy(Vec3 v ){
    x = v.x;
    y = v.y;
    z = v.z;
    return this;
  }

  /*mul( b, a, m ){
      return this.mulMat( m, a ).add( b );
  }
  mulMat( m, a ){
      var e = m.elements;
      var x = a.x, y = a.y, z = a.z;
      this.x = e[ 0 ] * x + e[ 1 ] * y + e[ 2 ] * z;
      this.y = e[ 3 ] * x + e[ 4 ] * y + e[ 5 ] * z;
      this.z = e[ 6 ] * x + e[ 7 ] * y + e[ 8 ] * z;
      return this;
  }*/

  /// Apply a 3x3 Matrix to this vector
  Vec3 applyMatrix3 (Mat33 m, [bool transpose = false]) {
    double x = this.x, y = this.y, z = this.z;
    List<double> e = m.elements;

    if( transpose ){
      this.x = e[ 0 ] * x + e[ 1 ] * y + e[ 2 ] * z;
      this.y = e[ 3 ] * x + e[ 4 ] * y + e[ 5 ] * z;
      this.z = e[ 6 ] * x + e[ 7 ] * y + e[ 8 ] * z;
    } 
    else {
      this.x = e[ 0 ] * x + e[ 3 ] * y + e[ 6 ] * z;
      this.y = e[ 1 ] * x + e[ 4 ] * y + e[ 7 ] * z;
      this.z = e[ 2 ] * x + e[ 5 ] * y + e[ 8 ] * z;
    }

    return this;
  }

  /// Apply a Quanternation to this vector
  Vec3 applyQuaternion (Quat q ) {
    double x = this.x;
    double y = this.y;
    double z = this.z;

    double qx = q.x;
    double qy = q.y;
    double qz = q.z;
    double qw = q.w;

    // calculate quat * vector

    double ix =  qw * x + qy * z - qz * y;
    double iy =  qw * y + qz * x - qx * z;
    double iz =  qw * z + qx * y - qy * x;
    double iw = - qx * x - qy * y - qz * z;

    // calculate result * inverse quat

    this.x = ix * qw + iw * - qx + iy * - qz - iz * - qy;
    this.y = iy * qw + iw * - qy + iz * - qx - ix * - qz;
    this.z = iz * qw + iw * - qz + ix * - qy - iy * - qx;

    return this;
  }

  /// Test if all the positions are zero e.g(x=y=z=0)
  bool testZero () {
    if(x!=0 || y!=0 || z!=0){ return true;}
    else{ return false;}
  }

  /// Check if [v] is different to this
  bool testDiff(Vec3 v ){
    return equals(v) ? false : true;
  }

  /// Is [v] == to this
  bool equals (Vec3 v ) {
    return v.x == x && v.y == y && v.z == z;
  }

  /// Clone this vector and return a new vector
  Vec3 clone(){
    return Vec3(x, y, z);
  }

  @override
  String toString(){
    return"Vec3[${x.toStringAsFixed(4)}, ${y.toStringAsFixed(4)}, ${z.toStringAsFixed(4)}]";
  }

  /// Multiply this vector by [scalar]
  Vec3 multiplyScalar (double scalar ) {
    if (Math.isFinite( scalar )) {
      x *= scalar;
      y *= scalar;
      z *= scalar;
    } else {
      x = 0;
      y = 0;
      z = 0;
    }
    return this;
  }

  /// Divide this vector by [scalar]
  Vec3 divideScalar (double scalar ) {
    return multiplyScalar( 1 / scalar );
  }

  /// Normalize this vector
  Vec3 normalize () {
    return divideScalar(length());
  }

  /// Place all position into the provided [array]
  void toArray (List<double> array, [int offset  = 0]) {
    array[ offset ] = x;
    array[ offset + 1 ] = y;
    array[ offset + 2 ] = z;
  }

  /// Place all parts of the array into this vectors positions
  Vec3 fromArray(List<double> array, [int offset = 0]){
    x = array[ offset ];
    y = array[ offset + 1 ];
    z = array[ offset + 2 ];
    return this;
  }
  double distanceTo(Vec3 v) {
    return math.sqrt(distanceToSquared(v));
  }
  double distanceToSquared(Vec3 v) {
    final dx = x - v.x; 
    final dy = y - v.y;
    double dz = z- v.z;

    return dx * dx + dy * dy + dz * dz;
  }

  Vec3 clamp(Vec3 min, Vec3 max) {
    // assumes min < max, componentwise
    x = math.max(min.x, math.min(max.x, x));
    y = math.max(min.y, math.min(max.y, y));
    z = math.max(min.z, math.min(max.z, z));
    return this;
  }
}