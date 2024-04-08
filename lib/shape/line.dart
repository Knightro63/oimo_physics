import 'package:vector_math/vector_math.dart';
import '../math/vec3.dart';
import 'dart:math';

class Line {
  late Vector3 start;
  late Vector3 end;

  Line([Vector3? start, Vector3? end]) {
    this.start = (start != null) ? start : Vector3.zero();
    this.end = (end != null) ? end : Vector3.zero();
  }

  Line set(Vector3 start, Vector3 end) {
    this.start.setFrom(start);
    this.end.setFrom(end);
    return this;
  }
  Vector3 delta(Vector3 target) {
    return target.sub2(end, start);
  }
  double closestPointToPointParameter(Vector3 point, bool clampToLine) {
    final _startP = Vector3.zero();
    final _startEnd = Vector3.zero();
    _startP.sub2(point, start);
    _startEnd.sub2(end, start);

    final startEnd2 = _startEnd.dot(_startEnd);
    final startEndStartP = _startEnd.dot(_startP);

    double t = startEndStartP / startEnd2;

    if (clampToLine) {
      t = max(0, min(1, t));
    }

    return t;
  }
  Vector3 closestPointToPoint(Vector3 point, bool clampToLine, Vector3 target) {
    final t = closestPointToPointParameter(point, clampToLine);
    return delta(target).multiplyScalar(t)..add(start);
  }
}