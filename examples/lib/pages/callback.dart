import 'package:flutter/material.dart';
import 'package:oimo_physics/core/rigid_body.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class Callback extends StatefulWidget {
  const Callback({
    Key? key,
  }) : super(key: key);

  @override
  _CallbackState createState() => _CallbackState();
}

class _CallbackState extends State<Callback> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: oimo.Vec3(0,-40,0),
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
    final world = demo.world;

    final moonShape = oimo.Sphere(
      oimo.ShapeConfig(
        density: 5,
      ),
      0.5
    );
    final moon = oimo.RigidBody(
      shapes: [moonShape],
      position: oimo.Vec3(-5, 0, 0),
      type: RigidBodyType.kinematic
    );

    final planetShape = oimo.Sphere(oimo.ShapeConfig(),3.5);
    final planet = oimo.RigidBody(
      shapes: [planetShape]
    );

    double startTime = world.time;

    world.postLoop = (){
      double progress = (world.time - startTime)*1.4; 
      
      double y = Math.sin(-progress)*(-5)-Math.cos(progress)*0;
      double x = Math.cos(-progress)*(-5)-Math.sin(progress)*0;
      moon.position.set(x, y, 0);
    };

    demo.addRigidBody(moon);
    demo.addRigidBody(planet);
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}