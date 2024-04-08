import 'package:flutter/material.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Tween extends StatefulWidget {
  const Tween({
    Key? key,
  }) : super(key: key);

  @override
  _TweenState createState() => _TweenState();
}

class _TweenState extends State<Tween> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-5,0),
        iterations: 50,
        broadPhaseType: oimo.BroadPhaseType.sweep,
        setPerformance: true
      ),
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

    final startPosition = vmath.Vector3(-5, 2, 0);
    vmath.Vector3 endPosition = vmath.Vector3(5, 2, 0);
    const tweenTime = 3; // seconds

    oimo.Box boxShape = oimo.Box(oimo.ShapeConfig(),2,2,2);
    final body = oimo.RigidBody(
      shapes: [boxShape],
      mass: 0,
      type: oimo.RigidBodyType.kinematic,
      position: startPosition,
    );
    demo.addRigidBody(body);

    // Compute direction vector and get total length of the path
    final direction = vmath.Vector3.zero();
    endPosition.sub2(startPosition, direction);
    double totalLength = direction.length;
    direction.normalize();
    double speed = totalLength / tweenTime;
    body.linearVelocity..setFrom(direction)..scale(speed*1.3);

    // Save the start time
    double startTime = world.time;

    void postStepListener() {
      // Progress is a number where 0 is at start position and 1 is at end position
      double progress = (world.time - startTime) / tweenTime; 
      if (progress > 1) {
        body.linearVelocity.setValues(0, 0, 0);
        body.position.setFrom(endPosition);
        world.postLoop = null;
      }
    }

    world.postLoop = postStepListener;
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}