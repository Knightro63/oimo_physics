import 'package:vector_math/vector_math.dart';
import 'vec3.dart';
import 'math.dart';
import 'dart:math' as math;

extension Quat on Quaternion{
    /// Is q the same as this
  bool testDiff(Quaternion  q ) {
    return equals( q ) ? false : true;
  }

  /// Is [q] equal to this
  bool equals(Quaternion  q ) {
    return x == q.x && y == q.y && z == q.z && w == q.w;
  }

  Quaternion addTime(Vector3 v, double t ){
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

  /// Convert Quant to Vec3
  Vector3 toVector3(){
    return Vector3(x,y,z);
  }

  /// Inverse the current Quant by [q]
  Quaternion invert(Quaternion q ) {
    x = q.x;
    y = q.y;
    z = q.z;
    w = q.w;
    conjugate();
    normalize();
    return this;
  }

  /// Multiply the this by [q] and return either p or this
  Quaternion multiply(Quaternion q, [Quaternion? p] ) {
    if ( p != null ) return multiplyQuaternions( q, p );
    return multiplyQuaternions( this, q );
  }

  /// Multiply [a] by [b]
  Quaternion multiplyQuaternions(Quaternion a, Quaternion b ) {
    double qax = a.x, qay = a.y, qaz = a.z, qaw = a.w;
    double qbx = b.x, qby = b.y, qbz = b.z, qbw = b.w;

    x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
    y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
    z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
    w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;
    return this;
  }
  /// Set Quant from [v1] and [v2]
  Quaternion setFromUnitVectors(Vector3 v1, Vector3 v2 ) {
    final vx = Vector3.zero();
    double r = v1.dot( v2 ) + 1;

    if ( r < Math.eps2 ) {
      r = 0;
      if (v1.x.abs() >v1.z.abs() ){ vx.setValues( - v1.y, v1.x, 0 );}
      else{ vx.setValues( 0, - v1.z, v1.y );}
    } 
    else {
      vx.cross2( v1, v2 );
    }

    x = vx.x;
    y = vx.y;
    z = vx.z;
    w = r;
    normalize();
    return this;
  }
  /// Multiply the quaternion by a vector
  Vector3 vmult(Vector3 v, [Vector3? target]){
    target ??= Vector3.zero();
    final x = v.x;
    final y = v.y;
    final z = v.z;
    
    final qx = this.x;
    final qy = this.y;
    final qz = this.z;
    final qw = w;

    // q*v
    final ix = qw * x + qy * z - qz * y;

    final iy = qw * y + qz * x - qx * z;
    final iz = qw * z + qx * y - qy * x;
    final iw = -qx * x - qy * y - qz * z;

    target.x = ix * qw + iw * -qx + iy * -qz - iz * -qy;
    target.y = iy * qw + iw * -qy + iz * -qx - ix * -qz;
    target.z = iz * qw + iw * -qz + ix * -qy - iy * -qx;

    return target;
  }
  Quaternion mult(Quaternion quat, [Quaternion? target]){
    target ??= Quaternion(0,0,0,1);
    final ax = x;
    final ay = y;
    final az = z;
    final aw = w;
    final bx = quat.x;
    final by = quat.y;
    final bz = quat.z;
    final bw = quat.w;

    target.x = ax * bw + aw * bx + ay * bz - az * by;
    target.y = ay * bw + aw * by + az * bx - ax * bz;
    target.z = az * bw + aw * bz + ax * by - ay * bx;
    target.w = aw * bw - ax * bx - ay * by - az * bz;

    return target;
  }

  /// Set Quant using Euler equation
  Quaternion eulerFromXYZ(double x, double y, double z){
    final c1 = math.cos( x * 0.5 );
    final c2 = math.cos( y * 0.5 );
    final c3 = math.cos( z * 0.5 );
    final s1 = math.sin( x * 0.5 );
    final s2 = math.sin( y * 0.5 );
    final s3 = math.sin( z * 0.5 );

    // XYZ
    final _x = s1 * c2 * c3 + c1 * s2 * s3;
    final _y = c1 * s2 * c3 - s1 * c2 * s3;
    final _z = c1 * c2 * s3 + s1 * s2 * c3;
    final _w = c1 * c2 * c3 - s1 * s2 * s3;

    return Quaternion(_x, _y, _z, _w);
  }
}