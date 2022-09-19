import 'Math.dart';
import 'Mat33.dart';
import 'Vec3.dart';
import 'dart:math' as math;

class Quat{
  Quat ([this.w = 1, this.x = 0, this.y = 0, this.z = 0]);
  double w;
  double x;
  double y;
  double z;

  Vec3 toVec3(){
    return Vec3(x,y,z);
  }

  Quat set( x, y, z, w ) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.w = w;

    return this;
  }

  Quat addTime(Vec3 v, double t ){
    double ax = v.x, ay = v.y, az = v.z;
    double qw = w, qx = x, qy = y, qz = z;
    t *= 0.5;    
    x += t * (  ax*qw + ay*qz - az*qy );
    y += t * (  ay*qw + az*qx - ax*qz );
    z += t * (  az*qw + ax*qy - ay*qx );
    w += t * ( -ax*qx - ay*qy - az*qz );
    normalize();
    return this;
  }

  /*mul( q1, q2 ){
      var ax = q1.x, ay = q1.y, az = q1.z, as = q1.w,
      bx = q2.x, by = q2.y, bz = q2.z, bs = q2.w;
      this.x = ax * bs + as * bx + ay * bz - az * by;
      this.y = ay * bs + as * by + az * bx - ax * bz;
      this.z = az * bs + as * bz + ax * by - ay * bx;
      this.w = as * bs - ax * bx - ay * by - az * bz;
      return this;
  }*/

  Quat multiply(Quat q, [Quat? p] ) {
    if ( p != null ) return multiplyQuaternions( q, p );
    return multiplyQuaternions( this, q );
  }

  Quat multiplyQuaternions(Quat a, Quat b ) {
    double qax = a.x, qay = a.y, qaz = a.z, qaw = a.w;
    double qbx = b.x, qby = b.y, qbz = b.z, qbw = b.w;

    x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
    y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
    z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
    w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;
    return this;
  }

  Quat setFromUnitVectors(Vec3 v1, Vec3 v2 ) {
    var vx = Vec3();
    var r = v1.dot( v2 ) + 1;

    if ( r < Math.EPS2 ) {
      r = 0;
      if (v1.x.abs() >v1.z.abs() ){ vx.set( - v1.y, v1.x, 0 );}
      else{ vx.set( 0, - v1.z, v1.y );}
    } 
    else {
      vx.crossVectors( v1, v2 );
    }

    x = vx.x;
    y = vx.y;
    z = vx.z;
    w = r;

    return normalize();
  }

  Quat arc(Vec3 v1, Vec3 v2 ){
    double x1 = v1.x;
    double y1 = v1.y;
    double z1 = v1.z;
    double x2 = v2.x;
    double y2 = v2.y;
    double z2 = v2.z;
    double d = x1*x2 + y1*y2 + z1*z2;
    if( d==-1 ){
        x2 = y1*x1 - z1*z1;
        y2 = -z1*y1 - x1*x1;
        z2 = x1*z1 + y1*y1;
        d = 1 / math.sqrt( x2*x2 + y2*y2 + z2*z2 );
        w = 0;
        x = x2*d;
        y = y2*d;
        z = z2*d;
        return this;
    }
    double cx = y1*z2 - z1*y2;
    double cy = z1*x2 - x1*z2;
    double cz = x1*y2 - y1*x2;
    w = math.sqrt( ( 1 + d) * 0.5 );
    d = 0.5 / w;
    x = cx * d;
    y = cy * d;
    z = cz * d;
    return this;
  }

  Quat normalize(){
    double l = length();
    if ( l == 0 ) {
      set( 0, 0, 0, 1 );
    } 
    else {
      l = 1 / l;
      x = x * l;
      y = y * l;
      z = z * l;
      w = w * l;
    }
    return this;
  }

  Quat inverse() {
    return conjugate().normalize();
  }

  Quat invert(Quat q ) {
    x = q.x;
    y = q.y;
    z = q.z;
    w = q.w;
    conjugate().normalize();
    return this;
  }

  Quat conjugate() {
    x *= - 1;
    y *= - 1;
    z *= - 1;
    return this;
  }

  double length(){
    return math.sqrt(x * x + y * y + z * z + w * w  );
  }

  double lengthSq() {
    return x * x +y * y + z * z + w * w;
  }
  
  Quat copy(Quat  q ){
    x = q.x;
    y = q.y;
    z = q.z;
    w = q.w;
    return this;
  }

  Quat clone(Quat  q ){
    return Quat(x,y,z,w);
  }

  bool testDiff(Quat  q ) {
    return equals( q ) ? false : true;
  }

  bool equals(Quat  q ) {
    return x == q.x && y == q.y && z == q.z && w == q.w;
  }

  @override
  String toString(){
    return"Quat["+x.toStringAsFixed(4)+", ("+y.toStringAsFixed(4)+", "+z.toStringAsFixed(4)+", "+w.toStringAsFixed(4)+")]";
  }

  Quat setFromEuler(double x, double y, double z){
    var c1 = math.cos( x * 0.5 );
    var c2 = math.cos( y * 0.5 );
    var c3 = math.cos( z * 0.5 );
    var s1 = math.sin( x * 0.5 );
    var s2 = math.sin( y * 0.5 );
    var s3 = math.sin( z * 0.5 );

    // XYZ
    this.x = s1 * c2 * c3 + c1 * s2 * s3;
    this.y = c1 * s2 * c3 - s1 * c2 * s3;
    this.z = c1 * c2 * s3 + s1 * s2 * c3;
    w = c1 * c2 * c3 - s1 * s2 * s3;

    return this;
  }
  
  Quat setFromAxis( axis, rad ) {
    axis.normalize();
    rad = rad * 0.5;
    double s = math.sin( rad );
    x = s * axis.x;
    y = s * axis.y;
    z = s * axis.z;
    w = math.cos( rad );
    return this;
  }

  Quat setFromMat33(Mat33 mat) {
    List<double> m = mat.elements;
    double trace = m[0] + m[4] + m[8];
    double root;

    if ( trace > 0 ) {
      root = math.sqrt( trace + 1.0 );
      w = 0.5 / root;
      root = 0.5 / root;
      x = ( m[5] - m[7] ) * root;
      y = ( m[6] - m[2] ) * root;
      z = ( m[1] - m[3] ) * root;
    }
    else {
      List<double> out = [];
      int i = 0;
      if ( m[4] > m[0] ) i = 1;
      if ( m[8] > m[i*3+i] ) i = 2;

      int j = (i+1)%3;
      int k = (i+2)%3;
      
      root = math.sqrt( m[i*3+i] - m[j*3+j] - m[k*3+k] + 1.0 );
      out[i] = 0.5 * root;
      root = 0.5 / root;
      w = ( m[j*3+k] - m[k*3+j] ) * root;
      out[j] = ( m[j*3+i] + m[i*3+j] ) * root;
      out[k] = ( m[k*3+i] + m[i*3+k] ) * root;

      x = out[1];
      y = out[2];
      z = out[3];
    }

    return this;
  }

  void toArray( array, [int offset = 0]) {
    array[ offset ] = x;
    array[ offset + 1 ] = y;
    array[ offset + 2 ] = z;
    array[ offset + 3 ] = w;
  }

  Quat fromArray( array, [int offset = 0] ){
    set( array[ offset ], array[ offset + 1 ], array[ offset + 2 ], array[ offset + 3 ] );
    return this;
  }
}