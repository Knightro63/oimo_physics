import 'joint_config.dart';
import 'base/linear_constraint.dart';
import 'joint_main.dart';

// * A ball-and-socket joint limits relative translation on two anchor points on rigid bodies.
class BallAndSocketJoint extends Joint{
  BallAndSocketJoint(JointConfig config ):super(config){
    jointType = JointType.socket;
    lc = LinearConstraint(this);
  }

  late LinearConstraint lc;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();
    // preSolve
    lc.preSolve( timeStep, invTimeStep );
  }

  @override
  void solve() {
    lc.solve();
  }
  @override
  void postSolve() {

  }
}