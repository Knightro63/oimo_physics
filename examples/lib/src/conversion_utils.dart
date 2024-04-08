import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart/three_dart.dart' hide Texture, Color;
import 'package:vector_math/vector_math.dart' as vmath;

extension Quant on vmath.Quaternion{
  Quaternion toQuaternion(){
    return Quaternion(x,y,z,w);
  }

}
extension Vec3 on vmath.Vector3{
  Vector3 toVector3(){
    return Vector3(x,y,z);
  }
}

class GeometryCache {
  List<Object3D> geometries = [];
  List gone = [];

  Scene scene;
  Function createFunc;

  GeometryCache(this.scene, this.createFunc);

  Object3D request(){
    Object3D geometry = geometries.isNotEmpty ? geometries.removeLast() : createFunc();

    scene.add(geometry);
    gone.add(geometry);
    return geometry;
  }

  void restart(){
    while (gone.isNotEmpty) {
      geometries.add(gone.removeLast());
    }
  }

  void hideCached(){
    geometries.forEach((geometry){
      scene.remove(geometry);
    });
  }
}

class ConversionUtils{
  static three.BufferGeometry? shapeToGeometry(oimo.Shape shape, {bool flatShading = true, vmath.Vector3? position}) {
    switch (shape.type) {
      case oimo.Shapes.tetra:
      case oimo.Shapes.none: {
        shape as oimo.Sphere;
        return  null;
      }
      case oimo.Shapes.sphere: {
        shape as oimo.Sphere;
        return three.SphereGeometry(shape.radius, 8, 8);
      }

      case oimo.Shapes.particle: {
        return three.SphereGeometry(0.1, 8, 8);
      }

      case oimo.Shapes.plane: {
        return three.PlaneGeometry(500, 500, 4, 4);
      }

      case oimo.Shapes.box: {
        shape as oimo.Box;
        return three.BoxGeometry(shape.width, shape.height, shape.depth);
      }

      case oimo.Shapes.cylinder: {
        shape as oimo.Cylinder;
        return three.CylinderGeometry(shape.radius, shape.radius, shape.height);
      }

      case oimo.Shapes.capsule: {
        shape as oimo.Capsule;
        return three.CylinderGeometry(shape.radius, shape.radius, shape.height);
      }

      case oimo.Shapes.octree: {
        shape as oimo.Cylinder;
        return three.CylinderGeometry(shape.radius, shape.radius, shape.height);
      }
    }
  }
  static Object3D bodyToMesh2(oimo.RigidBody body, three.Material material) {
    final group = Group();
    group.position.copy(body.position.toVector3());
    group.quaternion.copy(body.orientation.toQuaternion());
    for(oimo.Shape? shape = body.shapes; shape!=null; shape = shape.next){
      final geometry = shapeToGeometry(shape);
      final mesh = three.Mesh(geometry, material);
      // mesh.position.copy(shape.position);
      // mesh.quaternion.copy(oimo.Quat().setFromMat33(shape.rotation).toQuaternion());
      group.add(mesh);
    }

    return group;
  }
  static Object3D bodyToMesh(oimo.RigidBody body, three.Material material) {
    final group = Group();
    group.position.copy(body.position.toVector3());
    group.quaternion.copy(body.orientation.toQuaternion());

    List<three.Mesh> meshes = [];
    List<vmath.Vector3> positions = [];
    List<vmath.Quaternion> rotations = [];

    for(oimo.Shape? shapes = body.shapes; shapes != null; shapes = shapes.next){
      final geometry = shapeToGeometry(shapes);
      meshes.add(three.Mesh(geometry, material));
      positions.add(shapes.relativePosition);
      rotations.add(vmath.Quaternion(0,0,0,1)..setFromRotation(shapes.relativeRotation));
    }
    
    int i = 0;
    meshes.forEach((three.Mesh mesh){
      final offset = positions[i];
      final orientation = rotations[i];
      if(meshes.length > 1){
        mesh.position.copy(offset);
        mesh.quaternion.copy(orientation.toQuaternion());
      }
      group.add(mesh);
      i++;
    });

    return group;
  }
  static Object3D objectToMesh(oimo.ObjectConfigure body, three.Material material) {
    final group = Group();
    group.position.copy(body.position.toVector3());
    group.quaternion.copy(body.rotation.toQuaternion());
    final meshes = body.shapes.map((shape){
      final geometry = shapeToGeometry(shape);
      return three.Mesh(geometry, material);
    });
    
    int i = 0;
    meshes.forEach((three.Mesh mesh){
      final offset = body.shapes[i].position;
      final orientation = vmath.Quaternion(0,0,0,1)..setFromRotation(body.shapes[i].rotation);
      mesh.position.copy(offset);
      mesh.quaternion.copy(orientation.toQuaternion());
      group.add(mesh);
      i++;
    });

    return group;
  }

  static oimo.Shape geometryToShape(BufferGeometry geometry, oimo.ShapeConfig config) {
    switch (geometry.type) {
      case 'BoxGeometry':
      case 'BoxBufferGeometry': {
        final width = geometry.parameters!['width'];
        final height = geometry.parameters!['height'];
        final depth = geometry.parameters!['depth'];
        return oimo.Box(config,width,height,depth);
      }
      case 'PlaneGeometry':
      case 'PlaneBufferGeometry': {
        return oimo.Plane(config);
      }
      case 'SphereGeometry':
      case 'SphereBufferGeometry': {
        return oimo.Sphere(config,geometry.parameters!['radius']);
      }
      case 'CylinderGeometry':
      case 'CylinderBufferGeometry': {
        return oimo.Cylinder(
          config,
          geometry.parameters!['radiusTop'], 
          geometry.parameters!['height'].toDouble(), 
        );
      }
      // Create a ConvexPolyhedron with the convex hull if
      // it's none of these
      default: {
        throw('Only sphere, box, cylinder, and plane are allowed to be used.');
      }
    }
  }
  static oimo.Octree fromGraphNode(Object3D group, oimo.ShapeConfig config){
    List<double> vertices = [];
    List<int> indices = [];

    group.updateWorldMatrix(true, true);
    group.traverse((object){
      if(object is Mesh){
        Mesh obj = object;
        late BufferGeometry geometry;
        bool isTemp = false;

        if(obj.geometry!.index != null){
          isTemp = true;
          geometry = obj.geometry!.clone().toNonIndexed();
        } 
        else {
          geometry = obj.geometry!;
        }

			  BufferAttribute positionAttribute = geometry.getAttribute('position');

				for(int i = 0; i < positionAttribute.count; i += 3) {
					Vector3 v1 = Vector3().fromBufferAttribute(positionAttribute, i);
					Vector3 v2 = Vector3().fromBufferAttribute(positionAttribute, i + 1);
					Vector3 v3 = Vector3().fromBufferAttribute(positionAttribute, i + 2);

					v1.applyMatrix4(obj.matrixWorld);
					v2.applyMatrix4(obj.matrixWorld);
					v3.applyMatrix4(obj.matrixWorld);

          vertices.addAll([v1.x,v1.y,v1.z]);
          vertices.addAll([v2.x,v2.y,v2.z]);
          vertices.addAll([v3.x,v3.y,v3.z]);
          
          indices.addAll([i,i+1,i+2]);
				}

        if(isTemp){
          geometry.dispose();
        }
      }
    });

    return oimo.Octree(config, vertices, indices);
  }
}