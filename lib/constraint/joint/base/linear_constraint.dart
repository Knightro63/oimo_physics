import '../../../core/rigid_body.dart';
import 'dart:math' as math;
import '../joint_main.dart';
import '../../../math/mat33.dart';
import '../../../math/vec3.dart';

// * A linear constraint for all axes for various joints.
class LinearConstraint extends Joint{
  LinearConstraint(this.joint):super(joint.config){
    r1 = joint.relativeAnchorPoint1;
    r2 = joint.relativeAnchorPoint2;
    p1 = joint.anchorPoint1;
    p2 = joint.anchorPoint2;
    b1 = joint.body1;
    b2 = joint.body2;
    l1 = b1?.linearVelocity;
    l2 = b2?.linearVelocity;
    a1 = b1?.angularVelocity;
    a2 = b2?.angularVelocity;
    i1 = b1?.inverseInertia;
    i2 = b2?.inverseInertia;
  }

  double? m1;
  double? m2;

  Mat33? ii1;
  Mat33? ii2;
  Mat33? dd;

  double? r1x;
  double? r1y;
  double? r1z;

  double? r2x;
  double? r2y;
  double? r2z;

  double? ax1x;
  double? ax1y;
  double? ax1z;
  double? ay1x;
  double? ay1y;
  double? ay1z;
  double? az1x;
  double? az1y;
  double? az1z;

  double? ax2x;
  double? ax2y;
  double? ax2z;
  double? ay2x;
  double? ay2y;
  double? ay2z;
  double? az2x;
  double? az2y;
  double? az2z;

  double? vel;
  double? velx;
  double? vely;
  double? velz;


  Joint joint;
  late Vec3 r1;
  late Vec3 r2;
  late Vec3 p1;
  late Vec3 p2;
  RigidBody? b1;
  RigidBody? b2;
  Vec3? l1;
  Vec3? l2;
  Vec3? a1;
  Vec3? a2;
  Mat33? i1;
  Mat33? i2;
  double impx = 0;
  double impy = 0;
  double impz = 0;

