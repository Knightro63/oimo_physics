import '../../core/rigid_body.dart';
import 'joint_main.dart';

class JointLink{
  JointLink(this.joint);

  // The previous joint link.
  JointLink? prev;
  // The next joint link.
  JointLink? next;
  // The other rigid body connected to the joint.
  RigidBody? body;
  // The joint of the link.
  Joint joint;
}