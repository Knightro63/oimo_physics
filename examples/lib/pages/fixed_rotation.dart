import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class FixedRotation extends StatefulWidget {
  const FixedRotation({
    Key? key,
  }) : super(key: key);

  @override
  _FixedRotationState createState() => _FixedRotationState();
}

class _FixedRotationState extends State<FixedRotation> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-10,0),
        iterations: 5,
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
  void setScene(){
    final groundShape = oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box),100,100,0.1);
    final groundBody = oimo.RigidBody(
      mass: 0,
      shapes: [groundShape],
      orientation: vmath.Quaternion.euler(0,-math.pi / 2, 0)
    );
    demo.addRigidBody(groundBody);

    const size = 2.0;

    // Create a box with fixed rotation
    final shape1 = oimo.Box(
      oimo.ShapeConfig(       
        geometry: oimo.Shapes.box,
        restitution: 0,
      ),size, size, size);
    final boxBody1 = oimo.RigidBody(
      mass: 1,
      shapes: [shape1],
      position: vmath.Vector3(0, 1, 0),
      type: oimo.RigidBodyType.dynamic
    );
    boxBody1.fixedRotation = true;
    demo.addRigidBody(boxBody1);

    // Another one
    final shape2 = oimo.Box(
      oimo.ShapeConfig(
        geometry: oimo.Shapes.box,
        restitution: 0,
      ),size, size, size);
    final boxBody2 = oimo.RigidBody(
      mass: 1,
      shapes: [shape2],
      position: vmath.Vector3(-(1 * 3) / 2, 1 * 4, 0),
      type: oimo.RigidBodyType.dynamic,
    );
    boxBody2.fixedRotation = true;
    demo.addRigidBody(boxBody2);
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}