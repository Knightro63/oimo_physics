import 'package:flutter/material.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class Spring extends StatefulWidget {
  const Spring({
    Key? key,
  }) : super(key: key);

  @override
  _SpringState createState() => _SpringState();
}

class _SpringState extends State<Spring> {
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

    const size = 1.0;

    // Create a static sphere
    oimo.Sphere sphereShape = oimo.Sphere(oimo.ShapeConfig(),0.1);
    final sphereBody = oimo.RigidBody(
      mass: 0,
      shapes: [sphereShape]
    );
    demo.addRigidBody(sphereBody);

    // Create a box body
    final boxShape = oimo.Box(oimo.ShapeConfig(),size*2, size*2, size * 0.6);
    final boxBody = oimo.RigidBody( 
      mass: 5,
      shapes: [boxShape],
      position: oimo.Vec3(size, -size, 0)
    );
    demo.addRigidBody(boxBody);

    final spring = oimo.DistanceJoint(
      oimo.JointConfig(
        body1: sphereBody,
        body2: boxBody,
        localAxis1: oimo.Vec3(0,0,1),
        localAxis2: oimo.Vec3(0,0,1),
        localAnchorPoint2: oimo.Vec3(size, size, size*0.3),
        localAnchorPoint1: oimo.Vec3(0, 0, 0),
      ),0,1
    );
    spring.limitMotor.setSpring(500, 0.3);
    world.addJoint(spring);
    
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}