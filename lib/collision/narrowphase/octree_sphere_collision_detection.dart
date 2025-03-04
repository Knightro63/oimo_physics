import 'package:oimo_physics/collision/narrowphase/collision_detector.dart';
import 'package:oimo_physics/shape/octree_shape.dart';
import 'package:oimo_physics/shape/shape_config.dart';
import 'package:oimo_physics/shape/sphere_shape.dart';
import 'package:oimo_physics/math/triangle.dart';
import 'package:oimo_physics/shape/line.dart';
import '../../shape/shape_main.dart';
import '../../math/plane.dart';
import '../../constraint/contact/contact_manifold.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vmath;

class OctreeSphereCollisionDetector extends CollisionDetector{
	final vmath.Vector3 _v1 = vmath.Vector3.zero();
	final vmath.Vector3 _v2 = vmath.Vector3.zero();
	final vmath.Plane _plane = vmath.Plane();
	final Line _line1 = Line();
	final Sphere _sphere = Sphere(ShapeConfig(),1);

  List<Triangle> getSphereTriangles(Sphere sphere, List<Triangle> triangles, List<OctreeNode> subTrees) {
    for (int i = 0; i < subTrees.length; i ++ ) {
      OctreeNode subTree = subTrees[ i ];
      if (!sphere.intersectsBox(subTree.box)) continue;
      if ( subTree.triangles.isNotEmpty) {
        for (int j = 0; j < subTree.triangles.length; j ++ ) {
          if(!triangles.contains(subTree.triangles[j])){
            triangles.add( subTree.triangles[ j ] );
          } 
        }
      } 
      else {
        getSphereTriangles(sphere, triangles, subTree.subTrees);
      }
    }

    return triangles;
  }
  OctreeData? triangleSphereIntersect(Sphere sphere, Triangle triangle ) {
    triangle.getPlane( _plane );
    if(!sphere.intersectsPlane( _plane )) return null;
    double depth = _plane.distanceToSphere( sphere ).abs();
    double r2 = sphere.radius * sphere.radius - depth * depth;

    _plane.projectPoint( sphere.center, _v1 );

    if ( triangle.containsPoint( sphere.center ) ) {
      print('here2');
      return OctreeData(
        normal: _plane.normal.clone(), 
        point: _v1.clone(), 
        depth: _plane.distanceToSphere(sphere).abs()
      );
    }

    List<List<vmath.Vector3>> lines = [
      [ triangle.a, triangle.b ],
      [ triangle.b, triangle.c ],
      [ triangle.c, triangle.a ]
    ];

    for (int i = 0; i < lines.length; i ++ ) {
      _line1.set( lines[ i ][ 0 ], lines[ i ][ 1 ] );
      _line1.closestPointToPoint( _v1, true, _v2 );

      double d = _v2.distanceToSquared( sphere.center );
      vmath.Vector3 n = sphere.center.clone()..sub( _v2 )..normalize();
      if ( d < r2 ) {
        return OctreeData(
          normal: n, 
          point: sphere.position.clone()..addScaled(n, sphere.radius), 
          depth: sphere.radius - math.sqrt(d)
        );
      }
    }

    return null;
  }
  OctreeData? sphereIntersect(Sphere sphere, OctreeNode octree, ){
    _sphere.copy(sphere);
    final List<Triangle> triangles = [];

    getSphereTriangles(_sphere, triangles, octree.subTrees);
    bool hit = false;
    for(int i = 0; i < triangles.length; i ++ ) {
      OctreeData? result = triangleSphereIntersect(_sphere, triangles[i]);
      if(result != null) {
        hit = true;
        _sphere.center.add(result.normal..scale(result.depth));
      }
    }

    if(hit){
      vmath.Vector3 collisionVector = _sphere.center.clone()..sub(sphere.center);
      double depth = collisionVector.length;
      print('here3');
      return OctreeData(
        point:  _sphere.center.clone()..addScaled(collisionVector..normalize(), sphere.radius),
        normal: collisionVector..normalize(), 
        depth: depth
      );
    }
    triangles.clear();
    return null;
  }

  @override
  void detectCollision(Shape shape1, Shape shape2,ContactManifold manifold){
    Octree o;
    Sphere s;

    flip = shape1 is Sphere;

    if(flip){
      o = shape2 as Octree;
      s = shape1 as Sphere;
    }
    else{
      o = shape1 as Octree;
      s = shape2 as Sphere;
    }

    OctreeData? result = sphereIntersect(s,o.node);
    //OctreeData? result = o.node.sphereIntersect(s,);
    
    //playerCollider.translate(result.normal.multiplyScalar(result.depth));
    if(result != null && result.point != null){
      manifold.addPointVec(result.point!,result.normal,result.depth, flip );
    }
  }
}