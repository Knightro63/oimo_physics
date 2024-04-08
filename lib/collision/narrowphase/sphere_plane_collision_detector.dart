import 'collision_detector.dart';
import '../../shape/sphere_shape.dart';
import '../../shape/plane_shape.dart';
import '../../constraint/contact/contact_manifold.dart';
import '../../shape/shape_main.dart';
import 'dart:math' as math;
import '../../math/vec3.dart';
import 'package:vector_math/vector_math.dart' hide Plane, Sphere;

/// A collision detector which detects collisions between sphere and plane.
class SpherePlaneCollisionDetector extends CollisionDetector{

  Vector3 n = Vector3.zero();
  Vector3 p = Vector3.zero();

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold ) {
    Vector3 n = this.n;
    Vector3 p = this.p;

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

    n.sub2( s.position, pn.position );
    //var h = _Math.dotVectors( pn.normal, n );

    n.x *= pn.normal.x;//+ rad;
    n.y *= pn.normal.y;
    n.z *= pn.normal.z;//+ rad;

    
    len = n.length2;
    
    if(len > 0 && len < rad * rad){//&& h > rad*rad ){
      len = math.sqrt(len);
      //len = _Math.sqrt( h );
      n..setFrom(pn.normal)..inverse();
      //n.scaleEqual( 1/len );

      //(0, -1, 0)

      //n.normalize();
      p..setFrom( s.position )..addScaledVector( n, rad );
      manifold.addPointVec( p, n, len - rad, flip );
    }
  }
}