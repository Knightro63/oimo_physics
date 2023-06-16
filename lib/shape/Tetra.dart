import 'mass_info.dart';
import 'shape_config.dart';
import '../math/aabb.dart';
import '../math/vec3.dart';
import 'shape.dart';

class Face{
  Face(this.a,this.b,this.c);
  Vec3 a;
  Vec3 b;
  Vec3 c;
}

//  * A tetra shape.
class Tetra extends Shape{
  Tetra(ShapeConfig config, Vec3 p1, Vec3 p2, Vec3 p3, Vec3 p4 ):super(config){
    type = Shapes.tetra;
    verts = [ p1, p2, p3, p4 ];
    faces = [ mtri(p1, p2, p3), mtri(p2, p3, p4),];
  }

  // Vertices and faces of tetra
  late List<Vec3> verts;
  late List<Face> faces;

  @override
  void calculateMassInfo(MassInfo out ){
    // I guess you could calculate box mass and split it
    // in half for the tetra...
    aabb.setFromPoints(verts);
    List<double> p = aabb.elements;
    double x = p[3] - p[0];
    double y = p[4] - p[1];
    double z = p[5] - p[2];
    double mass = x * y * z * density;
    double divid = 1/12;
    out.mass = mass;
    out.inertia.set(
      mass * ( 2*y*2*y + 2*z*2*z ) * divid, 0, 0,
      0, mass * ( 2*x*2*x + 2*z*2*z ) * divid, 0,
      0, 0, mass * ( 2*y*2*y + 2*x*2*x ) * divid
    );
  }
  @override
  void updateProxy(){
    aabb.setFromPoints(verts);
    aabb.expandByScalar(AABB_PROX);
    if(this.proxy != null) this.proxy!.update();
  }

  Face mtri(Vec3 a, Vec3 b, Vec3 c){
    return Face(a, b, c);
  }
}