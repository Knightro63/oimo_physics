import 'joint_main.dart';
import 'joint_config.dart';
import 'limit_motor.dart';
import '../../math/vec3.dart';
import '../../math/quat.dart';
import 'base/angular_constraint.dart';
import 'base/translational3_constraint.dart';

// * A prismatic joint allows only for relative translation of rigid bodies along the axis.
class PrismaticJoint extends Joint{
  PrismaticJoint(JointConfig config, lowerTranslation, upperTranslation ):super(config){
    jointType = JointType.prismatic;

    localAxis1 = config.localAxis1.clone().normalize();
    localAxis2 = config.localAxis2.clone().normalize();

    ac = AngularConstraint(this, Quat().setFromUnitVectors(localAxis1, localAxis2));

    limitMotor = LimitMotor(nor, true);
    limitMotor.lowerLimit = lowerTranslation;
    limitMotor.upperLimit = upperTranslation;

    t3 = Translational3Constraint(this, limitMotor, LimitMotor(tan, true), LimitMotor(bin, true));
  }

  // The axis in the first body's coordinate system.
  late Vec3 localAxis1;
  // The axis in the second body's coordinate system.
  late Vec3 localAxis2;

  Vec3 ax1 = Vec3();
  Vec3 ax2 = Vec3();
  
  Vec3 nor = Vec3();
  Vec3 tan = Vec3();
  Vec3 bin = Vec3();

  late AngularConstraint ac;

  // The translational limit and motor information of the joint.
  late LimitMotor limitMotor;
  late Translational3Constraint t3;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();

    ax1.copy(localAxis1 ).applyMatrix3(body1!.rotation, true );
    ax2.copy(localAxis2 ).applyMatrix3(body2!.rotation, true );

    // normal tangent binormal

    nor.set(
      ax1.x*body2!.inverseMass + ax2.x*body1!.inverseMass,
      ax1.y*body2!.inverseMass + ax2.y*body1!.inverseMass,
      ax1.z*body2!.inverseMass + ax2.z*body1!.inverseMass
    ).normalize();
    tan.tangent(nor).normalize();
    bin.crossVectors(nor, tan);

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