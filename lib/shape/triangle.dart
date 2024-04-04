import 'package:oimo_physics/shape/plane_shape.dart';

import '../math/vec3.dart';

class Triangle {
  late Vec3 a;
  late Vec3 b;
  late Vec3 c;

  static final _v0 = Vec3();
  static final _v1 = Vec3();
  static final _v2 = Vec3();
  static final _v3 = Vec3();

  Triangle([Vec3? a, Vec3? b, Vec3? c]) {
    this.a = (a != null) ? a : Vec3();
    this.b = (b != null) ? b : Vec3();
    this.c = (c != null) ? c : Vec3();
  }

  Plane getPlane(Plane target) {
    return target.setFromCoplanarPoints(a, b, c);
  }

  bool containsPoint(Vec3 point) {
    return Triangle.staticContainsPoint(point, a, b, c);
  }

  static bool staticContainsPoint(Vec3 point, Vec3 a, Vec3 b, Vec3 c) {
    staticGetBarycoord(point, a, b, c, _v3);
    return (_v3.x >= 0) && (_v3.y >= 0) && ((_v3.x + _v3.y) <= 1);
  }
  static Vec3 staticGetBarycoord(Vec3 point, Vec3 a, Vec3 b, Vec3 c, Vec3 target) {
    _v0.subVectors(c, a);
    _v1.subVectors(b, a);
    _v2.subVectors(point, a);

    var dot00 = _v0.dot(_v0);
    var dot01 = _v0.dot(_v1);
    var dot02 = _v0.dot(_v2);
    var dot11 = _v1.dot(_v1);
    var dot12 = _v1.dot(_v2);

    var denom = (dot00 * dot11 - dot01 * dot01);

    // collinear or singular triangle
    if (denom == 0) {
      // arbitrary location outside of triangle?
      // not sure if this is the best idea, maybe should be returning null
      return target.set(-2, -1, -1);
    }

    var invDenom = 1 / denom;
    var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    var v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    // barycentric coordinates must always sum to 1
    return target.set(1 - u - v, v, u);
  }

  @override
  String toString(){
    return {
      'A': [a.x,a.y,a.z],
      'B': [b.x,b.y,b.z],
      'C': [c.x,c.y,c.z],
    }.toString();
  }
}