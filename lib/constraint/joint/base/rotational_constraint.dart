import '../../../math/vec3.dart';
import '../../../math/mat33.dart';
import '../joint_main.dart';
import '../limit_motor.dart';
import '../../../core/rigid_body.dart';

// * A rotational constraint for various joints.
class RotationalConstraint extends Joint{
  RotationalConstraint(Joint joint, this.limitMotor):super(joint.config){
    b1=joint.body1!;
    b2=joint.body2!;
    a1=b1.angularVelocity;
    a2=b2.angularVelocity;
    i1=b1.inverseInertia;
    i2=b2.inverseInertia;
  }

  double? cfm;
  double? i1e00;
  double? i1e01;
  double? i1e02;
  double? i1e10;
  double? i1e11;
  double? i1e12;
  double? i1e20;
  double? i1e21;
  double? i1e22;
  double? i2e00;
  double? i2e01;
  double? i2e02;
  double? i2e10;
  double? i2e11;
  double? i2e12;
  double? i2e20;
  double? i2e21;
  double? i2e22;
  double? motorDenom;
  double? invMotorDenom;
  double? invDenom;
  double? ax;
  double? ay;
  double? az;
  double? a1x;
  double? a1y;
  double? a1z;
  double? a2x;
  double? a2y;
  double? a2z;
  double? lowerLimit;
  double? upperLimit;
  double? limitVelocity;
  double? motorSpeed;
  double? maxMotorForce;
  double? maxMotorImpulse;

  bool enableLimit=false;
  int limitState=0; // -1: at lower, 0: locked, 1: at upper, 2: free
  bool enableMotor=false;

  LimitMotor limitMotor;
  late RigidBody b1;
  late RigidBody b2;
  late Vec3 a1;
  late Vec3 a2;
  late Mat33 i1;
  late Mat33 i2;
  double limitImpulse=0;
  double motorImpulse=0;

