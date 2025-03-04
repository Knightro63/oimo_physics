import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../src/demo.dart';
import 'package:three_js_geometry/three_js_geometry.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:three_js/three_js.dart' as three;
import 'package:vector_math/vector_math.dart' as vmath;

class Cloth extends StatefulWidget {
  const Cloth({
    Key? key,
  }) : super(key: key);

  @override
  _ClothPageState createState() => _ClothPageState();
}

class _ClothPageState extends State<Cloth> {
late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-9.81,0),
        iterations: 20,
        broadPhaseType: oimo.BroadPhaseType.sweep,
      )
    );
    setupWorld();
    super.initState();
  }
  @override
  void dispose() {
    demo.dispose();
    super.dispose();
  }

  void particleCloth() async{
    final world = demo.world;
    world.numIterations = 20;

    const clothMass = 1.0;
    const rows = 15;
    const cols = 15;
    const mass = (clothMass / cols) * rows;

    double sphereSize = 1;
    double clothSize = 10.0;

    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),sphereSize*1.3);
    final sphereBody = oimo.RigidBody(
      shapes: [sphereShape],
      mass: 50,
      type: oimo.RigidBodyType.static,
      position: vmath.Vector3(-1,6,0),
    );
    sphereBody.fixedRotation = true;
    demo.addRigidBody(sphereBody);

    double restDistance = clothSize / cols;  
    three.Vector3 clothFunction(double u, double v, three.Vector3 target) {
      double x = (u - 0.5) * restDistance * cols;
      double y = (v + 0.5) * restDistance * rows;
      double z = 0;

      target.setValues(x, y, z);

      return target;
    }

    three.Texture clothTexture = (await three.TextureLoader().fromAsset('assets/images/sunflower.jpg'))!;
    clothTexture.wrapS = three.RepeatWrapping;
    clothTexture.wrapT = three.RepeatWrapping;
    clothTexture.anisotropy = 16;
    clothTexture.encoding = three.sRGBEncoding;
    three.MeshPhongMaterial clothMaterial = three.MeshPhongMaterial.fromMap({
      'map': clothTexture,
      'side': three.DoubleSide,
    });
    // Cloth geometry
    final clothGeometry = ParametricGeometry(clothFunction, rows, cols);

    // Cloth mesh
    three.Mesh clothMesh = three.Mesh(clothGeometry, clothMaterial);
    demo.threeJs.scene.add(clothMesh);

    Map<String,oimo.RigidBody> bodies = {}; // bodies['i j'] => particle
    for (int i = 0; i < cols+1; i++) {
      for (int j = 0; j < rows+1; j++) {
        // Create a new body
        late final three.Vector3 point = three.Vector3();
        clothFunction(i / (cols + 1), j / (rows + 1), point);
        final body = oimo.RigidBody(
          shapes: [oimo.Sphere(oimo.ShapeConfig(),0.08)],
          mass: j == rows? 0 : mass,
          //position: vmath.Vector3(-restDistance * i+6, restDistance * j-4, 0),
          position: vmath.Vector3(point.x, point.y - rows * 0.9 * restDistance, point.z),
          //linearVelocity: vmath.Vector3(0, 0, (Math.sin(i * 0.1) + Math.sin(j * 0.1)) * 3)
          //linearVelocity: vmath.Vector3(0, 0, -0.1 * (rows - j))
        );
        bodies['$i $j'] = body;
        demo.addRigidBody(body);
      }
    }

    void connect(i1, j1, i2, j2) {
      final distanceConstraint = oimo.DistanceJoint(
        oimo.JointConfig(
          body1: bodies['$i1 $j1']!,
          body2: bodies['$i2 $j2']!,
          allowCollision: true
        ),
        restDistance,
        restDistance
      );
      world.addJoint(distanceConstraint);
    }

    for (int i = 0; i < cols+1; i++) {
      for (int j = 0; j < rows+1; j++) {
        if (i < cols) connect(i, j, i + 1, j);
        if (j < rows) connect(i, j, i, j + 1);
      }
    }

    double startTime = world.time;

    world.postLoop = (){
      // Make the three.js cloth follow the oimo.js particles
      for (int i = 0; i < cols+1; i++) {
        for (int j = 0; j < rows+1; j++) {
          int index = j * (cols + 1) + i;
          vmath.Vector3 v = bodies['$i $j']!.position;
          clothGeometry.attributes["position"].setXYZ(index, v.x, v.y, v.z);
        }
      }
      clothGeometry.attributes["position"].needsUpdate = true;

      clothGeometry.computeVertexNormals();
      clothGeometry.normalsNeedUpdate = true;
      clothGeometry.verticesNeedUpdate = true;

      // Move the ball in a circular motion
      double time = world.time - startTime;
      sphereBody.position.setValues(2 * math.sin(time)-1, 2 * math.cos(time)+2, 2 * math.cos(time));
    };
  }
  void setupWorld(){
    particleCloth();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}