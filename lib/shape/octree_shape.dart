import 'package:oimo_physics/oimo_physics.dart';
import 'package:oimo_physics/shape/mass_info.dart';
import 'dart:math' as math;
import '../shape/triangle.dart';
import 'package:vector_math/vector_math.dart' hide Triangle;

class OctreeData{
  OctreeData({
    required this.normal,
    this.point,
    required this.depth
  });

  Vector3? point;
  Vector3 normal;
  double depth;

  @override
  String toString() {
    // TODO: implement toString
    return {
      'point':[point?.x,point?.y,point?.z],
      'normal': [normal.x,normal.y,normal.z],
      'depth':depth
    }.toString();
  }
}

class OctreeNode{
  List<Triangle> triangles = [];
  late AABB box;
  AABB? bounds;
  List<OctreeNode> subTrees = [];

  OctreeNode([AABB? box]){
    this.box = box ?? AABB();
	}

  final Vector3 _v2 = Vector3.zero();
  final Vector3 _v1 = Vector3.zero();

  void addTriangle(Triangle triangle){
    bounds ??= AABB();
    
    bounds!.minX = math.min(math.min(bounds!.minX, triangle.a.x), math.min(triangle.b.x, triangle.c.x ));
    bounds!.minY = math.min(math.min(bounds!.minY, triangle.a.y), math.min(triangle.b.y, triangle.c.y ));
    bounds!.minZ = math.min(math.min(bounds!.minZ, triangle.a.z), math.min(triangle.b.z, triangle.c.z ));
    
    bounds!.maxX = math.max(math.max(bounds!.maxX, triangle.a.x), math.max(triangle.b.x, triangle.c.x ));
    bounds!.maxY = math.max(math.max(bounds!.maxY, triangle.a.y), math.max(triangle.b.y, triangle.c.y ));
    bounds!.maxZ = math.max(math.max(bounds!.maxZ, triangle.a.z), math.max(triangle.b.z, triangle.c.z ));
    triangles.add(triangle);
  }
  void calcBox(){
    box = bounds!.clone();

    // offset small ammount to account for regular grid
    box.minX -= 0.01;
    box.minY -= 0.01;
    box.minZ -= 0.01;
  }
  void split(int level){
    List<OctreeNode> _subTrees = [];
    Vector3 halfsize = _v2..setFrom(box.max)..sub(box.min)..multiplyScalar(0.5);

    for (int x = 0; x < 2; x ++ ) {
      for (int y = 0; y < 2; y ++ ) {
        for (int z = 0; z < 2; z ++ ) {
          AABB _box = AABB();
          final Vector3 v = _v1..setValues(x.toDouble(), y.toDouble(), z.toDouble());
          _box.min = _box.min..setFrom(box.min)..add(v..multiply(halfsize));
          _box.max = _box.max..setFrom(_box.min)..add(halfsize);
          _subTrees.add(OctreeNode(_box.clone()));
        }
      }
    }

    while(triangles.isNotEmpty){
      Triangle triangle = triangles.removeLast();
      for (int i = 0; i < _subTrees.length; i ++ ) {
        if(_subTrees[i].box.intersectsTriangle(triangle)){
          _subTrees[i].triangles.add(triangle);
        }
      }
    }

    for (int i = 0; i < _subTrees.length; i ++ ) {
      int len = _subTrees[i].triangles.length;
      if (len > 8 && level < 16) {
        _subTrees[i].split(level + 1);
      }
      if ( len != 0 ) {
        subTrees.add(_subTrees[i]);
      }
    }
  }
  void build(){
    calcBox();
    split(0);
  }
}

class Octree extends Shape{
  late final List<double> _vertices;
  /// Array of integers, indicating which vertices each triangle consists of. The length of this array is thus 3 times the doubleber of triangles.
  late final List<int> _indices; 
  // late final List<double>? _normals;
  // late final List<double>? _uvs;
  late OctreeNode node;

	Octree(
    ShapeConfig config,
    List<double> vertices, 
    List<int> indices,
    [
      // List<double>? normals,
      // List<double>? uvs,
      AABB? aabb,
    ]
  ):super(config){
    type = Shapes.octree;
    _vertices = vertices;
    _indices = indices;
    // _normals = normals;
    // _uvs = uvs;
    node = OctreeNode(aabb);
    _fromGraphNode();
	}

  List<int> get indices => _indices;
  List<double> get vertices => _vertices;

  void _fromGraphNode(){
    for(int i = 0; i < _vertices.length; i += 9) {
      Vector3 v1 = Vector3(_vertices[i],_vertices[i+1],_vertices[i+2]);
      Vector3 v2 = Vector3(_vertices[i+3],_vertices[i+4],_vertices[i+5]);
      Vector3 v3 = Vector3(_vertices[i+6],_vertices[i+7],_vertices[i+8]);

      // v1;//.applyMatrix4(obj.matrixWorld);
      // v2;//.applyMatrix4(obj.matrixWorld);
      // v3;//.applyMatrix4(obj.matrixWorld);

      node.addTriangle(Triangle(v1.clone(), v2.clone(), v3.clone()));
    }

    node.build();
  }

  @override
  void calculateMassInfo(MassInfo out) {
    out.mass = density;//0.0001;
    double inertia = 1;
    out.inertia.setValues( inertia, 0, 0, 0, inertia, 0, 0, 0, inertia );
  }

  @override
  void updateProxy() {
    //print('Bounds: ${node.bounds}');
    // The plane AABB is infinite, except if the normal is pointing along any axis
    aabb.set(
      node.bounds!.minX, 
      node.bounds!.maxX,
      node.bounds!.minY, 
      node.bounds!.maxY,
      node.bounds!.minZ, 
      node.bounds!.maxZ
    );
    if(proxy != null) proxy!.update();
  }
}