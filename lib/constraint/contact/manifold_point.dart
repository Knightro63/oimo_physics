import 'package:vector_math/vector_math.dart';

/// The class holds details of the contact point.
class ManifoldPoint{
  /// Whether this manifold point is persisting or not.
  bool warmStarted = false;
  /// The position of this manifold point.
  Vector3 position = Vector3.zero();
  /// The position in the first shape's coordinate.
  Vector3 localPoint1 = Vector3.zero();
  /// The position in the second shape's coordinate.
  Vector3 localPoint2 = Vector3.zero();
  /// The normal vector of this manifold point.
  Vector3 normal = Vector3.zero();
  /// The tangent vector of this manifold point.
  Vector3 tangent = Vector3.zero();
  /// The binormal vector of this manifold point.
  Vector3 binormal = Vector3.zero();
  /// The impulse in normal direction.
  double normalImpulse = 0;
  /// The impulse in tangent direction.
  double tangentImpulse = 0;
  /// The impulse in binormal direction.
  double binormalImpulse = 0;
  /// The denominator in normal direction.
  double normalDenominator = 0;
  /// The denominator in tangent direction.
  double tangentDenominator = 0;
  /// The denominator in binormal direction.
  double binormalDenominator = 0;
  /// The depth of penetration.
  double penetration = 0;
}