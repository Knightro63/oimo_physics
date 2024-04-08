import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:typed_data';

extension Mat33 on Matrix3{
  /// Invert matrix m
  Matrix3 invert2(Matrix3  m ) {
    Float32List te = storage, tm = m.storage;
    double a00 = tm[0], a10 = tm[3], a20 = tm[6],
    a01 = tm[1], a11 = tm[4], a21 = tm[7],
    a02 = tm[2], a12 = tm[5], a22 = tm[8],
    b01 = a22 * a11 - a12 * a21,
    b11 = -a22 * a10 + a12 * a20,
    b21 = a21 * a10 - a11 * a20,
    det = a00 * b01 + a01 * b11 + a02 * b21;

    if ( det == 0 ) {
      //print( "can't invert matrix, determinant is 0");
      setIdentity();
      return this;
    }

    det = 1.0 / det;
    te[0] = b01 * det;
    te[1] = (-a22 * a01 + a02 * a21) * det;
    te[2] = (a12 * a01 - a02 * a11) * det;
    te[3] = b11 * det;
    te[4] = (a22 * a00 - a02 * a20) * det;
    te[5] = (-a12 * a00 + a02 * a10) * det;
    te[6] = b21 * det;
    te[7] = (-a21 * a00 + a01 * a20) * det;
    te[8] = (a11 * a00 - a01 * a10) * det;
    return this;
  }

  /// Add offest to this matrix
  Matrix3 addOffset(double m, Vector3 v ) {
    double relX = v.x;
    double relY = v.y;
    double relZ = v.z;

    Float32List te = storage;
    te[0] += m * ( relY * relY + relZ * relZ );
    te[4] += m * ( relX * relX + relZ * relZ );
    te[8] += m * ( relX * relX + relY * relY );
    double xy = m * relX * relY;
    double yz = m * relY * relZ;
    double zx = m * relZ * relX;
    te[1] -= xy;
    te[3] -= xy;
    te[2] -= yz;
    te[6] -= yz;
    te[5] -= zx;
    te[7] -= zx;
    return this;
  }

  /// Subtract matrix m with offset v
  Matrix3 subOffset(double m,Vector3 v) {
    double relX = v.x;
    double relY = v.y;
    double relZ = v.z;

    Float32List te = storage;
    te[0] -= m * ( relY * relY + relZ * relZ );
    te[4] -= m * ( relX * relX + relZ * relZ );
    te[8] -= m * ( relX * relX + relY * relY );
    double xy = m * relX * relY;
    double yz = m * relY * relZ;
    double zx = m * relZ * relX;
    te[1] += xy;
    te[3] += xy;
    te[2] += yz;
    te[6] += yz;
    te[5] += zx;
    te[7] += zx;
    return this;
  }
  Matrix3 setQuat(Quaternion q ) {
    Float32List te = storage;
    double x = q.x, y = q.y, z = q.z, w = q.w;
    double x2 = x + x,  y2 = y + y, z2 = z + z;
    double xx = x * x2, xy = x * y2, xz = x * z2;
    double yy = y * y2, yz = y * z2, zz = z * z2;
    double wx = w * x2, wy = w * y2, wz = w * z2;
    
    te[0] = 1 - ( yy + zz );
    te[1] = xy - wz;
    te[2] = xz + wy;

    te[3] = xy + wz;
    te[4] = 1 - ( xx + zz );
    te[5] = yz - wx;

    te[6] = xz - wy;
    te[7] = yz + wx;
    te[8] = 1 - ( xx + yy );

    return this;
  }
  Matrix3 multiplyMatrices(Matrix3 m1, Matrix3 m2, [bool transpose = true]) {
    if(transpose) m2 = m2.clone()..transpose();
    Float32List te = storage;
    Float32List tm1 = m1.storage;
    Float32List tm2 = m2.storage;

    double a0 = tm1[0], a3 = tm1[3], a6 = tm1[6];
    double a1 = tm1[1], a4 = tm1[4], a7 = tm1[7];
    double a2 = tm1[2], a5 = tm1[5], a8 = tm1[8];
    double b0 = tm2[0], b3 = tm2[3], b6 = tm2[6];
    double b1 = tm2[1], b4 = tm2[4], b7 = tm2[7];
    double b2 = tm2[2], b5 = tm2[5], b8 = tm2[8];

    te[0] = a0*b0 + a1*b3 + a2*b6;
    te[1] = a0*b1 + a1*b4 + a2*b7;
    te[2] = a0*b2 + a1*b5 + a2*b8;
    te[3] = a3*b0 + a4*b3 + a5*b6;
    te[4] = a3*b1 + a4*b4 + a5*b7;
    te[5] = a3*b2 + a4*b5 + a5*b8;
    te[6] = a6*b0 + a7*b3 + a8*b6;
    te[7] = a6*b1 + a7*b4 + a8*b7;
    te[8] = a6*b2 + a7*b5 + a8*b8;

    return this;
  }
  /// Add a matrix to b matrix
  Matrix3 add2(Matrix3  a, Matrix3 b ) {
    Float32List te = storage, tem1 = a.storage, tem2 = b.storage;
    te[0] = tem1[0] + tem2[0]; te[1] = tem1[1] + tem2[1]; te[2] = tem1[2] + tem2[2];
    te[3] = tem1[3] + tem2[3]; te[4] = tem1[4] + tem2[4]; te[5] = tem1[5] + tem2[5];
    te[6] = tem1[6] + tem2[6]; te[7] = tem1[7] + tem2[7]; te[8] = tem1[8] + tem2[8];
    return this;
  }

  /// Multiple this matrix by s
  Matrix3 multiplyScalar(double s ) {
    Float32List te = storage;
    te[ 0 ] *= s; te[ 3 ] *= s; te[ 6 ] *= s;
    te[ 1 ] *= s; te[ 4 ] *= s; te[ 7 ] *= s;
    te[ 2 ] *= s; te[ 5 ] *= s; te[ 8 ] *= s;

    return this;
  }
}