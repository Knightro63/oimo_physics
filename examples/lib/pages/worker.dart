import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

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
        gravity: oimo.Vec3(0,-10,0),
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
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(groundBody);

    int N = 50;
    const mass = 1.0;
    const size = 0.25;

    final cylinderShape = oimo.Cylinder(oimo.ShapeConfig(),size,size * 2,);
    final cylinderBody = oimo.RigidBody(
      shapes: [cylinderShape],
      mass:mass,
      position: oimo.Vec3(size * 2, size + 1, size * 2)
    );
    demo.addRigidBody(cylinderBody);

    for (int i = 0; i < N; i++) {
      final position = oimo.Vec3(
        (Math.random() * 2 - 1) * 2.5,
        Math.random() * 10,
        (Math.random() * 2 - 1) * 2.5
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