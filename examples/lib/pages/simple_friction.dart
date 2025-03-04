import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class SimpleFriction extends StatefulWidget {
  const SimpleFriction({
    Key? key,
  }) : super(key: key);

  @override
  _SimpleFrictionState createState() => _SimpleFrictionState();
}

class _SimpleFrictionState extends State<SimpleFriction> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(3,-60,0),
        iterations: 5,
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
  void friction(){
    const size = 1.0;

    // Static ground plane
    final groundShape = oimo.Box(oimo.ShapeConfig(friction: 0.3),100,100,1);
    final groundBody = oimo.RigidBody(
      mass: 0,
      shapes: [groundShape],
      orientation: vmath.Quaternion.euler(0,-math.pi / 2, 0)
    );
    demo.addRigidBody(groundBody);

    // Create a slippery material (friction coefficient = 0.0)
    // Create slippery box
    final shape = oimo.Box(oimo.ShapeConfig(friction: 0),size*2, size*2, size*2);
    final boxBody1 = oimo.RigidBody(
      mass: 1, 
      shapes: [shape],
      position: vmath.Vector3(0, 5, 0)
    );
    demo.addRigidBody(boxBody1);

    // Create box made of groundMaterial
    final boxBody2 = oimo.RigidBody(
      mass: 10, 
      shapes: [oimo.Box(oimo.ShapeConfig(friction: 0.3),size*2, size*2, size*2)],
      position: vmath.Vector3(-size * 4, 5, 0)
    );
    demo.addRigidBody(boxBody2);
  }
  void perShape(){
    const size = 1.0;

    // Static ground plane
    final groundShape = oimo.Box(oimo.ShapeConfig(friction: 0.3),100,100,1);
    final groundBody = oimo.RigidBody(
      mass: 0,
      shapes: [groundShape],
      orientation: vmath.Quaternion.euler(0,-math.pi / 2, 0)
    );
    demo.addRigidBody(groundBody);

    // Create a slippery material (friction coefficient = 0.0)
    // Create slippery box - will slide on the plane
    final shape1 = oimo.Box(oimo.ShapeConfig(friction: 0),size*2, size*2, size*2);
    final boxBody1 = oimo.RigidBody(
      mass: 1,
      shapes: [shape1],
      position: vmath.Vector3(0,5,0)
    );
    demo.addRigidBody(boxBody1);

    // Create box made of groundMaterial - will not slide on the plane
    final shape2 = oimo.Box(oimo.ShapeConfig(),size*2, size*2, size*2);
    final boxBody2 = oimo.RigidBody(
      mass: 10,
      shapes: [shape2],
      position: vmath.Vector3(-size * 4, 5, 0)
    );
    demo.addRigidBody(boxBody2);
  }

  void setupWorld(){
    demo.addScene('Friction',friction);
    demo.addScene('Shape',perShape);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}