import 'dart:math' as math;
import 'vec3.dart';

// * An axis-aligned bounding box.
// AABB aproximation
double aabbProx = 0.005;

class AABB{
  AABB([double minX = 0,double maxX = 0,double minY = 0,double maxY = 0,double minZ = 0,double maxZ = 0]){
    elements[0] = minX; elements[1] = minY; elements[2] = minZ;
    elements[3] = maxX; elements[4] = maxY; elements[5] = maxZ;
  }

  List<double> elements = [1, 0, 0,0, 1, 0];

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

	bool intersectTest (AABB aabb ) {
		List<double> te = elements;
		List<double> ue = aabb.elements;
		return te[0] > ue[3] || te[1] > ue[4] || te[2] > ue[5] || te[3] < ue[0] || te[4] < ue[1] || te[5] < ue[2] ? true : false;
	}

	bool intersectTestTwo (AABB aabb ) {
		List<double> te = elements;
		List<double> ue = aabb.elements;
		return te[0] < ue[0] || te[1] < ue[1] || te[2] < ue[2] || te[3] > ue[3] || te[4] > ue[4] || te[5] > ue[5] ? true : false;
	}

	AABB clone () {
		return fromArray(elements);
	}

	AABB copy (AABB aabb, [double m = 0] ) {
		List<double> me = aabb.elements;
		set( me[ 0 ]-m, me[ 3 ]+m, me[ 1 ]-m, me[ 4 ]+m, me[ 2 ]-m, me[ 5 ]+m );
		return this;
	}

	AABB fromArray(List<double> array) {
    for(int i = 0; i < array.length; i++){
      elements[i] = array[i];
    }
		return this;
	}

	// Set this AABB to the combined AABB of aabb1 and aabb2.
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


	// Get the surface area.
	double surfaceArea () {
		List<double> te = elements;
		double a = te[3] - te[0];
		double h = te[4] - te[1];
		double d = te[5] - te[2];
		return 2 * (a * (h + d) + h * d );
	}


	// Get whether the AABB intersects with the point or not.

	bool intersectsWithPoint(double x, double y, double z){
		List<double> te = elements;
		return x>=te[0] && x<=te[3] && y>=te[1] && y<=te[4] && z>=te[2] && z<=te[5];
	}

	//  * Set the AABB from an array
	//  * of vertices. From THREE.
	void setFromPoints(List<Vec3> arr){
		makeEmpty();
		for(int i = 0; i < arr.length; i++){
			expandByPoint(arr[i]);
		}
	}

	void makeEmpty(){
		set(-double.maxFinite, -double.maxFinite, -double.maxFinite, double.maxFinite, double.maxFinite, double.maxFinite);
	}

	void expandByPoint(Vec3 pt){
		List<double> te = elements;
		set(
			math.min(te[ 0 ], pt.x), math.min(te[ 1 ], pt.y), math.min(te[ 2 ], pt.z),
			math.max(te[ 3 ], pt.x), math.max(te[ 4 ], pt.y), math.max(te[ 5 ], pt.z)
		);
	}

	void expandByScalar(double s){
		List<double> te = elements;
		te[0] += -s;
		te[1] += -s;
		te[2] += -s;
		te[3] += s;
		te[4] += s;
		te[5] += s;
	}
}