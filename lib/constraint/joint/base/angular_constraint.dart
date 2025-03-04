import '../../../core/rigid_body.dart';
import '../joint_main.dart';
import '../../../math/mat33.dart';
import '../../../math/vec3.dart';
import '../../../math/quat.dart';

import 'package:vector_math/vector_math.dart';

/// An angular constraint for all axes for various joints.
class AngularConstraint extends Joint{
  /// An angular constraint for all axes for various joints.
  /// 
  /// [joint] the joint of the angular constraint
  /// 
  /// [targetOrientation] Prientation of the angular constraint
  AngularConstraint(this.joint, Quaternion targetOrientation ):super(joint.config) {
    this.targetOrientation = Quaternion(0,0,0,1).invert(targetOrientation);

    b1 = joint.body1!;
    b2 = joint.body2!;
    a1 = b1.angularVelocity;
    a2 = b2.angularVelocity;
    i1 = b1.inverseInertia;
    i2 = b2.inverseInertia;
  }

  Joint joint;

  late Quaternion targetOrientation;

  Quaternion relativeOrientation = Quaternion(0,0,0,1);

  Matrix3? ii1;
  Matrix3? ii2;
  Matrix3? dd;

  Vector3 vel = Vector3.zero();
  Vector3 imp = Vector3.zero();

  Vector3 rn0 = Vector3.zero();
  Vector3 rn1 = Vector3.zero();
  Vector3 rn2 = Vector3.zero();

  late RigidBody b1;
  late RigidBody b2;
  late Vector3 a1;
  late Vector3 a2;
  late Matrix3 i1;
  late Matrix3 i2;

  @override
  void preSolve(double timeStep, double invTimeStep) {
    double inv, len;
    List<double> v;

    ii1 = i1.clone();
    ii2 = i2.clone();

    v = Matrix3.identity().add2(ii1!, ii2!).storage;
    inv = 1/( v[0]*(v[4]*v[8]-v[7]*v[5])  +  v[3]*(v[7]*v[2]-v[1]*v[8])  +  v[6]*(v[1]*v[5]-v[4]*v[2]) );
    dd = Matrix3(
        v[4]*v[8]-v[5]*v[7], v[2]*v[7]-v[1]*v[8], v[1]*v[5]-v[2]*v[4],
        v[5]*v[6]-v[3]*v[8], v[0]*v[8]-v[2]*v[6], v[2]*v[3]-v[0]*v[5],
        v[3]*v[7]-v[4]*v[6], v[1]*v[6]-v[0]*v[7], v[0]*v[4]-v[1]*v[3]
    )..multiplyScalar( inv );
    
    relativeOrientation.invert(b1.orientation).multiply(targetOrientation).multiply(b2.orientation);

    inv = relativeOrientation.w*2;

    vel..setFrom(relativeOrientation.toVector3())..scale(inv);

    len = vel.length;

    if( len > 0.02 ) {
      len = (0.02-len)/len*invTimeStep*0.05;
      vel.scale(len);
    }
    else{
      vel.setValues(0,0,0);
    }

    rn1..setFrom(imp)..applyMatrix3Transpose(ii1!);
    rn2..setFrom(imp)..applyMatrix3Transpose(ii2!);

    a1.add(rn1);
    a2.sub(rn2);
  }

  @override
  void solve(){
    Vector3 r = a2.clone()..sub(a1)..sub(vel);

    rn0..setFrom(r)..applyMatrix3Transpose(dd!);
    rn1..setFrom(rn0)..applyMatrix3Transpose(ii1!);
    rn2..setFrom(rn0)..applyMatrix3Transpose(ii2!);

    imp.add(rn0);
    a1.add(rn1);
    a2.sub(rn2);
  }
}