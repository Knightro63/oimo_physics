import '../../../math/vec3.dart';
import '../../../math/mat33.dart';
import '../joint.dart';
import '../limit_motor.dart';
import '../../../core/rigid_body.dart';

// * A three-axis translational constraint for various joints.
class Translational3Constraint extends Joint{
  Translational3Constraint(Joint joint,this.limitMotor1,this.limitMotor2,this.limitMotor3):super(joint.config){
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
  }

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
  double? ax1;
  double? ay1;
  double? az1;
  double? ax2;
  double? ay2;
  double? az2;
  double? ax3;
  double? ay3;
  double? az3;
  double? r1x;
  double? r1y;
  double? r1z;
  double? r2x;
  double? r2y;
  double? r2z;
  double? t1x1;// jacobians
  double? t1y1;
  double? t1z1;
  double? t2x1;
  double? t2y1;
  double? t2z1;
  double? l1x1;
  double? l1y1;
  double? l1z1;
  double? l2x1;
  double? l2y1;
  double? l2z1;
  double? a1x1;
  double? a1y1;
  double? a1z1;
  double? a2x1;
  double? a2y1;
  double? a2z1;
  double? t1x2;
  double? t1y2;
  double? t1z2;
  double? t2x2;
  double? t2y2;
  double? t2z2;
  double? l1x2;
  double? l1y2;
  double? l1z2;
  double? l2x2;
  double? l2y2;
  double? l2z2;
  double? a1x2;
  double? a1y2;
  double? a1z2;
  double? a2x2;
  double? a2y2;
  double? a2z2;
  double? t1x3;
  double? t1y3;
  double? t1z3;
  double? t2x3;
  double? t2y3;
  double? t2z3;
  double? l1x3;
  double? l1y3;
  double? l1z3;
  double? l2x3;
  double? l2y3;
  double? l2z3;
  double? a1x3;
  double? a1y3;
  double? a1z3;
  double? a2x3;
  double? a2y3;
  double? a2z3;
  double? lowerLimit1;
  double? upperLimit1;
  double? limitVelocity1;

  double? motorSpeed1;
  double? maxMotorForce1;
  double? maxMotorImpulse1;
  double? lowerLimit2;
  double? upperLimit2;
  double? limitVelocity2;

  double? motorSpeed2;
  double? maxMotorForce2;
  double? maxMotorImpulse2;
  double? lowerLimit3;
  double? upperLimit3;
  double? limitVelocity3;

  double? motorSpeed3;
  double? maxMotorForce3;
  double? maxMotorImpulse3;
  double? k00; // K = J*M*JT
  double? k01;
  double? k02;
  double? k10;
  double? k11;
  double? k12;
  double? k20;
  double? k21;
  double? k22;
  double? kv00; // diagonals without CFMs
  double? kv11;
  double? kv22;
  double? dv00; // ...inverted
  double? dv11;
  double? dv22;
  double? d00; // K^-1
  double? d01;
  double? d02;
  double? d10;
  double? d11;
  double? d12;
  double? d20;
  double? d21;
  double? d22;

  int limitState1 = 0; // -1: at lower, 0: locked, 1: at upper, 2: unlimited
  bool enableMotor1 = false;

  int limitState2 = 0; // -1: at lower, 0: locked, 1: at upper, 2: unlimited
  bool enableMotor2 = false;

  int limitState3 = 0; // -1: at lower, 0: locked, 1: at upper, 2: unlimited
  bool enableMotor3 = false;

  LimitMotor limitMotor1;
  LimitMotor limitMotor2;
  LimitMotor limitMotor3;

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

  double limitImpulse1 = 0;
  double motorImpulse1 = 0;
  double limitImpulse2 = 0;
  double motorImpulse2 = 0;
  double limitImpulse3 = 0;
  double motorImpulse3 = 0;
  double cfm1 = 0;// Constraint Force Mixing
  double cfm2 = 0;
  double cfm3 = 0;
  double weight = -1;

