import 'package:oimo_physics/shape/line.dart';

import 'mass_info.dart';
import 'shape_config.dart';
import '../math/aabb.dart';
import 'shape_main.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

/// Capsule shape
class Capsule extends Shape{
  late Vector3 start;
  late Vector3 end;

	final Vector3 _v1 = Vector3.zero();
	final Vector3 _v2 = Vector3.zero();
	final Vector3 _v3 = Vector3.zero();

	double eps = 1e-10;

  /// Capsule shape
  /// 
  /// [config] configuration of the shape
  /// 
  /// [radius] the top and bottom radius of the Capsule
  /// 
  /// [height] the height of the Capsule
  Capsule(ShapeConfig config, this.radius, this.height):super(config) {
    type = Shapes.capsule;
    halfHeight = height * 0.5;
    start = relativePosition..y += halfHeight;
    end = relativePosition..y -= halfHeight;
  }

  double radius;
  double height;
  late double halfHeight;

  Vector3 normalDirection = Vector3.zero();
  Vector3 halfDirection = Vector3.zero();

  void copy(Capsule capsule){
    start.setFrom(capsule.start);
    end.setFrom(capsule.end);
    radius = capsule.radius;
  }
  void translate(Vector3 v){
    start.add(v);
    end.add(v);
  }

	double volume(){
		return pi * radius * 1.333333;
	}
  bool checkAABBAxis(double p1x,double p1y,double p2x,double p2y,double minx,double maxx,double miny,double maxy, double radius){
    return (
      ( minx - p1x < radius || minx - p2x < radius ) &&
      ( p1x - maxx < radius || p2x - maxx < radius ) &&
      ( miny - p1y < radius || miny - p2y < radius ) &&
      ( p1y - maxy < radius || p2y - maxy < radius )
    );
  }
  Vector3 getCenter(Vector3 target){
    return target..setFrom(end)..add(start)..scale( 0.5 );
  }
  bool intersectsBox(AABB box){
    return (
      checkAABBAxis(
        start.x, start.y, end.x, end.y,
        box.minX, box.maxX, box.minY, box.maxY,
        radius 
      ) &&
      checkAABBAxis(
        start.x, start.z, end.x, end.z,
        box.minX, box.maxX, box.minZ, box.maxZ,
        radius 
      ) &&
      checkAABBAxis(
        start.y, start.z, end.y, end.z,
        box.minY, box.maxY, box.minZ, box.maxZ,
        radius 
      )
    );
  }
  List<Vector3> lineLineMinimumPoints(Line line1,Line line2 ){
    Vector3 r = _v1..setFrom( line1.end )..sub( line1.start );
    Vector3 s = _v2..setFrom( line2.end )..sub( line2.start );
    Vector3 w = _v3..setFrom( line2.start )..sub( line1.start );

    num a = r.dot( s ),
      b = r.dot( r ),
      c = s.dot( s ),
      d = s.dot( w ),
      e = r.dot( w );

    double t1; 
    double t2;
    num divisor = b * c - a * a;

    if (divisor.abs() < eps ) {
      double d1 = - d / c;
      double d2 = ( a - d ) / c;

      if ( ( d1 - 0.5 ).abs() < ( d2 - 0.5 ).abs() ) {
        t1 = 0;
        t2 = d1;
      } 
      else {
        t1 = 1;
        t2 = d2;
      }
    } 
    else {
      t1 = ( d * a + e * c ) / divisor;
      t2 = ( t1 * a - d ) / c;
    }

    t2 = max(0, min( 1, t2 ) );
    t1 = max(0, min( 1, t1 ) );

    Vector3 point1 = r..scale( t1 )..add( line1.start );
    Vector3 point2 = s..scale( t2 )..add( line2.start );

    return [point1, point2];
  }

  @override
  void calculateMassInfo(MassInfo out){
    double rsq = radius * radius;
    double sphereMass = volume() * radius * radius * density;
    double mass = pi * rsq * height * density + sphereMass;

    double sphereInertia = mass * radius * radius * 0.4;
    double inertiaXZ = ((0.25 * rsq) + (0.0833 * height * height)) * mass + sphereInertia;
    double inertiaY = 0.5 * rsq;

		out.mass = sphereMass + mass;
    out.inertia.setValues( inertiaXZ, 0, 0,  0, inertiaY, 0,  0, 0, inertiaXZ );
  }

  @override
  void updateProxy() {
    final te = rotation.storage;
    double len, wx, hy, dz, xx, yy, zz, w, h, d, p;

    xx = te[1] * te[1];
    yy = te[4] * te[4];
    zz = te[7] * te[7];

    normalDirection.setValues( te[1], te[4], te[7] );
    halfDirection..setFrom(normalDirection)..scale(halfHeight);

    wx = 1 - xx;
    len = sqrt(wx*wx + xx*yy + xx*zz);
    if(len>0) len = radius/len;
    wx *= len;
    hy = 1 - yy;
    len = sqrt(yy*xx + hy*hy + yy*zz);
    if(len>0) len = radius/len;
    hy *= len;
    dz = 1 - zz;
    len = sqrt(zz*xx + zz*yy + dz*dz);
    if(len>0) len = radius/len;
    dz *= len;

    w = halfDirection.x < 0 ? -halfDirection.x : halfDirection.x;
    h = halfDirection.y < 0 ? -halfDirection.y : halfDirection.y;
    d = halfDirection.z < 0 ? -halfDirection.z : halfDirection.z;

    w = wx < 0 ? w - wx : w + wx;
    h = hy < 0 ? h - hy : h + hy;
    d = dz < 0 ? d - dz : d + dz;

    p = aabbProx;

    aabb.set(
      position.x - w - p, position.x + w + p,
      position.y - h - p, position.y + h + p,
      position.z - d - p, position.z + d + p
    );

    if(proxy != null) proxy!.update();
  }
}