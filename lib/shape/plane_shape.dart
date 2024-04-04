import 'package:oimo_physics/math/quat.dart';
import 'package:oimo_physics/shape/sphere_shape.dart';

import 'mass_info.dart';
import 'shape_config.dart';
import '../math/aabb.dart';
import 'shape_main.dart';
import '../math/vec3.dart';

// Plane shape.
class Plane extends Shape{
  double constant = 0;
  final _vector1 = Vec3();
  final _vector2 = Vec3();
  /// Plane Shape
  /// 
  /// [config] config file of the shape
  /// 
  /// [normal] the direction of the plane
  Plane(ShapeConfig config, [Vec3? normal]):super(config){
    this.normal = normal ?? Vec3( 0, 0, 1 );
    type = Shapes.plane;
  }

  late Vec3 normal;

  double distanceToPoint(Vec3 point) {
    return normal.dot(point);
  }
  Vec3 projectPoint(Vec3 point, Vec3 target) {
    return target
        .copy(normal)
        .multiplyScalar(-distanceToPoint(point))
        .add(point);
  }
  double distanceToSphere(Sphere sphere) {
    return distanceToPoint(sphere.position) - sphere.radius;
  }
  Plane setFromNormalAndCoplanarPoint(Vec3 normal, Vec3 point) {
    this.normal.copy(normal);
    constant = -point.dot(this.normal).toDouble();
    return this;
  }
  Plane setFromCoplanarPoints(Vec3 a, Vec3 b, Vec3 c) {
    final normal = _vector1.subVectors(c, b).cross(_vector2.subVectors(a, b)).normalize();
    setFromNormalAndCoplanarPoint(normal, a);
    return this;
  }

  /// Calculate the volume of the plane
  double volume() {
    return double.maxFinite;
  }
  void computeNormal(Quat quat){
    quat.vmult(normal, normal);
  }

  @override
  void calculateMassInfo(MassInfo out ) {
    out.mass = density;//0.0001;
    double inertia = 1;
    out.inertia.set( inertia, 0, 0, 0, inertia, 0, 0, 0, inertia );
  }

  @override
  void updateProxy() {
    double p = aabbProx;
    double min = -double.maxFinite;
    double max = double.maxFinite;
    Vec3 n = normal;
    // The plane AABB is infinite, except if the normal is pointing along any axis
    aabb.set(
      n.x == -1 ? position.x - p : min, n.x == 1 ? position.x + p : max,
      n.y == -1 ? position.y - p : min, n.y == 1 ? position.y + p : max,
      n.z == -1 ? position.z - p : min, n.z == 1 ? position.z + p : max
    );
    if(proxy != null) proxy!.update();
  }
}