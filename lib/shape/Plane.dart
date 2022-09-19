import 'MassInfo.dart';
import 'ShapeConfig.dart';
import '../math/AABB.dart';
import 'Shape.dart';
import '../math/Vec3.dart';

/**
 * Plane shape.
 * @author lo-th
 */
class Plane extends Shape{
  Plane(ShapeConfig config, [Vec3? normal]):super(config){
    this.normal = normal ?? Vec3( 0, 1, 0 );
    type = Shapes.plane;
  }

  late Vec3 normal;

  double volume() {
    return double.maxFinite;
  }

  @override
  void calculateMassInfo(MassInfo out ) {
    out.mass = density;//0.0001;
    double inertia = 1;
    out.inertia.set( inertia, 0, 0, 0, inertia, 0, 0, 0, inertia );
  }

  @override
  void updateProxy() {
    double p = AABB_PROX;
    double min = -double.maxFinite;
    double max = double.maxFinite;
    Vec3 n = normal;
    // The plane AABB is infinite, except if the normal is pointing along any axis
    aabb.set(
      n.x == -1 ? position.x - p : min, n.x == 1 ? position.x + p : max,
      n.y == -1 ? position.y - p : min, n.y == 1 ? position.y + p : max,
      n.z == -1 ? position.z - p : min, n.z == 1 ? position.z + p : max
    );
    if(this.proxy != null ) this.proxy!.update();
  }
}