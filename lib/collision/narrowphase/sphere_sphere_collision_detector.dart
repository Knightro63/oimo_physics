import 'collision_detector.dart';
import '../../math/vec3.dart';
import '../../shape/shape.dart';
import '../../constraint/contact/contact_manifold.dart';
import '../../shape/sphere.dart';
import 'dart:math' as math;

// * A collision detector which detects collisions between two spheres.
class SphereSphereCollisionDetector extends CollisionDetector{

  SphereSphereCollisionDetector();

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold ){
    Sphere s1 = shape1 as Sphere;
    Sphere s2 = shape2 as Sphere;
    Vec3 p1 = s1.position;
    Vec3 p2 = s2.position;
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