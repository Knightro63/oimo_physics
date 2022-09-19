import 'CollisionDetector.dart';
import '../../math/Math.dart';
import '../../math/Vec3.dart';
import '../../core/Utils.dart';
import '../../shape/Shape.dart';
import '../../shape/Tetra.dart';
import '../../constraint/contact/ContactManifold.dart';
import '../../shape/Sphere.dart';
import 'dart:math' as math;

/**
 * Class for collision detection based on
 * ray casting. Ray source from THREE. This
 * class should only be used with the tetra
 * or a polygon.
 * @author xprogram
 */
class RayCollisionDetector extends CollisionDetector{
  RayCollisionDetector();

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold){
    if(shape1 is Tetra && shape2 is Tetra){
      Vec3 pos1 = shape1.position;
      Vec3 pos2 = shape2.position;
      Vec3 vec3_1 = Vec3(pos1.x, pos1.y, pos1.z);
      Vec3 vec3_2 = Vec3(pos2.x, pos2.y, pos2.z);
      Vec3? intersect;

      // Yes, it is a brute force approach but it works for now...
      for(int i = 0; i < shape2.faces.length; i++){
        intersect = triangleIntersect(vec3_1, vec3_2, shape2.faces[i], false);//vec3_1.angleTo(vec3_2)

        if(intersect != null){
          manifold.addPointVec(Vec3(intersect.x, intersect.y, intersect.z));
        }
      }
    }
  }

  /**
   * @author bhouston / http://clara.io
   */
  Vec3? triangleIntersect(Vec3 origin, Vec3 direction, Face face, bool backfaceCulling){
    Vec3 diff = Vec3();
    Vec3 edge1 = Vec3();
    Vec3 edge2 = Vec3();
    Vec3 normal = Vec3();

    Vec3 a = face.a, b = face.b, c = face.c;
    int sign;
    double DdN;

    edge1.subVectors(b, a);
    edge2.subVectors(c, a);
    normal.crossVectors(edge1, edge2);

    DdN = direction.dot(normal);
    if(DdN > 0){
      if(backfaceCulling)return null;
      sign = 1;
    } 
    else if(DdN < 0){
      sign = -1;
      DdN = -DdN;
    } 
    else {
      return null;
    }

    diff.subVectors(origin, a);
    double DdQxE2 = sign * direction.dot(edge2.crossVectors(diff, edge2));

    // b1 < 0, no intersection
    if ( DdQxE2 < 0 ) {
      return null;
    }

    double DdE1xQ = sign * direction.dot(edge1.cross(diff));

    // b2 < 0, no intersection
    if(DdE1xQ < 0){
      return null;
    }

    // b1+b2 > 1, no intersection
    if(DdQxE2 + DdE1xQ > DdN){
      return null;
    }

    // Line intersects triangle, check if ray does.
    double QdN = -sign * diff.dot(normal);

    // t < 0, no intersection
    if(QdN < 0){
      return null;
    }

    // Ray intersects triangle.
    return Vec3().copy( direction ).multiplyScalar(QdN / DdN).add( origin );
  }
}