import 'package:vector_math/vector_math.dart';

/// Shape type
enum Shapes{none,sphere,box,cylinder,capsule,plane,particle,octree,tetra}

/// A shape configuration holds common configuration data for constructing a shape.
/// These configurations can be reused safely.
class ShapeConfig{
  ShapeConfig({
    this.friction = 0.4,
    this.restitution = 0.4,
    this.density = 1,
    this.collidesWith = 0xffffffff,
    this.belongsTo =  1,
    this.geometry = Shapes.none,
    Vector3? relativePosition,
    Matrix3? relativeRotation
  }){
    this.relativePosition = relativePosition ?? Vector3.zero();
    this.relativeRotation = relativeRotation ?? Matrix3.identity();
  }
  /// position of the shape in parent's coordinate system.
  late Vector3 relativePosition;
  /// rotation matrix of the shape in parent's coordinate system.
  late Matrix3 relativeRotation;
  /// coefficient of friction of the shape.
  double friction ; // 0.4
  /// coefficient of restitution of the shape.
  double restitution;
  /// density of the shape.
  double density;
  /// bits of the collision groups to which the shape belongs.
  int belongsTo;
  /// bits of the collision groups with which the shape collides.
  int collidesWith;

  Shapes geometry;
}