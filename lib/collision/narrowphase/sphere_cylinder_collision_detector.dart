import 'collision_detector.dart';
import '../../math/vec3.dart';
import '../../shape/shape_main.dart';
import '../../shape/cylinder_shape.dart';
import '../../constraint/contact/contact_manifold.dart';
import '../../shape/sphere_shape.dart';
import 'dart:math' as math;

class SphereCylinderCollisionDetector extends CollisionDetector{
  SphereCylinderCollisionDetector();

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold){
    Sphere s;
    Cylinder c;

    flip = shape1 is Cylinder;

    if(flip){
      s = shape2 as Sphere;
      c = shape1 as Cylinder;
    }
    else{
      s = shape1 as Sphere;
      c = shape2 as Cylinder;
    }

    Vec3 ps = s.position;
    double psx = ps.x;
    double psy = ps.y;
    double psz = ps.z;
    Vec3 pc = c.position;
    double pcx = pc.x;
    double pcy = pc.y;
    double pcz = pc.z;
    double dirx = c.normalDirection.x;
    double diry = c.normalDirection.y;
    double dirz = c.normalDirection.z;
    double rads = s.radius;
    double radc = c.radius;
    double rad2 = rads + radc;
    double halfh = c.halfHeight;
    double dx = psx - pcx;
    double dy = psy - pcy;
    double dz = psz - pcz;
    double dot = dx * dirx + dy * diry + dz * dirz;

    if ( dot < -halfh - rads || dot > halfh + rads ) return;

    double cx = pcx + dot * dirx;
    double cy = pcy + dot * diry;
    double cz = pcz + dot * dirz;
    double d2x = psx - cx;
    double d2y = psy - cy;
    double d2z = psz - cz;
    double len = d2x * d2x + d2y * d2y + d2z * d2z;

    if ( len > rad2 * rad2 ) return;
    if ( len > radc * radc ) {
        len = radc / math.sqrt( len );
        d2x *= len;
        d2y *= len;
        d2z *= len;
    }

    if( dot < -halfh ){ 
      dot = -halfh;
    }
    else if( dot > halfh ){ 
      dot = halfh;
    }
    
    cx = pcx + dot * dirx + d2x;
    cy = pcy + dot * diry + d2y;
    cz = pcz + dot * dirz + d2z;
    dx = cx - psx;
    dy = cy - psy;
    dz = cz - psz;
    len = dx * dx + dy * dy + dz * dz;

    double invLen;
    if ( len > 0 && len < rads * rads ) {
      len = math.sqrt(len);
      invLen = 1 / len;
      dx *= invLen;
      dy *= invLen;
      dz *= invLen;
      ///result.addContactInfo(psx+dx*rads,psy+dy*rads,psz+dz*rads,dx,dy,dz,len-rads,s,c,0,0,false);
      manifold.addPoint( psx + dx * rads, psy + dy * rads, psz + dz * rads, dx, dy, dz, len - rads, flip);
    }
  }
}