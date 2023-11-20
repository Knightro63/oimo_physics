import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class Jenga extends StatefulWidget {
  const Jenga({
    Key? key,
  }) : super(key: key);

  @override
  _JengaState createState() => _JengaState();
}

class _JengaState extends State<Jenga> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: oimo.Vec3(0,-5,0),
        iterations: 5,
        broadPhaseType: oimo.BroadPhaseType.sweep
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
    const size = 0.5;
    const mass = 1.0;
    const gap = 0.02;

    // Layers
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 3; j++) {
        oimo.Vec3 halfExtents;

        int dx;
        int dz;
        if (i % 2 == 0) {
          halfExtents = oimo.Vec3(size*2, size*2, size * 6);
          dx = 1;
          dz = 0;
        } else {
          halfExtents = oimo.Vec3(size * 6, size*2, size*2);
          dx = 0;
          dz = 1;
        }
        oimo.Box shape = oimo.Box(
          oimo.ShapeConfig(),          
          halfExtents.x,
          halfExtents.y,
          halfExtents.z
        );

        oimo.RigidBody body = oimo.RigidBody(
          shapes: [shape],
          mass: mass,
          position: oimo.Vec3(
            2 * (size + gap) * (j - 1) * dx,
            2 * (size + gap) * (i + 1),
            2 * (size + gap) * (j - 1) * dz
          ),
          type: oimo.RigidBodyType.dynamic
        );

        demo.addRigidBody(body);
      }
    }

    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    oimo.RigidBody groundBody = oimo.RigidBody(
      mass: 0, 
      shapes: [groundShape],
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(groundBody);
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}