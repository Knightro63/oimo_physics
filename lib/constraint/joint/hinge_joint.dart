import 'joint_main.dart';
import 'joint_config.dart';
import 'limit_motor.dart';
import '../../math/vec3.dart';
import '../../math/quat.dart';
import '../../math/mat33.dart';
import '../../math/math.dart';

import 'base/linear_constraint.dart';
import 'base/rotational3_constraint.dart';

/// A hinge joint allows only for relative rotation of rigid bodies along the axis.
class HingeJoint extends Joint{

  /// A hinge joint allows only for relative rotation of rigid bodies along the axis.
  /// 
  /// [config] configuration profile of the joint
  /// 
  /// [lowerAngleLimit] the min angle the motor will travel
  /// 
  /// [upperAngleLimit] the max angle the motor will travel
  HingeJoint(JointConfig config,[double lowerAngleLimit = 0,double upperAngleLimit = 0 ]):super(config){
    type = JointType.hinge;
    limitMotor = LimitMotor(nor, false );
    limitMotor.lowerLimit = lowerAngleLimit;
    limitMotor.upperLimit = upperAngleLimit;
    lc = LinearConstraint(this);

    // The axis in the first body's coordinate system.
    localAxis1 = config.localAxis1.clone().normalize();
    // The axis in the second body's coordinate system.
    localAxis2 = config.localAxis2.clone().normalize();

    arc = Mat33().setQuat( Quat().setFromUnitVectors(localAxis1, localAxis2));
    localAngle1 = Vec3().tangent(localAxis1).normalize();
    localAngle2 = localAngle1.clone().applyMatrix3( arc, true );

    r3 = Rotational3Constraint(this, limitMotor, LimitMotor(tan, true), LimitMotor(bin, true));
  }

  /// The axis in the first body's coordinate system.
  late Vec3 localAxis1;
  /// The axis in the second body's coordinate system.
  late Vec3 localAxis2;

  // make angle axis
  late Mat33 arc;
  late Vec3 localAngle1;
  late Vec3 localAngle2;

  Vec3 ax1 = Vec3();
  Vec3 ax2 = Vec3();
  Vec3 an1 = Vec3();
  Vec3 an2 = Vec3();

  Vec3 tmp = Vec3();

  Vec3 nor = Vec3();
  Vec3 tan = Vec3();
  Vec3 bin = Vec3();

  /// The rotational limit and motor information of the joint.
  late LimitMotor limitMotor;

  late LinearConstraint lc;
  late Rotational3Constraint r3;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();

    ax1.copy(localAxis1).applyMatrix3(body1!.rotation, true );
    ax2.copy(localAxis2).applyMatrix3(body2!.rotation, true );

    an1.copy(localAngle1).applyMatrix3(body1!.rotation, true );
    an2.copy(localAngle2).applyMatrix3(body2!.rotation, true );

    // normal tangent binormal

    nor.set(
      ax1.x*body2!.inverseMass + ax2.x*body1!.inverseMass,
      ax1.y*body2!.inverseMass + ax2.y*body1!.inverseMass,
      ax1.z*body2!.inverseMass + ax2.z*body1!.inverseMass
    ).normalize();

    tan.tangent(nor).normalize();

    bin.crossVectors(nor,tan);

    // calculate hinge angle

    double limite = Math.acosClamp(Math.dotVectors(an1, an2) );

    tmp.crossVectors(an1, an2);

    if(Math.dotVectors(nor, tmp) < 0){limitMotor.angle = -limite;}
    else{limitMotor.angle = limite;}

    tmp.crossVectors(ax1, ax2);

    r3.limitMotor2.angle = Math.dotVectors(tan, tmp);
    r3.limitMotor3.angle = Math.dotVectors(bin, tmp);

    // preSolve
    
    r3.preSolve(timeStep, invTimeStep);
    lc.preSolve(timeStep, invTimeStep);
  }

  @override
  void solve() {
    r3.solve();
    lc.solve();
  }
  @override
  void postSolve() {

  }
}