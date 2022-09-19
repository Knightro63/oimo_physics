import 'MassInfo.dart';
import '../core/Utils.dart';
import '../constraint/Constraint.dart';
import '../math/Vec3.dart';
import '../math/Mat33.dart';
import '../math/AABB.dart';
import 'ShapeConfig.dart';
import '../core/RigidBody.dart';
import '../constraint/contact/ContactLink.dart';
import '../collision/broadphase/Proxy.dart';

var count = 0;
int ShapeIdCount() { return count++; }

/**
 * A shape is used to detect collisions of rigid bodies.
 *
 * @author saharan
 * @author lo-th
 */

class Shape{
  Shape(ShapeConfig config){
    relativePosition = Vec3().copy( config.relativePosition );
    relativeRotation = Mat33().copy( config.relativeRotation );

    density = config.density;
    friction = config.friction;
    restitution = config.restitution;
    belongsTo = config.belongsTo;
    collidesWith = config.collidesWith;
    type = config.geometry;
  }
  Shapes type = Shapes.none;
  // global identification of the shape should be unique to the shape.
  int id = ShapeIdCount();
  // previous shape in parent rigid body. Used for fast interations.
  Shape? prev;
  // next shape in parent rigid body. Used for fast interations.
  Shape? next;
  // proxy of the shape used for broad-phase collision detection.
  Proxy? proxy;
  // parent rigid body of the shape.
  RigidBody? parent;
  // linked list of the contacts with the shape.
  ContactLink? contactLink;
  // number of the contacts with the shape.
  int numContacts = 0;
  // center of gravity of the shape in world coordinate system.
  Vec3 position = Vec3();
  // rotation matrix of the shape in world coordinate system.
  Mat33 rotation = Mat33();
  // position of the shape in parent's coordinate system.
  late Vec3 relativePosition;
  // rotation matrix of the shape in parent's coordinate system.
  late Mat33 relativeRotation;
  // axis-aligned bounding box of the shape.
  AABB aabb = AABB();
  // density of the shape.
  late double density; 
  // coefficient of friction of the shape.
  late double friction;
  // coefficient of restitution of the shape.
  late double restitution;
  // bits of the collision groups to which the shape belongs.
  late int belongsTo;
  // bits of the collision groups with which the shape collides.
  late int collidesWith;

  // Calculate the mass information of the shape.
  void calculateMassInfo(MassInfo out){
    printError("Shape", "Inheritance error.");
  }

  // Update the proxy of the shape.
  void updateProxy(){
    printError("Shape Proxy", "Inheritance error.");
  }
}