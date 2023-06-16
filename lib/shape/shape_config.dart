import '../math/vec3.dart';
import '../math/mat33.dart';

//  * A shape configuration holds common configuration data for constructing a shape.
//  * These configurations can be reused safely.
// Shape type
enum Shapes{none,sphere,box,cylinder,plane,particle,tetra}

class ShapeConfig{
  ShapeConfig({
    this.friction = 0.2,
    this.restitution = 0.2,
    this.density = 1,
    this.collidesWith = 0xffffffff,
    this.belongsTo =  1 
  });
  // position of the shape in parent's coordinate system.
  Vec3 relativePosition = Vec3();
  // rotation matrix of the shape in parent's coordinate system.
  Mat33 relativeRotation = Mat33();
  // coefficient of friction of the shape.
  double friction ; // 0.4
  // coefficient of restitution of the shape.
  double restitution;
  // density of the shape.
  double density;
  // bits of the collision groups to which the shape belongs.
  int belongsTo;
  // bits of the collision groups with which the shape collides.
  int collidesWith;

  Shapes geometry = Shapes.none;
}