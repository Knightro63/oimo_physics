import 'package:flutter/material.dart';
import 'package:oimo_physics/core/rigid_body.dart';
import '../src/demo.dart';
import 'package:three_dart/three_dart.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class BodyTypes extends StatefulWidget {
  const BodyTypes({
    Key? key,
    this.offset = const Offset(0,0),
  }) : super(key: key);

  final Offset offset;

  @override
  _BodyTypesState createState() => _BodyTypesState();
}

class _BodyTypesState extends State<BodyTypes> {
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
    // Static ground plane
    final groundBody = oimo.RigidBody(
      shapes: [oimo.Plane(oimo.ShapeConfig(geometry: oimo.Shapes.plane))],
      position:oimo.Vec3(0.0,-4.0,0.0), 
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(groundBody);

    const size = 4.0;
    final boxBody = oimo.RigidBody(
      mass: 100.0,
      type: RigidBodyType.kinematic,
      shapes: [oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box),size, size, size)],
      position: oimo.Vec3(0, size * 0.5, 0), 
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(boxBody);

    // To control the box movement we must set its velocity
    boxBody.linearVelocity.set(0, 5, 0);
    double secs = 0;
    demo.addAnimationEvent((dt){
      secs += dt;
      if(secs > 1){
        if (boxBody.linearVelocity.y < 0) {
          boxBody.linearVelocity.set(0, 5, 0);
        } else {
          boxBody.linearVelocity.set(0, -5, 0);
        }
        secs = 0;
      }
    });

    final sphereBody = oimo.RigidBody(
      mass: 1.0,
      type: RigidBodyType.dynamic,
      shapes: [oimo.Sphere(oimo.ShapeConfig(geometry: oimo.Shapes.sphere, density: 0.1),size*0.5)],
      position: oimo.Vec3(0, size * 3, 0), 
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