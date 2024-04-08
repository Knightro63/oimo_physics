import 'joint_main.dart';
import 'joint_config.dart';
import 'limit_motor.dart';
import '../../math/vec3.dart';
import '../../math/quat.dart';
import '../../math/mat33.dart';
import '../../math/math.dart';
import 'base/rotational3_constraint.dart';
import 'base/translational3_constraint.dart';
import 'package:vector_math/vector_math.dart';

/// A slider joint allows for relative translation and relative rotation between two rigid bodies along the axis.
class SliderJoint extends Joint{

  /// A slider joint allows for relative translation and relative rotation between two rigid bodies along the axis.
  /// 
  /// [config] configuration profile of the joint
  /// 
  /// [lowerTranslation] the min movment the joint will slide
  /// 
  /// [upperTranslation] the max movment the joint will slide
  SliderJoint(JointConfig config, double lowerTranslation, double upperTranslation ):super(config){
    type = JointType.slider;
    localAxis1 = config.localAxis1.clone()..normalize();
    localAxis2 = config.localAxis2.clone()..normalize();

    translationalLimitMotor = LimitMotor(nor, true );
    translationalLimitMotor.lowerLimit = lowerTranslation;
    translationalLimitMotor.upperLimit = upperTranslation;

    arc = Matrix3.identity().setQuat( Quaternion(0,0,0,1).setFromUnitVectors( localAxis1, localAxis2 ) );

    localAngle1 = Vector3.zero()..tangent(localAxis1 )..normalize();
    localAngle2 = localAngle1.clone().applyMatrix3Transpose( arc );

    r3 = Rotational3Constraint(this,rotationalLimitMotor, LimitMotor( tan, true ), LimitMotor( bin, true ) );
    t3 = Translational3Constraint(this,translationalLimitMotor, LimitMotor( tan, true ), LimitMotor( bin, true ) );
  }

  /// The axis in the first body's coordinate system.
  late Vector3 localAxis1;
  /// The axis in the second body's coordinate system.
  late Vector3 localAxis2;

  // make angle axis
  late Matrix3 arc;
  late Vector3 localAngle1;
  late Vector3 localAngle2;

  Vector3 ax1 = Vector3.zero();
  Vector3 ax2 = Vector3.zero();
  Vector3 an1 = Vector3.zero();
  Vector3 an2 = Vector3.zero();

  Vector3 tmp = Vector3.zero();
  
  Vector3 nor = Vector3.zero();
  Vector3 tan = Vector3.zero();
  Vector3 bin = Vector3.zero();

  /// The limit and motor for the rotation
  late LimitMotor rotationalLimitMotor = LimitMotor(nor, false);
  late Rotational3Constraint r3;

  /// The limit and motor for the translation.
  late LimitMotor translationalLimitMotor;
  late Translational3Constraint t3;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();

    ax1..setFrom( localAxis1 )..applyMatrix3Transpose( body1!.rotation );
    an1..setFrom( localAngle1 )..applyMatrix3Transpose( body1!.rotation );

    ax2..setFrom( localAxis2 )..applyMatrix3Transpose( body2!.rotation );
    an2..setFrom( localAngle2 )..applyMatrix3Transpose( body2!.rotation );

    // normal tangent binormal

    nor..setValues(
      ax1.x*body2!.inverseMass + ax2.x*body1!.inverseMass,
      ax1.y*body2!.inverseMass + ax2.y*body1!.inverseMass,
      ax1.z*body2!.inverseMass + ax2.z*body1!.inverseMass
    )..normalize();
    tan.tangent( nor ).normalize();
    bin.cross2( nor, tan );

    // calculate hinge angle
    tmp.cross2( an1, an2 );

    double limite = Math.acosClamp( Math.dotVectors( an1, an2 ) );

    if(Math.dotVectors( nor, tmp ) < 0 ){
      rotationalLimitMotor.angle = -limite;
    }
    else{ 
      rotationalLimitMotor.angle = limite;
    }
    // angular error
    tmp.cross2( ax1, ax2 );
    r3.limitMotor2.angle = Math.dotVectors( tan, tmp );
    r3.limitMotor3.angle = Math.dotVectors( bin, tmp );

    // preSolve
    
    r3.preSolve( timeStep, invTimeStep );
    t3.preSolve( timeStep, invTimeStep );
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