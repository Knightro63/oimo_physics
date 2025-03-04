import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Events extends StatefulWidget {
  const Events({
    Key? key,
  }) : super(key: key);

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-20,0),
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
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      shapes: [groundShape],
      mass: 0,
      orientation: vmath.Quaternion.euler(0,-math.pi / 2, 0)
    );
    demo.addRigidBody(groundBody);

    const size = 1.0;

    // Sphere
    final sphere = oimo.Sphere(oimo.ShapeConfig(),size);
    final sphereBody = oimo.RigidBody(
      mass: 30,
      shapes: [sphere],
      position: vmath.Vector3(0, size * 6, 0)
    );
    demo.addRigidBody(sphereBody);

    // When a body collides with another body, they both dispatch the "collide" event.
    sphereBody.collide =  (body){
      print('The sphere just collided with the ground!');
      print('Collided with body: ${body.id}');
      print('Contact between bodies: ${body.type}');
    };
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}