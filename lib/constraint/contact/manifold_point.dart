import '../../math/vec3.dart';

/// The class holds details of the contact point.
class ManifoldPoint{
  /// Whether this manifold point is persisting or not.
  bool warmStarted = false;
  /// The position of this manifold point.
  Vec3 position = Vec3();
  /// The position in the first shape's coordinate.
  Vec3 localPoint1 = Vec3();
  /// The position in the second shape's coordinate.
  Vec3 localPoint2 = Vec3();
  /// The normal vector of this manifold point.
  Vec3 normal = Vec3();
  /// The tangent vector of this manifold point.
  Vec3 tangent = Vec3();
  /// The binormal vector of this manifold point.
  Vec3 binormal = Vec3();
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