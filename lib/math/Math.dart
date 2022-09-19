import 'dart:math' as math;
import 'Vec3.dart';

class Math {
  static double degtorad = 0.0174532925199432957;
  static double radtodeg = 57.295779513082320876;
  static double PI       = 3.141592653589793;
  static double TwoPI    = 6.283185307179586;
  static double PI90     = 1.570796326794896;
  static double PI270    = 4.712388980384689;

  static double INF      = double.maxFinite;
  static double EPZ      = 0.00001;
  static double EPS2     = 0.000001;

  static double lerp(double  x, double y, double t ) { 
    return ( 1 - t ) * x + t * y; 
  }

  static double randInt(double  low, double high ) {
    double rand = math.Random().nextDouble();
    return low + (rand * ( high - low + 1 ) ); 
  }
  static bool isFinite(num v) {
    return v != double.maxFinite || v != -double.maxFinite;
  }
  static double rand(double  low,double  high ) { 
    double rand = math.Random().nextDouble();
    return low + rand * ( high - low ); 
  }
  
  static String generateUUID() {
    // http://www.broofa.com/Tools/Math.uuid.htm
    List<String> chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split( '' );
    List uuid = List.filled( 36,'' );
    int rnd = 0, r;

    for ( var i = 0; i < 36; i ++ ) {
      if ( i == 8 || i == 13 || i == 18 || i == 23 ) {
        uuid[ i ] = '-';
      } 
      else if ( i == 14 ) {
        uuid[ i ] = '4';
      } 
      else {
        int rand = math.Random().nextInt(0x1000000);
        if ( rnd <= 0x02 ) rnd = 0x2000000 + ( rand * 0x1000000 ) | 0;
        r = rnd & 0xf;
        rnd = rnd >> 4;
        uuid[ i ] = chars[ ( i == 19 ) ? ( r & 0x3 ) | 0x8 : r ];
      }
    }
    return uuid.join( '' );
  }

  static double fix(double x,[double?  n]) { 
    return x.clamp(n ?? 3, 10).toDouble();// x.toStringAsFixed(n || 3, 10); 
  }

  static double clamp(double  value,double  min,double  max ) { 
    return math.max( min, math.min( max, value ) ); 
  }

  static double distance(List<double> p1,List<double > p2 ){
    double  xd = p2[0]-p1[0];
    double  yd = p2[1]-p1[1];
    double  zd = p2[2]-p1[2];
    return math.sqrt(xd*xd + yd*yd + zd*zd);
  }

  /*unwrapDegrees( r ) {
      r = r % 360;
      if (r > 180) r -= 360;
      if (r < -180) r += 360;
      return r;
  }
  unwrapRadian( r ){
      r = r % _Math.TwoPI;
      if (r > _Math.PI) r -= _Math.TwoPI;
      if (r < -_Math.PI) r += _Math.TwoPI;
      return r;
  }*/

  static double acosClamp(double  cos ) {
    if(cos>1){return 0;}
    else if(cos<-1){return math.pi;}
    else{ return math.acos(cos);}
  }

  static double distanceVector(Vec3 v1,Vec3 v2 ){
    double  xd = v1.x - v2.x;
    double  yd = v1.y - v2.y;
    double  zd = v1.z - v2.z;
    return xd * xd + yd * yd + zd * zd;
  }

  static double dotVectors(Vec3 a, Vec3 b ) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
  }

}