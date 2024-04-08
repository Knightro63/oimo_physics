import 'package:flutter/material.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vmath;

class Collisions extends StatefulWidget {
  const Collisions({
    Key? key,
  }) : super(key: key);

  @override
  _CollisionsState createState() => _CollisionsState();
}

class _CollisionsState extends State<Collisions> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        iterations: 5,
        broadPhaseType: oimo.BroadPhaseType.volume,
        gravity: vmath.Vector3.zero()
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
    demo.addScene('Sphere Sphere',setScene0);
    demo.addScene('Box Sphere',setScene1);
    demo.addScene('Box Edge Sphere',setScene2);
    demo.addScene('Box Point Sphere',setScene3);
  }
  void setScene0(){
    // Sphere 1
    final body1 = oimo.RigidBody(
      shapes: [oimo.Sphere(oimo.ShapeConfig(),1)],
      type: oimo.RigidBodyType.dynamic,
      position: vmath.Vector3(-5, 0, 0),
      mass: 5
    );
    body1.linearVelocity.setValues(5, 0, 0);
    demo.addRigidBody(body1);

    // Sphere 2
    final body2 = oimo.RigidBody(
      shapes: [oimo.Sphere(oimo.ShapeConfig(),1)],
      type: oimo.RigidBodyType.dynamic,
      position: vmath.Vector3(5, 0, 0),
      mass: 5
    );
    body2.linearVelocity.setValues(-5, 0, 0);
    demo.addRigidBody(body2);
  }
  void setScene1(){
    final boxShape = oimo.Box(oimo.ShapeConfig(),2, 2, 2);
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),1);
    // Box
    final body1 = oimo.RigidBody(
      shapes: [boxShape],
      type: oimo.RigidBodyType.dynamic,
      position: vmath.Vector3(-5, 0, 0),
      mass: 5
    );
    body1.linearVelocity.setValues(5, 0, 0);
    demo.addRigidBody(body1);

    // Sphere
    final body2 = oimo.RigidBody(
      shapes: [sphereShape],
      type: oimo.RigidBodyType.dynamic,
      position: vmath.Vector3(5, 0, 0),
      mass: 5
    );
    body2.linearVelocity.setValues(-5, 0, 0);
    demo.addRigidBody(body2);
  }
  void setScene2(){
    final boxShape = oimo.Box(oimo.ShapeConfig(),2, 2, 2);
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),1);
    final quaternion = vmath.Quaternion(0,0,0,1).eulerFromXYZ(0, math.pi * 0.25, 0);

    // Box
    final body1 = oimo.RigidBody(
      position: vmath.Vector3(-5,0,0),
      orientation: quaternion,
      type: oimo.RigidBodyType.dynamic,
      shapes: [boxShape],
      mass: 5
    );
    body1.linearVelocity = vmath.Vector3(5,0,0);
    demo.addRigidBody(body1);

    // Sphere
    final body2 = oimo.RigidBody(
      position: vmath.Vector3(5,0,0),
      type: oimo.RigidBodyType.dynamic,
      shapes: [sphereShape],
      mass: 5
    );
    body2.linearVelocity = vmath.Vector3(-5,0,0);
    demo.addRigidBody(body2);
  }
  void setScene3(){
    final boxShape = oimo.Box(oimo.ShapeConfig(),2, 2, 2);
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),1);
    final quaternion1 = vmath.Quaternion(0,0,1,0);
    quaternion1.setEuler(0, 0,math.pi * 0.25);
    final quaternion2 = vmath.Quaternion(0,0,1,0);
    quaternion2.setEuler(math.pi * 0.25,0,0);
    final quaternion = quaternion1.mult(quaternion2);
    // Box
    final body1 = oimo.RigidBody(
      shapes: [boxShape],
      type: oimo.RigidBodyType.dynamic,
      position: vmath.Vector3(-5, 0, 0),
      orientation: quaternion,
      mass: 5
    );

    body1.linearVelocity.setValues(5, 0, 0);
    demo.addRigidBody(body1);

    // Sphere
    final body2 = oimo.RigidBody(
      shapes: [sphereShape],
      type: oimo.RigidBodyType.dynamic,
      position: vmath.Vector3(5, 0, 0),
      mass: 5,
    );
    body2.fixedRotation = true;
    body2.linearVelocity.setValues(-5, 0, 0);
    demo.addRigidBody(body2);
  }
  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}