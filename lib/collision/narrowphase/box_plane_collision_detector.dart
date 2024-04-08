import 'collision_detector.dart';
import '../../math/vec3.dart';
import '../../math/math.dart';
import '../../shape/box_shape.dart';
import '../../shape/plane_shape.dart';
import '../../constraint/contact/contact_manifold.dart';
import '../../shape/shape_main.dart';
import 'package:vector_math/vector_math.dart' hide Plane;

/// The collision detector for Box on Plane collisions
class BoxPlaneCollisionDetector extends CollisionDetector{
  final Vector3 n = Vector3.zero();
  final Vector3 p = Vector3.zero();

  final Vector3 dix = Vector3.zero();
  final Vector3 diy = Vector3.zero();
  final Vector3 diz = Vector3.zero();

  final Vector3 cc = Vector3.zero();
  final Vector3 cc2 = Vector3.zero();

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold ) {
    final Vector3 n = this.n;
    final Vector3 p = this.p;
    final Vector3 cc = this.cc;

    Plane pn;
    Box b;

    flip = shape1 is Plane;

    if(!flip){
      pn = shape2 as Plane;
      b = shape1 as Box;
    }
    else{
      pn = shape1 as Plane;
      b = shape2 as Box;
    }

    final D = b.dimentions;
    final double hw = b.halfWidth;
    final double hh = b.halfHeight;
    final double hd = b.halfDepth;
    double len;
    int overlap = 0;

    dix.setValues( D[0], D[1], D[2] );
    diy.setValues( D[3], D[4], D[5] );
    diz.setValues( D[6], D[7], D[8] );

    n.sub2( b.position, pn.position );

    n.x *= pn.normal.x;//+ rad;
    n.y *= pn.normal.y;
    n.z *= pn.normal.z;//+ rad;

    cc.setValues(
      Math.dotVectors( dix, n ),
      Math.dotVectors( diy, n ),
      Math.dotVectors( diz, n )
    );

    if( cc.x > hw ){ 
      cc.x = hw;
    }
    else if( cc.x < -hw ){ 
      cc.x = -hw;
    }
    else{ 
      overlap = 1;
    }
    
    if( cc.y > hh ){
      cc.y = hh;
    }
    else if( cc.y < -hh ){ 
      cc.y = -hh;
    }
    else{ 
      overlap |= 2;
    }
    
    if( cc.z > hd ){ 
      cc.z = hd;
    }
    else if( cc.z < -hd ){ 
      cc.z = -hd;
    }
    else{ 
      overlap |= 4;
    }

    if(overlap == 7){
      // center of sphere is in the box
      n.setValues(
        cc.x < 0 ? hw + cc.x : hw - cc.x,
        cc.y < 0 ? hh + cc.y : hh - cc.y,
        cc.z < 0 ? hd + cc.z : hd - cc.z
      );
        
      if( n.x < n.y ){
        if( n.x < n.z ){
          len = n.x - hw;
          if( cc.x < 0 ){
            cc.x = -hw;
            n.setFrom( dix );
          }
          else{
            cc.x = hw;
            n.sub( dix );
          }
        }
        else{
          len = n.z - hd;
          if( cc.z < 0 ){
            cc.z = -hd;
            n.setFrom( diz );
          }
          else{
            cc.z = hd;
            n.sub( diz );
          }
        }
      }
      else{
        if( n.y < n.z ){
          len = n.y - hh;
          if( cc.y < 0 ){
            cc.y = -hh;
            n.setFrom( diy );
          }
          else{
            cc.y = hh;
            n.sub( diy );
          }
        }
        else{
          len = n.z - hd;
          if( cc.z < 0 ){
            cc.z = -hd;
            n.setFrom( diz );
          }
          else{
            cc.z = hd;
            n.sub( diz );
          }
        }
      }

      p..setFrom( pn.position )..addScaledVector( n, 1 );
      manifold.addPointVec( p, n, len, flip );
    }
  }
}