import 'collision_detector.dart';
import '../../math/vec3.dart';
import '../../math/math.dart';
import '../../shape/box_shape.dart';
import '../../shape/plane_shape.dart';
import '../../constraint/contact/contact_manifold.dart';
import '../../shape/shape_main.dart';

//  * A collision detector which detects collisions between two spheres.
class BoxPlaneCollisionDetector extends CollisionDetector{
  Vec3 n = Vec3();
  Vec3 p = Vec3();

  Vec3 dix = Vec3();
  Vec3 diy = Vec3();
  Vec3 diz = Vec3();

  Vec3 cc = Vec3();
  Vec3 cc2 = Vec3();

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold ) {
    Vec3 n = this.n;
    Vec3 p = this.p;
    Vec3 cc = this.cc;

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

    List<double> D = b.dimentions;
    double hw = b.halfWidth;
    double hh = b.halfHeight;
    double hd = b.halfDepth;
    double len;
    int overlap = 0;

    dix.set( D[0], D[1], D[2] );
    diy.set( D[3], D[4], D[5] );
    diz.set( D[6], D[7], D[8] );

    n.sub( b.position, pn.position );

    n.x *= pn.normal.x;//+ rad;
    n.y *= pn.normal.y;
    n.z *= pn.normal.z;//+ rad;

    cc.set(
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
      n.set(
        cc.x < 0 ? hw + cc.x : hw - cc.x,
        cc.y < 0 ? hh + cc.y : hh - cc.y,
        cc.z < 0 ? hd + cc.z : hd - cc.z
      );
        
      if( n.x < n.y ){
        if( n.x < n.z ){
          len = n.x - hw;
          if( cc.x < 0 ){
            cc.x = -hw;
            n.copy( dix );
          }
          else{
            cc.x = hw;
            n.subEqual( dix );
          }
        }
        else{
          len = n.z - hd;
          if( cc.z < 0 ){
            cc.z = -hd;
            n.copy( diz );
          }
          else{
            cc.z = hd;
            n.subEqual( diz );
          }
        }
      }
      else{
        if( n.y < n.z ){
          len = n.y - hh;
          if( cc.y < 0 ){
            cc.y = -hh;
            n.copy( diy );
          }
          else{
            cc.y = hh;
            n.subEqual( diy );
          }
        }
        else{
          len = n.z - hd;
          if( cc.z < 0 ){
            cc.z = -hd;
            n.copy( diz );
          }
          else{
            cc.z = hd;
            n.subEqual( diz );
          }
        }
      }

      p.copy( pn.position ).addScaledVector( n, 1 );
      manifold.addPointVec( p, n, len, flip );
    }
  }
}