import 'package:flutter/material.dart';
import 'package:oimo_physics/core/rigid_body.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Bounce extends StatefulWidget {
  const Bounce({
    Key? key,
  }) : super(key: key);
  @override
  _BounceState createState() => _BounceState();
}

class _BounceState extends State<Bounce> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-20,0),
        iterations: 3,
        broadPhaseType: oimo.BroadPhaseType.volume
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
    // Static ground plane
    final groundShape = oimo.Plane(oimo.ShapeConfig());
    final groundBody = oimo.RigidBody(
      shapes: [groundShape],
      name: 'ground',
      orientation: vmath.Quaternion.euler(0,-Math.PI / 2, 0)
    );
    demo.addRigidBody(groundBody);

    const double mass = 10;
    const double size = 1;
    const double height = 10;

    // Shape on plane
    final shapeBody1 = oimo.RigidBody(
      shapes: [oimo.Sphere(oimo.ShapeConfig(density: mass, restitution: 0, friction: 0),size)],
      position: vmath.Vector3(-size * 3, height, size),
      type: RigidBodyType.dynamic
    );
    //shapeBody1.linearDamping = damping;
    demo.addRigidBody(shapeBody1);

    final shapeBody2 = oimo.RigidBody(
      shapes: [oimo.Sphere(oimo.ShapeConfig(density: mass, restitution: 0.7, friction: 0),size)],
      position: vmath.Vector3(0, height, size),
      type: RigidBodyType.dynamic
    );
    //shapeBody2.linearDamping = damping;
    demo.addRigidBody(shapeBody2);

    final shapeBody3 = oimo.RigidBody(
      shapes: [oimo.Sphere(oimo.ShapeConfig(density: mass, restitution: 0.9, friction: 0),size)],
      position: vmath.Vector3(size * 3, height, size),
      type: RigidBodyType.dynamic
    );
    //shapeBody3.linearDamping = damping;
    demo.addRigidBody(shapeBody3);

  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}