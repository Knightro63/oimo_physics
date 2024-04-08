import 'manifold_point.dart';
import '../../core/rigid_body.dart';
import '../../shape/shape_main.dart';
import 'package:vector_math/vector_math.dart';
import '../../math/vec3.dart';

/// A contact manifold between two shapes.
class ContactManifold{
  ContactManifold();

  /// The first rigid body.
  RigidBody? body1;
  /// The second rigid body.
  RigidBody? body2;
  /// The number of manifold points.
  int numPoints = 0;
  /// The manifold points.
  List<ManifoldPoint> points = [
    ManifoldPoint(),
    ManifoldPoint(),
    ManifoldPoint(),
    ManifoldPoint()
  ];

  /// Reset the manifold.
  void reset(Shape shape1, Shape shape2){
    body1 = shape1.parent;
    body2 = shape2.parent;
    numPoints = 0;
  }

  ///  Add a point into this manifold.
  /// 
  /// [pos] position of the manifold
  /// 
  /// [norm] Normal vector of the point
  /// 
  /// [penetration] depth of the contact
  /// 
  /// [flip] flip direction of contact
  void addPointVec(Vector3 pos, [Vector3? norm, double penetration = 0, bool flip = false]) {
    ManifoldPoint p = points[numPoints++];

    p.position.setFrom(pos);
    p.localPoint1.sub2(pos, body1!.position).applyMatrix3(body1!.rotation );
    p.localPoint2.sub2(pos, body2!.position).applyMatrix3(body2!.rotation );

    if(norm != null){
      p.normal.setFrom(norm);
    }

    if(flip){
      p.normal.inverse();
    }

    p.normalImpulse = 0;
    p.penetration = penetration;
    p.warmStarted = false;
  }

  ///  Add a point into this manifold.
  /// 
  /// [x] x position
  /// 
  /// [y] y position
  /// 
  /// [z] z position
  /// 
  /// [nx] normal x
  /// 
  /// [ny] normal y
  /// 
  /// [nz] normal z
  /// 
  /// [penetration] depth of the point
  /// 
  /// [flip] need to be flipped
  void addPoint(double x,double y,double z,double nx,double ny,double nz,double penetration,bool flip){
    ManifoldPoint p = points[numPoints++];

    p.position.setValues( x, y, z );
    p.localPoint1.sub2( p.position, body1!.position ).applyMatrix3(body1!.rotation );
    p.localPoint2.sub2( p.position, body2!.position ).applyMatrix3(body2!.rotation );

    p.normalImpulse = 0;

    p.normal.setValues( nx, ny, nz );
    if( flip ) p.normal.inverse();

    p.penetration = penetration;
    p.warmStarted = false;
  }
}