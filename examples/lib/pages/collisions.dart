import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'dart:math' as math;

extension on oimo.Quat{
  Quaternion toQuaternion(){
    return Quaternion(x,y,z,w);
  }
}
extension on oimo.Vec3{
  Vector3 toVector3(){
    return Vector3(x,y,z);
  }
}

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
        gravity: oimo.Vec3()
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
      position: oimo.Vec3(-5, 0, 0),
      mass: 5
    );
    body1.linearVelocity.set(5, 0, 0);
    demo.addRigidBody(body1);

    // Sphere 2
    final body2 = oimo.RigidBody(
      shapes: [oimo.Sphere(oimo.ShapeConfig(),1)],
      type: oimo.RigidBodyType.dynamic,
      position: oimo.Vec3(5, 0, 0),
      mass: 5
    );
    body2.linearVelocity.set(-5, 0, 0);
    demo.addRigidBody(body2);
  }
  void setScene1(){
    final boxShape = oimo.Box(oimo.ShapeConfig(),2, 2, 2);
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),1);
    // Box
    final body1 = oimo.RigidBody(
      shapes: [boxShape],
      type: oimo.RigidBodyType.dynamic,
      position: oimo.Vec3(-5, 0, 0),
      mass: 5
    );
    body1.linearVelocity.set(5, 0, 0);
    demo.addRigidBody(body1);

    // Sphere
    final body2 = oimo.RigidBody(
      shapes: [sphereShape],
      type: oimo.RigidBodyType.dynamic,
      position: oimo.Vec3(5, 0, 0),
      mass: 5
    );
    body2.linearVelocity.set(-5, 0, 0);
    demo.addRigidBody(body2);
  }
  void setScene2(){
    final boxShape = oimo.Box(oimo.ShapeConfig(),2, 2, 2);
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),1);
    final quaternion = oimo.Quat().setFromEuler(0, math.pi * 0.25, 0);

    // Box
    final body1 = oimo.RigidBody(
      position: oimo.Vec3(-5,0,0),
      orientation: quaternion,
      type: oimo.RigidBodyType.dynamic,
      shapes: [boxShape],
      mass: 5
    );
    body1.linearVelocity = oimo.Vec3(5,0,0);
    demo.addRigidBody(body1);

    // Sphere
    final body2 = oimo.RigidBody(
      position: oimo.Vec3(5,0,0),
      type: oimo.RigidBodyType.dynamic,
      shapes: [sphereShape],
      mass: 5
    );
    body2.linearVelocity = oimo.Vec3(-5,0,0);
    demo.addRigidBody(body2);
  }
  void setScene3(){
    final boxShape = oimo.Box(oimo.ShapeConfig(),2, 2, 2);
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),1);
    final quaternion1 = oimo.Quat();
    quaternion1.setFromEuler(0, math.pi * 0.25, 0);
    final quaternion2 = oimo.Quat();
    quaternion2.setFromEuler(0, 0, math.pi * 0.25);
    final quaternion = quaternion1.mult(quaternion2);
    // Box
    final body1 = oimo.RigidBody(
      shapes: [boxShape],
      type: oimo.RigidBodyType.dynamic,
      position: oimo.Vec3(-5, 0, 0),
      orientation: quaternion,
      mass: 5
    );

    body1.linearVelocity.set(5, 0, 0);
    demo.addRigidBody(body1);

    // Sphere
    final body2 = oimo.RigidBody(
      shapes: [sphereShape],
      type: oimo.RigidBodyType.dynamic,
      position: oimo.Vec3(5, 0, 0),
      mass: 5,
    );
    body2.fixedRotation = true;
    body2.linearVelocity.set(-5, 0, 0);
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