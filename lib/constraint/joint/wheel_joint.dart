import 'joint_config.dart';
import 'joint_main.dart';
import 'limit_motor.dart';
import '../../math/vec3.dart';
import '../../math/quat.dart';
import '../../math/mat33.dart';
import '../../math/math.dart';
import 'base/translational3_constraint.dart';
import 'base/rotational3_constraint.dart';
import 'package:vector_math/vector_math.dart';

/// A wheel joint allows for relative rotation between two rigid bodies along two axes.
/// The wheel joint also allows for relative translation for the suspension.
class WheelJoint extends Joint{
  WheelJoint (JointConfig config):super(config){
    type = JointType.wheel;

    localAxis1 = config.localAxis1.clone()..normalize();
    localAxis2 = config.localAxis2.clone()..normalize();

    dot = Math.dotVectors(localAxis1, localAxis2);

    if( dot > -1 && dot < 1 ){
      localAngle1..setValues(
        localAxis2.x - dot*localAxis1.x,
        localAxis2.y - dot*localAxis1.y,
        localAxis2.z - dot*localAxis1.z
      )..normalize();

      localAngle2..setValues(
        localAxis1.x - dot*localAxis2.x,
        localAxis1.y - dot*localAxis2.y,
        localAxis1.z - dot*localAxis2.z
      )..normalize();
    } 
    else {
      Matrix3 arc = Matrix3.identity().setQuat( Quaternion(0,0,0,1).setFromUnitVectors(localAxis1, localAxis2));
      localAngle1.tangent(localAxis1).normalize();
      localAngle2 = localAngle1.clone()..applyMatrix3Transpose(arc);
    }

    translationalLimitMotor = LimitMotor(tan,true);
    translationalLimitMotor.frequency = 8;
    translationalLimitMotor.dampingRatio = 1;

    rotationalLimitMotor1 = LimitMotor( tan, false );
    // The second rotational limit and motor information of the joint.
    rotationalLimitMotor2 = LimitMotor( bin, false );

    t3 = Translational3Constraint( this, LimitMotor(nor, true),translationalLimitMotor,LimitMotor(bin, true));
    t3.weight = 1;
    r3 = Rotational3Constraint(this,LimitMotor(nor, true),rotationalLimitMotor1,rotationalLimitMotor2);
  }

  /// The axis in the first body's coordinate system.
  late Vector3 localAxis1;
  /// The axis in the second body's coordinate system.
  late Vector3 localAxis2;

  Vector3 localAngle1 = Vector3.zero();
  Vector3 localAngle2 = Vector3.zero();

  late double dot;

  Vector3 ax1 = Vector3.zero();
  Vector3 ax2 = Vector3.zero();
  Vector3 an1 = Vector3.zero();
  Vector3 an2 = Vector3.zero();
  Vector3 tmp = Vector3.zero();
  Vector3 nor = Vector3.zero();
  Vector3 tan = Vector3.zero();
  Vector3 bin = Vector3.zero();

  /// The translational limit and motor information of the joint.
  late LimitMotor translationalLimitMotor;
  /// The first rotational limit and motor information of the joint.
  late LimitMotor rotationalLimitMotor1;
  /// The second rotational limit and motor information of the joint.
  late LimitMotor rotationalLimitMotor2;

  late Translational3Constraint t3;
  late Rotational3Constraint r3;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();

    ax1..setFrom(localAxis1)..applyMatrix3Transpose(body1!.rotation);
    an1..setFrom(localAngle1)..applyMatrix3Transpose(body1!.rotation);

    ax2..setFrom(localAxis2)..applyMatrix3Transpose(body2!.rotation);
    an2..setFrom(localAngle2)..applyMatrix3Transpose(body2!.rotation);

    r3.limitMotor1.angle = Math.dotVectors(ax1, ax2);

    var limite = Math.dotVectors(an1, ax2);

    if( Math.dotVectors(ax1, tmp.cross2(an1, ax2)) < 0){
      rotationalLimitMotor1.angle = -limite;
    }
    else{ 
      rotationalLimitMotor1.angle = limite;
    }

    limite = Math.dotVectors(an2, ax1);

    if(Math.dotVectors(ax2, tmp.cross2(an2, ax1)) < 0 ){ 
      rotationalLimitMotor2.angle = -limite;
    }
    else{ 
      rotationalLimitMotor2.angle = limite;
    }

    nor.cross2( ax1, ax2 ).normalize();
    tan.cross2( nor, ax2 ).normalize();
    bin.cross2( nor, ax1 ).normalize();
    
    r3.preSolve(timeStep,invTimeStep);
    t3.preSolve(timeStep,invTimeStep);
  }
  @override
  void solve() {
    r3.solve();
    t3.solve();
  }
  @override
  void postSolve() {

  }
}