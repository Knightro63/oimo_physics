import 'package:vector_math/vector_math.dart';
import 'plane.dart';
import '../math/vec3.dart';

class Triangle {
  late Vector3 a;
  late Vector3 b;
  late Vector3 c;

  static final _v0 = Vector3.zero();
  static final _v1 = Vector3.zero();
  static final _v2 = Vector3.zero();
  static final _v3 = Vector3.zero();

  Triangle([Vector3? a, Vector3? b, Vector3? c]) {
    this.a = (a != null) ? a : Vector3.zero();
    this.b = (b != null) ? b : Vector3.zero();
    this.c = (c != null) ? c : Vector3.zero();
  }

  Plane getPlane(Plane target) {
    return target.setFromCoplanarPoints(a, b, c);
  }

  bool containsPoint(Vector3 point) {
    return Triangle.staticContainsPoint(point, a, b, c);
  }

  static bool staticContainsPoint(Vector3 point, Vector3 a, Vector3 b, Vector3 c) {
    staticGetBarycoord(point, a, b, c, _v3);
    return (_v3.x >= 0) && (_v3.y >= 0) && ((_v3.x + _v3.y) <= 1);
  }
  static Vector3 staticGetBarycoord(Vector3 point, Vector3 a, Vector3 b, Vector3 c, Vector3 target) {
    _v0.sub2(c, a);
    _v1.sub2(b, a);
    _v2.sub2(point, a);

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
      return target..setValues(-2, -1, -1);
    }

    var invDenom = 1 / denom;
    var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    var v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    // barycentric coordinates must always sum to 1
    return target..setValues(1 - u - v, v, u);
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