import 'JointConfig.dart';
import 'base/LinearConstraint.dart';
import 'Joint.dart';

/**
 * A ball-and-socket joint limits relative translation on two anchor points on rigid bodies.
 *
 * @author saharan
 * @author lo-th
 */

class BallAndSocketJoint extends Joint{
  BallAndSocketJoint(JointConfig config ):super(config){
    type = JointType.socket;
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