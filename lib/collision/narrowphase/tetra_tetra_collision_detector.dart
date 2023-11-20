import 'collision_detector.dart';
import '../../math/vec3.dart';
import '../../shape/shape_main.dart';
import '../../constraint/contact/contact_manifold.dart';
import '../../shape/tetra_shape.dart';

/// Class for checking collisions between 2 tetras,
/// a shape that is made with 4 vertices and 4 faces
/// arranged in triangles. With this algorigthm, soft
/// body physics are possible and easier to implement.
class TetraTetraCollisionDetector extends CollisionDetector{

  @override
  void detectCollision(Shape shape1, Shape shape2,ContactManifold manifold){
    if(shape1 is Tetra && shape2 is Tetra){
      int i, j;
      Vec3 vec; 
      List<Face> fs1 = shape1.faces;
      List<Vec3> vs1 = shape1.verts;
      Vec3 j1, j2, j3;
      int ts = 0; // Triangle vertices `j1`, `j2` and `j3`

      // fs is undeclared
      List<Face> fs = fs1;
    
      for(i = 0; i < 4; i++){
        vec = vs1[i];
        for(j = 0; j < 4; j++){
          j1 = fs[i].a;
          j2 = fs[i].b;
          j3 = fs[i].c;

          if(
            tricheck(pt(vec.x, vec.y), pt(j1.x, j1.y), pt(j2.x, j2.y), pt(j3.x, j3.y)) &&
            tricheck(pt(vec.x, vec.z), pt(j1.x, j1.z), pt(j2.x, j2.z), pt(j3.x, j3.z)) &&
            tricheck(pt(vec.z, vec.y), pt(j1.z, j1.y), pt(j2.z, j2.y), pt(j3.z, j3.y))
          ){
            ts++;
          }

          if(ts == 4){
            manifold.addPointVec(vec);
          }
        }
      }
    }
  }

  // Taken from: http://jsfiddle.net/PerroAZUL/zdaY8/1/
  /// Check the triangle for intersections
  bool tricheck(Vec3 p,Vec3 p0,Vec3 p1,Vec3 p2){
    double A = 0.5 * (-p1.y * p2.x + p0.y * (-p1.x + p2.x) + p0.x * (p1.y - p2.y) + p1.x * p2.y);
    int sg = A < 0 ? -1 : 1;
    double s = (p0.y * p2.x - p0.x * p2.y + (p2.y - p0.y) * p.x + (p0.x - p2.x) * p.y) * sg;
    double t = (p0.x * p1.y - p0.y * p1.x + (p0.y - p1.y) * p.x + (p1.x - p0.x) * p.y) * sg;
    return s > 0 && t > 0 && (s + t) < 2 * A * sg;
  }

  /// point from x and y
  Vec3 pt(x, y){
    return Vec3(x,y);
  }
}