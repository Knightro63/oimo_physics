import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class Shapes extends StatefulWidget {
  const Shapes({
    Key? key,
  }) : super(key: key);

  @override
  _ShapesState createState() => _ShapesState();
}

class _ShapesState extends State<Shapes> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: oimo.Vec3(0,-30,0),
        iterations: 17,
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

  void setScene(){
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      mass: 0,
      shapes: [groundShape],
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(groundBody);

    const mass = 1.0;
    const size = 1.0;

    // Sphere shape
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),size);
    final sphereBody = oimo.RigidBody(
      mass:mass,
      shapes: [sphereShape],
      position: oimo.Vec3(-size * 2, size + 1, size * 2)
    );
    demo.addRigidBody(sphereBody);

    // Cylinder shape
    final cylinderShape = oimo.Cylinder(
      oimo.ShapeConfig(),
      size, 
      size*2,
    );
    final cylinderBody = oimo.RigidBody(
      mass:mass,
      shapes: [cylinderShape],
      position: oimo.Vec3(size * 2, size + 1, size * 2)
    );
    demo.addRigidBody(cylinderBody);

    // Cylinder shape 2
    final cylinderShape2 = oimo.Cylinder(
      oimo.ShapeConfig(),
      size, 
      size*2, 
    );
    final cylinderBody2 = oimo.RigidBody(
      mass:mass,
      shapes: [cylinderShape2],
      position: oimo.Vec3(size * 2, size * 4 + 1, size * 2),
      orientation: oimo.Quat().setFromEuler(Math.PI / 2, Math.PI / 2, 0)
    );
    demo.addRigidBody(cylinderBody2);

    // Box shape
    final boxShape = oimo.Box(oimo.ShapeConfig(),size*2, size*2, size*2);
    final boxBody = oimo.RigidBody(
      mass:mass,
      shapes: [boxShape],
      position: oimo.Vec3(size * 2, size + 1, -size * 2)
    );
    demo.addRigidBody(boxBody);

    // Compound
    final compoundBody = oimo.RigidBody(
      mass:mass,
      shapes: [
        oimo.Box(oimo.ShapeConfig(relativePosition: oimo.Vec3(0, size, 0)),size, size, size),
        oimo.Box(oimo.ShapeConfig(relativePosition: oimo.Vec3(0, 0, 0)),size, size, size),
        oimo.Box(oimo.ShapeConfig(relativePosition: oimo.Vec3(0, -size, 0)),size, size, size),
        oimo.Box(oimo.ShapeConfig(relativePosition: oimo.Vec3(size, -size, 0)),size, size, size)
      ],
      position: oimo.Vec3(size * 4, size + 1, size * 4)
    );
    demo.addRigidBody(compoundBody);
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}