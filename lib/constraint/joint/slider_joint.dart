import 'joint_main.dart';
import 'joint_config.dart';
import 'limit_motor.dart';
import '../../math/vec3.dart';
import '../../math/quat.dart';
import '../../math/mat33.dart';
import '../../math/math.dart';
import 'base/rotational3_constraint.dart';
import 'base/translational3_constraint.dart';

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
    localAxis1 = config.localAxis1.clone().normalize();
    localAxis2 = config.localAxis2.clone().normalize();

    translationalLimitMotor = LimitMotor(nor, true );
    translationalLimitMotor.lowerLimit = lowerTranslation;
    translationalLimitMotor.upperLimit = upperTranslation;

    arc = Mat33().setQuat( Quat().setFromUnitVectors( localAxis1, localAxis2 ) );

    localAngle1 = Vec3().tangent(localAxis1 ).normalize();
    localAngle2 = localAngle1.clone().applyMatrix3( arc, true );

    r3 = Rotational3Constraint(this,rotationalLimitMotor, LimitMotor( tan, true ), LimitMotor( bin, true ) );
    t3 = Translational3Constraint(this,translationalLimitMotor, LimitMotor( tan, true ), LimitMotor( bin, true ) );
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

  /// The limit and motor for the rotation
  late LimitMotor rotationalLimitMotor = LimitMotor(nor, false);
  late Rotational3Constraint r3;

  /// The limit and motor for the translation.
  late LimitMotor translationalLimitMotor;
  late Translational3Constraint t3;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();

    ax1.copy( localAxis1 ).applyMatrix3( body1!.rotation, true );
    an1.copy( localAngle1 ).applyMatrix3( body1!.rotation, true );

    ax2.copy( localAxis2 ).applyMatrix3( body2!.rotation, true );
    an2.copy( localAngle2 ).applyMatrix3( body2!.rotation, true );

    // normal tangent binormal

    nor.set(
      ax1.x*body2!.inverseMass + ax2.x*body1!.inverseMass,
      ax1.y*body2!.inverseMass + ax2.y*body1!.inverseMass,
      ax1.z*body2!.inverseMass + ax2.z*body1!.inverseMass
    ).normalize();
    tan.tangent( nor ).normalize();
    bin.crossVectors( nor, tan );

    // calculate hinge angle
    tmp.crossVectors( an1, an2 );

    double limite = Math.acosClamp( Math.dotVectors( an1, an2 ) );

    if(Math.dotVectors( nor, tmp ) < 0 ){
      rotationalLimitMotor.angle = -limite;
    }
    else{ 
      rotationalLimitMotor.angle = limite;
    }
    // angular error
    tmp.crossVectors( ax1, ax2 );
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