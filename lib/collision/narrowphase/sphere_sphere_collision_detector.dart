import 'collision_detector.dart';
import '../../shape/shape_main.dart';
import '../../constraint/contact/contact_manifold.dart';
import '../../shape/sphere_shape.dart';
import 'dart:math' as math;

/// A collision detector which detects collisions between two spheres.
class SphereSphereCollisionDetector extends CollisionDetector{

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold ){
    final s1 = shape1 as Sphere;
    final s2 = shape2 as Sphere;
    final p1 = s1.position;
    final p2 = s2.position;
    double dx = p2.x - p1.x;
    double dy = p2.y - p1.y;
    double dz = p2.z - p1.z;
    double len = dx * dx + dy * dy + dz * dz;
    double r1 = s1.radius;
    double r2 = s2.radius;
    double rad = r1 + r2;
    if ( len > 0 && len < rad * rad ){
      len = math.sqrt( len );
      double invLen = 1 / len;
      dx *= invLen;
      dy *= invLen;
      dz *= invLen;
      manifold.addPoint( p1.x + dx * r1, p1.y + dy * r1, p1.z + dz * r1, dx, dy, dz, len - rad, false );
    }
  }
}