import '../../math/mat33.dart';
import 'dart:math' as math;
import '../constraint.dart';
import 'contact_point_data_buffer.dart';
import 'contact_manifold.dart';

import '../../math/vec3.dart';
import 'manifold_point.dart';
import '../../math/math.dart';

class ContactConstraint extends Constraint{
  ContactConstraint(this.manifold):super(){
    cs.next = ContactPointDataBuffer();
    cs.next!.next = ContactPointDataBuffer();
    cs.next!.next!.next = ContactPointDataBuffer();

    ps = manifold.points;
  }
  // The contact manifold of the constraint.
  ContactManifold manifold;
  // The coefficient of restitution of the constraint.
  double? restitution;
  // The coefficient of friction of the constraint.
  double? friction;
  Vec3? p1;
  Vec3? p2;
  Vec3? lv1;
  Vec3? lv2;
  Vec3? av1;
  Vec3? av2;
  Mat33? i1;
  Mat33? i2;

  //ii1 = null;
  //ii2 = null;

  Vec3 tmp = Vec3();
  Vec3 tmpC1 = Vec3();
  Vec3 tmpC2 = Vec3();

  Vec3 tmpP1 = Vec3();
  Vec3 tmpP2 = Vec3();

  Vec3 tmplv1 = Vec3();
  Vec3 tmplv2 = Vec3();
  Vec3 tmpav1 = Vec3();
  Vec3 tmpav2 = Vec3();

  double? m1;
  double? m2;
  double num=0;
    
  late List<ManifoldPoint> ps;
  ContactPointDataBuffer cs = ContactPointDataBuffer();

  // Attach the constraint to the bodies.
  void attach(){
    p1=body1!.position;
    p2=body2!.position;
    lv1=body1!.linearVelocity;
    av1=body1!.angularVelocity;
    lv2=body2!.linearVelocity;
    av2=body2!.angularVelocity;
    i1=body1!.inverseInertia;
    i2=body2!.inverseInertia;
  }

  // Detach the constraint from the bodies.
  void detach(){
    p1=null;
    p2=null;
    lv1=null;
    lv2=null;
    av1=null;
    av2=null;
    i1=null;
    i2=null;
  }

  @override
  void preSolve(double timeStep,double invTimeStep ){
    m1 = body1!.inverseMass;
    m2 = body2!.inverseMass;

    double m1m2 = m1! + m2!;

    num = manifold.numPoints.toDouble();

    ContactPointDataBuffer? c = cs;
    ManifoldPoint p;
    double rvn, len, norImp, norTar, sepV;
    Mat33 i1, i2;

    for(int i=0; i < num; i++){
      p = ps[i];

      tmpP1.sub( p.position, p1 );
      tmpP2.sub( p.position, p2 );

      tmpC1.crossVectors(av1!, tmpP1 );
      tmpC2.crossVectors(av2!, tmpP2 );

      c!.norImp = p.normalImpulse;
      c.tanImp = p.tangentImpulse;
      c.binImp = p.binormalImpulse;

      c.nor.copy( p.normal );

      tmp.set(
        ( lv2!.x + tmpC2.x ) - ( lv1!.x + tmpC1.x ),
        ( lv2!.y + tmpC2.y ) - ( lv1!.y + tmpC1.y ),
        ( lv2!.z + tmpC2.z ) - ( lv1!.z + tmpC1.z )
      );

      rvn = Math.dotVectors( c.nor, tmp );

      c.tan.set(
        tmp.x - rvn * c.nor.x,
        tmp.y - rvn * c.nor.y,
        tmp.z - rvn * c.nor.z
      );

      len = Math.dotVectors( c.tan, c.tan );

      if( len <= 0.04 ) {
        c.tan.tangent( c.nor );
      }

      c.tan.normalize();

      c.bin.crossVectors( c.nor, c.tan );

      c.norU1.scale( c.nor, m1! );
      c.norU2.scale( c.nor, m2! );

      c.tanU1.scale( c.tan, m1! );
      c.tanU2.scale( c.tan, m2! );

      c.binU1.scale( c.bin, m1! );
      c.binU2.scale( c.bin, m2! );

      c.norT1.crossVectors( tmpP1, c.nor );
      c.tanT1.crossVectors( tmpP1, c.tan );
      c.binT1.crossVectors( tmpP1, c.bin );

      c.norT2.crossVectors( tmpP2, c.nor );
      c.tanT2.crossVectors( tmpP2, c.tan );
      c.binT2.crossVectors( tmpP2, c.bin );

      i1 = this.i1!;
      i2 = this.i2!;

      c.norTU1.copy( c.norT1 ).applyMatrix3( i1, true );
      c.tanTU1.copy( c.tanT1 ).applyMatrix3( i1, true );
      c.binTU1.copy( c.binT1 ).applyMatrix3( i1, true );

      c.norTU2.copy( c.norT2 ).applyMatrix3( i2, true );
      c.tanTU2.copy( c.tanT2 ).applyMatrix3( i2, true );
      c.binTU2.copy( c.binT2 ).applyMatrix3( i2, true );

      tmpC1.crossVectors( c.norTU1, tmpP1 );
      tmpC2.crossVectors( c.norTU2, tmpP2 );
      tmp.add( tmpC1, tmpC2 );
      c.norDen = 1 / ( m1m2 +Math.dotVectors( c.nor, tmp ));

      tmpC1.crossVectors( c.tanTU1, tmpP1 );
      tmpC2.crossVectors( c.tanTU2, tmpP2 );
      tmp.add( tmpC1, tmpC2 );
      c.tanDen = 1 / ( m1m2 +Math.dotVectors( c.tan, tmp ));

      tmpC1.crossVectors( c.binTU1, tmpP1 );
      tmpC2.crossVectors( c.binTU2, tmpP2 );
      tmp.add( tmpC1, tmpC2 );
      c.binDen = 1 / ( m1m2 +Math.dotVectors( c.bin, tmp ));

      if( p.warmStarted ){
        norImp = p.normalImpulse;
        lv1!.addScaledVector( c.norU1, norImp );
        av1!.addScaledVector( c.norTU1, norImp );
        lv2!.subScaledVector( c.norU2, norImp );
        av2!.subScaledVector( c.norTU2, norImp );
        c.norImp = norImp;
        c.tanImp = 0;
        c.binImp = 0;
        rvn = 0; // disable bouncing
      } 
      else {
        c.norImp=0;
        c.tanImp=0;
        c.binImp=0;
      }

      if(rvn>-1) rvn=0; // disable bouncing
      
      norTar = restitution!*-rvn;
      sepV = -(p.penetration+0.005)*invTimeStep*0.05; // allow 0.5cm error
      if(norTar<sepV) norTar=sepV;
      c.norTar = norTar;
      c.last = i==num-1;
      c = c.next;
    }
  }

