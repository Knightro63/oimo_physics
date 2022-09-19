import 'CollisionDetector.dart';
import '../../math/Vec3.dart';
import '../../math/Math.dart' as Math;
import '../../shape/Sphere.dart';
import '../../shape/Plane.dart';
import '../../constraint/contact/ContactManifold.dart';
import '../../shape/Shape.dart';
import 'dart:math' as math;

/**
 * A collision detector which detects collisions between two spheres.
 * @author saharan 
 * @author lo-th
 */
class SpherePlaneCollisionDetector extends CollisionDetector{

  Vec3 n = Vec3();
  Vec3 p = Vec3();

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold ) {
    Vec3 n = this.n;
    Vec3 p = this.p;

    Plane pn;
    Sphere s;

    flip = shape1 is Plane;

    if(!flip){
      pn = shape2 as Plane;
      s = shape1 as Sphere;
    }
    else{
      pn = shape1 as Plane;
      s = shape2 as Sphere;
    }

    double rad = s.radius;
    double len;

    n.sub( s.position, pn.position );
    //var h = _Math.dotVectors( pn.normal, n );

    n.x *= pn.normal.x;//+ rad;
    n.y *= pn.normal.y;
    n.z *= pn.normal.z;//+ rad;

    
    len = n.lengthSq();
    
    if(len > 0 && len < rad * rad){//&& h > rad*rad ){
      len = math.sqrt(len);
      //len = _Math.sqrt( h );
      n.copy(pn.normal).negate();
      //n.scaleEqual( 1/len );

      //(0, -1, 0)

      //n.normalize();
      p.copy( s.position ).addScaledVector( n, rad );
      manifold.addPointVec( p, n, len - rad, flip );
    }
  }
}