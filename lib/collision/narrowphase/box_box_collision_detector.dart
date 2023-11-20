import 'collision_detector.dart';
import '../../shape/shape_main.dart';
import '../../constraint/contact/contact_manifold.dart';
import 'dart:math' as math;
import '../../shape/box_shape.dart';

/// A collision detector which detects collisions between two boxes.
class BoxBoxCollisionDetector extends CollisionDetector{
  List<double> clipVertices1 = List.filled(24, 0);//new Float32Array( 24 ); // 8 vertices x,y,z
  List<double> clipVertices2 = List.filled(24, 0);//new Float32Array( 24 );
  List<bool>used = List.filled(8, false);//new Float32Array( 8 );
  double inf = 1/0;

    @override
    void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold ) {
      Box b1;
      Box b2;
      if(shape1.id<shape2.id){
        b1=shape1 as Box;
        b2=shape2 as Box;
      }
      else{
        b1= shape2 as Box;
        b2= shape1 as Box;
      }
      final vv1 = b1.elements;
      final vv2 = b2.elements;

      final dd1 = b1.dimentions;
      final dd2 = b2.dimentions;

      final p1=b1.position;
      final p2=b2.position;
      double p1x=p1.x;
      double p1y=p1.y;
      double p1z=p1.z;
      double p2x=p2.x;
      double p2y=p2.y;
      double p2z=p2.z;
      // diff
      double dx=p2x-p1x;
      double dy=p2y-p1y;
      double dz=p2z-p1z;
      // distance
      double w1=b1.halfWidth;
      double h1=b1.halfHeight;
      double d1=b1.halfDepth;
      double w2=b2.halfWidth;
      double h2=b2.halfHeight;
      double d2=b2.halfDepth;
      // direction

      // ----------------------------
      // 15 separating axes
      // 1~6: face
      // 7~f: edge
      // http://marupeke296.com/COL_3D_No13_OBBvsOBB.html
      // ----------------------------
      
      double a1x=dd1[0];
      double a1y=dd1[1];
      double a1z=dd1[2];
      double a2x=dd1[3];
      double a2y=dd1[4];
      double a2z=dd1[5];
      double a3x=dd1[6];
      double a3y=dd1[7];
      double a3z=dd1[8];
      double d1x=dd1[9];
      double d1y=dd1[10];
      double d1z=dd1[11];
      double d2x=dd1[12];
      double d2y=dd1[13];
      double d2z=dd1[14];
      double d3x=dd1[15];
      double d3y=dd1[16];
      double d3z=dd1[17];

      double a4x=dd2[0];
      double a4y=dd2[1];
      double a4z=dd2[2];
      double a5x=dd2[3];
      double a5y=dd2[4];
      double a5z=dd2[5];
      double a6x=dd2[6];
      double a6y=dd2[7];
      double a6z=dd2[8];
      double d4x=dd2[9];
      double d4y=dd2[10];
      double d4z=dd2[11];
      double d5x=dd2[12];
      double d5y=dd2[13];
      double d5z=dd2[14];
      double d6x=dd2[15];
      double d6y=dd2[16];
      double d6z=dd2[17];
      
      double a7x=a1y*a4z-a1z*a4y;
      double a7y=a1z*a4x-a1x*a4z;
      double a7z=a1x*a4y-a1y*a4x;
      double a8x=a1y*a5z-a1z*a5y;
      double a8y=a1z*a5x-a1x*a5z;
      double a8z=a1x*a5y-a1y*a5x;
      double a9x=a1y*a6z-a1z*a6y;
      double a9y=a1z*a6x-a1x*a6z;
      double a9z=a1x*a6y-a1y*a6x;
      double aax=a2y*a4z-a2z*a4y;
      double aay=a2z*a4x-a2x*a4z;
      double aaz=a2x*a4y-a2y*a4x;
      double abx=a2y*a5z-a2z*a5y;
      double aby=a2z*a5x-a2x*a5z;
      double abz=a2x*a5y-a2y*a5x;
      double acx=a2y*a6z-a2z*a6y;
      double acy=a2z*a6x-a2x*a6z;
      double acz=a2x*a6y-a2y*a6x;
      double adx=a3y*a4z-a3z*a4y;
      double ady=a3z*a4x-a3x*a4z;
      double adz=a3x*a4y-a3y*a4x;
      double aex=a3y*a5z-a3z*a5y;
      double aey=a3z*a5x-a3x*a5z;
      double aez=a3x*a5y-a3y*a5x;
      double afx=a3y*a6z-a3z*a6y;
      double afy=a3z*a6x-a3x*a6z;
      double afz=a3x*a6y-a3y*a6x;
      // right or left flags
      bool right1;
      bool right2;
      bool right3;
      bool right4;
      bool right5;
      bool right6;
      bool right7;
      bool right8;
      bool right9;
      bool righta;
      bool rightb;
      bool rightc;
      bool rightd;
      bool righte;
      bool rightf;
      // overlapping distances
      double overlap1;
      double overlap2;
      double overlap3;
      double overlap4;
      double overlap5;
      double overlap6;
      double overlap7;
      double overlap8;
      double overlap9;
      double overlapa;
      double overlapb;
      double overlapc;
      double overlapd;
      double overlape;
      double overlapf;
      // invalid flags
      bool invalid7=false;
      bool invalid8=false;
      bool invalid9=false;
      bool invalida=false;
      bool invalidb=false;
      bool invalidc=false;
      bool invalidd=false;
      bool invalide=false;
      bool invalidf=false;
      // temporary variables
      double len;
      double len1;
      double len2;
      double dot1;
      double dot2;
      double dot3;
      // try axis 1
      len=a1x*dx+a1y*dy+a1z*dz;
      right1=len>0;
      if(!right1)len=-len;
      len1=w1;
      dot1=a1x*a4x+a1y*a4y+a1z*a4z;
      dot2=a1x*a5x+a1y*a5y+a1z*a5z;
      dot3=a1x*a6x+a1y*a6y+a1z*a6z;
      if(dot1<0)dot1=-dot1;
      if(dot2<0)dot2=-dot2;
      if(dot3<0)dot3=-dot3;
      len2=dot1*w2+dot2*h2+dot3*d2;
      overlap1=len-len1-len2;
      if(overlap1>0)return;
      // try axis 2
      len=a2x*dx+a2y*dy+a2z*dz;
      right2=len>0;
      if(!right2)len=-len;
      len1=h1;
      dot1=a2x*a4x+a2y*a4y+a2z*a4z;
      dot2=a2x*a5x+a2y*a5y+a2z*a5z;
      dot3=a2x*a6x+a2y*a6y+a2z*a6z;
      if(dot1<0)dot1=-dot1;
      if(dot2<0)dot2=-dot2;
      if(dot3<0)dot3=-dot3;
      len2=dot1*w2+dot2*h2+dot3*d2;
      overlap2=len-len1-len2;
      if(overlap2>0)return;
      // try axis 3
      len=a3x*dx+a3y*dy+a3z*dz;
      right3=len>0;
      if(!right3)len=-len;
      len1=d1;
      dot1=a3x*a4x+a3y*a4y+a3z*a4z;
      dot2=a3x*a5x+a3y*a5y+a3z*a5z;
      dot3=a3x*a6x+a3y*a6y+a3z*a6z;
      if(dot1<0)dot1=-dot1;
      if(dot2<0)dot2=-dot2;
      if(dot3<0)dot3=-dot3;
      len2=dot1*w2+dot2*h2+dot3*d2;
      overlap3=len-len1-len2;
      if(overlap3>0)return;
      // try axis 4
      len=a4x*dx+a4y*dy+a4z*dz;
      right4=len>0;
      if(!right4)len=-len;
      dot1=a4x*a1x+a4y*a1y+a4z*a1z;
      dot2=a4x*a2x+a4y*a2y+a4z*a2z;
      dot3=a4x*a3x+a4y*a3y+a4z*a3z;
      if(dot1<0)dot1=-dot1;
      if(dot2<0)dot2=-dot2;
      if(dot3<0)dot3=-dot3;
      len1=dot1*w1+dot2*h1+dot3*d1;
      len2=w2;
      overlap4=(len-len1-len2)*1.0;
      if(overlap4>0)return;
      // try axis 5
      len=a5x*dx+a5y*dy+a5z*dz;
      right5=len>0;
      if(!right5)len=-len;
      dot1=a5x*a1x+a5y*a1y+a5z*a1z;
      dot2=a5x*a2x+a5y*a2y+a5z*a2z;
      dot3=a5x*a3x+a5y*a3y+a5z*a3z;
      if(dot1<0)dot1=-dot1;
      if(dot2<0)dot2=-dot2;
      if(dot3<0)dot3=-dot3;
      len1=dot1*w1+dot2*h1+dot3*d1;
      len2=h2;
      overlap5=(len-len1-len2)*1.0;
      if(overlap5>0)return;
      // try axis 6
      len=a6x*dx+a6y*dy+a6z*dz;
      right6=len>0;
      if(!right6)len=-len;
      dot1=a6x*a1x+a6y*a1y+a6z*a1z;
      dot2=a6x*a2x+a6y*a2y+a6z*a2z;
      dot3=a6x*a3x+a6y*a3y+a6z*a3z;
      if(dot1<0)dot1=-dot1;
      if(dot2<0)dot2=-dot2;
      if(dot3<0)dot3=-dot3;
      len1=dot1*w1+dot2*h1+dot3*d1;
      len2=d2;
      overlap6=(len-len1-len2)*1.0;
      if(overlap6>0)return;
      // try axis 7
      len=a7x*a7x+a7y*a7y+a7z*a7z;
      if(len>1e-5){
        len=1/math.sqrt(len);
        a7x*=len;
        a7y*=len;
        a7z*=len;
        len=a7x*dx+a7y*dy+a7z*dz;
        right7=len>0;
        if(!right7)len=-len;
        dot1=a7x*a2x+a7y*a2y+a7z*a2z;
        dot2=a7x*a3x+a7y*a3y+a7z*a3z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*h1+dot2*d1;
        dot1=a7x*a5x+a7y*a5y+a7z*a5z;
        dot2=a7x*a6x+a7y*a6y+a7z*a6z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*h2+dot2*d2;
        overlap7=len-len1-len2;
        if(overlap7>0)return;
      }
      else{
        right7=false;
        overlap7=0;
        invalid7=true;
      }
      // try axis 8
      len=a8x*a8x+a8y*a8y+a8z*a8z;
      if(len>1e-5){
        len=1/math.sqrt(len);
        a8x*=len;
        a8y*=len;
        a8z*=len;
        len=a8x*dx+a8y*dy+a8z*dz;
        right8=len>0;
        if(!right8)len=-len;
        dot1=a8x*a2x+a8y*a2y+a8z*a2z;
        dot2=a8x*a3x+a8y*a3y+a8z*a3z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*h1+dot2*d1;
        dot1=a8x*a4x+a8y*a4y+a8z*a4z;
        dot2=a8x*a6x+a8y*a6y+a8z*a6z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*w2+dot2*d2;
        overlap8=len-len1-len2;
        if(overlap8>0)return;
      }
      else{
        right8=false;
        overlap8=0;
        invalid8=true;
      }
      // try axis 9
      len=a9x*a9x+a9y*a9y+a9z*a9z;
      if(len>1e-5){
        len=1/math.sqrt(len);
        a9x*=len;
        a9y*=len;
        a9z*=len;
        len=a9x*dx+a9y*dy+a9z*dz;
        right9=len>0;
        if(!right9)len=-len;
        dot1=a9x*a2x+a9y*a2y+a9z*a2z;
        dot2=a9x*a3x+a9y*a3y+a9z*a3z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*h1+dot2*d1;
        dot1=a9x*a4x+a9y*a4y+a9z*a4z;
        dot2=a9x*a5x+a9y*a5y+a9z*a5z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*w2+dot2*h2;
        overlap9=len-len1-len2;
        if(overlap9>0)return;
      }
      else{
        right9=false;
        overlap9=0;
        invalid9=true;
      }
      // try axis 10
      len=aax*aax+aay*aay+aaz*aaz;
      if(len>1e-5){
        len=1/math.sqrt(len);
        aax*=len;
        aay*=len;
        aaz*=len;
        len=aax*dx+aay*dy+aaz*dz;
        righta=len>0;
        if(!righta)len=-len;
        dot1=aax*a1x+aay*a1y+aaz*a1z;
        dot2=aax*a3x+aay*a3y+aaz*a3z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*w1+dot2*d1;
        dot1=aax*a5x+aay*a5y+aaz*a5z;
        dot2=aax*a6x+aay*a6y+aaz*a6z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*h2+dot2*d2;
        overlapa=len-len1-len2;
        if(overlapa>0)return;
      }
      else{
        righta=false;
        overlapa=0;
        invalida=true;
      }
      // try axis 11
      len=abx*abx+aby*aby+abz*abz;
      if(len>1e-5){
        len=1/math.sqrt(len);
        abx*=len;
        aby*=len;
        abz*=len;
        len=abx*dx+aby*dy+abz*dz;
        rightb=len>0;
        if(!rightb)len=-len;
        dot1=abx*a1x+aby*a1y+abz*a1z;
        dot2=abx*a3x+aby*a3y+abz*a3z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*w1+dot2*d1;
        dot1=abx*a4x+aby*a4y+abz*a4z;
        dot2=abx*a6x+aby*a6y+abz*a6z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*w2+dot2*d2;
        overlapb=len-len1-len2;
        if(overlapb>0)return;
      }
      else{
        rightb=false;
        overlapb=0;
        invalidb=true;
      }
      // try axis 12
      len=acx*acx+acy*acy+acz*acz;
      if(len>1e-5){
        len=1/math.sqrt(len);
        acx*=len;
        acy*=len;
        acz*=len;
        len=acx*dx+acy*dy+acz*dz;
        rightc=len>0;
        if(!rightc)len=-len;
        dot1=acx*a1x+acy*a1y+acz*a1z;
        dot2=acx*a3x+acy*a3y+acz*a3z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*w1+dot2*d1;
        dot1=acx*a4x+acy*a4y+acz*a4z;
        dot2=acx*a5x+acy*a5y+acz*a5z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*w2+dot2*h2;
        overlapc=len-len1-len2;
        if(overlapc>0)return;
      }
      else{
        rightc=false;
        overlapc=0;
        invalidc=true;
      }
      // try axis 13
      len=adx*adx+ady*ady+adz*adz;
      if(len>1e-5){
        len=1/math.sqrt(len);
        adx*=len;
        ady*=len;
        adz*=len;
        len=adx*dx+ady*dy+adz*dz;
        rightd=len>0;
        if(!rightd)len=-len;
        dot1=adx*a1x+ady*a1y+adz*a1z;
        dot2=adx*a2x+ady*a2y+adz*a2z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*w1+dot2*h1;
        dot1=adx*a5x+ady*a5y+adz*a5z;
        dot2=adx*a6x+ady*a6y+adz*a6z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*h2+dot2*d2;
        overlapd=len-len1-len2;
        if(overlapd>0)return;
      }
      else{
        rightd=false;
        overlapd=0;
        invalidd=true;
      }
      // try axis 14
      len=aex*aex+aey*aey+aez*aez;
      if(len>1e-5){
        len=1/math.sqrt(len);
        aex*=len;
        aey*=len;
        aez*=len;
        len=aex*dx+aey*dy+aez*dz;
        righte=len>0;
        if(!righte)len=-len;
        dot1=aex*a1x+aey*a1y+aez*a1z;
        dot2=aex*a2x+aey*a2y+aez*a2z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*w1+dot2*h1;
        dot1=aex*a4x+aey*a4y+aez*a4z;
        dot2=aex*a6x+aey*a6y+aez*a6z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*w2+dot2*d2;
        overlape=len-len1-len2;
        if(overlape>0)return;
      }
      else{
        righte=false;
        overlape=0;
        invalide=true;
      }
      // try axis 15
      len=afx*afx+afy*afy+afz*afz;
      if(len>1e-5){
        len=1/math.sqrt(len);
        afx*=len;
        afy*=len;
        afz*=len;
        len=afx*dx+afy*dy+afz*dz;
        rightf=len>0;
        if(!rightf)len=-len;
        dot1=afx*a1x+afy*a1y+afz*a1z;
        dot2=afx*a2x+afy*a2y+afz*a2z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len1=dot1*w1+dot2*h1;
        dot1=afx*a4x+afy*a4y+afz*a4z;
        dot2=afx*a5x+afy*a5y+afz*a5z;
        if(dot1<0)dot1=-dot1;
        if(dot2<0)dot2=-dot2;
        len2=dot1*w2+dot2*h2;
        overlapf=len-len1-len2;
        if(overlapf>0)return;
      }
      else{
        rightf=false;
        overlapf=0;
        invalidf=true;
      }
      // boxes are overlapping
      double depth=overlap1;
      double depth2=overlap1;
      int minIndex=0;
      bool right=right1;
      if(overlap2>depth2){
        depth=overlap2;
        depth2=overlap2;
        minIndex=1;
        right=right2;
      }
      if(overlap3>depth2){
        depth=overlap3;
        depth2=overlap3;
        minIndex=2;
        right=right3;
      }
      if(overlap4>depth2){
        depth=overlap4;
        depth2=overlap4;
        minIndex=3;
        right=right4;
      }
      if(overlap5>depth2){
        depth=overlap5;
        depth2=overlap5;
        minIndex=4;
        right=right5;
      }
      if(overlap6>depth2){
        depth=overlap6;
        depth2=overlap6;
        minIndex=5;
        right=right6;
      }
      if(overlap7-0.01>depth2&&!invalid7){
        depth=overlap7;
        depth2=overlap7-0.01;
        minIndex=6;
        right=right7;
      }
      if(overlap8-0.01>depth2&&!invalid8){
        depth=overlap8;
        depth2=overlap8-0.01;
        minIndex=7;
        right=right8;
      }
      if(overlap9-0.01>depth2&&!invalid9){
        depth=overlap9;
        depth2=overlap9-0.01;
        minIndex=8;
        right=right9;
      }
      if(overlapa-0.01>depth2&&!invalida){
        depth=overlapa;
        depth2=overlapa-0.01;
        minIndex=9;
        right=righta;
      }
      if(overlapb-0.01>depth2&&!invalidb){
        depth=overlapb;
        depth2=overlapb-0.01;
        minIndex=10;
        right=rightb;
      }
      if(overlapc-0.01>depth2&&!invalidc){
        depth=overlapc;
        depth2=overlapc-0.01;
        minIndex=11;
        right=rightc;
      }
      if(overlapd-0.01>depth2&&!invalidd){
        depth=overlapd;
        depth2=overlapd-0.01;
        minIndex=12;
        right=rightd;
      }
      if(overlape-0.01>depth2&&!invalide){
        depth=overlape;
        depth2=overlape-0.01;
        minIndex=13;
        right=righte;
      }
      if(overlapf-0.01>depth2&&!invalidf){
        depth=overlapf;
        minIndex=14;
        right=rightf;
      }
      // normal
      double nx=0;
      double ny=0;
      double nz=0;
      // edge line or face side normal
      double n1x=0;
      double n1y=0;
      double n1z=0;
      double n2x=0;
      double n2y=0;
      double n2z=0;
      // center of current face
      double cx=0;
      double cy=0;
      double cz=0;
      // face side
      double s1x=0;
      double s1y=0;
      double s1z=0;
      double s2x=0;
      double s2y=0;
      double s2z=0;
      // swap b1 b2
      bool swap=false;

      //_______________________________________

      if(minIndex==0){// b1.x * b2
        if(right){
          cx=p1x+d1x; cy=p1y+d1y;  cz=p1z+d1z;
          nx=a1x; ny=a1y; nz=a1z;
        }
        else{
          cx=p1x-d1x; cy=p1y-d1y; cz=p1z-d1z;
          nx=-a1x; ny=-a1y; nz=-a1z;
        }
        s1x=d2x; s1y=d2y; s1z=d2z;
        n1x=-a2x; n1y=-a2y; n1z=-a2z;
        s2x=d3x; s2y=d3y; s2z=d3z;
        n2x=-a3x; n2y=-a3y; n2z=-a3z;
      }
      else if(minIndex==1){// b1.y * b2
        if(right){
          cx=p1x+d2x; cy=p1y+d2y; cz=p1z+d2z;
          nx=a2x; ny=a2y; nz=a2z;
        }
        else{
          cx=p1x-d2x; cy=p1y-d2y; cz=p1z-d2z;
          nx=-a2x; ny=-a2y; nz=-a2z;
        }
        s1x=d1x; s1y=d1y; s1z=d1z;
        n1x=-a1x; n1y=-a1y; n1z=-a1z;
        s2x=d3x; s2y=d3y; s2z=d3z;
        n2x=-a3x; n2y=-a3y; n2z=-a3z;
      }
      else if(minIndex==2){// b1.z * b2
        if(right){
          cx=p1x+d3x; cy=p1y+d3y; cz=p1z+d3z;
          nx=a3x; ny=a3y; nz=a3z;
        }
        else{
          cx=p1x-d3x; cy=p1y-d3y; cz=p1z-d3z;
          nx=-a3x; ny=-a3y; nz=-a3z;
        }
        s1x=d1x; s1y=d1y; s1z=d1z;
        n1x=-a1x; n1y=-a1y; n1z=-a1z;
        s2x=d2x; s2y=d2y; s2z=d2z;
        n2x=-a2x; n2y=-a2y; n2z=-a2z;
      }
      else if(minIndex==3){// b2.x * b1
        swap=true;
        if(!right){
          cx=p2x+d4x; cy=p2y+d4y; cz=p2z+d4z;
          nx=a4x; ny=a4y; nz=a4z;
        }
        else{
          cx=p2x-d4x; cy=p2y-d4y; cz=p2z-d4z;
          nx=-a4x; ny=-a4y; nz=-a4z;
        }
        s1x=d5x; s1y=d5y; s1z=d5z;
        n1x=-a5x; n1y=-a5y; n1z=-a5z;
        s2x=d6x; s2y=d6y; s2z=d6z;
        n2x=-a6x; n2y=-a6y; n2z=-a6z;
      }
      else if(minIndex==4){// b2.y * b1
        swap=true;
        if(!right){
          cx=p2x+d5x; cy=p2y+d5y; cz=p2z+d5z;
          nx=a5x; ny=a5y; nz=a5z;
        }
        else{
          cx=p2x-d5x; cy=p2y-d5y; cz=p2z-d5z;
          nx=-a5x; ny=-a5y; nz=-a5z;
        }
        s1x=d4x; s1y=d4y; s1z=d4z;
        n1x=-a4x; n1y=-a4y; n1z=-a4z;
        s2x=d6x; s2y=d6y; s2z=d6z;
        n2x=-a6x; n2y=-a6y; n2z=-a6z;
      }
      else if(minIndex==5){// b2.z * b1
        swap=true;
        if(!right){
          cx=p2x+d6x; cy=p2y+d6y; cz=p2z+d6z;
          nx=a6x; ny=a6y; nz=a6z;
        }
        else{
          cx=p2x-d6x; cy=p2y-d6y; cz=p2z-d6z;
          nx=-a6x; ny=-a6y; nz=-a6z;
        }
        s1x=d4x; s1y=d4y; s1z=d4z;
        n1x=-a4x; n1y=-a4y; n1z=-a4z;
        s2x=d5x; s2y=d5y; s2z=d5z;
        n2x=-a5x; n2y=-a5y; n2z=-a5z;
      }
      else if(minIndex==6){// b1.x * b2.x
        nx=a7x; ny=a7y; nz=a7z;
        n1x=a1x; n1y=a1y; n1z=a1z;
        n2x=a4x; n2y=a4y; n2z=a4z;
      }
      else if(minIndex==7){// b1.x * b2.y
        nx=a8x; ny=a8y; nz=a8z;
        n1x=a1x; n1y=a1y; n1z=a1z;
        n2x=a5x; n2y=a5y; n2z=a5z;
      }
      else if(minIndex==8){// b1.x * b2.z
        nx=a9x; ny=a9y; nz=a9z;
        n1x=a1x; n1y=a1y; n1z=a1z;
        n2x=a6x; n2y=a6y; n2z=a6z;
      }
      else if(minIndex==9){// b1.y * b2.x
        nx=aax; ny=aay; nz=aaz;
        n1x=a2x; n1y=a2y; n1z=a2z;
        n2x=a4x; n2y=a4y; n2z=a4z;
      }
      else if(minIndex==10){// b1.y * b2.y
        nx=abx; ny=aby; nz=abz;
        n1x=a2x; n1y=a2y; n1z=a2z;
        n2x=a5x; n2y=a5y; n2z=a5z;
      }
      else if(minIndex==11){// b1.y * b2.z
        nx=acx; ny=acy; nz=acz;
        n1x=a2x; n1y=a2y; n1z=a2z;
        n2x=a6x; n2y=a6y; n2z=a6z;
      }
      else if(minIndex==12){// b1.z * b2.x
        nx=adx;  ny=ady; nz=adz;
        n1x=a3x; n1y=a3y; n1z=a3z;
        n2x=a4x; n2y=a4y; n2z=a4z;
      }
      else if(minIndex==13){// b1.z * b2.y
        nx=aex; ny=aey; nz=aez;
        n1x=a3x; n1y=a3y; n1z=a3z;
        n2x=a5x; n2y=a5y; n2z=a5z;
      }
      else if(minIndex==14){// b1.z * b2.z
        nx=afx; ny=afy; nz=afz;
        n1x=a3x; n1y=a3y; n1z=a3z;
        n2x=a6x; n2y=a6y; n2z=a6z;
      }

      //__________________________________________

      //double v;
      if(minIndex>5){
        if(!right){
          nx=-nx; ny=-ny; nz=-nz;
        }
        double distance;
        double maxDistance;
        double vx;
        double vy;
        double vz;
        double v1x;
        double v1y;
        double v1z;
        double v2x;
        double v2y;
        double v2z;
        //vertex1;
        v1x=vv1[0]; v1y=vv1[1]; v1z=vv1[2];
        maxDistance=nx*v1x+ny*v1y+nz*v1z;
        //vertex2;
        vx=vv1[3]; vy=vv1[4]; vz=vv1[5];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance>maxDistance){
          maxDistance=distance;
          v1x=vx; v1y=vy; v1z=vz;
        }
        //vertex3;
        vx=vv1[6]; vy=vv1[7]; vz=vv1[8];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance>maxDistance){
          maxDistance=distance;
          v1x=vx; v1y=vy; v1z=vz;
        }
        //vertex4;
        vx=vv1[9]; vy=vv1[10]; vz=vv1[11];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance>maxDistance){
          maxDistance=distance;
          v1x=vx; v1y=vy; v1z=vz;
        }
        //vertex5;
        vx=vv1[12]; vy=vv1[13]; vz=vv1[14];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance>maxDistance){
          maxDistance=distance;
          v1x=vx; v1y=vy; v1z=vz;
        }
        //vertex6;
        vx=vv1[15]; vy=vv1[16]; vz=vv1[17];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance>maxDistance){
          maxDistance=distance;
          v1x=vx; v1y=vy; v1z=vz;
        }
        //vertex7;
        vx=vv1[18]; vy=vv1[19]; vz=vv1[20];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance>maxDistance){
          maxDistance=distance;
          v1x=vx; v1y=vy; v1z=vz;
        }
        //vertex8;
        vx=vv1[21]; vy=vv1[22]; vz=vv1[23];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance>maxDistance){
          maxDistance=distance;
          v1x=vx; v1y=vy; v1z=vz;
        }
        //vertex1;
        v2x=vv2[0]; v2y=vv2[1]; v2z=vv2[2];
        maxDistance=nx*v2x+ny*v2y+nz*v2z;
        //vertex2;
        vx=vv2[3]; vy=vv2[4]; vz=vv2[5];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance<maxDistance){
          maxDistance=distance;
          v2x=vx; v2y=vy; v2z=vz;
        }
        //vertex3;
        vx=vv2[6]; vy=vv2[7]; vz=vv2[8];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance<maxDistance){
          maxDistance=distance;
          v2x=vx; v2y=vy; v2z=vz;
        }
        //vertex4;
        vx=vv2[9]; vy=vv2[10]; vz=vv2[11];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance<maxDistance){
          maxDistance=distance;
          v2x=vx; v2y=vy; v2z=vz;
        }
        //vertex5;
        vx=vv2[12]; vy=vv2[13]; vz=vv2[14];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance<maxDistance){
          maxDistance=distance;
          v2x=vx; v2y=vy; v2z=vz;
        }
        //vertex6;
        vx=vv2[15]; vy=vv2[16]; vz=vv2[17];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance<maxDistance){
          maxDistance=distance;
          v2x=vx; v2y=vy; v2z=vz;
        }
        //vertex7;
        vx=vv2[18]; vy=vv2[19]; vz=vv2[20];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance<maxDistance){
          maxDistance=distance;
          v2x=vx; v2y=vy; v2z=vz;
        }
        //vertex8;
        vx=vv2[21]; vy=vv2[22]; vz=vv2[23];
        distance=nx*vx+ny*vy+nz*vz;
        if(distance<maxDistance){
          maxDistance=distance;
          v2x=vx; v2y=vy; v2z=vz;
        }
        vx=v2x-v1x; vy=v2y-v1y; vz=v2z-v1z;
        dot1=n1x*n2x+n1y*n2y+n1z*n2z;
        double t=(vx*(n1x-n2x*dot1)+vy*(n1y-n2y*dot1)+vz*(n1z-n2z*dot1))/(1-dot1*dot1);
        manifold.addPoint(v1x+n1x*t+nx*depth*0.5,v1y+n1y*t+ny*depth*0.5,v1z+n1z*t+nz*depth*0.5,nx.toDouble(),ny.toDouble(),nz.toDouble(),depth,false);
        return;
      }
      // now detect face-face collision...
      // target quad
      late double q1x;
      late double q1y;
      late double q1z;
      late double q2x;
      late double q2y;
      late double q2z;
      late double q3x;
      late double q3y;
      late double q3z;
      late double q4x;
      late double q4y;
      late double q4z;
      // search support face and vertex
      double minDot=1;
      double dot=0;
      double minDotIndex=0;

      if(swap){
        dot=a1x*nx+a1y*ny+a1z*nz;
        if(dot<minDot){
          minDot=dot;
          minDotIndex=0;
        }
        if(-dot<minDot){
          minDot=-dot;
          minDotIndex=1;
        }
        dot=a2x*nx+a2y*ny+a2z*nz;
        if(dot<minDot){
          minDot=dot;
          minDotIndex=2;
        }
        if(-dot<minDot){
          minDot=-dot;
          minDotIndex=3;
        }
        dot=a3x*nx+a3y*ny+a3z*nz;
        if(dot<minDot){
          minDot=dot;
          minDotIndex=4;
        }
        if(-dot<minDot){
          minDot=-dot;
          minDotIndex=5;
        }

        if(minDotIndex==0){// x+ face
          q1x=vv1[0]; q1y=vv1[1]; q1z=vv1[2];//vertex1
          q2x=vv1[6]; q2y=vv1[7]; q2z=vv1[8];//vertex3
          q3x=vv1[9]; q3y=vv1[10]; q3z=vv1[11];//vertex4
          q4x=vv1[3]; q4y=vv1[4]; q4z=vv1[5];//vertex2
        }
        else if(minDotIndex==1){// x- face
          q1x=vv1[15]; q1y=vv1[16]; q1z=vv1[17];//vertex6
          q2x=vv1[21]; q2y=vv1[22]; q2z=vv1[23];//vertex8
          q3x=vv1[18]; q3y=vv1[19]; q3z=vv1[20];//vertex7
          q4x=vv1[12]; q4y=vv1[13]; q4z=vv1[14];//vertex5
        }
        else if(minDotIndex==2){// y+ face
          q1x=vv1[12]; q1y=vv1[13]; q1z=vv1[14];//vertex5
          q2x=vv1[0]; q2y=vv1[1]; q2z=vv1[2];//vertex1
          q3x=vv1[3]; q3y=vv1[4]; q3z=vv1[5];//vertex2
          q4x=vv1[15]; q4y=vv1[16]; q4z=vv1[17];//vertex6
        }
        else if(minDotIndex==3){// y- face
          q1x=vv1[21]; q1y=vv1[22]; q1z=vv1[23];//vertex8
          q2x=vv1[9]; q2y=vv1[10]; q2z=vv1[11];//vertex4
          q3x=vv1[6]; q3y=vv1[7]; q3z=vv1[8];//vertex3
          q4x=vv1[18]; q4y=vv1[19]; q4z=vv1[20];//vertex7
        }
        else if(minDotIndex==4){// z+ face
          q1x=vv1[12]; q1y=vv1[13]; q1z=vv1[14];//vertex5
          q2x=vv1[18]; q2y=vv1[19]; q2z=vv1[20];//vertex7
          q3x=vv1[6]; q3y=vv1[7]; q3z=vv1[8];//vertex3
          q4x=vv1[0]; q4y=vv1[1]; q4z=vv1[2];//vertex1
        }
        else if(minDotIndex==5){// z- face
          q1x=vv1[3]; q1y=vv1[4]; q1z=vv1[5];//vertex2
          q2x=vv1[6]; q2y=vv1[7]; q2z=vv1[8];//vertex4 !!!
          //q2x=vv2[9]; q2y=vv2[10]; q2z=vv2[11];//vertex4
          q3x=vv1[21]; q3y=vv1[22]; q3z=vv1[23];//vertex8
          q4x=vv1[15]; q4y=vv1[16]; q4z=vv1[17];//vertex6
        }
      }
      else{
        dot=a4x*nx+a4y*ny+a4z*nz;
        if(dot<minDot){
            minDot=dot;
            minDotIndex=0;
        }
        if(-dot<minDot){
            minDot=-dot;
            minDotIndex=1;
        }
        dot=a5x*nx+a5y*ny+a5z*nz;
        if(dot<minDot){
            minDot=dot;
            minDotIndex=2;
        }
        if(-dot<minDot){
            minDot=-dot;
            minDotIndex=3;
        }
        dot=a6x*nx+a6y*ny+a6z*nz;
        if(dot<minDot){
            minDot=dot;
            minDotIndex=4;
        }
        if(-dot<minDot){
            minDot=-dot;
            minDotIndex=5;
        }

        //______________________________________________________

        if(minDotIndex==0){// x+ face
          q1x=vv2[0]; q1y=vv2[1]; q1z=vv2[2];//vertex1
          q2x=vv2[6]; q2y=vv2[7]; q2z=vv2[8];//vertex3
          q3x=vv2[9]; q3y=vv2[10]; q3z=vv2[11];//vertex4
          q4x=vv2[3]; q4y=vv2[4]; q4z=vv2[5];//vertex2
        }
        else if(minDotIndex==1){// x- face
          q1x=vv2[15]; q1y=vv2[16]; q1z=vv2[17];//vertex6
          q2x=vv2[21]; q2y=vv2[22]; q2z=vv2[23]; //vertex8
          q3x=vv2[18]; q3y=vv2[19]; q3z=vv2[20];//vertex7
          q4x=vv2[12]; q4y=vv2[13]; q4z=vv2[14];//vertex5
        }
        else if(minDotIndex==2){// y+ face
          q1x=vv2[12]; q1y=vv2[13]; q1z=vv2[14];//vertex5
          q2x=vv2[0]; q2y=vv2[1]; q2z=vv2[2];//vertex1
          q3x=vv2[3]; q3y=vv2[4]; q3z=vv2[5];//vertex2
          q4x=vv2[15]; q4y=vv2[16]; q4z=vv2[17];//vertex6
        }
        else if(minDotIndex==3){// y- face
          q1x=vv2[21]; q1y=vv2[22]; q1z=vv2[23];//vertex8
          q2x=vv2[9]; q2y=vv2[10]; q2z=vv2[11];//vertex4
          q3x=vv2[6]; q3y=vv2[7]; q3z=vv2[8];//vertex3
          q4x=vv2[18]; q4y=vv2[19]; q4z=vv2[20];//vertex7
        }
      else if(minDotIndex==4){// z+ face
          q1x=vv2[12]; q1y=vv2[13]; q1z=vv2[14];//vertex5
          q2x=vv2[18]; q2y=vv2[19]; q2z=vv2[20];//vertex7
          q3x=vv2[6]; q3y=vv2[7]; q3z=vv2[8];//vertex3
          q4x=vv2[0]; q4y=vv2[1]; q4z=vv2[2];//vertex1
        }
        else if(minDotIndex==5){// z- face
          q1x=vv2[3]; q1y=vv2[4]; q1z=vv2[5];//vertex2
          q2x=vv2[9]; q2y=vv2[10]; q2z=vv2[11];//vertex4
          q3x=vv2[21]; q3y=vv2[22]; q3z=vv2[23];//vertex8
          q4x=vv2[15]; q4y=vv2[16]; q4z=vv2[17];//vertex6
        }
      }
      // clip vertices
      int numClipVertices;
      int numAddedClipVertices;
      int index;
      double x1;
      double y1;
      double z1;
      double x2;
      double y2;
      double z2;

      clipVertices1[0]=q1x;
      clipVertices1[1]=q1y;
      clipVertices1[2]=q1z;
      clipVertices1[3]=q2x;
      clipVertices1[4]=q2y;
      clipVertices1[5]=q2z;
      clipVertices1[6]=q3x;
      clipVertices1[7]=q3y;
      clipVertices1[8]=q3z;
      clipVertices1[9]=q4x;
      clipVertices1[10]=q4y;
      clipVertices1[11]=q4z;

      numAddedClipVertices=0;

      x1=clipVertices1[9];
      y1=clipVertices1[10];
      z1=clipVertices1[11];

      dot1=(x1-cx-s1x)*n1x+(y1-cy-s1y)*n1y+(z1-cz-s1z)*n1z;

      double t;

      //double i = 4;
      //while(i--){
      for(int i=3;i>=0;i--){
        index=i*3;
        x2=clipVertices1[index];
        y2=clipVertices1[index+1];
        z2=clipVertices1[index+2];
        dot2=(x2-cx-s1x)*n1x+(y2-cy-s1y)*n1y+(z2-cz-s1z)*n1z;
        if(dot1>0){
          if(dot2>0){
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            clipVertices2[index]=x2;
            clipVertices2[index+1]=y2;
            clipVertices2[index+2]=z2;
          }
          else{
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            t=dot1/(dot1-dot2);
            clipVertices2[index]=x1+(x2-x1)*t;
            clipVertices2[index+1]=y1+(y2-y1)*t;
            clipVertices2[index+2]=z1+(z2-z1)*t;
          }
        }
        else{
          if(dot2>0){
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            t=dot1/(dot1-dot2);
            clipVertices2[index]=x1+(x2-x1)*t;
            clipVertices2[index+1]=y1+(y2-y1)*t;
            clipVertices2[index+2]=z1+(z2-z1)*t;
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            clipVertices2[index]=x2;
            clipVertices2[index+1]=y2;
            clipVertices2[index+2]=z2;
          }
        }
        x1=x2;
        y1=y2;
        z1=z2;
        dot1=dot2;
      }

      numClipVertices=numAddedClipVertices;
      if(numClipVertices==0)return;
      numAddedClipVertices=0;
      index=(numClipVertices-1)*3;
      x1=clipVertices2[index];
      y1=clipVertices2[index+1];
      z1=clipVertices2[index+2];
      dot1=(x1-cx-s2x)*n2x+(y1-cy-s2y)*n2y+(z1-cz-s2z)*n2z;

      //i = numClipVertices;
      //while(i--){
      for(int i=numClipVertices-1;i>=0;i--){
        index=i*3;
        x2=clipVertices2[index];
        y2=clipVertices2[index+1];
        z2=clipVertices2[index+2];
        dot2=(x2-cx-s2x)*n2x+(y2-cy-s2y)*n2y+(z2-cz-s2z)*n2z;
        if(dot1>0){
          if(dot2>0){
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            clipVertices1[index]=x2;
            clipVertices1[index+1]=y2;
            clipVertices1[index+2]=z2;
          }
          else{
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            t=dot1/(dot1-dot2);
            clipVertices1[index]=x1+(x2-x1)*t;
            clipVertices1[index+1]=y1+(y2-y1)*t;
            clipVertices1[index+2]=z1+(z2-z1)*t;
          }
        }
        else{
          if(dot2>0){
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            t=dot1/(dot1-dot2);
            clipVertices1[index]=x1+(x2-x1)*t;
            clipVertices1[index+1]=y1+(y2-y1)*t;
            clipVertices1[index+2]=z1+(z2-z1)*t;
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            clipVertices1[index]=x2;
            clipVertices1[index+1]=y2;
            clipVertices1[index+2]=z2;
          }
        }
        x1=x2;
        y1=y2;
        z1=z2;
        dot1=dot2;
      }

      numClipVertices=numAddedClipVertices;
      if(numClipVertices==0)return;
      numAddedClipVertices=0;
      index=(numClipVertices-1)*3;
      x1=clipVertices1[index];
      y1=clipVertices1[index+1];
      z1=clipVertices1[index+2];
      dot1=(x1-cx+s1x)*-n1x+(y1-cy+s1y)*-n1y+(z1-cz+s1z)*-n1z;

      //i = numClipVertices;
      //while(i--){
      for(int i=numClipVertices-1;i>=0;i--){
        index=i*3;
        x2=clipVertices1[index];
        y2=clipVertices1[index+1];
        z2=clipVertices1[index+2];
        dot2=(x2-cx+s1x)*-n1x+(y2-cy+s1y)*-n1y+(z2-cz+s1z)*-n1z;
        if(dot1>0){
          if(dot2>0){
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            clipVertices2[index]=x2;
            clipVertices2[index+1]=y2;
            clipVertices2[index+2]=z2;
          }
          else{
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            t=dot1/(dot1-dot2);
            clipVertices2[index]=x1+(x2-x1)*t;
            clipVertices2[index+1]=y1+(y2-y1)*t;
            clipVertices2[index+2]=z1+(z2-z1)*t;
          }
        }
        else{
          if(dot2>0){
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            t=dot1/(dot1-dot2);
            clipVertices2[index]=x1+(x2-x1)*t;
            clipVertices2[index+1]=y1+(y2-y1)*t;
            clipVertices2[index+2]=z1+(z2-z1)*t;
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            clipVertices2[index]=x2;
            clipVertices2[index+1]=y2;
            clipVertices2[index+2]=z2;
          }
        }
        x1=x2;
        y1=y2;
        z1=z2;
        dot1=dot2;
      }

      numClipVertices=numAddedClipVertices;
      if(numClipVertices==0)return;
      numAddedClipVertices=0;
      index=(numClipVertices-1)*3;
      x1=clipVertices2[index];
      y1=clipVertices2[index+1];
      z1=clipVertices2[index+2];
      dot1=(x1-cx+s2x)*-n2x+(y1-cy+s2y)*-n2y+(z1-cz+s2z)*-n2z;

      //i = numClipVertices;
      //while(i--){
      for(int i=numClipVertices-1;i>=0;i--){
        index=i*3;
        x2=clipVertices2[index];
        y2=clipVertices2[index+1];
        z2=clipVertices2[index+2];
        dot2=(x2-cx+s2x)*-n2x+(y2-cy+s2y)*-n2y+(z2-cz+s2z)*-n2z;
        if(dot1>0){
          if(dot2>0){
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            clipVertices1[index]=x2;
            clipVertices1[index+1]=y2;
            clipVertices1[index+2]=z2;
          }
          else{
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            t=dot1/(dot1-dot2);
            clipVertices1[index]=x1+(x2-x1)*t;
            clipVertices1[index+1]=y1+(y2-y1)*t;
            clipVertices1[index+2]=z1+(z2-z1)*t;
          }
        }
        else{
          if(dot2>0){
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            t=dot1/(dot1-dot2);
            clipVertices1[index]=x1+(x2-x1)*t;
            clipVertices1[index+1]=y1+(y2-y1)*t;
            clipVertices1[index+2]=z1+(z2-z1)*t;
            index=numAddedClipVertices*3;
            numAddedClipVertices++;
            clipVertices1[index]=x2;
            clipVertices1[index+1]=y2;
            clipVertices1[index+2]=z2;
          }
        }
        x1=x2;
        y1=y2;
        z1=z2;
        dot1=dot2;
      }

    numClipVertices=numAddedClipVertices;
    if(swap){
      Box tb=b1;
      b1=b2;
      b2=tb;
    }
    if(numClipVertices==0)return;
    bool flipped=b1!=shape1;

    if(numClipVertices>4){
      x1=(q1x+q2x+q3x+q4x)*0.25;
      y1=(q1y+q2y+q3y+q4y)*0.25;
      z1=(q1z+q2z+q3z+q4z)*0.25;
      n1x=q1x-x1;
      n1y=q1y-y1;
      n1z=q1z-z1;
      n2x=q2x-x1;
      n2y=q2y-y1;
      n2z=q2z-z1;

      int index1=0;
      int index2=0;
      int index3=0;
      int index4=0;

      double maxDot=-inf;
      double minDot=inf;

      //i = numClipVertices;
      //while(i--){
      for(int i=numClipVertices-1;i>=0;i--){
        used[i]=false;
        index=i*3;
        x1=clipVertices1[index];
        y1=clipVertices1[index+1];
        z1=clipVertices1[index+2];
        dot=x1*n1x+y1*n1y+z1*n1z;
        if(dot<minDot){
            minDot=dot;
            index1=i;
        }
        if(dot>maxDot){
          maxDot=dot;
          index3=i;
        }
      }

      used[index1]=true;
      used[index3]=true;
      maxDot=-inf;
      minDot=inf;

      //i = numClipVertices;
      //while(i--){
      for(int i=numClipVertices-1;i>=0;i--){
        if(used[i])continue;
        index=i*3;
        x1=clipVertices1[index];
        y1=clipVertices1[index+1];
        z1=clipVertices1[index+2];
        dot=x1*n2x+y1*n2y+z1*n2z;
        if(dot<minDot){
          minDot=dot;
          index2=i;
        }
        if(dot>maxDot){
          maxDot=dot;
          index4=i;
        }
      }

      index=index1*3;
      x1=clipVertices1[index];
      y1=clipVertices1[index+1];
      z1=clipVertices1[index+2];
      dot=(x1-cx)*nx+(y1-cy)*ny+(z1-cz)*nz;
      if(dot<0) manifold.addPoint(x1,y1,z1,nx,ny,nz,dot,flipped);
      
      index=index2*3;
      x1=clipVertices1[index];
      y1=clipVertices1[index+1];
      z1=clipVertices1[index+2];
      dot=(x1-cx)*nx+(y1-cy)*ny+(z1-cz)*nz;
      if(dot<0) manifold.addPoint(x1,y1,z1,nx,ny,nz,dot,flipped);
      
      index=index3*3;
      x1=clipVertices1[index];
      y1=clipVertices1[index+1];
      z1=clipVertices1[index+2];
      dot=(x1-cx)*nx+(y1-cy)*ny+(z1-cz)*nz;
      if(dot<0) manifold.addPoint(x1,y1,z1,nx,ny,nz,dot,flipped);
      
      index=index4*3;
      x1=clipVertices1[index];
      y1=clipVertices1[index+1];
      z1=clipVertices1[index+2];
      dot=(x1-cx)*nx+(y1-cy)*ny+(z1-cz)*nz;
      if(dot<0) manifold.addPoint(x1,y1,z1,nx,ny,nz,dot,flipped);
    }
    else{
      //i = numClipVertices;
      //while(i--){
      for(int i=numClipVertices-1;i>=0;i--){
        index=i*3;
        x1=clipVertices1[index];
        y1=clipVertices1[index+1];
        z1=clipVertices1[index+2];
        dot=(x1-cx)*nx+(y1-cy)*ny+(z1-cz)*nz;
        if(dot<0)manifold.addPoint(x1,y1,z1,nx,ny,nz,dot,flipped);
      }
    }
  }
}