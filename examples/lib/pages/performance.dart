import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Performance extends StatefulWidget {
  const Performance({
    Key? key,
  }) : super(key: key);
  @override
  _PerformanceState createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-50,0),
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
  void setupFallingBoxes(int N) {
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      shapes: [groundShape],
      mass: 0,
      orientation: vmath.Quaternion.euler(0,-Math.PI / 2, 0)
    );
    demo.addRigidBody(groundBody);

    const size = 0.5;
    const mass = 10.0;

    for (int i = 0; i < N; i++) {
      final boxShape = oimo.Box(oimo.ShapeConfig(),size, size, size);
      // start with random positions
      final position = vmath.Vector3(
        (Math.random() * 2 - 1) * 2.5,
        Math.random() * 10,
        (Math.random() * 2 - 1) * 2.5
      );

      final boxBody = oimo.RigidBody(
        shapes: [boxShape],
        position: position,
        mass: mass,
        type: oimo.RigidBodyType.dynamic,
        allowSleep: true
      );
      demo.addRigidBody(boxBody);
    }
  }

  void setupWorld(){
    setupFallingBoxes(500);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}