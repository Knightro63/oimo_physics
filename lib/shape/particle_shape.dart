import 'mass_info.dart';
import 'shape_config.dart';
import 'shape_main.dart';
import 'package:vector_math/vector_math.dart';

/// A Particule shape
class Particle extends Shape{

  /// Particule Shape
  /// 
  /// [config] config file of the shape
  /// 
  /// [normal] the direction of the particle
  Particle(ShapeConfig config, this.normal):super(config){
    type = Shapes.particle;
  }

  late Vector3 normal;

  /// Calculate the volume of the particle
  double volume() {
    return double.maxFinite;
  }

  @override
  void calculateMassInfo(MassInfo out) {
    double inertia = 0;
    out.inertia.setValues(inertia, 0, 0, 0, inertia, 0, 0, 0, inertia);
  }
  @override
  void updateProxy() {
    int p = 0;//AABB_PROX;
    aabb.set(
      position.x - p, position.x + p,
      position.y - p, position.y + p,
      position.z - p, position.z + p
    );
    if (proxy != null) proxy!.update();
  }
}