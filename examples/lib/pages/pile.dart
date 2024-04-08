import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' as vmath;

class Pile extends StatefulWidget {
  const Pile({
    Key? key,
  }) : super(key: key);

  @override
  _PileState createState() => _PileState();
}

class _PileState extends State<Pile> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-50,0),
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
  void setScene() {
    final world = demo.world;

    final groundShape = oimo.Plane(oimo.ShapeConfig());
    final groundBody = oimo.RigidBody(
      mass: 0, 
      shapes: [groundShape],
      orientation: vmath.Quaternion.euler(0,-Math.PI / 2, 0)
    );
    demo.addRigidBody(groundBody);

    final planeShapeXmin = oimo.Plane(oimo.ShapeConfig());
    final planeXmin = oimo.RigidBody(
      mass: 0,
      shapes: [planeShapeXmin],
      orientation: vmath.Quaternion.euler(0, Math.PI / 2, 0),
      position: vmath.Vector3(-5, 0, 0)
    );
    world.addRigidBody(planeXmin);

    // Plane +x
    final planeShapeXmax = oimo.Plane(oimo.ShapeConfig());
    final planeXmax = oimo.RigidBody(
      mass: 0,
      shapes: [planeShapeXmax],
      orientation: vmath.Quaternion.euler(0, -Math.PI / 2, 0),
      position: vmath.Vector3(5, 0, 0)
    );
    world.addRigidBody(planeXmax);
    
    // Plane -z
    final planeShapeZmin = oimo.Plane(oimo.ShapeConfig());
    final planeZmin = oimo.RigidBody(
      mass: 0,
      shapes: [planeShapeZmin],
      orientation: vmath.Quaternion.euler(0, 0, 0),
      position: vmath.Vector3(0, 0, -5)
    );
    world.addRigidBody(planeZmin);

    // Plane +z
    final planeShapeZmax = oimo.Plane(oimo.ShapeConfig());
    final planeZmax = oimo.RigidBody(
      mass: 0,
      shapes: [planeShapeZmax],
      orientation: vmath.Quaternion.euler(0, Math.PI, 0),
      position: vmath.Vector3(0, 0, 5)
    );
    world.addRigidBody(planeZmax);

    const size = 1.0;
    List<oimo.RigidBody> bodies = [];
    int i = 0;

    demo.addAnimationEvent((dt){
      i++;
      final sphereShape = oimo.Sphere(oimo.ShapeConfig(),size);
      final sphereBody = oimo.RigidBody(
        shapes: [sphereShape],
        mass: 5,
        position: vmath.Vector3(-size * 2 * Math.sin(i), size * 2 * 7, size * 2 * Math.cos(i)),
      );
      demo.addRigidBody(sphereBody);
      bodies.add(sphereBody);

      if (bodies.length > 80) {
        final bodyToKill = bodies.removeAt(0);
        demo.removeVisual(bodyToKill);
        world.removeRigidBody(bodyToKill);
      }
    });
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}