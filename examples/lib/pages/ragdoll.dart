import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class RagdollData{
  RagdollData({
    required this.bodies,
    required this.constraints
  });
  List<oimo.RigidBody> bodies;
  List<oimo.Joint> constraints;
}

class RagDoll extends StatefulWidget {
  const RagDoll({
    Key? key,
  }) : super(key: key);

  @override
  _RagDollState createState() => _RagDollState();
}

class _RagDollState extends State<RagDoll> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: oimo.Vec3(0,-5,0),
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
  void setScene() {
    final groundShape = oimo.Box(oimo.ShapeConfig(),100,100,1);
    final groundBody = oimo.RigidBody(
      mass: 0,
      shapes: [groundShape],
      position: oimo.Vec3(0, -1, 0),
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, -0.5, 0)
    );
    demo.addRigidBody(groundBody);
  }
  void normalConeJoints(){
    setScene();
    final world = demo.world;

    // Add a sphere to land on
    demo.addRigidBody(createStaticSphere());

    // Create the ragdoll
    // It returns an array of body parts and their constraints
    final RagdollData data = createRagdoll(
      scale: 3,
      angle: Math.PI / 4,
      angleShoulders: Math.PI / 3,
      twistAngle: Math.PI / 8,
    );

    data.bodies.forEach((body){
      // Move the ragdoll up
      final position = oimo.Vec3(0, 10, 0);
      body.position.vadd(position, body.position);
      demo.addRigidBody(body);
    });

    data.constraints.forEach((constraint){
      world.addJoint(constraint);
    });
  }
  void noConeJoints(){
    setScene();
    final world = demo.world;

    // Add a sphere to land on
    final sphereBody = createStaticSphere();
    demo.addRigidBody(sphereBody);

    // Create the ragdoll
    // It returns an array of body parts and their constraints
    final RagdollData data = createRagdoll(
      scale: 3,
      angle: Math.PI/4,
      angleShoulders: Math.PI,
      twistAngle: Math.PI/5,
    );
      // angle: Math.PI / 4,
      // angleShoulders: Math.PI / 3,
      // twistAngle: Math.PI / 8,
    data.bodies.forEach((body){
      // Move the ragdoll up
      final position = oimo.Vec3(0, 10, 0);
      body.position.vadd(position, body.position);
      demo.addRigidBody(body);
    });

    data.constraints.forEach((constraint){
      world.addJoint(constraint);
    });
  }
  void thinConeJoints(){
    setScene();
    final world = demo.world;

    // Add a sphere to land on
    demo.addRigidBody(createStaticSphere());

    // Create the ragdoll
    // It returns an array of body parts and their constraints
    final RagdollData data = createRagdoll(
      scale: 3,
      angle: 0,
      angleShoulders: 0,
      twistAngle:0,
    );

    data.bodies.forEach((body){
      // Move the ragdoll up
      final position = oimo.Vec3(0, 10, 0);
      body.position.vadd(position, body.position);
      demo.addRigidBody(body);
    });

    data.constraints.forEach((constraint){
      world.addJoint(constraint);
    });
  }
  oimo.RigidBody createStaticSphere() {
    final sphereShape = oimo.Sphere(oimo.ShapeConfig(),4);
    final sphereBody = oimo.RigidBody(
      mass: 0,
      shapes: [sphereShape],
      position: oimo.Vec3(0, -1, 0)
    );
    return sphereBody;
  }
  RagdollData createRagdoll({
    double scale = 1, 
    required double angle,
    required double angleShoulders,
    required double twistAngle 
  }) {
    List<oimo.RigidBody> bodies = [];
    List<oimo.Joint> constraints = [];

    final shouldersDistance = 0.5 * scale;
    final upperArmLength = 0.4 * scale;
    final lowerArmLength = 0.4 * scale;
    final upperArmSize = 0.2 * scale;
    final lowerArmSize = 0.2 * scale;
    final neckLength = 0.1 * scale;
    final headRadius = 0.25 * scale;
    final upperBodyLength = 0.6 * scale;
    final pelvisLength = 0.4 * scale;
    final upperLegLength = 0.5 * scale;
    final upperLegSize = 0.2 * scale;
    final lowerLegSize = 0.2 * scale;
    final lowerLegLength = 0.5 * scale;

    // Lower legs
    final lowerLeftLeg = oimo.RigidBody(
      shapes: [oimo.Box(
      oimo.ShapeConfig(),
      lowerLegSize, lowerArmSize, lowerLegLength
    )],
      mass: 1,
      position: oimo.Vec3(shouldersDistance / 2, 0, lowerLegLength / 2),
    );
    final lowerRightLeg = oimo.RigidBody(
      shapes: [oimo.Box(
      oimo.ShapeConfig(),
      lowerLegSize, lowerArmSize, lowerLegLength
    )],
      mass: 1,
      position: oimo.Vec3(-shouldersDistance / 2, 0, lowerLegLength / 2),
    );
    bodies.add(lowerLeftLeg);
    bodies.add(lowerRightLeg);

    // Upper legs
    final upperLeftLeg = oimo.RigidBody(
      shapes: [oimo.Box(
      oimo.ShapeConfig(),
      upperLegSize, lowerArmSize, upperLegLength
    )],
      mass: 1,
      position: oimo.Vec3(
        shouldersDistance / 2,
        0,
        lowerLeftLeg.position.z + lowerLegLength / 2 + upperLegLength / 2
      ),
    );
    final upperRightLeg = oimo.RigidBody(
      shapes: [oimo.Box(
      oimo.ShapeConfig(),
      upperLegSize, lowerArmSize, upperLegLength
    )],
      mass: 1,
      position: oimo.Vec3(
        -shouldersDistance / 2,
        0,
        lowerRightLeg.position.z + lowerLegLength / 2 + upperLegLength / 2
      ),
    );
    bodies.add(upperLeftLeg);
    bodies.add(upperRightLeg);

    // Pelvis
    final pelvis = oimo.RigidBody(
      shapes: [oimo.Box(
      oimo.ShapeConfig(),
      shouldersDistance, lowerArmSize, pelvisLength
    )],
      mass: 1,
      position: oimo.Vec3(0, 0, upperLeftLeg.position.z + upperLegLength / 2 + pelvisLength / 2),
    );
    bodies.add(pelvis);

    // Upper body
    final upperBody = oimo.RigidBody(
      shapes: [ oimo.Box(
      oimo.ShapeConfig(),
      shouldersDistance, lowerArmSize, upperBodyLength
    )],
      mass: 1,
      position: oimo.Vec3(0, 0, pelvis.position.z + pelvisLength / 2 + upperBodyLength / 2),
    );
    bodies.add(upperBody);

    // Head
    final head = oimo.RigidBody(
      shapes: [oimo.Sphere(oimo.ShapeConfig(),headRadius)],
      mass: 1,
      position: oimo.Vec3(0, 0, upperBody.position.z + upperBodyLength / 2 + headRadius + neckLength),
    );
    bodies.add(head);

    // Upper arms
    final upperLeftArm = oimo.RigidBody(
      shapes: [oimo.Box(oimo.ShapeConfig(),upperArmLength, upperArmSize, upperArmSize)],
      mass: 1,
      position: oimo.Vec3(
        shouldersDistance / 2 + upperArmLength / 2,
        0,
        upperBody.position.z + upperBodyLength / 2
      ),
    );
    final upperRightArm = oimo.RigidBody(
      mass: 1,
      shapes: [oimo.Box(oimo.ShapeConfig(),upperArmLength, upperArmSize, upperArmSize)],
      position: oimo.Vec3(
        -shouldersDistance / 2 - upperArmLength / 2,
        0,
        upperBody.position.z + upperBodyLength / 2
      ),
    );
    bodies.add(upperLeftArm);
    bodies.add(upperRightArm);

    // Lower arms
    final lowerLeftArm = oimo.RigidBody(
      shapes: [oimo.Box(
      oimo.ShapeConfig(),
      lowerArmLength, lowerArmSize, lowerArmSize
    )],
      mass: 1,
      position: oimo.Vec3(
        upperLeftArm.position.x + lowerArmLength / 2 + upperArmLength / 2,
        0,
        upperLeftArm.position.z
      ),
    );
    final lowerRightArm = oimo.RigidBody(
      shapes: [oimo.Box(
      oimo.ShapeConfig(),
      lowerArmLength, lowerArmSize, lowerArmSize
    )],
      mass: 1,
      position: oimo.Vec3(
        upperRightArm.position.x - lowerArmLength / 2 - upperArmLength / 2,
        0,
        upperRightArm.position.z
      ),
    );
    bodies.add(lowerLeftArm);
    bodies.add(lowerRightArm);

    // Neck joint
    final neckJoint = oimo.HingeJoint(
      oimo.JointConfig(
        body1:head, 
        body2:upperBody,
        localAnchorPoint1: oimo.Vec3(0, 0, -headRadius - neckLength / 2),
        localAnchorPoint2: oimo.Vec3(0, 0, upperBodyLength / 2),
        localAxis1: oimo.Vec3(0,1,0),
        localAxis2: oimo.Vec3(0,1,0),
      ),
      angle,
      twistAngle,
    );
    constraints.add(neckJoint);

    // Knee joints
    final leftKneeJoint = oimo.HingeJoint(
      oimo.JointConfig(
        body1:lowerLeftLeg, 
        body2:upperLeftLeg,
        localAnchorPoint1: oimo.Vec3(0, 0, lowerLegLength / 2),
        localAnchorPoint2: oimo.Vec3(0, 0, -upperLegLength / 2),
        localAxis1: oimo.Vec3(1,0,0),
        localAxis2: oimo.Vec3(1,0,0),
      ),
      angle,
      twistAngle,
    );
    final rightKneeJoint = oimo.HingeJoint(
      oimo.JointConfig(
        body1:lowerRightLeg, 
        body2:upperRightLeg, 
        localAnchorPoint1: oimo.Vec3(0, 0, lowerLegLength / 2),
        localAnchorPoint2: oimo.Vec3(0, 0, -upperLegLength / 2),
        localAxis1: oimo.Vec3(1,0,0),
        localAxis2: oimo.Vec3(1,0,0),
      ),
      angle,
      twistAngle,
    );
    constraints.add(leftKneeJoint);
    constraints.add(rightKneeJoint);

    // Hip joints
    final leftHipJoint = oimo.HingeJoint(
      oimo.JointConfig(
        body1: upperLeftLeg, 
        body2: pelvis,
        localAnchorPoint1: oimo.Vec3(0, 0, upperLegLength / 2),
        localAnchorPoint2: oimo.Vec3(shouldersDistance / 2, 0, -pelvisLength / 2),
        localAxis1: oimo.Vec3(0,1,0),
        localAxis2: oimo.Vec3(0,1,0),
      ),
      angle,
      twistAngle,
    );
    final rightHipJoint = oimo.HingeJoint(
      oimo.JointConfig(
        body1:upperRightLeg, 
        body2:pelvis,
        localAnchorPoint1: oimo.Vec3(0, 0, upperLegLength / 2),
        localAnchorPoint2: oimo.Vec3(-shouldersDistance / 2, 0, -pelvisLength / 2),
        localAxis1: oimo.Vec3(0,1,0),
        localAxis2: oimo.Vec3(0,1,0),
      ),
      angle,
      twistAngle,
    );
    constraints.add(leftHipJoint);
    constraints.add(rightHipJoint);

    // Spine
    final spineJoint = oimo.HingeJoint(
      oimo.JointConfig(
        body1:pelvis, 
        body2:upperBody,
        localAnchorPoint1: oimo.Vec3(0, 0, pelvisLength / 2),
        localAnchorPoint2: oimo.Vec3(0, 0, -upperBodyLength / 2),
         localAxis1: oimo.Vec3(1,0,0),
        localAxis2: oimo.Vec3(1,0,0),
      ),
      angle,
      twistAngle,
    );
    constraints.add(spineJoint);

    // Shoulders
    final leftShoulder = oimo.HingeJoint(
      oimo.JointConfig(
        body1:upperBody, 
        body2:upperLeftArm,
        localAnchorPoint1: oimo.Vec3(shouldersDistance / 2, 0, upperBodyLength / 2),
        localAnchorPoint2: oimo.Vec3(-upperArmLength / 2, 0, 0),
        localAxis1: oimo.Vec3(1,0,0),
        localAxis2: oimo.Vec3(1,0,0),
      ),
      0,
      angleShoulders,
    );
    final rightShoulder = oimo.HingeJoint(
      oimo.JointConfig(
        body1:upperBody, 
        body2:upperRightArm,
        localAnchorPoint1: oimo.Vec3(-shouldersDistance / 2, 0, upperBodyLength / 2),
        localAnchorPoint2: oimo.Vec3(upperArmLength / 2, 0, 0),
        localAxis1: oimo.Vec3(0,1,1),
        localAxis2: oimo.Vec3(0,1,1),
      ),
      0,
      angleShoulders,
    );
    constraints.add(leftShoulder);
    constraints.add(rightShoulder);

    // Elbow joint
    final leftElbowJoint = oimo.HingeJoint(
      oimo.JointConfig(
        body1:lowerLeftArm, 
        body2:upperLeftArm,
        localAnchorPoint1: oimo.Vec3(-lowerArmLength / 2, 0, 0),
        localAnchorPoint2: oimo.Vec3(upperArmLength / 2, 0, 0),
        localAxis1: oimo.Vec3(0,1,0),
        localAxis2: oimo.Vec3(0,1,0),
      ),
      angle,
      twistAngle,
    );
    final rightElbowJoint = oimo.HingeJoint(
      oimo.JointConfig(
        body1:lowerRightArm, 
        body2:upperRightArm,
        localAnchorPoint1: oimo.Vec3(lowerArmLength / 2, 0, 0),
        localAnchorPoint2: oimo.Vec3(-upperArmLength / 2, 0, 0),
        localAxis1: oimo.Vec3(0,1,0),
        localAxis2: oimo.Vec3(0,1,0),
      ),
      angle,
      twistAngle,
    );
    constraints.add(leftElbowJoint);
    constraints.add(rightElbowJoint);

    return RagdollData(bodies:bodies, constraints:constraints);
  }
  void setupWorld(){
    demo.addScene('Normal Cone Joints',normalConeJoints);
    demo.addScene('No Cone Joints',noConeJoints);
    demo.addScene('Thin Cone Joints',thinConeJoints);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}