  @override
  void preSolve(double timeStep,double invTimeStep){
    ax1=limitMotor1.axis.x;
    ay1=limitMotor1.axis.y;
    az1=limitMotor1.axis.z;
    ax2=limitMotor2.axis.x;
    ay2=limitMotor2.axis.y;
    az2=limitMotor2.axis.z;
    ax3=limitMotor3.axis.x;
    ay3=limitMotor3.axis.y;
    az3=limitMotor3.axis.z;
    lowerLimit1=limitMotor1.lowerLimit;
    upperLimit1=limitMotor1.upperLimit;
    motorSpeed1=limitMotor1.motorSpeed;
    maxMotorForce1=limitMotor1.maxMotorForce;
    enableMotor1 = maxMotorForce1! > 0;
    lowerLimit2=limitMotor2.lowerLimit;
    upperLimit2=limitMotor2.upperLimit;
    motorSpeed2=limitMotor2.motorSpeed;
    maxMotorForce2=limitMotor2.maxMotorForce;
    enableMotor2=maxMotorForce2! > 0;
    lowerLimit3=limitMotor3.lowerLimit;
    upperLimit3=limitMotor3.upperLimit;
    motorSpeed3=limitMotor3.motorSpeed;
    maxMotorForce3=limitMotor3.maxMotorForce;
    enableMotor3 = maxMotorForce3! > 0;
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
    double d1=dx*ax1!+dy*ay1!+dz*az1!;
    double d2=dx*ax2!+dy*ay2!+dz*az2!;
    double d3=dx*ax3!+dy*ay3!+dz*az3!;
    int frequency1=limitMotor1.frequency;
    int frequency2=limitMotor2.frequency;
    int frequency3=limitMotor3.frequency;
    bool enableSpring1=frequency1>0;
    bool enableSpring2=frequency2>0;
    bool enableSpring3=frequency3>0;
    bool enableLimit1=lowerLimit1!<=upperLimit1!;
    bool enableLimit2=lowerLimit2!<=upperLimit2!;
    bool enableLimit3=lowerLimit3!<=upperLimit3!;

    // for stability
    if(enableSpring1&&d1>20||d1<-20){
      enableSpring1=false;
    }
    if(enableSpring2&&d2>20||d2<-20){
      enableSpring2=false;
    }
    if(enableSpring3&&d3>20||d3<-20){
      enableSpring3=false;
    }

    if(enableLimit1){
      if(lowerLimit1==upperLimit1){
        if(limitState1!=0){
          limitState1=0;
          limitImpulse1=0;
        }
        limitVelocity1=lowerLimit1!-d1;
        if(!enableSpring1)d1=lowerLimit1!;
      }
      else if(d1<lowerLimit1!){
        if(limitState1!=-1){
          limitState1=-1;
          limitImpulse1=0;
        }
        limitVelocity1=lowerLimit1!-d1;
        if(!enableSpring1)d1=lowerLimit1!;
      }
      else if(d1>upperLimit1!){
        if(limitState1!=1){
          limitState1=1;
          limitImpulse1=0;
        }
        limitVelocity1=upperLimit1!-d1;
        if(!enableSpring1)d1=upperLimit1!;
      }
      else{
        limitState1=2;
        limitImpulse1=0;
        limitVelocity1=0;
      }

      if(!enableSpring1){
        if(limitVelocity1!>0.005){
          limitVelocity1 = limitVelocity1!-0.005;
        }
        else if(limitVelocity1! < -0.005){
          limitVelocity1 = limitVelocity1!+0.005;
        }
        else{
          limitVelocity1=0;
        }
      }
    }
    else{
      limitState1=2;
      limitImpulse1=0;
    }

    if(enableLimit2){
      if(lowerLimit2==upperLimit2){
        if(limitState2!=0){
          limitState2=0;
          limitImpulse2=0;
        }
        limitVelocity2=lowerLimit2!-d2;
        if(!enableSpring2){
          d2=lowerLimit2!;
        }
      }
      else if(d2<lowerLimit2!){
        if(limitState2!=-1){
          limitState2=-1;
          limitImpulse2=0;
        }
        limitVelocity2=lowerLimit2!-d2;
        if(!enableSpring2){
          d2=lowerLimit2!;
        }
      }
      else if(d2>upperLimit2!){
        if(limitState2!=1){
          limitState2=1;
          limitImpulse2=0;
        }
        limitVelocity2=upperLimit2!-d2;
        if(!enableSpring2){
          d2=upperLimit2!;
        }
      }
      else{
        limitState2=2;
        limitImpulse2=0;
        limitVelocity2=0;
      }
      if(!enableSpring2){
        if(limitVelocity2! > 0.005){
          limitVelocity2 = limitVelocity2!-0.005;
        }
        else if(limitVelocity2! < -0.005){
          limitVelocity2 = limitVelocity2!+0.005;
        }
        else{
          limitVelocity2=0;
        }
      }
    }
    else{
      limitState2=2;
      limitImpulse2=0;
    }

    if(enableLimit3){
      if(lowerLimit3==upperLimit3){
        if(limitState3!=0){
          limitState3=0;
          limitImpulse3=0;
        }
        limitVelocity3=lowerLimit3!-d3;
        if(!enableSpring3){
          d3=lowerLimit3!;
        }
      }
      else if(d3<lowerLimit3!){
        if(limitState3!=-1){
          limitState3=-1;
          limitImpulse3=0;
        }
        limitVelocity3=lowerLimit3!-d3;
        if(!enableSpring3){
          d3=lowerLimit3!;
        }
      }
      else if(d3>upperLimit3!){
        if(limitState3!=1){
          limitState3=1;
          limitImpulse3=0;
        }
        limitVelocity3=upperLimit3!-d3;
        if(!enableSpring3)d3=upperLimit3!;
      }
      else{
        limitState3=2;
        limitImpulse3=0;
        limitVelocity3=0;
      }

      if(!enableSpring3){
        if(limitVelocity3! > 0.005){
          limitVelocity3 = limitVelocity3!-0.005;
        }
        else if(limitVelocity3! < -0.005){
          limitVelocity3 = limitVelocity3!+0.005;
        }
        else {
          limitVelocity3=0;
        }
      }
    }
    else{
      limitState3=2;
      limitImpulse3=0;
    }

    if(enableMotor1&&(limitState1!=0||enableSpring1)){
      maxMotorImpulse1=maxMotorForce1!*timeStep;
    }
    else{
      motorImpulse1=0;
      maxMotorImpulse1=0;
    }

    if(enableMotor2&&(limitState2!=0||enableSpring2)){
      maxMotorImpulse2=maxMotorForce2!*timeStep;
    }
    else{
      motorImpulse2=0;
      maxMotorImpulse2=0;
    }

    if(enableMotor3&&(limitState3!=0||enableSpring3)){
      maxMotorImpulse3=maxMotorForce3!*timeStep;
    }
    else{
      motorImpulse3=0;
      maxMotorImpulse3=0;
    }
    
    double rdx=d1*ax1!+d2*ax2!+d3*ax2!;
    double rdy=d1*ay1!+d2*ay2!+d3*ay2!;
    double rdz=d1*az1!+d2*az2!+d3*az2!;
    double w1=m2!/(m1!+m2!);
    if(weight>=0){
      w1=weight; // use given weight
    }
    double w2=1-w1;
    r1x=r1.x+rdx*w1;
    r1y=r1.y+rdy*w1;
    r1z=r1.z+rdz*w1;
    r2x=r2.x-rdx*w2;
    r2y=r2.y-rdy*w2;
    r2z=r2.z-rdz*w2;

    // build jacobians
    t1x1=r1y!*az1!-r1z!*ay1!;
    t1y1=r1z!*ax1!-r1x!*az1!;
    t1z1=r1x!*ay1!-r1y!*ax1!;
    t2x1=r2y!*az1!-r2z!*ay1!;
    t2y1=r2z!*ax1!-r2x!*az1!;
    t2z1=r2x!*ay1!-r2y!*ax1!;
    l1x1=ax1!*m1!;
    l1y1=ay1!*m1!;
    l1z1=az1!*m1!;
    l2x1=ax1!*m2!;
    l2y1=ay1!*m2!;
    l2z1=az1!*m2!;
    a1x1=t1x1!*i1e00!+t1y1!*i1e01!+t1z1!*i1e02!;
    a1y1=t1x1!*i1e10!+t1y1!*i1e11!+t1z1!*i1e12!;
    a1z1=t1x1!*i1e20!+t1y1!*i1e21!+t1z1!*i1e22!;
    a2x1=t2x1!*i2e00!+t2y1!*i2e01!+t2z1!*i2e02!;
    a2y1=t2x1!*i2e10!+t2y1!*i2e11!+t2z1!*i2e12!;
    a2z1=t2x1!*i2e20!+t2y1!*i2e21!+t2z1!*i2e22!;

    t1x2=r1y!*az2!-r1z!*ay2!;
    t1y2=r1z!*ax2!-r1x!*az2!;
    t1z2=r1x!*ay2!-r1y!*ax2!;
    t2x2=r2y!*az2!-r2z!*ay2!;
    t2y2=r2z!*ax2!-r2x!*az2!;
    t2z2=r2x!*ay2!-r2y!*ax2!;
    l1x2=ax2!*m1!;
    l1y2=ay2!*m1!;
    l1z2=az2!*m1!;
    l2x2=ax2!*m2!;
    l2y2=ay2!*m2!;
    l2z2=az2!*m2!;
    a1x2=t1x2!*i1e00!+t1y2!*i1e01!+t1z2!*i1e02!;
    a1y2=t1x2!*i1e10!+t1y2!*i1e11!+t1z2!*i1e12!;
    a1z2=t1x2!*i1e20!+t1y2!*i1e21!+t1z2!*i1e22!;
    a2x2=t2x2!*i2e00!+t2y2!*i2e01!+t2z2!*i2e02!;
    a2y2=t2x2!*i2e10!+t2y2!*i2e11!+t2z2!*i2e12!;
    a2z2=t2x2!*i2e20!+t2y2!*i2e21!+t2z2!*i2e22!;

    t1x3=r1y!*az3!-r1z!*ay3!;
    t1y3=r1z!*ax3!-r1x!*az3!;
    t1z3=r1x!*ay3!-r1y!*ax3!;
    t2x3=r2y!*az3!-r2z!*ay3!;
    t2y3=r2z!*ax3!-r2x!*az3!;
    t2z3=r2x!*ay3!-r2y!*ax3!;
    l1x3=ax3!*m1!;
    l1y3=ay3!*m1!;
    l1z3=az3!*m1!;
    l2x3=ax3!*m2!;
    l2y3=ay3!*m2!;
    l2z3=az3!*m2!;
    a1x3=t1x3!*i1e00!+t1y3!*i1e01!+t1z3!*i1e02!;
    a1y3=t1x3!*i1e10!+t1y3!*i1e11!+t1z3!*i1e12!;
    a1z3=t1x3!*i1e20!+t1y3!*i1e21!+t1z3!*i1e22!;
    a2x3=t2x3!*i2e00!+t2y3!*i2e01!+t2z3!*i2e02!;
    a2y3=t2x3!*i2e10!+t2y3!*i2e11!+t2z3!*i2e12!;
    a2z3=t2x3!*i2e20!+t2y3!*i2e21!+t2z3!*i2e22!;

    // build an impulse matrix
    double m12=m1!+m2!;
    k00=(ax1!*ax1!+ay1!*ay1!+az1!*az1!)*m12;
    k01=(ax1!*ax2!+ay1!*ay2!+az1!*az2!)*m12;
    k02=(ax1!*ax3!+ay1!*ay3!+az1!*az3!)*m12;
    k10=(ax2!*ax1!+ay2!*ay1!+az2!*az1!)*m12;
    k11=(ax2!*ax2!+ay2!*ay2!+az2!*az2!)*m12;
    k12=(ax2!*ax3!+ay2!*ay3!+az2!*az3!)*m12;
    k20=(ax3!*ax1!+ay3!*ay1!+az3!*az1!)*m12;
    k21=(ax3!*ax2!+ay3!*ay2!+az3!*az2!)*m12;
    k22=(ax3!*ax3!+ay3!*ay3!+az3!*az3!)*m12;

    k00= k00!+t1x1!*a1x1!+t1y1!*a1y1!+t1z1!*a1z1!;
    k01= k01!+t1x1!*a1x2!+t1y1!*a1y2!+t1z1!*a1z2!;
    k02= k02!+t1x1!*a1x3!+t1y1!*a1y3!+t1z1!*a1z3!;
    k10= k10!+t1x2!*a1x1!+t1y2!*a1y1!+t1z2!*a1z1!;
    k11= k11!+t1x2!*a1x2!+t1y2!*a1y2!+t1z2!*a1z2!;
    k12= k12!+t1x2!*a1x3!+t1y2!*a1y3!+t1z2!*a1z3!;
    k20= k20!+t1x3!*a1x1!+t1y3!*a1y1!+t1z3!*a1z1!;
    k21= k21!+t1x3!*a1x2!+t1y3!*a1y2!+t1z3!*a1z2!;
    k22= k22!+t1x3!*a1x3!+t1y3!*a1y3!+t1z3!*a1z3!;

    k00= k00!+t2x1!*a2x1!+t2y1!*a2y1!+t2z1!*a2z1!;
    k01= k01!+t2x1!*a2x2!+t2y1!*a2y2!+t2z1!*a2z2!;
    k02= k02!+t2x1!*a2x3!+t2y1!*a2y3!+t2z1!*a2z3!;
    k10= k10!+t2x2!*a2x1!+t2y2!*a2y1!+t2z2!*a2z1!;
    k11= k11!+t2x2!*a2x2!+t2y2!*a2y2!+t2z2!*a2z2!;
    k12= k12!+t2x2!*a2x3!+t2y2!*a2y3!+t2z2!*a2z3!;
    k20= k20!+t2x3!*a2x1!+t2y3!*a2y1!+t2z3!*a2z1!;
    k21= k21!+t2x3!*a2x2!+t2y3!*a2y2!+t2z3!*a2z2!;
    k22= k22!+t2x3!*a2x3!+t2y3!*a2y3!+t2z3!*a2z3!;

    kv00=k00;
    kv11=k11;
    kv22=k22;

    dv00=1/kv00!;
    dv11=1/kv11!;
    dv22=1/kv22!;

    if(enableSpring1&&limitState1!=2){
      double omega=6.2831853*frequency1;
      double k=omega*omega*timeStep;
      double dmp=invTimeStep/(k+2*limitMotor1.dampingRatio*omega);
      cfm1=kv00!*dmp;
      limitVelocity1 = limitVelocity1!*k*dmp;
    }
    else{
      cfm1=0;
      limitVelocity1 = limitVelocity1!*invTimeStep*0.05;
    }

    if(enableSpring2&&limitState2!=2){
      double omega=6.2831853*frequency2;
      double k=omega*omega*timeStep;
      double dmp=invTimeStep/(k+2*limitMotor2.dampingRatio*omega);
      cfm2=kv11!*dmp;
      limitVelocity2 = limitVelocity2!*k*dmp;
    }
    else{
      cfm2=0;
      limitVelocity2 = limitVelocity2!*invTimeStep*0.05;
    }

    if(enableSpring3&&limitState3!=2){
      double omega=6.2831853*frequency3;
      double k=omega*omega*timeStep;
      double dmp=invTimeStep/(k+2*limitMotor3.dampingRatio*omega);
      cfm3=kv22!*dmp;
      limitVelocity3 = limitVelocity3!*k*dmp;
    }
    else{
      cfm3=0;
      limitVelocity3 = limitVelocity3!*invTimeStep*0.05;
    }
    k00 = k00!+cfm1;
    k11 = k11!+cfm2;
    k22 = k22!+cfm3;

    double inv=1/(
      k00!*(k11!*k22!-k21!*k12!)+
      k10!*(k21!*k02!-k01!*k22!)+
      k20!*(k01!*k12!-k11!*k02!)
    );
    d00=(k11!*k22!-k12!*k21!)*inv;
    d01=(k02!*k21!-k01!*k22!)*inv;
    d02=(k01!*k12!-k02!*k11!)*inv;
    d10=(k12!*k20!-k10!*k22!)*inv;
    d11=(k00!*k22!-k02!*k20!)*inv;
    d12=(k02!*k10!-k00!*k12!)*inv;
    d20=(k10!*k21!-k11!*k20!)*inv;
    d21=(k01!*k20!-k00!*k21!)*inv;
    d22=(k00!*k11!-k01!*k10!)*inv;

    // warm starting
    double totalImpulse1=limitImpulse1+motorImpulse1;
    double totalImpulse2=limitImpulse2+motorImpulse2;
    double totalImpulse3=limitImpulse3+motorImpulse3;
    
    l1.x+=totalImpulse1*l1x1!+totalImpulse2*l1x2!+totalImpulse3*l1x3!;
    l1.y+=totalImpulse1*l1y1!+totalImpulse2*l1y2!+totalImpulse3*l1y3!;
    l1.z+=totalImpulse1*l1z1!+totalImpulse2*l1z2!+totalImpulse3*l1z3!;
    a1.x+=totalImpulse1*a1x1!+totalImpulse2*a1x2!+totalImpulse3*a1x3!;
    a1.y+=totalImpulse1*a1y1!+totalImpulse2*a1y2!+totalImpulse3*a1y3!;
    a1.z+=totalImpulse1*a1z1!+totalImpulse2*a1z2!+totalImpulse3*a1z3!;
    l2.x-=totalImpulse1*l2x1!+totalImpulse2*l2x2!+totalImpulse3*l2x3!;
    l2.y-=totalImpulse1*l2y1!+totalImpulse2*l2y2!+totalImpulse3*l2y3!;
    l2.z-=totalImpulse1*l2z1!+totalImpulse2*l2z2!+totalImpulse3*l2z3!;
    a2.x-=totalImpulse1*a2x1!+totalImpulse2*a2x2!+totalImpulse3*a2x3!;
    a2.y-=totalImpulse1*a2y1!+totalImpulse2*a2y2!+totalImpulse3*a2y3!;
    a2.z-=totalImpulse1*a2z1!+totalImpulse2*a2z2!+totalImpulse3*a2z3!;
  }

