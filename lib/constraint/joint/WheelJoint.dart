import 'JointConfig.dart';

import '../../constants.dart';
import 'Joint.dart';
import 'LimitMotor.dart';
import '../../math/Vec3.dart';
import '../../math/Quat.dart';
import '../../math/Mat33.dart';
import '../../math/Math.dart';

import 'base/Translational3Constraint.dart';
import 'base/Rotational3Constraint.dart';

/**
 * A wheel joint allows for relative rotation between two rigid bodies along two axes.
 * The wheel joint also allows for relative translation for the suspension.
 *
 * @author saharan
 * @author lo-th
 */
class WheelJoint extends Joint{
  WheelJoint (JointConfig config):super(config){
    type = JointType.wheel;

    localAxis1 = config.localAxis1.clone().normalize();
    localAxis2 = config.localAxis2.clone().normalize();

    dot = Math.dotVectors(localAxis1, localAxis2);

    if( dot > -1 && dot < 1 ){
      localAngle1.set(
        localAxis2.x - dot*localAxis1.x,
        localAxis2.y - dot*localAxis1.y,
        localAxis2.z - dot*localAxis1.z
      ).normalize();

      localAngle2.set(
        localAxis1.x - dot*localAxis2.x,
        localAxis1.y - dot*localAxis2.y,
        localAxis1.z - dot*localAxis2.z
      ).normalize();
    } 
    else {
      Mat33 arc = Mat33().setQuat( Quat().setFromUnitVectors(localAxis1, localAxis2));
      localAngle1.tangent(localAxis1).normalize();
      localAngle2 = localAngle1.clone().applyMatrix3(arc, true);
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

    // The axis in the first body's coordinate system.
    late Vec3 localAxis1;
    // The axis in the second body's coordinate system.
    late Vec3 localAxis2;

    Vec3 localAngle1 = Vec3();
    Vec3 localAngle2 = Vec3();

    late double dot;

    Vec3 ax1 = Vec3();
    Vec3 ax2 = Vec3();
    Vec3 an1 = Vec3();
    Vec3 an2 = Vec3();
    Vec3 tmp = Vec3();
    Vec3 nor = Vec3();
    Vec3 tan = Vec3();
    Vec3 bin = Vec3();

    // The translational limit and motor information of the joint.
    late LimitMotor translationalLimitMotor;
    // The first rotational limit and motor information of the joint.
    late LimitMotor rotationalLimitMotor1;
    // The second rotational limit and motor information of the joint.
    late LimitMotor rotationalLimitMotor2;

    late Translational3Constraint t3;
    late Rotational3Constraint r3;

  @override
  void preSolve(double timeStep,double invTimeStep ) {
    updateAnchorPoints();

    ax1.copy(localAxis1).applyMatrix3(body1!.rotation, true);
    an1.copy(localAngle1).applyMatrix3(body1!.rotation, true);

    ax2.copy(localAxis2).applyMatrix3(body2!.rotation, true);
    an2.copy(localAngle2).applyMatrix3(body2!.rotation, true);

    r3.limitMotor1.angle = Math.dotVectors(ax1, ax2);

    var limite = Math.dotVectors(an1, ax2);

    if( Math.dotVectors(ax1, tmp.crossVectors(an1, ax2)) < 0){
      rotationalLimitMotor1.angle = -limite;
    }
    else{ 
      rotationalLimitMotor1.angle = limite;
    }

    limite = Math.dotVectors(an2, ax1);

    if(Math.dotVectors(ax2, tmp.crossVectors(an2, ax1)) < 0 ){ 
      rotationalLimitMotor2.angle = -limite;
    }
    else{ 
      rotationalLimitMotor2.angle = limite;
    }

    nor.crossVectors( ax1, ax2 ).normalize();
    tan.crossVectors( nor, ax2 ).normalize();
    bin.crossVectors( nor, ax1 ).normalize();
    
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