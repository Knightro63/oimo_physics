import 'package:oimo_physics/core/core_main.dart';
import '../joint_main.dart';
import '../../../math/mat33.dart';
import '../../../math/vec3.dart';
import '../../../math/quat.dart';

// * An angular constraint for all axes for various joints.
class AngularConstraint extends Joint{
  AngularConstraint(this.joint, targetOrientation ):super(joint.config) {
    targetOrientation = Quat().invert( targetOrientation );

    b1 = joint.body1!;
    b2 = joint.body2!;
    a1 = b1.angularVelocity;
    a2 = b2.angularVelocity;
    i1 = b1.inverseInertia;
    i2 = b2.inverseInertia;
  }

  Joint joint;

  late Quat targetOrientation;

  Quat relativeOrientation = Quat();

  Mat33? ii1;
  Mat33? ii2;
  Mat33? dd;

  Vec3 vel = Vec3();
  Vec3 imp = Vec3();

  Vec3 rn0 = Vec3();
  Vec3 rn1 = Vec3();
  Vec3 rn2 = Vec3();

  late Core b1;
  late Core b2;
  late Vec3 a1;
  late Vec3 a2;
  late Mat33 i1;
  late Mat33 i2;

  @override
  void preSolve(double timeStep, double invTimeStep) {
    double inv, len;
    List<double> v;

    ii1 = i1.clone();
    ii2 = i2.clone();

    v = Mat33().add(ii1!, ii2).elements;
    inv = 1/( v[0]*(v[4]*v[8]-v[7]*v[5])  +  v[3]*(v[7]*v[2]-v[1]*v[8])  +  v[6]*(v[1]*v[5]-v[4]*v[2]) );
    dd = Mat33().set(
        v[4]*v[8]-v[5]*v[7], v[2]*v[7]-v[1]*v[8], v[1]*v[5]-v[2]*v[4],
        v[5]*v[6]-v[3]*v[8], v[0]*v[8]-v[2]*v[6], v[2]*v[3]-v[0]*v[5],
        v[3]*v[7]-v[4]*v[6], v[1]*v[6]-v[0]*v[7], v[0]*v[4]-v[1]*v[3]
    ).multiplyScalar( inv );
    
    relativeOrientation.invert(b1.orientation).multiply(targetOrientation).multiply(b2.orientation);

    inv = relativeOrientation.w*2;

    vel.copy(relativeOrientation.toVec3()).multiplyScalar(inv);

    len = vel.length();

    if( len > 0.02 ) {
      len = (0.02-len)/len*invTimeStep*0.05;
      vel.multiplyScalar(len);
    }
    else{
      vel.set(0,0,0);
    }

    rn1.copy(imp).applyMatrix3(ii1!, true);
    rn2.copy(imp).applyMatrix3(ii2!, true);

    a1.add(rn1);
    a2.sub(rn2);
  }

  @override
  void solve(){
    Vec3 r = a2.clone().sub(a1).sub(vel);

    rn0.copy(r).applyMatrix3(dd!, true);
    rn1.copy(rn0).applyMatrix3(ii1!, true);
    rn2.copy(rn0).applyMatrix3(ii2!, true);

    imp.add(rn0);
    a1.add(rn1);
    a2.sub(rn2);
  }
}