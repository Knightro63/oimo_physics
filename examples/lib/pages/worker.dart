import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Worker extends StatefulWidget {
  const Worker({
    Key? key,
  }) : super(key: key);

  @override
  _WorkerState createState() => _WorkerState();
}

class _WorkerState extends State<Worker> {
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
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      shapes: [groundShape],
      mass: 0,
      orientation: vmath.Quaternion.euler(0,-math.pi / 2, 0)
    );
    demo.addRigidBody(groundBody);

    int N = 50;
    const mass = 1.0;
    const size = 0.25;

    final cylinderShape = oimo.Cylinder(oimo.ShapeConfig(),size,size * 2,);
    final cylinderBody = oimo.RigidBody(
      shapes: [cylinderShape],
      mass:mass,
      position: vmath.Vector3(size * 2, size + 1, size * 2)
    );
    demo.addRigidBody(cylinderBody);

    for (int i = 0; i < N; i++) {
      final position = vmath.Vector3(
        (math.Random().nextDouble() * 2 - 1) * 2.5,
        math.Random().nextDouble() * 10,
        (math.Random().nextDouble() * 2 - 1) * 2.5
      );


      demo.addRigidBody(          
        oimo.RigidBody(
          shapes: [oimo.Box(oimo.ShapeConfig(),size*2,size*2,size*2)],
          position: position,
          mass: mass,
        )
      );
    }
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}