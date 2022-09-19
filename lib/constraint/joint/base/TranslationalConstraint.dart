import '../Joint.dart';
import '../../../core/RigidBody.dart';
import '../LimitMotor.dart';

import '../../../math/Mat33.dart';
import '../../../math/Vec3.dart';

/**
* A translational constraint for various joints.
* @author saharan
*/
class TranslationalConstraint extends Joint{
  TranslationalConstraint(Joint joint, this.limitMotor):super(joint.config){
    b1=joint.body1!;
    b2=joint.body2!;
    p1=joint.anchorPoint1;
    p2=joint.anchorPoint2;
    r1=joint.relativeAnchorPoint1;
    r2=joint.relativeAnchorPoint2;
    l1=b1.linearVelocity;
    l2=b2.linearVelocity;
    a1=b1.angularVelocity;
    a2=b2.angularVelocity;
    i1=b1.inverseInertia;
    i2=b2.inverseInertia;

    p1=joint.anchorPoint1;
    p2=joint.anchorPoint2;
    r1=joint.relativeAnchorPoint1;
    r2=joint.relativeAnchorPoint2;
  }
    double? cfm;
    double? m1;
    double? m2;
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
    double? r1x;
    double? r1y;
    double? r1z;
    double? r2x;
    double? r2y;
    double? r2z;
    double? t1x;
    double? t1y;
    double? t1z;
    double? t2x;
    double? t2y;
    double? t2z;
    double? l1x;
    double? l1y;
    double? l1z;
    double? l2x;
    double? l2y;
    double? l2z;
    double? a1x;
    double? a1y;
    double? a1z;
    double? a2x;
    double? a2y;
    double? a2z;
    double? lowerLimit;
    double? upperLimit;
    double? limitVelocity;
    double limitState=0; // -1: at lower, 0: locked, 1: at upper, 2: free
    bool enableMotor=false;
    double? motorSpeed;
    double? maxMotorForce;
    double? maxMotorImpulse;

    LimitMotor limitMotor;
    late RigidBody b1;
    late RigidBody b2;
    late Vec3 p1;
    late Vec3 p2;
    late Vec3 r1;
    late Vec3 r2;
    late Vec3 l1;
    late Vec3 l2;
    late Vec3 a1;
    late Vec3 a2;
    late Mat33 i1;
    late Mat33 i2;
    double limitImpulse=0;
    double motorImpulse=0;
    