  @override
  void preSolve(double timeStep, double invTimeStep ) {
    r1x = r1.x;
    r1y = r1.y;
    r1z = r1.z;

    r2x = r2.x;
    r2y = r2.y;
    r2z = r2.z;

    m1 = b1?.inverseMass;
    m2 = b2?.inverseMass;

    this.ii1 = i1!.clone();
    this.ii2 = i2!.clone();

    List<double> ii1 = this.ii1!.elements;
    List<double> ii2 = this.ii2!.elements;

    ax1x = r1z!*ii1[1]+-r1y!*ii1[2];
    ax1y = r1z!*ii1[4]+-r1y!*ii1[5];
    ax1z = r1z!*ii1[7]+-r1y!*ii1[8];
    ay1x = -r1z!*ii1[0]+r1x!*ii1[2];
    ay1y = -r1z!*ii1[3]+r1x!*ii1[5];
    ay1z = -r1z!*ii1[6]+r1x!*ii1[8];
    az1x = r1y!*ii1[0]+-r1x!*ii1[1];
    az1y = r1y!*ii1[3]+-r1x!*ii1[4];
    az1z = r1y!*ii1[6]+-r1x!*ii1[7];
    ax2x = r2z!*ii2[1]+-r2y!*ii2[2];
    ax2y = r2z!*ii2[4]+-r2y!*ii2[5];
    ax2z = r2z!*ii2[7]+-r2y!*ii2[8];
    ay2x = -r2z!*ii2[0]+r2x!*ii2[2];
    ay2y = -r2z!*ii2[3]+r2x!*ii2[5];
    ay2z = -r2z!*ii2[6]+r2x!*ii2[8];
    az2x = r2y!*ii2[0]+-r2x!*ii2[1];
    az2y = r2y!*ii2[3]+-r2x!*ii2[4];
    az2z = r2y!*ii2[6]+-r2x!*ii2[7];

    double rxx = m1!+m2!;

    Mat33 kk = Mat33().set( rxx, 0, 0,  0, rxx, 0,  0, 0, rxx );
    List<double> k = kk.elements;

    k[0] += ii1[4]*r1z!*r1z!-(ii1[7]+ii1[5])*r1y!*r1z!+ii1[8]*r1y!*r1y!;
    k[1] += (ii1[6]*r1y!+ii1[5]*r1x!)*r1z!-ii1[3]*r1z!*r1z!-ii1[8]*r1x!*r1y!;
    k[2] += (ii1[3]*r1y!-ii1[4]*r1x!)*r1z!-ii1[6]*r1y!*r1y!+ii1[7]*r1x!*r1y!;
    k[3] += (ii1[2]*r1y!+ii1[7]*r1x!)*r1z!-ii1[1]*r1z!*r1z!-ii1[8]*r1x!*r1y!;
    k[4] += ii1[0]*r1z!*r1z!-(ii1[6]+ii1[2])*r1x!*r1z!+ii1[8]*r1x!*r1x!;
    k[5] += (ii1[1]*r1x!-ii1[0]*r1y!)*r1z!-ii1[7]*r1x!*r1x!+ii1[6]*r1x!*r1y!;
    k[6] += (ii1[1]*r1y!-ii1[4]*r1x!)*r1z!-ii1[2]*r1y!*r1y!+ii1[5]*r1x!*r1y!;
    k[7] += (ii1[3]*r1x!-ii1[0]*r1y!)*r1z!-ii1[5]*r1x!*r1x!+ii1[2]*r1x!*r1y!;
    k[8] += ii1[0]*r1y!*r1y!-(ii1[3]+ii1[1])*r1x!*r1y!+ii1[4]*r1x!*r1x!;

    k[0] += ii2[4]*r2z!*r2z!-(ii2[7]+ii2[5])*r2y!*r2z!+ii2[8]*r2y!*r2y!;
    k[1] += (ii2[6]*r2y!+ii2[5]*r2x!)*r2z!-ii2[3]*r2z!*r2z!-ii2[8]*r2x!*r2y!;
    k[2] += (ii2[3]*r2y!-ii2[4]*r2x!)*r2z!-ii2[6]*r2y!*r2y!+ii2[7]*r2x!*r2y!;
    k[3] += (ii2[2]*r2y!+ii2[7]*r2x!)*r2z!-ii2[1]*r2z!*r2z!-ii2[8]*r2x!*r2y!;
    k[4] += ii2[0]*r2z!*r2z!-(ii2[6]+ii2[2])*r2x!*r2z!+ii2[8]*r2x!*r2x!;
    k[5] += (ii2[1]*r2x!-ii2[0]*r2y!)*r2z!-ii2[7]*r2x!*r2x!+ii2[6]*r2x!*r2y!;
    k[6] += (ii2[1]*r2y!-ii2[4]*r2x!)*r2z!-ii2[2]*r2y!*r2y!+ii2[5]*r2x!*r2y!;
    k[7] += (ii2[3]*r2x!-ii2[0]*r2y!)*r2z!-ii2[5]*r2x!*r2x!+ii2[2]*r2x!*r2y!;
    k[8] += ii2[0]*r2y!*r2y!-(ii2[3]+ii2[1])*r2x!*r2y!+ii2[4]*r2x!*r2x!;

    double inv=1/( k[0]*(k[4]*k[8]-k[7]*k[5]) + k[3]*(k[7]*k[2]-k[1]*k[8]) + k[6]*(k[1]*k[5]-k[4]*k[2]) );
    dd = Mat33().set(
      k[4]*k[8]-k[5]*k[7], k[2]*k[7]-k[1]*k[8], k[1]*k[5]-k[2]*k[4],
      k[5]*k[6]-k[3]*k[8], k[0]*k[8]-k[2]*k[6], k[2]*k[3]-k[0]*k[5],
      k[3]*k[7]-k[4]*k[6], k[1]*k[6]-k[0]*k[7], k[0]*k[4]-k[1]*k[3]
    ).scaleEqual( inv );

    velx = p2.x-p1.x;
    vely = p2.y-p1.y;
    velz = p2.z-p1.z;
    var len = math.sqrt(velx!*velx!+vely!*vely!+velz!*velz!);
    if(len>0.005){
      len = (0.005-len)/len*invTimeStep*0.05;
      velx = velx!*len;
      vely = vely!*len;
      velz = velz!*len;
    }
    else{
      velx = 0;
      vely = 0;
      velz = 0;
    }

    impx *= 0.95;
    impy *= 0.95;
    impz *= 0.95;
    
    l1!.x += impx*m1!;
    l1!.y += impy*m1!;
    l1!.z += impz*m1!;
    a1!.x += impx*ax1x!+impy*ay1x!+impz*az1x!;
    a1!.y += impx*ax1y!+impy*ay1y!+impz*az1y!;
    a1!.z += impx*ax1z!+impy*ay1z!+impz*az1z!;
    l2!.x -= impx*m2!;
    l2!.y -= impy*m2!;
    l2!.z -= impz*m2!;
    a2!.x -= impx*ax2x!+impy*ay2x!+impz*az2x!;
    a2!.y -= impx*ax2y!+impy*ay2y!+impz*az2y!;
    a2!.z -= impx*ax2z!+impy*ay2z!+impz*az2z!;
  }

  @override
  void solve(){
    List<double> d = dd!.elements;
    double rvx = l2!.x-l1!.x+a2!.y*r2z!-a2!.z*r2y!-a1!.y*r1z!+a1!.z*r1y!-velx!;
    double rvy = l2!.y-l1!.y+a2!.z*r2x!-a2!.x*r2z!-a1!.z*r1x!+a1!.x*r1z!-vely!;
    double rvz = l2!.z-l1!.z+a2!.x*r2y!-a2!.y*r2x!-a1!.x*r1y!+a1!.y*r1x!-velz!;
    double nimpx = rvx*d[0]+rvy*d[1]+rvz*d[2];
    double nimpy = rvx*d[3]+rvy*d[4]+rvz*d[5];
    double nimpz = rvx*d[6]+rvy*d[7]+rvz*d[8];
    impx += nimpx;
    impy += nimpy;
    impz += nimpz;
    l1!.x += nimpx*m1!;
    l1!.y += nimpy*m1!;
    l1!.z += nimpz*m1!;
    a1!.x += nimpx*ax1x!+nimpy*ay1x!+nimpz*az1x!;
    a1!.y += nimpx*ax1y!+nimpy*ay1y!+nimpz*az1y!;
    a1!.z += nimpx*ax1z!+nimpy*ay1z!+nimpz*az1z!;
    l2!.x -= nimpx*m2!;
    l2!.y -= nimpy*m2!;
    l2!.z -= nimpz*m2!;
    a2!.x -= nimpx*ax2x!+nimpy*ay2x!+nimpz*az2x!;
    a2!.y -= nimpx*ax2y!+nimpy*ay2y!+nimpz*az2y!;
    a2!.z -= nimpx*ax2z!+nimpy*ay2z!+nimpz*az2z!;
  }
}