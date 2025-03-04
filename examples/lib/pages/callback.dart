import 'package:flutter/material.dart';
import 'package:oimo_physics/core/rigid_body.dart';
import 'dart:math' as math;
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

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
        gravity: vmath.Vector3(0,-40,0),
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
      position: vmath.Vector3(-5, 0, 0),
      type: RigidBodyType.kinematic
    );

    final planetShape = oimo.Sphere(oimo.ShapeConfig(),3.5);
    final planet = oimo.RigidBody(
      shapes: [planetShape]
    );

    double startTime = world.time;

    world.postLoop = (){
      double progress = (world.time - startTime)*1.4; 
      
      double y = math.sin(-progress)*(-5);
      double x = math.cos(-progress)*(-5);
      moon.position.setValues(x, y, 0);
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