import 'package:vector_math/vector_math.dart' hide Sphere;
import 'vec3.dart';
import '../shape/sphere_shape.dart';

final _vector1 = Vector3.zero();
final _vector2 = Vector3.zero();

extension PlaneUtil on Plane{
  Plane clone() {
    return Plane.copy(this);
  }
  Vector3 projectPoint(Vector3 point, Vector3 target) {
    return target
        ..setFrom(normal)
        ..scale(-distanceToPoint(point))
        ..add(point);
  }
  double distanceToSphere(Sphere sphere) {
    return distanceToPoint(sphere.position) - sphere.radius;
  }

  Vector3 coplanarPoint(Vector3 target) {
    target.setFrom(normal);
    target.scale(-constant);
    return target;
  }
  Plane setFromNormalAndCoplanarPoint(Vector3 normal, Vector3 point) {
    this.normal.setFrom(normal);
    constant = -point.dot(this.normal).toDouble();
    return this;
  }
  Plane setFromCoplanarPoints(Vector3 a, Vector3 b, Vector3 c) {
    final normal = _vector1.sub2(c, b)..cross(_vector2.sub2(a, b))..normalize();
    setFromNormalAndCoplanarPoint(normal, a);
    return this;
  }

  double distanceToPoint(Vector3 point) {
    return normal.dot(point) + constant;
  }

}