  @override
  void solve(){
    tmplv1.copy( lv1! );
    tmplv2.copy( lv2! );
    tmpav1.copy( av1! );
    tmpav2.copy( av2! );

    double oldImp1, newImp1, oldImp2, newImp2, rvn, norImp, tanImp, binImp, max, len;
    ContactPointDataBuffer c = cs;

    while(true){
      norImp = c.norImp;
      tanImp = c.tanImp;
      binImp = c.binImp;
      max = -norImp * friction!;

      tmp.sub( tmplv2, tmplv1 );

      rvn = Math.dotVectors( tmp, c.tan ) + Math.dotVectors( tmpav2, c.tanT2 ) - Math.dotVectors( tmpav1, c.tanT1 );
  
      oldImp1 = tanImp;
      newImp1 = rvn*c.tanDen;
      tanImp += newImp1;

      rvn = Math.dotVectors( tmp, c.bin ) + Math.dotVectors( tmpav2, c.binT2 ) - Math.dotVectors( tmpav1, c.binT1 );

      oldImp2 = binImp;
      newImp2 = rvn*c.binDen;
      binImp += newImp2;

      // cone friction clamp
      len = tanImp*tanImp + binImp*binImp;
      if(len > max * max ){
        len = max/math.sqrt(len);
        tanImp *= len;
        binImp *= len;
      }

      newImp1 = tanImp-oldImp1;
      newImp2 = binImp-oldImp2;

      //
      tmp.set( 
        c.tanU1.x*newImp1 + c.binU1.x*newImp2,
        c.tanU1.y*newImp1 + c.binU1.y*newImp2,
        c.tanU1.z*newImp1 + c.binU1.z*newImp2
      );

      tmplv1.addEqual( tmp );

      tmp.set(
        c.tanTU1.x*newImp1 + c.binTU1.x*newImp2,
        c.tanTU1.y*newImp1 + c.binTU1.y*newImp2,
        c.tanTU1.z*newImp1 + c.binTU1.z*newImp2
      );

      tmpav1.addEqual( tmp );

      tmp.set(
        c.tanU2.x*newImp1 + c.binU2.x*newImp2,
        c.tanU2.y*newImp1 + c.binU2.y*newImp2,
        c.tanU2.z*newImp1 + c.binU2.z*newImp2
      );

      tmplv2.subEqual( tmp );

      tmp.set(
          c.tanTU2.x*newImp1 + c.binTU2.x*newImp2,
          c.tanTU2.y*newImp1 + c.binTU2.y*newImp2,
          c.tanTU2.z*newImp1 + c.binTU2.z*newImp2
      );

      tmpav2.subEqual( tmp );

      // restitution part

      tmp.sub( tmplv2, tmplv1 );

      rvn = Math.dotVectors( tmp, c.nor ) + Math.dotVectors( tmpav2, c.norT2 ) - Math.dotVectors( tmpav1, c.norT1 );

      oldImp1 = norImp;
      newImp1 = (rvn-c.norTar)*c.norDen;
      norImp += newImp1;
      if( norImp > 0 ){ norImp = 0;}

      newImp1 = norImp - oldImp1;

      tmplv1.addScaledVector( c.norU1, newImp1 );
      tmpav1.addScaledVector( c.norTU1, newImp1 );
      tmplv2.subScaledVector( c.norU2, newImp1 );
      tmpav2.subScaledVector( c.norTU2, newImp1 );

      c.norImp = norImp;
      c.tanImp = tanImp;
      c.binImp = binImp;

      if(c.last){break;}
      c = c.next!;
    }

    lv1!.copy( tmplv1 );
    lv2!.copy( tmplv2 );
    av1!.copy( tmpav1 );
    av2!.copy( tmpav2 );
  }

  @override
  void postSolve(){
    ContactPointDataBuffer? c = cs;
    ManifoldPoint p;
    for(int i = (num-1).toInt();i >=0; i--){
      p = ps[i];
      p.normal.copy( c!.nor );
      p.tangent.copy( c.tan );
      p.binormal.copy( c.bin );

      p.normalImpulse = c.norImp;
      p.tangentImpulse = c.tanImp;
      p.binormalImpulse = c.binImp;
      p.normalDenominator = c.norDen;
      p.tangentDenominator = c.tanDen;
      p.binormalDenominator = c.binDen;
      c = c.next;
    }
  }
}