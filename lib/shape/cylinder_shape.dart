import 'mass_info.dart';
import 'shape_config.dart';
import '../math/aabb.dart';
import 'shape_main.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

/// Cylinder shape
class Cylinder extends Shape{

  /// Cylinder shape
  /// 
  /// [config] configuration of the shape
  /// 
  /// [radius] the top and bottom radius of the cylinder
  /// 
  /// [height] the height of the cylinder
  Cylinder(ShapeConfig config, this.radius, this.height ):super(config) {
    type = Shapes.cylinder;
    halfHeight = height * 0.5;
  }

  double radius;
  double height;
  late double halfHeight;

  Vector3 normalDirection = Vector3.zero();
  Vector3 halfDirection = Vector3.zero();

  @override
  void calculateMassInfo(MassInfo out){
    double rsq = radius * radius;
    double mass = math.pi * rsq * height * density;
    double inertiaXZ = ( ( 0.25 * rsq ) + ( 0.0833 * height * height ) ) * mass;
    double inertiaY = 0.5 * rsq;
    out.mass = mass;
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
    len = math.sqrt(wx*wx + xx*yy + xx*zz);
    if(len>0) len = radius/len;
    wx *= len;
    hy = 1 - yy;
    len = math.sqrt(yy*xx + hy*hy + yy*zz);
    if(len>0) len = radius/len;
    hy *= len;
    dz = 1 - zz;
    len = math.sqrt(zz*xx + zz*yy + dz*dz);
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