  @override
  void preSolve(double timeStep,double invTimeStep){
    ax=limitMotor.axis.x;
    ay=limitMotor.axis.y;
    az=limitMotor.axis.z;
    lowerLimit=limitMotor.lowerLimit;
    upperLimit=limitMotor.upperLimit;
    motorSpeed=limitMotor.motorSpeed;
    maxMotorForce=limitMotor.maxMotorForce;
    enableMotor=maxMotorForce!>0;

    List<double> ti1 = i1.elements;
    List<double> ti2 = i2.elements;
    i1e00=ti1[0];
    i1e01=ti1[1];
    i1e02=ti1[2];
    i1e10=ti1[3];
    i1e11=ti1[4];
    i1e12=ti1[5];
    i1e20=ti1[6];
    i1e21=ti1[7];
    i1e22=ti1[8];

    i2e00=ti2[0];
    i2e01=ti2[1];
    i2e02=ti2[2];
    i2e10=ti2[3];
    i2e11=ti2[4];
    i2e12=ti2[5];
    i2e20=ti2[6];
    i2e21=ti2[7];
    i2e22=ti2[8];

    int frequency=limitMotor.frequency;
    bool enableSpring=frequency>0;
    bool enableLimit=lowerLimit! <= upperLimit!;
    double angle=limitMotor.angle;

    if(enableLimit){
      if(lowerLimit==upperLimit){
        if(limitState!=0){
          limitState=0;
          limitImpulse=0;
        }
        limitVelocity=lowerLimit!-angle;
      }
      else if(angle<lowerLimit!){
        if(limitState!=-1){
          limitState=-1;
          limitImpulse=0;
        }
        limitVelocity=lowerLimit!-angle;
      }
      else if(angle>upperLimit!){
        if(limitState!=1){
          limitState=1;
          limitImpulse=0;
        }
        limitVelocity=upperLimit!-angle;
      }
      else{
        limitState=2;
        limitImpulse=0;
        limitVelocity=0;
      }

      if(!enableSpring){
        if(limitVelocity! > 0.02){
          limitVelocity = limitVelocity!-0.02;
        }
        else if(limitVelocity! < -0.02){
          limitVelocity = limitVelocity!+0.02;
        }
        else{
          limitVelocity=0;
        }
      }
    }
    else{
      limitState=2;
      limitImpulse=0;
    }

    if(enableMotor&&(limitState!=0||enableSpring)){
      maxMotorImpulse=maxMotorForce!*timeStep;
    }
    else{
      motorImpulse=0;
      maxMotorImpulse=0;
    }

    a1x=ax!*i1e00!+ay!*i1e01!+az!*i1e02!;
    a1y=ax!*i1e10!+ay!*i1e11!+az!*i1e12!;
    a1z=ax!*i1e20!+ay!*i1e21!+az!*i1e22!;
    a2x=ax!*i2e00!+ay!*i2e01!+az!*i2e02!;
    a2y=ax!*i2e10!+ay!*i2e11!+az!*i2e12!;
    a2z=ax!*i2e20!+ay!*i2e21!+az!*i2e22!;
    motorDenom=ax!*(a1x!+a2x!)+ay!*(a1y!+a2y!)+az!*(a1z!+a2z!);
    invMotorDenom=1/motorDenom!;

    if(enableSpring&&limitState!=2){
      double omega=6.2831853*frequency;
      double k=omega*omega*timeStep;
      double dmp=invTimeStep/(k+2*limitMotor.dampingRatio*omega);
      cfm=motorDenom!*dmp;
      limitVelocity = limitVelocity!*k*dmp;
    }
    else{
      cfm=0;
      limitVelocity = limitVelocity!*invTimeStep*0.05;
    }

    invDenom=1/(motorDenom!+cfm!);
    
    limitImpulse*=0.95;
    motorImpulse*=0.95;
    double totalImpulse=limitImpulse+motorImpulse;
    a1.x+=totalImpulse*a1x!;
    a1.y+=totalImpulse*a1y!;
    a1.z+=totalImpulse*a1z!;
    a2.x-=totalImpulse*a2x!;
    a2.y-=totalImpulse*a2y!;
    a2.z-=totalImpulse*a2z!;
  }

  @override
  void solve(){
    double rvn=ax!*(a2.x-a1.x)+ay!*(a2.y-a1.y)+az!*(a2.z-a1.z);

    // motor part
    double newMotorImpulse;
    if(enableMotor){
      newMotorImpulse=(rvn-motorSpeed!)*invMotorDenom!;
      double oldMotorImpulse=motorImpulse;
      motorImpulse+=newMotorImpulse;
      if(motorImpulse>maxMotorImpulse!){
        motorImpulse=maxMotorImpulse!;
      }
      else if(motorImpulse < -maxMotorImpulse!){
        motorImpulse =- maxMotorImpulse!;
      }
      newMotorImpulse=motorImpulse-oldMotorImpulse;
      rvn-=newMotorImpulse*motorDenom!;
    }
    else {
      newMotorImpulse=0;
    }

    // limit part
    double newLimitImpulse;
    if(limitState!=2){
      newLimitImpulse=(rvn-limitVelocity!-limitImpulse*cfm!)*invDenom!;
      double oldLimitImpulse=limitImpulse;
      limitImpulse+=newLimitImpulse;
      if(limitImpulse*limitState<0){
        limitImpulse=0;
      }
      newLimitImpulse=limitImpulse-oldLimitImpulse;
    }
    else{
      newLimitImpulse=0;
    }

    double totalImpulse=newLimitImpulse+newMotorImpulse;
    a1.x+=totalImpulse*a1x!;
    a1.y+=totalImpulse*a1y!;
    a1.z+=totalImpulse*a1z!;
    a2.x-=totalImpulse*a2x!;
    a2.y-=totalImpulse*a2y!;
    a2.z-=totalImpulse*a2z!;
  }
}