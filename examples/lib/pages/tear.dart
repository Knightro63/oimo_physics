import 'package:flutter/material.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class Tear extends StatefulWidget {
  const Tear({
    Key? key,
  }) : super(key: key);

  @override
  _TearState createState() => _TearState();
}

class _TearState extends State<Tear> {
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
    final world = demo.world;

    const size = 0.45;
    double mass = 1;

    // The number of chain links
    const N = 15;
    // The distance constraint between those links
    const distance = size * 2 + 0.12;

    // To be able to propagate force throw the chain of N spheres, we need at least N solver iterations.
    world.numIterations = N;

    List<oimo.DistanceJoint> constraints = [];
    oimo.RigidBody? lastBody;
    for (int i = 0; i < N; i++) {
      // First body is static (mass = 0) to support the other bodies
      oimo.RigidBody sphereBody = oimo.RigidBody(
        shapes: [oimo.Sphere(oimo.ShapeConfig(),size)],
        mass: (i == 0 ? 0 : mass),
        position: oimo.Vec3(0, (N - i) * distance - 9, 0)
      );
      demo.addRigidBody(sphereBody);

      // Connect this body to the last one added
      if (lastBody != null) {
        oimo.DistanceJoint constraint = oimo.DistanceJoint(
          oimo.JointConfig(
            body1: sphereBody,
            body2: lastBody
          ),
          distance,
          distance
        );

        lastBody.collide = (b){
          world.removeJoint(constraint);
        };

        world.addJoint(constraint);
        constraints.add(constraint);
      }
      // Keep track of the last added body
      lastBody = sphereBody;
    }

    // Throw a body on the chain to break it!
    oimo.RigidBody sphereBody = oimo.RigidBody(
      mass: mass * 2,
      position: oimo.Vec3(-20, 3, 0),
      linearVelocity: oimo.Vec3(30),
      shapes: [oimo.Sphere(oimo.ShapeConfig(),size)]
    );
    demo.addRigidBody(sphereBody);
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}