import 'collision_detector.dart';
import '../../math/vec3.dart';
import '../../shape/shape_main.dart';
import '../../shape/box_shape.dart';
import '../../constraint/contact/contact_manifold.dart';
import '../../shape/sphere_shape.dart';
import 'dart:math' as math;

//  * A collision detector which detects collisions between sphere and box.
class SphereBoxCollisionDetector extends CollisionDetector{

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold ){
    Sphere s;
    Box b;

    flip = shape1 is Box;

    if(flip){
      s = shape2 as Sphere;
      b = shape1 as Box;
    }
    else{
      s = shape1 as Sphere;
      b = shape2 as Box;
    }

    List<double> D = b.dimentions;
    Vec3 ps=s.position;
    Vec3 pb=b.position;
    
    double psx=ps.x;
    double psy=ps.y;
    double psz=ps.z;
    
    double pbx=pb.x;
    double pby=pb.y;
    double pbz=pb.z;
    double rad=s.radius;

    double hw=b.halfWidth;
    double hh=b.halfHeight;
    double hd=b.halfDepth;

    double dx=psx-pbx;
    double dy=psy-pby;
    double dz=psz-pbz;
    double sx=D[0]*dx+D[1]*dy+D[2]*dz;
    double sy=D[3]*dx+D[4]*dy+D[5]*dz;
    double sz=D[6]*dx+D[7]*dy+D[8]*dz;
    double cx;
    double cy;
    double cz;
    double len;
    double invLen;
    int overlap=0;

    if(sx>hw){
      sx=hw;
    }
    else if(sx<-hw){
      sx=-hw;
    }
    else{
      overlap=1;
    }

    if(sy>hh){
      sy=hh;
    }
    else if(sy<-hh){
      sy=-hh;
    }
    else{
      overlap|=2;
    }
    
    if(sz>hd){
      sz=hd;
    }
    else if(sz<-hd){
      sz=-hd;
    }
    else{
      overlap|=4;
    }
    if(overlap==7){
      // center of sphere is in the box
      if(sx<0){
        dx=hw+sx;
      }
      else{
        dx=hw-sx;
      }

      if(sy<0){
        dy=hh+sy;
      }
      else{
        dy=hh-sy;
      }
      
      if(sz<0){
        dz=hd+sz;
      }
      else{
        dz=hd-sz;
      }
      if(dx<dy){
        if(dx<dz){
          len=dx-hw;
          if(sx<0){
            sx=-hw;
            dx=D[0];
            dy=D[1];
            dz=D[2];
          }
          else{
            sx=hw;
            dx=-D[0];
            dy=-D[1];
            dz=-D[2];
          }
        }
        else{
          len=dz-hd;
          if(sz<0){
            sz=-hd;
            dx=D[6];
            dy=D[7];
            dz=D[8];
          }
          else{
            sz=hd;
            dx=-D[6];
            dy=-D[7];
            dz=-D[8];
          }
        }
      }
      else{
        if(dy<dz){
          len=dy-hh;
          if(sy<0){
            sy=-hh;
            dx=D[3];
            dy=D[4];
            dz=D[5];
          }
          else{
            sy=hh;
            dx=-D[3];
            dy=-D[4];
            dz=-D[5];
          }
        }
        else{
          len=dz-hd;
          if(sz<0){
              sz=-hd;
              dx=D[6];
              dy=D[7];
              dz=D[8];
          }
          else{
            sz=hd;
            dx=-D[6];
            dy=-D[7];
            dz=-D[8];
          }
        }
      }
      cx=pbx+sx*D[0]+sy*D[3]+sz*D[6];
      cy=pby+sx*D[1]+sy*D[4]+sz*D[7];
      cz=pbz+sx*D[2]+sy*D[5]+sz*D[8];
      manifold.addPoint(psx+rad*dx,psy+rad*dy,psz+rad*dz,dx,dy,dz,len-rad,flip);
    }
    else{
      cx=pbx+sx*D[0]+sy*D[3]+sz*D[6];
      cy=pby+sx*D[1]+sy*D[4]+sz*D[7];
      cz=pbz+sx*D[2]+sy*D[5]+sz*D[8];
      dx=cx-ps.x;
      dy=cy-ps.y;
      dz=cz-ps.z;
      len=dx*dx+dy*dy+dz*dz;
      if(len>0&&len<rad*rad){
        len=math.sqrt(len);
        invLen=1/len;
        dx*=invLen;
        dy*=invLen;
        dz*=invLen;
        manifold.addPoint(psx+rad*dx,psy+rad*dy,psz+rad*dz,dx,dy,dz,len-rad,flip);
      }
    }
  }
}