import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class Friction extends StatefulWidget {
  const Friction({
    Key? key,
  }) : super(key: key);

  @override
  _FrictionState createState() => _FrictionState();
}

class _FrictionState extends State<Friction> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: oimo.Vec3(3,-60,0),
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
    const size =2.0;

    // Static ground plane
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      mass: 0, 
      shapes: [groundShape],
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(groundBody);

    // Create slippery box
    final boxBody1 = oimo.RigidBody( 
      mass: 1, 
      shapes: [oimo.Box(oimo.ShapeConfig(restitution: 0.3, friction: 0),size, size, size)],
      position: oimo.Vec3(0, 5, 0)
    );
    demo.addRigidBody(boxBody1);

    // Create box made of groundMaterial
    final boxBody2 = oimo.RigidBody(
      mass: 10, 
      shapes: [oimo.Box(oimo.ShapeConfig(restitution: 0.3),size, size, size)],
      position: oimo.Vec3(-size * 2, 5, 0)
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