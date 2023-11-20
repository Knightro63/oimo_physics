import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart';
import '../src/demo.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

class Constraints extends StatefulWidget {
  const Constraints({
    Key? key,
  }) : super(key: key);

  @override
  _ConstraintsState createState() => _ConstraintsState();
}

class _ConstraintsState extends State<Constraints> {
  late Demo demo;

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      settings: oimo.WorldConfigure(
        gravity: oimo.Vec3(0,-40,0),
        iterations: 20,
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
      position: oimo.Vec3(0, 0.5, 0),
      orientation: oimo.Quat().setFromEuler(-Math.PI / 2, 0, 0)
    );
    demo.addRigidBody(groundBody);
  }

  void lockScene(){
    setScene();
    final world = demo.world;

    world.gravity.set(0, -10, 0);
    world.numIterations = 20;

    const size = 0.5;
    const mass = 1.0;
    const space = size * 0.1;
    const N = 10;

    oimo.RigidBody? previous;
    oimo.Vec3 prevPos = oimo.Vec3();
    for (int i = 0; i < N; i++) {
      final newPos = oimo.Vec3(-(N - i - N / 2) * (size * 2 + 2 * space), size * 6 + space, 0);
      // Create a box
      final boxBody = oimo.RigidBody(
        mass: mass,
        shapes: [oimo.Box(oimo.ShapeConfig(),size*2, size*2, size*2)],
        position: newPos,
      );
      demo.addRigidBody(boxBody);

      if (previous != null) {
        //double dist = (size+space)*2;
        // Connect the current body to the last one
        final lockConstraint = oimo.HingeJoint(
          oimo.JointConfig(
            body1: previous,
            body2: boxBody,
            localAnchorPoint1: oimo.Vec3().copy(newPos).vadd(oimo.Vec3(size,0,size)),
            localAnchorPoint2: oimo.Vec3().copy(prevPos).vadd(oimo.Vec3(size,0,size)),
            localAxis1: oimo.Vec3(0, 0, 1),
            localAxis2: oimo.Vec3(0, 0, 1),
            allowCollision: true
          ),
          0,
          0.05
        );
        world.addJoint(lockConstraint);
      }

      // To keep track of which body was added last
      previous = boxBody;
      prevPos.copy(newPos);
    }

    // Create stands
    final body1 = oimo.RigidBody(
      mass: 0,
      shapes: [oimo.Box(oimo.ShapeConfig(),size*2, size*2, size*2)],
      position: oimo.Vec3(-(-N / 2 + 1) * (size * 2 + 2 * space), size * 3, 0),
    );
    demo.addRigidBody(body1);

    final body2 = oimo.RigidBody(
      mass: 0,
      shapes: [oimo.Box(oimo.ShapeConfig(),size*2, size*2, size*2)],
      position: oimo.Vec3(-(N / 2) * (size * 2 + space * 2), size * 3, 0),
    );
    demo.addRigidBody(body2);
  }
  void linkScene(){
    setScene();
    final world = demo.world;
    world.gravity.set(0, -20, -1);

    const size = 1.0;
    double mass = 0;
    const space = size * 0.1;

    final boxShape = oimo.Box(oimo.ShapeConfig(),size, size, size * 0.1);

    const N = 10;
    oimo.RigidBody? previous;
    for (int i = 0; i < N; i++) {
      // Create a box
      final boxBody = oimo.RigidBody(
        mass:mass,
        shapes: [boxShape],
        position: oimo.Vec3(0, (N - i) * (size * 2 + space * 2) + size * 2 + space, 0)
      );
      demo.addRigidBody(boxBody);

      if (i != 0) {
        // Connect the current body to the last one
        // We connect two corner points to each other.
        final pointConstraint1 = oimo.BallAndSocketJoint(
          oimo.JointConfig(
            body1: boxBody,
            body2: previous!,
            localAnchorPoint1: oimo.Vec3(size, size + space, 0),
            localAnchorPoint2: oimo.Vec3(size, -size - space, 0)
          )
        );
        final pointConstraint2 = oimo.BallAndSocketJoint(
          oimo.JointConfig(
            body1: boxBody,
            body2: previous,
            localAnchorPoint1: oimo.Vec3(-size, size + space, 0),
            localAnchorPoint2: oimo.Vec3(-size, -size - space, 0)
          )
        );

        world.addJoint(pointConstraint1);
        world.addJoint(pointConstraint2);
      } else {
        // First body is now static. The rest should be dynamic.
        mass = 0.3;
      }

      // To keep track of which body was added last
      previous = boxBody;
    }
  }
  void clothOnSphere(){
    setScene();
    final world = demo.world;

    const dist = 0.2;
    const mass = 0.5;
    // To construct the cloth we need rows*cols particles.
    const rows = 15;
    const cols = 15;

    Map<String,oimo.RigidBody> bodies = {}; // bodies['i j'] => particle
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        // Create a new body
        final body = oimo.RigidBody(
          mass: mass,
          shapes: [oimo.Sphere(oimo.ShapeConfig(),0.08)]
        );
        body.position.set(-(i - cols * 0.5) * dist, 5, (j - rows * 0.5) * dist);
        bodies['$i $j'] = body;
        demo.addRigidBody(body);
      }
    }

    // To connect two particles, we use a distance constraint. This forces the particles to be at a constant distance from each other.
    void connect(i1, j1, i2, j2) {
      final distanceConstraint = oimo.DistanceJoint(
        oimo.JointConfig(
          body1: bodies['$i1 $j1']!,
          body2: bodies['$i2 $j2']!
        ),
        dist,
        dist
      );
      world.addJoint(distanceConstraint);
    }

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        // Connect particle at position (i,j) to (i+1,j) and to (i,j+1).
        if (i < cols - 1) connect(i, j, i + 1, j);
        if (j < rows - 1) connect(i, j, i, j + 1);
      }
    }

    // Add the static sphere we throw the cloth on top of
    final sphere = oimo.Sphere(oimo.ShapeConfig(),1.5);
    final body = oimo.RigidBody(
      shapes: [sphere],
      mass: 0,
      position: oimo.Vec3(0, 3.5, 0)
    );
    demo.addRigidBody(body);
  }
  void spherePendulum(){
    setScene();
    final world = demo.world;

    const size = 1.0;
    const mass = 1.0;

    final spherebody = oimo.RigidBody(
      shapes: [oimo.Sphere(oimo.ShapeConfig(),size)],
      mass:mass,
      position: oimo.Vec3(0, size * 3, 0),
      linearVelocity: oimo.Vec3(-5, 0, 0)
    );
    demo.addRigidBody(spherebody);

    final spherebody2 = oimo.RigidBody(
      mass: 0,
      shapes: [oimo.Sphere(oimo.ShapeConfig(),size)],
      position: oimo.Vec3(0, size * 7, 0)
    );
    demo.addRigidBody(spherebody2);

    // Connect this body to the last one
    final pointConstraint = oimo.BallAndSocketJoint(
      oimo.JointConfig(
        body1: spherebody,
        body2: spherebody2,
        localAnchorPoint1: oimo.Vec3(0, size * 2, 0),
        localAnchorPoint2: oimo.Vec3(0, -size * 2, 0)
      )
    );
    world.addJoint(pointConstraint);
  }
  void sphereChain(){
    setScene();
    final world = demo.world;
    // world.solver.setSpookParams(1e20, 3)

    const size = 0.5;
    const dist = size * 2 + 0.12;
    const mass = 1.0;
    const N = 20;

    world.numIterations = N ;// To be able to propagate force throw the chain of N spheres, we need at least N solver iterations.

    oimo.RigidBody? previous;
    for (int i = 0; i < N; i++) {
      // Create a new body
      final sphereBody = oimo.RigidBody(
        shapes: [oimo.Sphere(oimo.ShapeConfig(),size)],
        mass: i == 0 ? 0 : mass,
        position: oimo.Vec3(0, dist * (N - i), 0),
        linearVelocity: oimo.Vec3(-i*1.0)
      );
      demo.addRigidBody(sphereBody);

      // Connect this body to the last one added
      if (previous != null) {
        final distanceConstraint = oimo.DistanceJoint(
          oimo.JointConfig(
            body1: sphereBody,
            body2: previous
          ),  
          dist,
          dist
        );
        world.addJoint(distanceConstraint);
      }

      // Keep track of the lastly added body
      previous = sphereBody;
    }
  }
  void particleCloth(){
    setScene();
    final world = demo.world;
    // world.solver.setSpookParams(1e20, 3)
    world.numIterations = 18;

    const dist = 0.2;
    const mass = 0.5;
    const rows = 15;
    const cols = 15;

    Map<String,oimo.RigidBody> bodies = {}; // bodies['i j'] => particle
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        // Create a new body
        final body = oimo.RigidBody(
          shapes: [oimo.Sphere(oimo.ShapeConfig(),0.1)],
          mass: j == rows - 1 ? 0 : mass,
          position: oimo.Vec3(-dist * i, dist * j + 5, 0),
          linearVelocity: oimo.Vec3(0, 0, (Math.sin(i * 0.1) + Math.sin(j * 0.1)) * 3)
        );
        bodies['$i $j'] = body;
        demo.addRigidBody(body);
      }
    }

    void connect(i1, j1, i2, j2) {
      final distanceConstraint = oimo.DistanceJoint(
        oimo.JointConfig(
          body1: bodies['$i1 $j1']!,
          body2: bodies['$i2 $j2']!,
          allowCollision: true
        ),
        dist,
        dist
      );
      world.addJoint(distanceConstraint);
    }

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        if (i < cols - 1) connect(i, j, i + 1, j);
        if (j < rows - 1) connect(i, j, i, j + 1);
      }
    }
  }
  void clothStructure(){
    setScene();
    final world = demo.world;

    // Max solver iterations: Use more for better force propagation, but keep in mind that it's not very computationally cheap!
    world.numIterations = 20;

    const dist = 1.0;
    const mass = 1.0;
    const Nx = 6;
    const Ny = 3;
    const Nz = 3;

    Map<String,oimo.RigidBody> bodies = {}; // bodies['i j k'] => particle
    for (int i = 0; i < Nx; i++) {
      for (int j = 0; j < Ny; j++) {
        for (int k = 0; k < Nz; k++) {
          // Create a new body
          final body = oimo.RigidBody(
            shapes: [oimo.Sphere(oimo.ShapeConfig(),0.08)],
            mass:mass,
            position: oimo.Vec3(-dist * i, dist * k + dist * Nz * 0.3 + 1, dist * j),
            linearVelocity: oimo.Vec3(0, 0, (Math.sin(i * 0.1) + Math.sin(j * 0.1)) * 30)
          );
          bodies['$i $j $k'] = body;
          demo.addRigidBody(body);
        }
      }
    }

    void connect(i1, j1, k1, i2, j2, k2, distance) {
      final distanceConstraint = oimo.DistanceJoint(
        oimo.JointConfig(
          body1: bodies['$i1 $j1 $k1']!,
          body2: bodies['$i2 $j2 $k2']!
        ),
        distance,
        distance
      );
      world.addJoint(distanceConstraint);
    }

    for (int i = 0; i < Nx; i++) {
      for (int j = 0; j < Ny; j++) {
        for (int k = 0; k < Nz; k++) {
          // normal directions
          if (i < Nx - 1) connect(i, j, k, i + 1, j, k, dist);
          if (j < Ny - 1) connect(i, j, k, i, j + 1, k, dist);
          if (k < Nz - 1) connect(i, j, k, i, j, k + 1, dist);

          // Diagonals
          if (i < Nx - 1 && j < Ny - 1 && k < Nz - 1) {
            // 3d diagonals
            connect(i, j, k, i + 1, j + 1, k + 1, Math.sqrt(3) * dist);
            connect(i + 1, j, k, i, j + 1, k + 1, Math.sqrt(3) * dist);
            connect(i, j + 1, k, i + 1, j, k + 1, Math.sqrt(3) * dist);
            connect(i, j, k + 1, i + 1, j + 1, k, Math.sqrt(3) * dist);
          }

          // 2d diagonals
          if (i < Nx - 1 && j < Ny - 1) {
            connect(i + 1, j, k, i, j + 1, k, Math.sqrt(2) * dist);
            connect(i, j + 1, k, i + 1, j, k, Math.sqrt(2) * dist);
          }
          if (i < Nx - 1 && k < Nz - 1) {
            connect(i + 1, j, k, i, j, k + 1, Math.sqrt(2) * dist);
            connect(i, j, k + 1, i + 1, j, k, Math.sqrt(2) * dist);
          }
          if (j < Ny - 1 && k < Nz - 1) {
            connect(i, j + 1, k, i, j, k + 1, Math.sqrt(2) * dist);
            connect(i, j, k + 1, i, j + 1, k, Math.sqrt(2) * dist);
          }
        }
      }
    }
  }
  void setupWorld(){
    demo.addScene('Lock',lockScene);
    demo.addScene('Link',clothOnSphere);
    demo.addScene('Sphere Pendulum',spherePendulum);
    demo.addScene('Sphere Chain',sphereChain);
    demo.addScene('Particle Cloth',particleCloth);
    demo.addScene('Cloth Structure',clothStructure);
  }
  @override
  Widget build(BuildContext context) {
    return demo.threeDart();
  }
}