import 'dart:math' as math;
import 'package:oimo_physics/shape/sphere_shape.dart';
import 'package:oimo_physics/math/triangle.dart';
import 'package:vector_math/vector_math.dart' hide Triangle, Sphere;
import 'vec3.dart';

/// AABB aproximation
double aabbProx = 0.005;

/// An axis-aligned bounding box.
class AABB{
  final Vector3 _center = Vector3.zero();
  final Vector3 _extents = Vector3.zero();
  final _triangleNormal = Vector3.zero();
  final _v0 = Vector3.zero();
  final _box3v1 = Vector3.zero();
  final _v2 = Vector3.zero();
  final _f0 = Vector3.zero();
  final _f1 = Vector3.zero();
  final _f2 = Vector3.zero();

  /// An axis-aligned bounding box.
  /// 
  /// [minX] the min x position
  /// 
  /// [maxX] the max x position
  /// 
  /// [minY] the min y position
  /// 
  /// [maxY] the max y position
  /// 
  /// [minZ] the min z position
  /// 
  /// [maxZ] the max z position
  AABB([
    double minX = double.infinity,
    double maxX = -double.infinity,
    double minY = double.infinity,
    double maxY = -double.infinity,
    double minZ = double.infinity,
    double maxZ = -double.infinity
  ]){
    elements[0] = minX; elements[1] = minY; elements[2] = minZ;
    elements[3] = maxX; elements[4] = maxY; elements[5] = maxZ;
  }

  double get minX => elements[0];
  double get maxX => elements[3];
  double get minY => elements[1];
  double get maxY => elements[4];
  double get minZ => elements[2];
  double get maxZ => elements[5];

  set minX(double v){
    elements[0] = v;
  }
  set maxX(double v){
    elements[3] = v;
  }
  set minY(double v){
    elements[1] = v;
  }
  set maxY(double v){
    elements[4] = v;
  }
  set minZ(double v){
    elements[2] = v;
  }
  set maxZ(double v){
    elements[5] = v;
  }

  Vector3 get min => Vector3(elements[0],elements[1],elements[2]);
  Vector3 get max => Vector3(elements[3],elements[4],elements[5]);

  set min(Vector3 v){
    elements[0] = v.x;
    elements[1] = v.y;
    elements[2] = v.z;
  }
  set max(Vector3 v){
    elements[3] = v.x;
    elements[4] = v.y;
    elements[5] = v.z;
  }
  List<double> elements = [1, 0, 0, 0, 1, 0];

  /// Set the AABB with new parameters
  /// 
  /// [minX] the min x position
  /// 
  /// [maxX] the max x position
  /// 
  /// [minY] the min y position
  /// 
  /// [maxY] the max y position
  /// 
  /// [minZ] the min z position
  /// 
  /// [maxZ] the max z position
	AABB set(double minX,double maxX,double minY,double maxY,double minZ,double maxZ){
		List<double> te = elements;
		te[0] = minX;
		te[3] = maxX;
		te[1] = minY;
		te[4] = maxY;
		te[2] = minZ;
		te[5] = maxZ;
		return this;
	}
  bool isEmpty() {
    // this is a more robust check for empty than ( volume <= 0 ) because volume can get positive with two negative axes
    return (max.x < min.x) || (max.y < min.y) || (max.z < min.z);
  }
  Vector3 getCenter(Vector3 target) {
    if (isEmpty()) {
      target.setValues(0, 0, 0);
    } else {
      target.add2(min, max).scale(0.5);
    }

    return target;
  }
  bool intersectsTriangle(Triangle triangle) {
    if (isEmpty()) {
      return false;
    }
    // compute box center and extents
    getCenter(_center);
    _extents.sub2(max, _center);

    // translate triangle to aabb origin
    _v0.sub2(triangle.a, _center);
    _box3v1.sub2(triangle.b, _center);
    _v2.sub2(triangle.c, _center);

    // compute edge vectors for triangle
    _f0.sub2(_box3v1, _v0);
    _f1.sub2(_v2, _box3v1);
    _f2.sub2(_v0, _v2);

    // test against axes that are given by cross product combinations of the edges of the triangle and the edges of the aabb
    // make an axis testing of each of the 3 sides of the aabb against each of the 3 sides of the triangle = 9 axis of separation
    // axis_ij = u_i x f_j (u0, u1, u2 = face normals of aabb = x,y,z axes vectors since aabb is axis aligned)
    List<double> axes = [
      0,
      -_f0.z,
      _f0.y,
      0,
      -_f1.z,
      _f1.y,
      0,
      -_f2.z,
      _f2.y,
      _f0.z,
      0,
      -_f0.x,
      _f1.z,
      0,
      -_f1.x,
      _f2.z,
      0,
      -_f2.x,
      -_f0.y,
      _f0.x,
      0,
      -_f1.y,
      _f1.x,
      0,
      -_f2.y,
      _f2.x,
      0
    ];
    if (!satForAxes(axes, _v0, _box3v1, _v2, _extents)) {
      return false;
    }

    // test 3 face normals from the aabb
    axes = [1, 0, 0, 0, 1, 0, 0, 0, 1];
    if (!satForAxes(axes, _v0, _box3v1, _v2, _extents)) {
      return false;
    }

    // finally testing the face normal of the triangle
    // use already existing triangle edge vectors here
    _triangleNormal.cross2(_f0, _f1);
    axes = [_triangleNormal.x, _triangleNormal.y, _triangleNormal.z];

    return satForAxes(axes, _v0, _box3v1, _v2, _extents);
  }
  bool satForAxes(List<double> axes, Vector3 v0, Vector3 v1, Vector3 v2, Vector3 extents) {
    Vector3 _testAxis = Vector3.zero();
    for (int i = 0, j = axes.length - 3; i <= j; i += 3) {
      _testAxis.copyFromArray(axes, i);
      // project the aabb onto the seperating axis
      final r = extents.x * _testAxis.x.abs() +
          extents.y * _testAxis.y.abs() +
          extents.z * _testAxis.z.abs();
      // project all 3 vertices of the triangle onto the seperating axis
      final p0 = v0.dot(_testAxis);
      final p1 = v1.dot(_testAxis);
      final p2 = v2.dot(_testAxis);
      // actual test, basically see if either of the most extreme of the triangle points intersects r
      if (math.max(-math.max(p0, math.max(p1, p2)), math.min(p0, math.min(p1, p2))) > r) {
        // points of the projected triangle are outside the projected half-length of the aabb
        // the axis is seperating and we can exit
        return false;
      }
    }

    return true;
  }

