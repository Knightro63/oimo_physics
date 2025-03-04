import 'package:oimo_physics/collision/narrowphase/collision_detector.dart';
import 'package:oimo_physics/math/vec3.dart';
import 'package:oimo_physics/shape/capsule_shape.dart';
import 'package:oimo_physics/shape/line.dart';
import 'package:oimo_physics/shape/octree_shape.dart';
import 'package:oimo_physics/shape/shape_config.dart';
import 'package:oimo_physics/math/triangle.dart';
import '../../shape/shape_main.dart';
import '../../math/plane.dart';
import '../../constraint/contact/contact_manifold.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' hide Triangle;

class OctreeCapsuleCollisionDetector extends CollisionDetector{
	final Vector3 _v1 = Vector3.zero();
	final Plane _plane = Plane();
	final Line _line1 = Line();
	final Line _line2 = Line();
	final Capsule _capsule = Capsule(ShapeConfig(),1,1);

  List<Triangle> getCapsuleTriangles(Capsule capsule, List<Triangle> triangles, List<OctreeNode> subTrees){
    for (int i = 0; i < subTrees.length; i ++ ) {
      OctreeNode subTree = subTrees[i];
      if(!capsule.intersectsBox(subTree.box)) continue;
      if(subTree.triangles.isNotEmpty){
        for(int j = 0; j < subTree.triangles.length; j ++ ) {
          if(!triangles.contains(subTree.triangles[j])){
            triangles.add( subTree.triangles[ j ] );
          }
        }
      } 
      else {
        getCapsuleTriangles( capsule, triangles, subTree.subTrees);//subTree.
      }
    }

    return triangles;
  }
  OctreeData? capsuleIntersect(Capsule capsule, OctreeNode octree){
    _capsule.copy(capsule);

    List<Triangle> triangles = getCapsuleTriangles(_capsule, [], octree.subTrees); 
    bool hit = false;
    for(int i = 0; i < triangles.length; i ++ ) {
      OctreeData? result = triangleCapsuleIntersect(_capsule, triangles[i]);
      if (result != null){
        hit = true;
        _capsule.translate(result.normal..scale(result.depth));
      }
    }

    if(hit){
      Vector3 collisionVector = _capsule.getCenter(Vector3.zero())..sub( capsule.getCenter(_v1));
      double depth = collisionVector.length;
      return OctreeData(point: Vector3.zero(), normal: collisionVector..normalize(), depth: depth);
    }

    return null;
  }

  OctreeData? triangleCapsuleIntersect(Capsule capsule, Triangle triangle) {
    Vector3 point1, point2;
    Line line1, line2;

    triangle.getPlane(_plane);

    double d1 = _plane.distanceToPoint(capsule.start) - capsule.radius;
    double d2 = _plane.distanceToPoint(capsule.end) - capsule.radius;

    if(( d1 > 0 && d2 > 0 ) || ( d1 < - capsule.radius && d2 < - capsule.radius)){
      return null;
    }

    double delta = (d1 / (d1.abs() + d2.abs())).abs();
    Vector3 intersectPoint = _v1..setFrom( capsule.start )..lerp( capsule.end, delta );

    if(triangle.containsPoint( intersectPoint)){
      return OctreeData(normal: _plane.normal.clone(), point: intersectPoint.clone(), depth: math.min( d1, d2 ).toDouble().abs());
    }

    double r2 = capsule.radius * capsule.radius;

    line1 = _line1.set( capsule.start, capsule.end );

    List<List<Vector3>> lines = [
      [ triangle.a, triangle.b ],
      [ triangle.b, triangle.c ],
      [ triangle.c, triangle.a ]
    ];

    for (int i = 0; i < lines.length; i++){
      line2 = _line2.set( lines[ i ][ 0 ], lines[ i ][ 1 ] );

      List<Vector3> pt = capsule.lineLineMinimumPoints( line1, line2 );
      point1  = pt[0];
      point2 = pt[1];
      if ( point1.distanceToSquared( point2 ) < r2 ) {
        return OctreeData(normal: point1.clone()..sub( point2 )..normalize(), point: point2.clone(), depth: capsule.radius - point1.distanceTo( point2 ));
      }
    }

    return null;
  }

  @override
  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold){
    Octree o;
    Capsule c;

    flip = shape1 is Capsule;

    if(flip){
      o = shape2 as Octree;
      c = shape1 as Capsule;
    }
    else{
      o = shape1 as Octree;
      c = shape2 as Capsule;
    }
    
    OctreeData? result = capsuleIntersect(c,o.node);
    //playerCollider.translate(result.normal.multiplyScalar(result.depth));
    if(result != null && result.point != null){
      manifold.addPointVec(result.point!,result.normal,result.depth, flip );
    }
  }
}