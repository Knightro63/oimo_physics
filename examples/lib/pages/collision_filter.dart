import 'package:flutter/material.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class CollisionFilter extends StatefulWidget {
  const CollisionFilter({
    Key? key,
  }) : super(key: key);

  @override
  _CollisionFilterState createState() => _CollisionFilterState();
}

class _CollisionFilterState extends State<CollisionFilter> {
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
    // Collision filter groups - must be powers of 2!
    const g1 = 1;
    const g2 = 2;
    const g3 = 4;

    const size = 1.0;
    const mass = 1.0;

    // Sphere
    final sphereShape = oimo.Sphere(
      oimo.ShapeConfig(
        belongsTo: g2|g3,
        collidesWith: g1,
        density: mass,
        geometry: oimo.Shapes.sphere
      ),
      size
    );
    final sphereBody = oimo.RigidBody(
      position: oimo.Vec3(-5, 0, 0),
      shapes: [sphereShape],
      type: oimo.RigidBodyType.dynamic
    );
    sphereBody.linearVelocity = oimo.Vec3(5, 0, 0);

    // Box
    final boxBody = oimo.RigidBody(
      type: oimo.RigidBodyType.dynamic,
      shapes: [oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box,density: 0.1, belongsTo: g1,collidesWith: g2),size*2, size*2, size*2)],
    );

    // Cylinder
    final cylinderShape = oimo.Cylinder(
      oimo.ShapeConfig(
        geometry: oimo.Shapes.cylinder,
        density: 0.1,
        belongsTo: g1,
        collidesWith: g3,
      ),
      size, 
      size * 2.2, 
    );
    final cylinderBody = oimo.RigidBody(
      shapes: [cylinderShape],
      position: oimo.Vec3(5, 0, 0),
      type: oimo.RigidBodyType.dynamic
    );

    demo.addRigidBody(sphereBody);
    demo.addRigidBody(boxBody);
    demo.addRigidBody(cylinderBody);
  }

  void setupWorld(){
    setScene();
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}