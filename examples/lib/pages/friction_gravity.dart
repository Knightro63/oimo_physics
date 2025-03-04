import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class FrictionGravity extends StatefulWidget {
  const FrictionGravity({
    Key? key,
  }) : super(key: key);

  @override
  _FrictionGravityState createState() => _FrictionGravityState();
}

class _FrictionGravityState extends State<FrictionGravity> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(3,-60,0),
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
    late oimo.RigidBody boxBody1;
    late oimo.RigidBody boxBody2;
    const size = 1.0;

    // Static ground plane
    final groundShape = oimo.Box(oimo.ShapeConfig(restitution: 0.3),100,100,1);
    final groundBody = oimo.RigidBody(
      mass: 0, 
      shapes: [groundShape],
      orientation: vmath.Quaternion.euler(0,-math.pi / 2, 0)
    );
    demo.addRigidBody(groundBody);

    // Create slippery box
    final boxShape = oimo.Box(
      oimo.ShapeConfig(
        restitution: 0.3
      ),size, size, size);
    boxBody1 = oimo.RigidBody(
      mass: 1, 
      shapes: [boxShape],
      position: vmath.Vector3(0, 5, 0),
      type: oimo.RigidBodyType.dynamic
    );
    demo.addRigidBody(boxBody1);

    // Create box made of groundMaterial
    final boxShape2 = oimo.Box(
      oimo.ShapeConfig(
        friction: 0,
        restitution: 0.3
      ),size, size, size);
    boxBody2 = oimo.RigidBody(
      mass: 10, 
      shapes: [boxShape2],
      position: vmath.Vector3(-size * 4, 5, 0),
      type: oimo.RigidBodyType.dynamic
    );
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