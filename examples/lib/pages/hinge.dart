import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Hinge extends StatefulWidget {
  const Hinge({
    Key? key,
  }) : super(key: key);

  @override
  _HingeState createState() => _HingeState();
}

class _HingeState extends State<Hinge> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-9.81,0),
        iterations: 5,
        broadPhaseType: oimo.BroadPhaseType.volume,
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

    // Static ground plane
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      mass: 0, 
      shapes: [groundShape],
      position: vmath.Vector3(0,-1.2,0),
      orientation: vmath.Quaternion.euler(0,-Math.PI / 2, 0)
    );
    demo.addRigidBody(groundBody);

    const mass = 1.0;

    // Wheels
    final leftFrontWheel = oimo.RigidBody(
      mass: mass, 
      shapes: [oimo.Sphere(oimo.ShapeConfig(),1.2)],
      position: vmath.Vector3(-5, 0, 5),
      //angularVelocity: vmath.Vector3(0,0,14)
    );
    final rightFrontWheel = oimo.RigidBody(
      mass: mass,
      shapes: [oimo.Sphere(oimo.ShapeConfig(),1.2)],
      position: vmath.Vector3(-5, 0, -5)
    );
    final leftRearWheel = oimo.RigidBody(
      mass: mass,
      shapes: [oimo.Sphere(oimo.ShapeConfig(),1.2)],
      position: vmath.Vector3(5, 0, 5),
    );
    final rightRearWheel = oimo.RigidBody(
      mass: mass,
      shapes: [oimo.Sphere(oimo.ShapeConfig(),1.2)],
      position: vmath.Vector3(5, 0, -5),
    );

    final chassisShape = oimo.Box(oimo.ShapeConfig(),10,1, 4);
    final chassis = oimo.RigidBody(
      mass: mass,
      shapes: [chassisShape],
    );

    // finalrain wheels
    List constraints = [];

    // Hinge the wheels
    final leftAxis = vmath.Vector3(0, 0, 1);
    //final rightAxis = vmath.Vector3(0, 0, -1);
    // final leftFrontAxis = vmath.Vector3(0, 0, 1);
    // final rightFrontAxis = vmath.Vector3(0, 0, -1);
    final leftFrontAxis = vmath.Vector3(-0.3, 0, 0.7);
    //final rightFrontAxis = vmath.Vector3(0.3, 0, -0.7);

    constraints.add(
      oimo.WheelJoint(
        oimo.JointConfig(
          body1: chassis,
          body2: leftFrontWheel,
          localAnchorPoint1: vmath.Vector3(-5, 0, 5),
          localAnchorPoint2: vmath.Vector3(0,0,0),
          localAxis1: leftFrontAxis,
          localAxis2: leftAxis
        )
      )
    );
    // constraints.add(
    //   oimo.WheelJoint(
    //     oimo.JointConfig(
    //       body1: chassis,
    //       body2: rightFrontWheel,
    //       localAnchorPoint1: vmath.Vector3(-5, 0, -5),
    //       //localAnchorPoint2: vmath.Vector3(0,0,1),
    //       localAxis1: rightFrontAxis,
    //       localAxis2: rightAxis
    //     )
    //   )
    // );
    // constraints.add(
    //   oimo.WheelJoint(
    //     oimo.JointConfig(
    //       body1: chassis,
    //       body2: leftRearWheel,
    //       localAnchorPoint1: vmath.Vector3(5, 0, 5),
    //       //localAnchorPoint2: vmath.Vector3(0,0,1),
    //       localAxis1: leftAxis,
    //       localAxis2: leftAxis
    //     )
    //   )
    // );
    // constraints.add(
    //   oimo.WheelJoint(
    //     oimo.JointConfig(
    //       body1: chassis,
    //       body2: rightRearWheel,
    //       localAnchorPoint1: vmath.Vector3(5, 0, -5),
    //       //localAnchorPoint2: vmath.Vector3(0,0,1),
    //       localAxis1: rightAxis,
    //       localAxis2: rightAxis
    //     )
    //   )
    // );

    constraints.forEach((constraint){
      world.addJoint(constraint);
    });

    final bodies = [chassis, leftFrontWheel, rightFrontWheel, leftRearWheel, rightRearWheel];
    bodies.forEach((body){
      demo.addRigidBody(body);
    });

    // Enable motors and set their velocities
    // final oimo.HingeJoint frontLeftHinge = constraints[2];
    // final oimo.HingeJoint frontRightHinge = constraints[3];
    // const velocity = -14.0;
    // frontLeftHinge.limitMotor.setMotor(velocity,10);
    // frontRightHinge.limitMotor.setMotor(-velocity,10);
    // frontLeftHinge.limitMotor.setSpring(10,0.1);
    // frontRightHinge.limitMotor.setSpring(10,0.1);
  }

  void setScene2(){
    final world = demo.world;
     world.gravity.setValues(0, -20, 5);

    const size = 5.0;
    const distance = size * 0.1;

    final hingedBody = oimo.RigidBody(
      mass:1,
      shapes: [oimo.Box(oimo.ShapeConfig(),size, size, size * 0.1*2)]
    );
    demo.addRigidBody(hingedBody);

    final staticBody = oimo.RigidBody(
      mass: 0,
      shapes: [oimo.Box(oimo.ShapeConfig(),size, size, size * 0.1*2)],
      position: vmath.Vector3(0,size + distance * 2,0)
    );
    demo.addRigidBody(staticBody);

    // Hinge it
    final finalraint = oimo.HingeJoint(
      oimo.JointConfig(
        body1: staticBody,
        body2: hingedBody,
        localAnchorPoint1: vmath.Vector3(0, -size * 0.5 - distance, 0,),
        localAnchorPoint2: vmath.Vector3(0, size * 0.5 + distance, 0),
        localAxis1: vmath.Vector3(-1, 0, 0),
        localAxis2: vmath.Vector3(-1, 0, 0)
      ),
      0,Math.PI
    );
    world.addJoint(finalraint);
  }

  void setupWorld(){
    demo.addScene('Hinge',setScene2);
    //demo.addScene('Motor',setScene);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}