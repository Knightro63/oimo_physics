import 'package:oimo_physics/core/rigid_body.dart';

import '../../core/world_core.dart';
import '../constraint_main.dart';
import 'joint_link.dart';
import 'joint_config.dart';
import '../../math/vec3.dart';

enum JointType{none,distance,socket,hinge,wheel,slider,prismatic}

// * Joints are used to constrain the motion between two rigid bodies.
class Joint extends Constraint{
  Joint(this.config):super(){
    b1Link = JointLink(this);
    b2Link = JointLink(this);

    body1 = config.body1;
    body2 = config.body2;
  
    localAnchorPoint1 = Vec3().copy( config.localAnchorPoint1 );
    localAnchorPoint2 = Vec3().copy( config.localAnchorPoint2 );

    allowCollision = config.allowCollision;
  }
  JointConfig config;
  // The type of the joint.
  JointType jointType = JointType.none;
  //  The previous joint in the world.
  Joint? prev;
  // The next joint in the world.
  Joint? next;

  // anchor point on the first rigid body in local coordinate system.
  late Vec3 localAnchorPoint1;
  // anchor point on the second rigid body in local coordinate system.
  late Vec3 localAnchorPoint2;
  // anchor point on the first rigid body in world coordinate system relative to the body's origin.
  Vec3 relativeAnchorPoint1 = Vec3();
  // anchor point on the second rigid body in world coordinate system relative to the body's origin.
  Vec3 relativeAnchorPoint2 = Vec3();
  //  anchor point on the first rigid body in world coordinate system.
  Vec3 anchorPoint1 = Vec3();
  // anchor point on the second rigid body in world coordinate system.
  Vec3 anchorPoint2 = Vec3();
  // Whether allow collision between connected rigid bodies or not.
  late bool allowCollision;

  late JointLink b1Link;
  late JointLink b2Link;

  void setId(int i){ 
    id = i; 
  }
  @override
  void setParent(World world) {
    parent = world;
    scale = parent!.scale;
    invScale = parent!.invScale;
    id = parent?.numJoints;
    if(name == '') name = 'J$id';
  }

  // Update all the anchor points.a
  void updateAnchorPoints() {
    relativeAnchorPoint1.copy( localAnchorPoint1 ).applyMatrix3(body1!.rotation, true );
    relativeAnchorPoint2.copy(localAnchorPoint2 ).applyMatrix3(body2!.rotation, true );

    anchorPoint1.add( relativeAnchorPoint1, body1!.position );
    anchorPoint2.add( relativeAnchorPoint2, body2!.position );
  }

  // Attach the joint from the bodies.
  void attach(){//[bool isX = false]) {
    b1Link.body = body2 as RigidBody?;
    b2Link.body = body1 as RigidBody?;

    // if(isX){
    //   body1!.jointLink.push(b1Link);
    //   body2!.jointLink.push(b2Link);
    // } 
    // else {
      if(b1Link.body!.jointLink != null){ 
        (b1Link.next=b1Link.body!.jointLink)!.prev = b1Link;
      }
      else{ 
        b1Link.next = null;
      }
      b1Link.body!.jointLink = b1Link;
      b1Link.body!.numJoints++;
      if(b2Link.body!.jointLink != null){ 
        (b2Link.next=b2Link.body!.jointLink)!.prev = b2Link;
      }
      else{
        b2Link.next = null;
      }
      b2Link.body!.jointLink = b2Link;
      b2Link.body!.numJoints++;
    //}
  }

  // Detach the joint from the bodies.
  void detach(){
    final RigidBody? b1 = body1 as RigidBody?;
    final RigidBody? b2 = body2 as RigidBody?;
    // if( isX ){
    //   body1!.jointLink.splice(body1!.jointLink.indexOf(b1Link ), 1 );
    //   body2!.jointLink.splice(body2!.jointLink.indexOf(b2Link ), 1 );
    // } 
    // else {
      JointLink? prev = b1Link.prev;
      JointLink? next = b1Link.next;
      if(prev != null){ prev.next = next;}
      if(next != null){ next.prev = prev;}
      if(b1!.jointLink == b1Link){b1.jointLink = next;}
      b1Link.prev = null;
      b1Link.next = null;
      b1Link.body = null;
      b1.numJoints--;

      prev = b2Link.prev;
      next = b2Link.next;
      if(prev != null){ prev.next = next;}
      if(next != null){ next.prev = prev;}
      if(b2!.jointLink==b2Link) b2.jointLink = next;
      b2Link.prev = null;
      b2Link.next = null;
      b2Link.body = null;
      b2.numJoints--;
    //}
    b1Link.body = null;
    b2Link.body = null;
  }

  // Awake the bodies.
  @override
  void awake() {
    body1!.awake();
    body2!.awake();
  }

  // calculation function
  @override
  void preSolve( timeStep, invTimeStep ) {

  }
  @override
  void solve() {

  }
  @override
  void postSolve() {

  }
  // Delete process
  @override
  void remove() {
    dispose();
  }
  @override
  void dispose() {
    parent?.removeJoint(this);
  }

  // Three js add
  List<Vec3> getPosition() {
    Vec3 p1 = Vec3().scale(anchorPoint1, scale);
    Vec3 p2 = Vec3().scale(anchorPoint2, scale);
    return [p1, p2];
  }
}