import 'package:vector_math/vector_math.dart';

/// This class holds mass information of a shape.
class MassInfo{
  /// Mass of the shape.
  double mass = 0;
  /// The moment inertia of the shape.
  Matrix3 inertia = Matrix3.identity();
}