  @override
  void preSolve(double timeStep, double invTimeStep){
    ax=limitMotor.axis.x;
    ay=limitMotor.axis.y;
    az=limitMotor.axis.z;
    lowerLimit=limitMotor.lowerLimit;
    upperLimit=limitMotor.upperLimit;
    motorSpeed=limitMotor.motorSpeed;
    maxMotorForce=limitMotor.maxMotorForce;
    enableMotor=maxMotorForce!>0;
    m1=b1.inverseMass;
    m2=b2.inverseMass;

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

    double dx=p2.x-p1.x;
    double dy=p2.y-p1.y;
    double dz=p2.z-p1.z;
    double d=dx*ax!+dy*ay!+dz*az!;
    int frequency=limitMotor.frequency;
    bool enableSpring=frequency>0;
    bool enableLimit=lowerLimit!<=upperLimit!;

    if(enableSpring&&d>20||d<-20){
      enableSpring=false;
    }

    if(enableLimit){
      if(lowerLimit==upperLimit){
        if(limitState!=0){
          limitState=0;
          limitImpulse=0;
        }
        limitVelocity=lowerLimit!-d;
        if(!enableSpring)d=lowerLimit!;
      }
      else if(d<lowerLimit!){
        if(limitState!=-1){
          limitState=-1;
          limitImpulse=0;
        }
        limitVelocity=lowerLimit!-d;
        if(!enableSpring)d=lowerLimit!;
      }
      else if(d>upperLimit!){
        if(limitState!=1){
          limitState=1;
          limitImpulse=0;
        }
        limitVelocity=upperLimit!-d;
        if(!enableSpring)d=upperLimit!;
      }
      else{
        limitState=2;
        limitImpulse=0;
        limitVelocity=0;
      }

      if(!enableSpring){
        if(limitVelocity!>0.005){
          limitVelocity=limitVelocity!-0.005;
        }
        else if(limitVelocity!<-0.005){
          limitVelocity=limitVelocity!+0.005;
        }
        else {
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

    var rdx=d*ax!;
    var rdy=d*ay!;
    var rdz=d*az!;
    var w1=m1!/(m1!+m2!);
    var w2=1-w1;
    r1x=r1.x+rdx*w1;
    r1y=r1.y+rdy*w1;
    r1z=r1.z+rdz*w1;
    r2x=r2.x-rdx*w2;
    r2y=r2.y-rdy*w2;
    r2z=r2.z-rdz*w2;

    t1x=r1y!*az!-r1z!*ay!;
    t1y=r1z!*ax!-r1x!*az!;
    t1z=r1x!*ay!-r1y!*ax!;
    t2x=r2y!*az!-r2z!*ay!;
    t2y=r2z!*ax!-r2x!*az!;
    t2z=r2x!*ay!-r2y!*ax!;
    l1x=ax!*m1!;
    l1y=ay!*m1!;
    l1z=az!*m1!;
    l2x=ax!*m2!;
    l2y=ay!*m2!;
    l2z=az!*m2!;
    a1x=t1x!*i1e00!+t1y!*i1e01!+t1z!*i1e02!;
    a1y=t1x!*i1e10!+t1y!*i1e11!+t1z!*i1e12!;
    a1z=t1x!*i1e20!+t1y!*i1e21!+t1z!*i1e22!;
    a2x=t2x!*i2e00!+t2y!*i2e01!+t2z!*i2e02!;
    a2y=t2x!*i2e10!+t2y!*i2e11!+t2z!*i2e12!;
    a2z=t2x!*i2e20!+t2y!*i2e21!+t2z!*i2e22!;
    motorDenom=
    m1!+m2!+
        ax!*(a1y!*r1z!-a1z!*r1y!+a2y!*r2z!-a2z!*r2y!)+
        ay!*(a1z!*r1x!-a1x!*r1z!+a2z!*r2x!-a2x!*r2z!)+
        az!*(a1x!*r1y!-a1y!*r1x!+a2x!*r2y!-a2y!*r2x!);

    invMotorDenom=1/motorDenom!;

    if(enableSpring&&limitState!=2){
      double omega=6.2831853*frequency;
      double k=omega*omega*timeStep;
      double dmp=invTimeStep/(k+2*limitMotor.dampingRatio*omega);
      cfm=motorDenom!*dmp;
      limitVelocity=limitVelocity!*k*dmp;
    }
    else{
      cfm=0;
      limitVelocity=limitVelocity!*invTimeStep*0.05;
    }

    invDenom=1/(motorDenom!+cfm!);

    double totalImpulse=limitImpulse+motorImpulse;
    l1.x+=totalImpulse*l1x!;
    l1.y+=totalImpulse*l1y!;
    l1.z+=totalImpulse*l1z!;
    a1.x+=totalImpulse*a1x!;
    a1.y+=totalImpulse*a1y!;
    a1.z+=totalImpulse*a1z!;
    l2.x-=totalImpulse*l2x!;
    l2.y-=totalImpulse*l2y!;
    l2.z-=totalImpulse*l2z!;
    a2.x-=totalImpulse*a2x!;
    a2.y-=totalImpulse*a2y!;
    a2.z-=totalImpulse*a2z!;
  }

  @override
  void solve(){
    double rvn=
        ax!*(l2.x-l1.x)+ay!*(l2.y-l1.y)+az!*(l2.z-l1.z)+
        t2x!*a2.x-t1x!*a1.x+t2y!*a2.y-t1y!*a1.y+t2z!*a2.z-t1z!*a1.z;

    // motor part
    double newMotorImpulse;
    if(enableMotor){
      newMotorImpulse=(rvn-motorSpeed!)*invMotorDenom!;
      var oldMotorImpulse=motorImpulse;
      motorImpulse+=newMotorImpulse;
      if(motorImpulse>maxMotorImpulse!){
        motorImpulse=maxMotorImpulse!;
      }
      else if(motorImpulse<-maxMotorImpulse!){
        motorImpulse=-maxMotorImpulse!;
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
    else {
      newLimitImpulse=0;
    }
    
    double totalImpulse=newLimitImpulse+newMotorImpulse;
    l1.x+=totalImpulse*l1x!;
    l1.y+=totalImpulse*l1y!;
    l1.z+=totalImpulse*l1z!;
    a1.x+=totalImpulse*a1x!;
    a1.y+=totalImpulse*a1y!;
    a1.z+=totalImpulse*a1z!;
    l2.x-=totalImpulse*l2x!;
    l2.y-=totalImpulse*l2y!;
    l2.z-=totalImpulse*l2z!;
    a2.x-=totalImpulse*a2x!;
    a2.y-=totalImpulse*a2y!;
    a2.z-=totalImpulse*a2z!;
  }
}