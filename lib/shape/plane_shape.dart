import 'package:oimo_physics/math/quat.dart';

import 'mass_info.dart';
import 'shape_config.dart';
import '../math/aabb.dart';
import 'shape_main.dart';
import '../math/vec3.dart';

// Plane shape.
class Plane extends Shape{

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