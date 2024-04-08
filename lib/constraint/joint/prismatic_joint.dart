import 'joint_main.dart';
import 'joint_config.dart';
import 'limit_motor.dart';
import '../../math/vec3.dart';
import '../../math/quat.dart';
import 'base/angular_constraint.dart';
import 'base/translational3_constraint.dart';
import 'package:vector_math/vector_math.dart';

/// A prismatic joint allows only for relative translation of rigid bodies along the axis.
class PrismaticJoint extends Joint{

  /// A prismatic joint allows only for relative translation of rigid bodies along the axis.
  /// 
  /// [config] configuration profile of the joint
  /// 
  /// [lowerTranslation] the min movment the joint will travel
  /// 
  /// [upperTranslation] the max movment the joint will travel
  PrismaticJoint(JointConfig config, lowerTranslation, upperTranslation ):super(config){
    type = JointType.prismatic;

    localAxis1 = config.localAxis1.clone()..normalize();
    localAxis2 = config.localAxis2.clone()..normalize();

    ac = AngularConstraint(this, Quaternion(0,0,0,1).setFromUnitVectors(localAxis1, localAxis2));

    limitMotor = LimitMotor(nor, true);
    limitMotor.lowerLimit = lowerTranslation;
    limitMotor.upperLimit = upperTranslation;

    t3 = Translational3Constraint(this, limitMotor, LimitMotor(tan, true), LimitMotor(bin, true));
  }

  /// The axis in the first body's coordinate system.
  late Vector3 localAxis1;
  /// The axis in the second body's coordinate system.
  late Vector3 localAxis2;

  Vector3 ax1 = Vector3.zero();
  Vector3 ax2 = Vector3.zero();
  
  Vector3 nor = Vector3.zero();
  Vector3 tan = Vector3.zero();
  Vector3 bin = Vector3.zero();

  late AngularConstraint ac;

  /// The translational limit and motor information of the joint.
  late LimitMotor limitMotor;
  late Translational3Constraint t3;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();

    ax1..setFrom(localAxis1 )..applyMatrix3Transpose(body1!.rotation );
    ax2..setFrom(localAxis2 )..applyMatrix3Transpose(body2!.rotation );

    // normal tangent binormal

    nor..setValues(
      ax1.x*body2!.inverseMass + ax2.x*body1!.inverseMass,
      ax1.y*body2!.inverseMass + ax2.y*body1!.inverseMass,
      ax1.z*body2!.inverseMass + ax2.z*body1!.inverseMass
    )..normalize();
    tan.tangent(nor).normalize();
    bin.cross2(nor, tan);

    // preSolve

    ac.preSolve( timeStep, invTimeStep );
    t3.preSolve( timeStep, invTimeStep );
  }
  @override
  void solve() {
    ac.solve();
    t3.solve();
  }
  @override
  void postSolve() {

  }
}