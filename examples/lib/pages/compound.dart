import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Compound extends StatefulWidget {
  const Compound({
    Key? key,
  }) : super(key: key);

  @override
  _CompoundState createState() => _CompoundState();
}

class _CompoundState extends State<Compound> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-30,0),
        iterations: 5,
        broadPhaseType: oimo.BroadPhaseType.force
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
  void sceneBox(){
    setScene();
    const size = 1.5;

    // Now create a Body for our Compound
    final body = oimo.RigidBody(
      shapes: [
        oimo.Box(oimo.ShapeConfig(relativePosition: vmath.Vector3(-size, -size, 0)),size, size, size),
        oimo.Box(oimo.ShapeConfig(relativePosition: vmath.Vector3(-size, size, 0)),size, size, size),
        oimo.Box(oimo.ShapeConfig(relativePosition: vmath.Vector3(size, -size, 0)),size, size, size),
        oimo.Box(oimo.ShapeConfig(relativePosition: vmath.Vector3(size, size, 0)),size, size, size),

        oimo.Box(oimo.ShapeConfig(relativePosition: vmath.Vector3(size, 0, 0)),size, size, size),
        oimo.Box(oimo.ShapeConfig(relativePosition: vmath.Vector3(0, -size, 0)),size, size, size),
        oimo.Box(oimo.ShapeConfig(relativePosition: vmath.Vector3(0, size, 0)),size, size, size),
      ],
      mass:1.0,
      position: vmath.Vector3(0, 6, 0),
      orientation: vmath.Quaternion.euler(0, 0, math.pi * 0.03),
      type: oimo.RigidBodyType.dynamic
    );

    demo.addRigidBody(body);
  }

  // Here we create a compound made out of spheres
  void sceneSpheres(){
    setScene();
    final body = oimo.RigidBody(
      shapes: [
        oimo.Sphere(oimo.ShapeConfig(relativePosition: vmath.Vector3(-1, -1, 0)),1),
        oimo.Sphere(oimo.ShapeConfig(relativePosition: vmath.Vector3(-1, 1, 0)),1),
        oimo.Sphere(oimo.ShapeConfig(relativePosition: vmath.Vector3(1, -1, 0)),1),
        oimo.Sphere(oimo.ShapeConfig(relativePosition: vmath.Vector3(1, 1, 0)),1)
      ],
      mass:1.0,
      position: vmath.Vector3(0, 6, 0),
      orientation: vmath.Quaternion.euler(0, 0, -math.pi * 0.03),
      type: oimo.RigidBodyType.dynamic
    );

    demo.addRigidBody(body);
  }

  void setScene(){
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      shapes: [groundShape],
      mass: 0,
      orientation: vmath.Quaternion.euler(0,-math.pi / 2, 0),
    );
    demo.addRigidBody(groundBody);
  }

  void setupWorld(){
    demo.addScene('Box',sceneBox);
    demo.addScene('Sphere',sceneSpheres);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}