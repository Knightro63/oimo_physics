import 'package:flutter/material.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class Trigger extends StatefulWidget {
  const Trigger({
    Key? key,
  }) : super(key: key);

  @override
  _TriggerState createState() => _TriggerState();
}

class _TriggerState extends State<Trigger> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: oimo.Vec3(0,0,0),
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
    const radius = 1.0;

    // Sphere moving towards right
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),radius);
    final sphereBody = oimo.RigidBody(
      shapes: [sphereShape],
      mass: 1,
      position: oimo.Vec3(-5, 0, 0),
    );
    oimo.Vec3 impulse = oimo.Vec3(5.5, 0, 0);
    oimo.Vec3 topPoint = oimo.Vec3(0, radius, 0);
    sphereBody.applyImpulse(topPoint,impulse);
    demo.addRigidBody(sphereBody);

    // Trigger body
    final boxShape = oimo.Box(oimo.ShapeConfig(),4,4,10);
    final triggerBody = oimo.RigidBody(
      shapes: [boxShape],
      isTrigger: true,
      position: oimo.Vec3(5, radius, 0)
    );
    triggerBody.collide = (body){
      if (body == sphereBody) {
        print('The sphere entered the trigger! $body');
      }
    };
    demo.addRigidBody(triggerBody);
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}