  @override
  void solve(){
    double rvx=l2.x-l1.x+a2.y*r2z!-a2.z*r2y!-a1.y*r1z!+a1.z*r1y!;
    double rvy=l2.y-l1.y+a2.z*r2x!-a2.x*r2z!-a1.z*r1x!+a1.x*r1z!;
    double rvz=l2.z-l1.z+a2.x*r2y!-a2.y*r2x!-a1.x*r1y!+a1.y*r1x!;
    double rvn1=rvx*ax1!+rvy*ay1!+rvz*az1!;
    double rvn2=rvx*ax2!+rvy*ay2!+rvz*az2!;
    double rvn3=rvx*ax3!+rvy*ay3!+rvz*az3!;
    double oldMotorImpulse1=motorImpulse1;
    double oldMotorImpulse2=motorImpulse2;
    double oldMotorImpulse3=motorImpulse3;
    double dMotorImpulse1=0;
    double dMotorImpulse2=0;
    double dMotorImpulse3=0;

    if(enableMotor1){
      dMotorImpulse1=(rvn1-motorSpeed1!)*dv00!;
      motorImpulse1+=dMotorImpulse1;
      if(motorImpulse1>maxMotorImpulse1!){ // clamp motor impulse
        motorImpulse1=maxMotorImpulse1!;
      }
      else if(motorImpulse1 < -maxMotorImpulse1!){
        motorImpulse1 = -maxMotorImpulse1!;
      }
      dMotorImpulse1=motorImpulse1-oldMotorImpulse1;
    }
    if(enableMotor2){
      dMotorImpulse2=(rvn2-motorSpeed2!)*dv11!;
      motorImpulse2+=dMotorImpulse2;
      if(motorImpulse2>maxMotorImpulse2!){ // clamp motor impulse
        motorImpulse2=maxMotorImpulse2!;
      }
      else if(motorImpulse2<-maxMotorImpulse2!){
        motorImpulse2=-maxMotorImpulse2!;
      }
      dMotorImpulse2=motorImpulse2-oldMotorImpulse2;
    }
    if(enableMotor3){
      dMotorImpulse3=(rvn3-motorSpeed3!)*dv22!;
      motorImpulse3+=dMotorImpulse3;
      if(motorImpulse3>maxMotorImpulse3!){ // clamp motor impulse
        motorImpulse3=maxMotorImpulse3!;
      }
      else if(motorImpulse3<-maxMotorImpulse3!){
        motorImpulse3=-maxMotorImpulse3!;
      }
      dMotorImpulse3=motorImpulse3-oldMotorImpulse3;
    }

    // apply motor impulse to relative velocity
    rvn1+=dMotorImpulse1*kv00!+dMotorImpulse2*k01!+dMotorImpulse3*k02!;
    rvn2+=dMotorImpulse1*k10!+dMotorImpulse2*kv11!+dMotorImpulse3*k12!;
    rvn3+=dMotorImpulse1*k20!+dMotorImpulse2*k21!+dMotorImpulse3*kv22!;

    // subtract target velocity and applied impulse
    rvn1-=limitVelocity1!+limitImpulse1*cfm1;
    rvn2-=limitVelocity2!+limitImpulse2*cfm2;
    rvn3-=limitVelocity3!+limitImpulse3*cfm3;

    double oldLimitImpulse1=limitImpulse1;
    double oldLimitImpulse2=limitImpulse2;
    double oldLimitImpulse3=limitImpulse3;

    double dLimitImpulse1=rvn1*d00!+rvn2*d01!+rvn3*d02!;
    double dLimitImpulse2=rvn1*d10!+rvn2*d11!+rvn3*d12!;
    double dLimitImpulse3=rvn1*d20!+rvn2*d21!+rvn3*d22!;

    limitImpulse1+=dLimitImpulse1;
    limitImpulse2+=dLimitImpulse2;
    limitImpulse3+=dLimitImpulse3;

    // clamp
    int clampState=0;
    if(limitState1==2||limitImpulse1*limitState1<0){
      dLimitImpulse1=-oldLimitImpulse1;
      rvn2+=dLimitImpulse1*k10!;
      rvn3+=dLimitImpulse1*k20!;
      clampState|=1;
    }
    if(limitState2==2||limitImpulse2*limitState2<0){
      dLimitImpulse2=-oldLimitImpulse2;
      rvn1+=dLimitImpulse2*k01!;
      rvn3+=dLimitImpulse2*k21!;
      clampState|=2;
    }
    if(limitState3==2||limitImpulse3*limitState3<0){
      dLimitImpulse3=-oldLimitImpulse3;
      rvn1+=dLimitImpulse3*k02!;
      rvn2+=dLimitImpulse3*k12!;
      clampState|=4;
    }

    // update un-clamped impulse
    // dart(todo) isolate division
    double det;
    switch(clampState){
      case 1:// update 2 3
        det=1/(k11!*k22!-k12!*k21!);
        dLimitImpulse2=(k22!*rvn2+-k12!*rvn3)*det;
        dLimitImpulse3=(-k21!*rvn2+k11!*rvn3)*det;
        break;
      case 2:// update 1 3
        det=1/(k00!*k22!-k02!*k20!);
        dLimitImpulse1=(k22!*rvn1+-k02!*rvn3)*det;
        dLimitImpulse3=(-k20!*rvn1+k00!*rvn3)*det;
        break;
      case 3:// update 3
        dLimitImpulse3=rvn3/k22!;
        break;
      case 4:// update 1 2
        det=1/(k00!*k11!-k01!*k10!);
        dLimitImpulse1=(k11!*rvn1+-k01!*rvn2)*det;
        dLimitImpulse2=(-k10!*rvn1+k00!*rvn2)*det;
        break;
      case 5:// update 2
        dLimitImpulse2=rvn2/k11!;
        break;
      case 6:// update 1
        dLimitImpulse1=rvn1/k00!;
        break;
    }

    limitImpulse1=oldLimitImpulse1+dLimitImpulse1;
    limitImpulse2=oldLimitImpulse2+dLimitImpulse2;
    limitImpulse3=oldLimitImpulse3+dLimitImpulse3;

    double dImpulse1=dMotorImpulse1+dLimitImpulse1;
    double dImpulse2=dMotorImpulse2+dLimitImpulse2;
    double dImpulse3=dMotorImpulse3+dLimitImpulse3;

    // apply impulse
    l1.x+=dImpulse1*l1x1!+dImpulse2*l1x2!+dImpulse3*l1x3!;
    l1.y+=dImpulse1*l1y1!+dImpulse2*l1y2!+dImpulse3*l1y3!;
    l1.z+=dImpulse1*l1z1!+dImpulse2*l1z2!+dImpulse3*l1z3!;
    a1.x+=dImpulse1*a1x1!+dImpulse2*a1x2!+dImpulse3*a1x3!;
    a1.y+=dImpulse1*a1y1!+dImpulse2*a1y2!+dImpulse3*a1y3!;
    a1.z+=dImpulse1*a1z1!+dImpulse2*a1z2!+dImpulse3*a1z3!;
    l2.x-=dImpulse1*l2x1!+dImpulse2*l2x2!+dImpulse3*l2x3!;
    l2.y-=dImpulse1*l2y1!+dImpulse2*l2y2!+dImpulse3*l2y3!;
    l2.z-=dImpulse1*l2z1!+dImpulse2*l2z2!+dImpulse3*l2z3!;
    a2.x-=dImpulse1*a2x1!+dImpulse2*a2x2!+dImpulse3*a2x3!;
    a2.y-=dImpulse1*a2y1!+dImpulse2*a2y2!+dImpulse3*a2y3!;
    a2.z-=dImpulse1*a2z1!+dImpulse2*a2z2!+dImpulse3*a2z3!;
  }
}