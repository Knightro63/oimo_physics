import 'joint_config.dart';
import 'joint_main.dart';
import 'limit_motor.dart';
import '../../math/vec3.dart';
import 'base/translational_constraint.dart';

/// A distance joint limits the distance between two anchor points on rigid bodies.
class DistanceJoint extends Joint{

  /// A distance joint limits the distance between two anchor points on rigid bodies.
  /// 
  /// [config] configuration profile of the joint
  /// 
  /// [minDistance] the min distance the motor will travel
  /// 
  /// [maxDistance] the max distance the motor will travel
  DistanceJoint(JointConfig config, [double minDistance = 0, double maxDistance = 0]):super(config){
    type = JointType.distance;
    limitMotor = LimitMotor(nor, true);
    limitMotor.lowerLimit = minDistance;
    limitMotor.upperLimit = maxDistance;
    t = TranslationalConstraint(this, limitMotor);
  }
  
  Vec3 nor = Vec3();

  /// The limit and motor information of the joint.
  late LimitMotor limitMotor;
  late TranslationalConstraint t;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();
    nor.sub(anchorPoint2, anchorPoint1 ).normalize();
    // preSolve
    t.preSolve(timeStep, invTimeStep);
  }
  @override
  void solve() {
    t.solve();
  }
  @override
  void postSolve() {

  }
}