import 'mat33.dart';
import 'quat.dart';
import 'math.dart';
import 'dart:math' as math;

class Vec3{
  Vec3([this.x = 0,this.y = 0,this.z = 0]);
  double x;
  double y;
  double z;
    
  Vec3 set(double x, double y, double z ){
    this.x = x;
    this.y = y;
    this.z = z;
    return this;
  }

  Vec3 add (Vec3 a,[Vec3? b ]) {
    if ( b != null ) return addVectors( a, b );
    x += a.x;
    y += a.y;
    z += a.z;
    return this;
  }

  Vec3 addVectors (Vec3 a,Vec3 b ) {
    x = a.x + b.x;
    y = a.y + b.y;
    z = a.z + b.z;
    return this;
  }

  Vec3 addEqual (Vec3 v ) {
    x += v.x;
    y += v.y;
    z += v.z;
    return this;
  }

  Vec3 sub (Vec3 a, [Vec3? b]) {
    if ( b != null ) return subVectors( a, b );
    x -= a.x;
    y -= a.y;
    z -= a.z;
    return this;
  }

  Vec3 subVectors (Vec3 a,Vec3 b ) {
    x = a.x - b.x;
    y = a.y - b.y;
    z = a.z - b.z;
    return this;
  }

  Vec3 subEqual (Vec3 v ) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
    return this;
  }

  Vec3 scale (Vec3 v, double s ) {
    x = v.x * s;
    y = v.y * s;
    z = v.z * s;
    return this;
  }

  Vec3 scaleEqual(double s ){
    x *= s;
    y *= s;
    z *= s;
    return this;
  }

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

  Vec3 addScaledVector (Vec3 v,double s ) {
    x += v.x * s;
    y += v.y * s;
    z += v.z * s;

    return this;
  }

  Vec3 subScaledVector (Vec3 v, double s ) {
    x -= v.x * s;
    y -= v.y * s;
    z -= v.z * s;

    return this;
  }

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
  
  Vec3 cross(Vec3 a, [Vec3? b ]) {
    if ( b != null ) return crossVectors( a, b );

    double x = this.x, y = this.y, z = this.z;

    this.x = y * a.z - z * a.y;
    this.y = z * a.x - x * a.z;
    this.z = x * a.y - y * a.x;

    return this;
  }

  Vec3 crossVectors (Vec3 a, Vec3 b ) {
    double ax = a.x, ay = a.y, az = a.z;
    double bx = b.x, by = b.y, bz = b.z;

    x = ay * bz - az * by;
    y = az * bx - ax * bz;
    z = ax * by - ay * bx;

    return this;
  }

  Vec3 tangent (Vec3 a ) {
    double ax = a.x, ay = a.y, az = a.z;

    x = ay * ax - az * az;
    y = - az * ay - ax * ax;
    z = ax * az + ay * ay;

    return this;
  }

  Vec3 invert (Vec3 v ) {
    x=-v.x;
    y=-v.y;
    z=-v.z;
    return this;
  }

  Vec3 negate () {
    x = - x;
    y = - y;
    z = - z;
    return this;
  }

  double dot (Vec3 v ) {
    return x * v.x + y * v.y + z * v.z;
  }

  double addition () {
    return x + y + z;
  }

  double lengthSq () {
    return x * x + y * y + z * z;
  }

  double length () {
    return math.sqrt( x * x + y * y + z * z);
  }

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

  bool testZero () {
    if(x!=0 || y!=0 || z!=0){ return true;}
    else{ return false;}
  }

  bool testDiff(Vec3 v ){
    return equals(v) ? false : true;
  }

  bool equals (Vec3 v ) {
    return v.x == x && v.y == y && v.z == z;
  }

  Vec3 clone(){
    return Vec3(x, y, z);
  }

  @override
  String toString(){
    return"Vec3[${x.toStringAsFixed(4)}, ${y.toStringAsFixed(4)}, ${z.toStringAsFixed(4)}]";
  }

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

  Vec3 divideScalar (double scalar ) {
    return multiplyScalar( 1 / scalar );
  }

  Vec3 normalize () {
    return divideScalar(length());
  }

  void toArray (List<double> array, [int offset  = 0]) {
    array[ offset ] = x;
    array[ offset + 1 ] = y;
    array[ offset + 2 ] = z;
  }

  Vec3 fromArray(List<double> array, [int offset = 0]){
    x = array[ offset ];
    y = array[ offset + 1 ];
    z = array[ offset + 2 ];
    return this;
  }
}