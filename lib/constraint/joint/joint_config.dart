import '../../core/rigid_body.dart';
import 'package:vector_math/vector_math.dart';

class JointConfig{
  JointConfig({
    this.body1,
    this.body2,
    this.scale = 1,
    this.invScale= 1,
    this.allowCollision = false,
    Vector3? localAnchorPoint1,
    Vector3? localAnchorPoint2,
    Vector3? localAxis1,
    Vector3? localAxis2
  }){
    this.localAnchorPoint1 = localAnchorPoint1 ?? Vector3.zero();
    this.localAnchorPoint2 = localAnchorPoint2 ?? Vector3.zero();
    this.localAxis1 = localAxis1 ?? Vector3.zero();
    this.localAxis2 = localAxis2 ?? Vector3.zero();
  }

  double scale;
  double invScale;

  /// The first rigid body of the joint.
  RigidBody? body1;
  /// The second rigid body of the joint.
  RigidBody? body2;
  /// The anchor point on the first rigid body in local coordinate system.
  late Vector3 localAnchorPoint1;
  ///  The anchor point on the second rigid body in local coordinate system.
  late Vector3 localAnchorPoint2;
  /// The axis in the first body's coordinate system.
  /// his property is available in some joints.
  late Vector3 localAxis1;
  /// The axis in the second body's coordinate system.
  /// This property is available in some joints.
  late Vector3 localAxis2;
  ///  Whether allow collision between connected rigid bodies or not.
  bool allowCollision;
}