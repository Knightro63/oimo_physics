import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class ContainerCP extends StatefulWidget {
  const ContainerCP({
    Key? key,
  }) : super(key: key);

  @override
  _ContainerState createState() => _ContainerState();
}

class _ContainerState extends State<ContainerCP> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-30,0),
        iterations: 10,
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

  void createContainer(nx, ny, nz) {
    final world = demo.world;
    // Ground plane
    final groundShape = oimo.Plane(oimo.ShapeConfig());
    final groundBody = oimo.RigidBody(
      mass: 0, 
      shapes: [groundShape],
      orientation: vmath.Quaternion(0,0,0,1).eulerFromXYZ(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(groundBody);

    // Plane -x
    final planeShapeXmin = oimo.Plane(oimo.ShapeConfig());
    final planeXmin = oimo.RigidBody(
      mass: 0, 
      shapes: [planeShapeXmin],
      position: vmath.Vector3(-5, 0, 0),
      orientation: vmath.Quaternion(0,0,0,1).eulerFromXYZ(0, Math.PI / 2, 0)
    );
    world.addRigidBody(planeXmin);

    // Plane +x
    final planeShapeXmax = oimo.Plane(oimo.ShapeConfig());
    final planeXmax = oimo.RigidBody(
      mass: 0, 
      shapes: [planeShapeXmax],
      position: vmath.Vector3(5, 0, 0),
      orientation: vmath.Quaternion(0,0,0,1).eulerFromXYZ(0, -Math.PI / 2, 0)
    );
    world.addRigidBody(planeXmax);

    // Plane -z
    final planeShapeZmin = oimo.Plane(oimo.ShapeConfig());
    final planeZmin = oimo.RigidBody(
      mass: 0, 
      shapes: [planeShapeZmin],
      position: vmath.Vector3(0, 0, -5),
      orientation: vmath.Quaternion(0,0,0,1).eulerFromXYZ(0, 0, 0)
    );
    world.addRigidBody(planeZmin);

    // Plane +z
    final planeShapeZmax = oimo.Plane(oimo.ShapeConfig());
    final planeZmax = oimo.RigidBody(
      mass: 0, 
      shapes: [planeShapeZmax],
      position: vmath.Vector3(0, 0, 5),
      orientation: vmath.Quaternion(0,0,0,1).eulerFromXYZ(0, Math.PI, 0)
    );
    world.addRigidBody(planeZmax);

    // Create spheres
    const randRange = 0.1;
    const heightOffset = 0;

    // Sharing shape saves memory
    for (int i = 0; i < nx; i++) {
      for (int j = 0; j < ny; j++) {
        for (int k = 0; k < nz; k++) {
          final sphereShape = oimo.Sphere(oimo.ShapeConfig(),1);
          final sphereBody = oimo.RigidBody(
            mass: 5, 
            shapes: [sphereShape],
            position: vmath.Vector3(
              -(i * 2 - nx * 0.5 + (Math.random() - 0.5) * randRange),
              1 + k * 2.1 + heightOffset,
              j * 2 - ny * 0.5 + (Math.random() - 0.5) * randRange
            ),
            allowSleep: true,
            type: oimo.RigidBodyType.dynamic
          );
          sphereBody.sleepTime = 5;
          demo.addRigidBody(sphereBody);
        }
      }
    }
  }

  void setupWorld(){
    createContainer(4, 4, 10);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}