import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

extension Vec3 on Vector3{
  /// Subtract [a] from [b]
  Vector3 sub2 (Vector3 a,Vector3 b ) {
    x = a.x - b.x;
    y = a.y - b.y;
    z = a.z - b.z;
    return this;
  }
  /// Test if all the positions are zero e.g(x=y=z=0)
  bool testZero () {
    if(x!=0 || y!=0 || z!=0){ return true;}
    else{ return false;}
  }
  /// Check if [v] is different to this
  bool testDiff(Vector3 v ){
    return equals(v) ? false : true;
  }

  /// Is [v] == to this
  bool equals (Vector3 v ) {
    return v.x == x && v.y == y && v.z == z;
  }
  /// Subtract [v] scaled by [s] with this vector
  Vector3 subScaledVector (Vector3 v, double s ) {
    x -= v.x * s;
    y -= v.y * s;
    z -= v.z * s;

    return this;
  }
  /// Apply a 3x3 Matrix to this vector
  Vector3 applyMatrix3Transpose(Matrix3 m) {
    double x = this.x, y = this.y, z = this.z;
    Float32List e = m.storage;

    this.x = e[ 0 ] * x + e[ 1 ] * y + e[ 2 ] * z;
    this.y = e[ 3 ] * x + e[ 4 ] * y + e[ 5 ] * z;
    this.z = e[ 6 ] * x + e[ 7 ] * y + e[ 8 ] * z;

    return this;
  }
  /// Cross [a] with [b]
  Vector3 cross2(Vector3 a, Vector3 b ) {
    double ax = a.x, ay = a.y, az = a.z;
    double bx = b.x, by = b.y, bz = b.z;

    x = ay * bz - az * by;
    y = az * bx - ax * bz;
    z = ax * by - ay * bx;

    return this;
  }
  /// add vector [a] to vector [b]
  Vector3 add2 (Vector3 a,Vector3 b ) {
    x = a.x + b.x;
    y = a.y + b.y;
    z = a.z + b.z;
    return this;
  }
  Vector3 lerp(Vector3 v, num alpha) {
    x += (v.x - x) * alpha;
    y += (v.y - y) * alpha;
    z += (v.z - z) * alpha;

    return this;
  }
  /// Invert this vector
  Vector3 inverse(){
    x *= -1;
    y *= -1;
    z *= -1;
    return this;
  }
  /// Get the tangent of this vector with respect to [a]
  Vector3 tangent (Vector3 a ) {
    double ax = a.x, ay = a.y, az = a.z;

    x = ay * ax - az * az;
    y = - az * ay - ax * ax;
    z = ax * az + ay * ay;

    return this;
  }
  /// scale vector [v] with s and set for this vector
  Vector3 scale2(Vector3 v, double s ) {
    x = v.x * s;
    y = v.y * s;
    z = v.z * s;
    return this;
  }
}