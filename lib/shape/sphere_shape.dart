import 'dart:math' as math;
import 'shape_config.dart';
import '../math/aabb.dart';
import 'shape_main.dart';

/// Sphere shape
class Sphere extends Shape{
  /// Sphere shape
  /// 
  /// [config] the configuration of the shape
  /// 
  /// [radius] The radius of the sphere
  Sphere(ShapeConfig config, this.radius):super(config) {
    type = Shapes.sphere;
    //Object.assign(Object.create(Shape.prototype));
  }

  late double radius;

	double volume(){
		return math.pi * radius * 1.333333;
	}

  @override
	void calculateMassInfo( out ) {
		double mass = volume() * radius * radius * density;
		out.mass = mass;
		double inertia = mass * radius * radius * 0.4;
		out.inertia.set( inertia, 0, 0, 0, inertia, 0, 0, 0, inertia );
	}

  @override
	void updateProxy(){
		double p = aabbProx;

		aabb.set(
			position.x - radius - p, position.x + radius + p,
			position.y - radius - p, position.y + radius + p,
			position.z - radius - p, position.z + radius + p
		);

		if(proxy != null) proxy!.update();
	}
}