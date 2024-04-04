import 'package:oimo_physics/math/aabb.dart';
import 'package:oimo_physics/math/vec3.dart';

class Ray {
  late Vec3 origin;
  late Vec3 direction;

  Ray([Vec3? origin, Vec3? direction]) {
    this.origin = (origin != null) ? origin : Vec3();
    this.direction = (direction != null) ? direction : Vec3(0, 0, -1);
  }
  Vec3 at(double t, [Vec3? target]) {
    target ??= Vec3();
    return target.copy(direction).multiplyScalar(t).add(origin);
  }
  Vec3? intersectBox(AABB box, [Vec3? target]) {
    double tmin, tmax, tymin, tymax, tzmin, tzmax;

    final invdirx = 1 / direction.x,
        invdiry = 1 / direction.y,
        invdirz = 1 / direction.z;

    final origin = this.origin;

    if (invdirx >= 0) {
      tmin = (box.min.x - origin.x) * invdirx;
      tmax = (box.max.x - origin.x) * invdirx;
    } else {
      tmin = (box.max.x - origin.x) * invdirx;
      tmax = (box.min.x - origin.x) * invdirx;
    }

    if (invdiry >= 0) {
      tymin = (box.min.y - origin.y) * invdiry;
      tymax = (box.max.y - origin.y) * invdiry;
    } else {
      tymin = (box.max.y - origin.y) * invdiry;
      tymax = (box.min.y - origin.y) * invdiry;
    }

    if ((tmin > tymax) || (tymin > tmax)) return null;

    // These lines also handle the case where tmin or tmax is NaN
    // (result of 0 * Infinity). x !== x returns true if x is NaN

    if (tymin > tmin || tmin != tmin) tmin = tymin;

    if (tymax < tmax || tmax != tmax) tmax = tymax;

    if (invdirz >= 0) {
      tzmin = (box.min.z - origin.z) * invdirz;
      tzmax = (box.max.z - origin.z) * invdirz;
    } else {
      tzmin = (box.max.z - origin.z) * invdirz;
      tzmax = (box.min.z - origin.z) * invdirz;
    }

    if ((tmin > tzmax) || (tzmin > tmax)) return null;

    if (tzmin > tmin || tmin != tmin) tmin = tzmin;

    if (tzmax < tmax || tmax != tmax) tmax = tzmax;

    //return point closest to the ray (positive side)

    if (tmax < 0) return null;

    return at(tmin >= 0 ? tmin : tmax, target);
  }

  bool intersectsBox(AABB box) {
    return intersectBox(box) != null;
  }
  Vec3? intersectTriangle(Vec3 a, Vec3 b, Vec3 c, bool backfaceCulling, Vec3 target) {
    final _edge1 = Vec3();
    final _edge2 = Vec3();
    final _normal = Vec3();
    final _diff = Vec3();

    _edge1.subVectors(b, a);
    _edge2.subVectors(c, a);
    _normal.crossVectors(_edge1, _edge2);

    // Solve Q + t*D = b1*E1 + b2*E2 (Q = kDiff, D = ray direction,
    // E1 = kEdge1, E2 = kEdge2, N = Cross(E1,E2)) by
    //   |Dot(D,N)|*b1 = sign(Dot(D,N))*Dot(D,Cross(Q,E2))
    //   |Dot(D,N)|*b2 = sign(Dot(D,N))*Dot(D,Cross(E1,Q))
    //   |Dot(D,N)|*t = -sign(Dot(D,N))*Dot(Q,N)
    double DdN = direction.dot(_normal);
    int sign;

    if (DdN > 0) {
      if (backfaceCulling) return null;
      sign = 1;
    } else if (DdN < 0) {
      sign = -1;
      DdN = -DdN;
    } else {
      return null;
    }

    _diff.subVectors(origin, a);
    final DdQxE2 = sign * direction.dot(_edge2.crossVectors(_diff, _edge2));

    // b1 < 0, no intersection
    if (DdQxE2 < 0) {
      return null;
    }

    final DdE1xQ = sign * direction.dot(_edge1.cross(_diff));

    // b2 < 0, no intersection
    if (DdE1xQ < 0) {
      return null;
    }

    // b1+b2 > 1, no intersection
    if (DdQxE2 + DdE1xQ > DdN) {
      return null;
    }

    // Line intersects triangle, check if ray does.
    final QdN = -sign * _diff.dot(_normal);

    // t < 0, no intersection
    if (QdN < 0) {
      return null;
    }

    // Ray intersects triangle.
    return at(QdN / DdN, target);
  }
}