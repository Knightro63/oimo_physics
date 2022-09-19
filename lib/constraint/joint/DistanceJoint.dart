import 'JointConfig.dart';

import '../../constants.dart';
import 'Joint.dart';
import 'LimitMotor.dart';
import '../../math/Vec3.dart';

import 'base/TranslationalConstraint.dart';


/**
 * A distance joint limits the distance between two anchor points on rigid bodies.
 *
 * @author saharan
 * @author lo-th
 */
class DistanceJoint extends Joint{
  DistanceJoint(JointConfig config, double minDistance, double maxDistance ):super(config){
    type = JointType.distance;
    limitMotor = LimitMotor(nor, true);
    limitMotor.lowerLimit = minDistance;
    limitMotor.upperLimit = maxDistance;
    t = TranslationalConstraint(this, limitMotor);
  }
  
  Vec3 nor = Vec3();

  // The limit and motor information of the joint.
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