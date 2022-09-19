import '../../core/RigidBody.dart';

import '../../math/Vec3.dart';
class JointConfig{
  JointConfig();

  double scale = 1;
  double invScale = 1;

  // The first rigid body of the joint.
  RigidBody? body1;
  // The second rigid body of the joint.
  RigidBody? body2;
  // The anchor point on the first rigid body in local coordinate system.
  Vec3 localAnchorPoint1 = Vec3();
  //  The anchor point on the second rigid body in local coordinate system.
  Vec3 localAnchorPoint2 = Vec3();
  // The axis in the first body's coordinate system.
  // his property is available in some joints.
  Vec3 localAxis1 = Vec3();
  // The axis in the second body's coordinate system.
  // This property is available in some joints.
  Vec3 localAxis2 = Vec3();
  //  Whether allow collision between connected rigid bodies or not.
  bool allowCollision = false;
}