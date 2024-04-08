import 'package:flutter/material.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Impulses extends StatefulWidget {
  const Impulses({
    Key? key,
  }) : super(key: key);

  @override
  _ImpulsesState createState() => _ImpulsesState();
}

class _ImpulsesState extends State<Impulses> {
  late Demo demo;
  final radius = 1.0;
  final mass = 2.0;
  final strength = 500.0;
  final dt = 1 / 60;
  final damping = 0.5;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3.zero(),
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
  void centerImpulse(){
    final shape = oimo.Sphere(oimo.ShapeConfig(),radius);
    final body = oimo.RigidBody(
      mass:mass,
      shapes: [shape]
    );
    demo.addRigidBody(body);

    final impulse = vmath.Vector3(-strength * dt, 0, 0);
    body.applyImpulse(vmath.Vector3.zero(),impulse);
  }
  void topImpulse(){
    final shape = oimo.Sphere(oimo.ShapeConfig(),radius);
    final body = oimo.RigidBody(
      mass:mass,
      shapes: [shape]
    );
    demo.addRigidBody(body);

    // The top of the sphere, relative to the sphere center
    final topPoint = vmath.Vector3(0, radius, 0);
    final impulse = vmath.Vector3(-strength * dt, 0, 0);
    body.applyImpulse(topPoint,impulse);
  }

  void torque(){
    final shape = oimo.Sphere(oimo.ShapeConfig(),radius);
    final body = oimo.RigidBody(
      mass:mass,
      shapes: [shape]
    );
    demo.addRigidBody(body);

    // add a positive rotation in the z-axis
    final torque = vmath.Vector3(0, 0, -strength);
    body.applyTorque(torque);
  }
  void setupWorld(){
    demo.addScene('Center Impulse',centerImpulse);
    demo.addScene('Top Impulse',topImpulse);
    demo.addScene('Torque',torque);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}