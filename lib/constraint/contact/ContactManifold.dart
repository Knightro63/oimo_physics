import 'ManifoldPoint.dart';
import '../../math/Vec3.dart';
import '../../core/RigidBody.dart';
import '../../shape/Shape.dart';
/**
* A contact manifold between two shapes.
* @author saharan
* @author lo-th
*/
class ContactManifold{
  ContactManifold();

  // The first rigid body.
  RigidBody? body1;
  // The second rigid body.
  RigidBody? body2;
  // The number of manifold points.
  int numPoints = 0;
  // The manifold points.
  List<ManifoldPoint> points = [
    ManifoldPoint(),
    ManifoldPoint(),
    ManifoldPoint(),
    ManifoldPoint()
  ];

  //Reset the manifold.
  void reset(Shape shape1, Shape shape2){
    body1 = shape1.parent;
    body2 = shape2.parent;
    numPoints = 0;
  }

  //  Add a point into this manifold.
  void addPointVec(Vec3 pos, [Vec3? norm, double penetration = 0, bool flip = false]) {
    ManifoldPoint p = points[numPoints++];

    p.position.copy(pos);
    p.localPoint1.sub(pos, body1!.position).applyMatrix3(body1!.rotation );
    p.localPoint2.sub(pos, body2!.position).applyMatrix3(body2!.rotation );

    if(norm != null){
      p.normal.copy(norm);
    }

    if(flip){
      p.normal.negate();
    }

    p.normalImpulse = 0;
    p.penetration = penetration;
    p.warmStarted = false;
  }

  //  Add a point into this manifold.
  void addPoint(double x,double y,double z,double nx,double ny,double nz,double penetration,bool flip){
    ManifoldPoint p = points[numPoints++];

    p.position.set( x, y, z );
    p.localPoint1.sub( p.position, body1!.position ).applyMatrix3(body1!.rotation );
    p.localPoint2.sub( p.position, body2!.position ).applyMatrix3(body2!.rotation );

    p.normalImpulse = 0;

    p.normal.set( nx, ny, nz );
    if( flip ) p.normal.negate();

    p.penetration = penetration;
    p.warmStarted = false;
  }
}