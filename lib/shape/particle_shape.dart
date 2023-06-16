import 'mass_info.dart';
import 'shape_config.dart';
import 'shape_main.dart';
import '../math/vec3.dart';

// * A Particule shape
class Particle extends Shape{
  Particle(ShapeConfig config, this.normal):super(config){
    type = Shapes.particle;
  }

  late Vec3 normal;

  double volume() {
    return double.maxFinite;
  }

  @override
  void calculateMassInfo(MassInfo out) {
    double inertia = 0;
    out.inertia.set(inertia, 0, 0, 0, inertia, 0, 0, 0, inertia);
  }
  @override
  void updateProxy() {
    int p = 0;//AABB_PROX;
    aabb.set(
      position.x - p, position.x + p,
      position.y - p, position.y + p,
      position.z - p, position.z + p
    );
    if ( this.proxy != null ) this.proxy!.update();
  }
}