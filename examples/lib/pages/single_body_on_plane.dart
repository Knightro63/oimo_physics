import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class SBOP extends StatefulWidget {
  const SBOP({
    Key? key,
  }) : super(key: key);

  @override
  _SBOPState createState() => _SBOPState();
}

class _SBOPState extends State<SBOP> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: oimo.Vec3(0,-10,0),
        iterations: 5,
        broadPhaseType: oimo.BroadPhaseType.volume,
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
  void plane(){
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      shapes: [groundShape],
      mass: 0,
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(groundBody);
  }
  void box(){
    plane();

    const size = 2.0;

    final boxShape = oimo.Box(oimo.ShapeConfig(),size*2, size*2, size*2);
    final body = oimo.RigidBody(
      shapes: [boxShape],
      mass: 3.0,
      position: oimo.Vec3(0, size * 2, size)
    );
    demo.addRigidBody(body);
  }
  void sphere(){
    plane();
    const size = 2.0;

    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),size);
    final body = oimo.RigidBody(
      shapes: [sphereShape],
      mass: 30,
      position: oimo.Vec3(0, size * 2, size)
    );
    demo.addRigidBody(body);
  }
  void setupWorld(){
    demo.addScene('Box',box);
    demo.addScene('Sphere',sphere);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}