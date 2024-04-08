import 'mass_info.dart';
import 'shape_config.dart';
import '../math/aabb.dart';
import 'shape_main.dart';
import 'package:vector_math/vector_math.dart';

/// Face of the tetra shape
class Face{
  Face(this.a,this.b,this.c);
  Vector3 a;
  Vector3 b;
  Vector3 c;
}

/// Tetra shape.
class Tetra extends Shape{

  /// Tetra shape.
  /// 
  /// [config] the configuration of the shape
  Tetra(ShapeConfig config, Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4 ):super(config){
    type = Shapes.tetra;
    verts = [ p1, p2, p3, p4 ];
    faces = [ mtri(p1, p2, p3), mtri(p2, p3, p4),];
  }

  /// Vertices and faces of tetra
  late List<Vector3> verts;
  late List<Face> faces;

  @override
  void calculateMassInfo(MassInfo out ){
    /// I guess you could calculate box mass and split it
    /// in half for the tetra...
    aabb.setFromPoints(verts);
    List<double> p = aabb.elements;
    double x = p[3] - p[0];
    double y = p[4] - p[1];
    double z = p[5] - p[2];
    double mass = x * y * z * density;
    double divid = 1/12;
    out.mass = mass;
    out.inertia.setValues(
      mass * ( 2*y*2*y + 2*z*2*z ) * divid, 0, 0,
      0, mass * ( 2*x*2*x + 2*z*2*z ) * divid, 0,
      0, 0, mass * ( 2*y*2*y + 2*x*2*x ) * divid
    );
  }
  @override
  void updateProxy(){
    aabb.setFromPoints(verts);
    aabb.expandByScalar(aabbProx);
    if(proxy != null) proxy!.update();
  }

  Face mtri(Vector3 a, Vector3 b, Vector3 c){
    return Face(a, b, c);
  }
}