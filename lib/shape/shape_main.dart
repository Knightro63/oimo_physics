import 'package:oimo_physics/collision/broadphase/proxy_broad_phase.dart';
import 'package:oimo_physics/constraint/contact/contact_link.dart';
import 'package:oimo_physics/core/core_main.dart';
import 'package:oimo_physics/math/aabb.dart';
import 'package:oimo_physics/math/mat33.dart';
import 'package:oimo_physics/math/vec3.dart';
import 'package:oimo_physics/shape/shape_config.dart';

import 'mass_info.dart';
import '../core/utils_core.dart';

var count = 0;
int shapeIdCount() { return count++; }

// * A shape is used to detect collisions of rigid bodies.
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
  int id = shapeIdCount();
  // previous shape in parent rigid body. Used for fast interations.
  Shape? prev;
  // next shape in parent rigid body. Used for fast interations.
  Shape? next;
  // proxy of the shape used for broad-phase collision detection.
  Proxy? proxy;
  // parent rigid body of the shape.
  Core? parent;
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