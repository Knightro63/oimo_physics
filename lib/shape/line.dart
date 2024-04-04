import 'package:oimo_physics/math/vec3.dart';
import 'dart:math';

class Line {
  late Vec3 start;
  late Vec3 end;

  Line([Vec3? start, Vec3? end]) {
    this.start = (start != null) ? start : Vec3();
    this.end = (end != null) ? end : Vec3();
  }

  Line set(Vec3 start, Vec3 end) {
    this.start.copy(start);
    this.end.copy(end);
    return this;
  }
  Vec3 delta(Vec3 target) {
    return target.subVectors(end, start);
  }
  double closestPointToPointParameter(Vec3 point, bool clampToLine) {
    final _startP = Vec3();
    final _startEnd = Vec3();
    _startP.subVectors(point, start);
    _startEnd.subVectors(end, start);

    final startEnd2 = _startEnd.dot(_startEnd);
    final startEndStartP = _startEnd.dot(_startP);

    double t = startEndStartP / startEnd2;

    if (clampToLine) {
      t = max(0, min(1, t));
    }

    return t;
  }
  Vec3 closestPointToPoint(Vec3 point, bool clampToLine, Vec3 target) {
    final t = closestPointToPointParameter(point, clampToLine);
    return delta(target).multiplyScalar(t).add(start);
  }
}