  /// Chack to see if [aabb] intersects this.AABB
	bool intersectTest (AABB aabb ) {
		List<double> te = elements;
		List<double> ue = aabb.elements;
		return te[0] > ue[3] || te[1] > ue[4] || te[2] > ue[5] || te[3] < ue[0] || te[4] < ue[1] || te[5] < ue[2] ? true : false;
	}
  // Chack to see if [aabb] intersects this.AABB
	bool intersectTestTwo (AABB aabb ) {
		List<double> te = elements;
		List<double> ue = aabb.elements;
		return te[0] < ue[0] || te[1] < ue[1] || te[2] < ue[2] || te[3] > ue[3] || te[4] > ue[4] || te[5] > ue[5] ? true : false;
	}
  Vector3 clampPoint(Vector3 point, Vector3 target) {
    return target..setFrom(point)..clamp(min, max);
  }
  bool intersectsSphere(Sphere sphere) {
    Vector3 temp = Vector3.zero();
    // Find the point on the AABB closest to the sphere center.
    clampPoint(sphere.position, temp);
    // If that point is inside the sphere, the AABB and sphere intersect.
    return temp.distanceToSquared(sphere.position) <=
        (sphere.radius * sphere.radius);
  }
  // Clone this AABB
	AABB clone () {
		return fromArray(elements);
	}

  /// Copy all info in this AABB to another AABB
	AABB copy (AABB aabb, [double m = 0] ) {
		List<double> me = aabb.elements;
		set( me[ 0 ]-m, me[ 3 ]+m, me[ 1 ]-m, me[ 4 ]+m, me[ 2 ]-m, me[ 5 ]+m );
		return this;
	}

  /// Create this AABB from an array
	AABB fromArray(List<double> array) {
    for(int i = 0; i < array.length; i++){
      elements[i] = array[i];
    }
		return this;
	}

	/// Set this AABB to the combined AABB of aabb1 and aabb2.
	AABB combine(AABB aabb1,AABB aabb2 ) {
		List<double> a = aabb1.elements;
		List<double> b = aabb2.elements;
		List<double> te = elements;

		te[0] = a[0] < b[0] ? a[0] : b[0];
		te[1] = a[1] < b[1] ? a[1] : b[1];
		te[2] = a[2] < b[2] ? a[2] : b[2];

		te[3] = a[3] > b[3] ? a[3] : b[3];
		te[4] = a[4] > b[4] ? a[4] : b[4];
		te[5] = a[5] > b[5] ? a[5] : b[5];

		return this;
	}


	/// Get the surface area.
	double surfaceArea () {
		List<double> te = elements;
		double a = te[3] - te[0];
		double h = te[4] - te[1];
		double d = te[5] - te[2];
		return 2 * (a * (h + d) + h * d );
	}


	/// Get whether the AABB intersects with the point or not.
	bool intersectsWithPoint(double x, double y, double z){
		List<double> te = elements;
		return x>=te[0] && x<=te[3] && y>=te[1] && y<=te[4] && z>=te[2] && z<=te[5];
	}

	/// Set the AABB from an array
	/// of vertices. From THREE.
	void setFromPoints(List<Vector3> arr){
		makeEmpty();
		for(int i = 0; i < arr.length; i++){
			expandByPoint(arr[i]);
		}
	}

  /// Clear all info from this AABB
	void makeEmpty(){
		set(-double.maxFinite, -double.maxFinite, -double.maxFinite, double.maxFinite, double.maxFinite, double.maxFinite);
	}

  /// Make this AABB larger by this point
	void expandByPoint(Vector3 pt){
		List<double> te = elements;
		set(
			math.min(te[ 0 ], pt.x), math.min(te[ 1 ], pt.y), math.min(te[ 2 ], pt.z),
			math.max(te[ 3 ], pt.x), math.max(te[ 4 ], pt.y), math.max(te[ 5 ], pt.z)
		);
	}

  /// Make this AABB larger by this value
	void expandByScalar(double s){
		List<double> te = elements;
		te[0] += -s;
		te[1] += -s;
		te[2] += -s;
		te[3] += s;
		te[4] += s;
		te[5] += s;
	}
  @override
  String toString(){
    return elements.toString();
  }
}