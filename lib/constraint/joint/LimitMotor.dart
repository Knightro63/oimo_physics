import '../../math/Vec3.dart';

/**
* An information of limit and motor.
*
* @author saharan
*/
class LimitMotor{
  LimitMotor(this.axis, [this.fixed = false]) {
    lowerLimit = fixed?0:1;
  }

  bool fixed;
  // The axis of the constraint.
  Vec3 axis;
  // The current angle for rotational constraints.
  double angle = 0;
  // The lower limit. Set lower > upper to disable
  late double lowerLimit;

  //  The upper limit. Set lower > upper to disable.
  double upperLimit = 0;
  // The target motor speed.
  double motorSpeed = 0;
  // The maximum motor force or torque. Set 0 to disable.
  double maxMotorForce = 0;
  // The frequency of the spring. Set 0 to disable.
  int frequency = 0;
  // The damping ratio of the spring. Set 0 for no damping, 1 for critical damping.
  double dampingRatio = 0;

  // Set limit data into this constraint.
  void setLimit(double lowerLimit,double upperLimit) {
    this.lowerLimit = lowerLimit;
    this.upperLimit = upperLimit;
  }

  // Set motor data into this constraint.
  void setMotor(double motorSpeed, double maxMotorForce ) {
    this.motorSpeed = motorSpeed;
    this.maxMotorForce = maxMotorForce;
  }

  // Set spring data into this constraint.
  void setSpring(int frequency,double dampingRatio ) {
    this.frequency = frequency;
    this.dampingRatio = dampingRatio;
  }
}