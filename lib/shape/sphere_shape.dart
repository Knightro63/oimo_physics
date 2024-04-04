import 'dart:math' as math;
import 'package:oimo_physics/math/vec3.dart';

import 'shape_config.dart';
import '../math/aabb.dart';
import 'shape_main.dart';
import 'plane_shape.dart';

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

  Vec3 get center => position;

  void copy(Sphere sphere) {
    radius = sphere.radius;
    friction = sphere.friction;
    restitution = sphere.restitution;
    density = sphere.density;
    collidesWith = sphere.collidesWith;
    belongsTo = sphere.belongsTo;
    relativePosition = sphere.relativePosition.clone();
    relativeRotation = sphere.relativeRotation.clone();
    position = sphere.position.clone();
    rotation = sphere.rotation.clone();
  }

	double volume(){
		return math.pi * radius * 1.333333;
	}
  bool intersectsBox(AABB box) {
    return box.intersectsSphere(this);
  }
  bool intersectsSphere(Sphere sphere) {
    final radiusSum = radius + sphere.radius;
    return sphere.position.distanceToSquared(position) <= (radiusSum * radiusSum);
  }
  bool intersectsPlane(Plane plane) {
    return plane.distanceToPoint(center).abs() <= radius;
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