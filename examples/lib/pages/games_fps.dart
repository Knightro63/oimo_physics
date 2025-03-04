import 'dart:async';
import 'dart:math' as math;

import 'package:oimo_physics/core/rigid_body.dart';
import 'package:oimo_physics_example/src/conversion_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:three_js/three_js.dart' as three;
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:three_js_objects/three_js_objects.dart';
import 'package:vector_math/vector_math.dart' as vmath;

class SphereData{
  SphereData({
    required this.mesh,
    required this.body,
  });

  three.Mesh mesh;
  oimo.RigidBody body;
}

class TestGame extends StatefulWidget {
  const TestGame({Key? key,}):super(key: key);

  @override
  _TestGamePageState createState() => _TestGamePageState();
}

class _TestGamePageState extends State<TestGame> {
  late three.FirstPersonControls fpsControl;
  late three.ThreeJS threeJs;
  int stepsPerFrame = 5;

  double gravity = 30;

  List<oimo.RigidBody> balls = [];
  int sphereIdx = 0;

  Capsule playerCollider = Capsule(three.Vector3( 0, 0.35, 0 ), three.Vector3( 0, 1, 0 ), 0.35);
  late oimo.RigidBody playerBody;

  bool playerOnFloor = false;
  int mouseTime = 0;
  Map<LogicalKeyboardKey,bool> keyStates = {
    LogicalKeyboardKey.keyW: false,
    LogicalKeyboardKey.keyA: false,
    LogicalKeyboardKey.keyS: false,
    LogicalKeyboardKey.keyD: false,
    LogicalKeyboardKey.space: false,

    LogicalKeyboardKey.arrowUp: false,
    LogicalKeyboardKey.arrowLeft: false,
    LogicalKeyboardKey.arrowDown: false,
    LogicalKeyboardKey.arrowRight: false,
  };

  three.Vector3 vector1 = three.Vector3();
  three.Vector3 vector2 = three.Vector3();
  three.Vector3 vector3 = three.Vector3();

  late final three.Vector3 playerVelocity;
  
  late oimo.RigidBody sphereBody;

  late oimo.World world;
  List<SphereData> spheres = [];
  double? lastCallTime;
  bool split = false;
  bool paused = false;

  @override
  void initState() {
    threeJs = three.ThreeJS(
      onSetupComplete: (){setState(() {});}, 
      setup: setup,
      settings: three.Settings(
        useSourceTexture: true
      )
    );
    super.initState();
  }
  @override
  void dispose() {
    threeJs.dispose();
    super.dispose();
  }
  //----------------------------------
  //  oimo PHYSICS
  //----------------------------------
  void initoimoPhysics(){
    world = oimo.World();
    lastCallTime = world.time;
    world.gravity.setValues(0, -gravity, 0);
  }
  void updatePhysics() {
    world.step();
  }

  Future<void> setup() async {
    initoimoPhysics();
    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(0x88ccee);

    threeJs.camera = three.PerspectiveCamera(70, threeJs.width / threeJs.height, 0.1, 1000);
    threeJs.camera.rotation.order = three.RotationOrders.yxz;

    // lights
    three.HemisphereLight fillLight1 = three.HemisphereLight( 0x4488bb, 0x002244, 0.5 );
    fillLight1.position.setValues( 2, 1, 1 );
    threeJs.scene.add(fillLight1);

    three.DirectionalLight directionalLight = three.DirectionalLight( 0xffffff, 0.8 );
    directionalLight.position.setValues( - 5, 25, - 1 );
    directionalLight.castShadow = true;

    directionalLight.shadow!.camera!.near = 0.01;
    directionalLight.shadow!.camera!.far = 500;
    directionalLight.shadow!.camera!.right = 30;
    directionalLight.shadow!.camera!.left = - 30;
    directionalLight.shadow!.camera!.top	= 30;
    directionalLight.shadow!.camera!.bottom = - 30;
    directionalLight.shadow!.mapSize.width = 1024;
    directionalLight.shadow!.mapSize.height = 1024;
    directionalLight.shadow!.radius = 4;
    directionalLight.shadow!.bias = - 0.00006;

    threeJs.scene.add(directionalLight);

    three.GLTFLoader().setPath('assets/models/').fromAsset('collision-world.glb').then((gltf){
      three.Object3D object = gltf!.scene;
      oimo.Octree triShape = ConversionUtils.fromGraphNode(object,oimo.ShapeConfig());
      final triBody = oimo.RigidBody(
        shapes: [triShape],
        name: 'trimesh',
        orientation: vmath.Quaternion(0,0,0,0),
      );
      
      world.addRigidBody(triBody);
      three.Mesh m = three.Mesh(ConversionUtils.shapeToGeometry(triShape),three.MeshPhongMaterial.fromMap({
        'color': three.Color.fromHex32(0xff414141),
        'specular': three.Color(0.5, 0.5, 0.5), 
        'shininess': 15 
      }));
      threeJs.scene.add(m);

      m.traverse((child){
        if(child is three.Mesh){
          three.Mesh part = child;
          part.castShadow = true;
          part.visible = true;
          part.receiveShadow = true;
        }
      });
    });

    // Create the user collision sphere
    const double mass = 5;
    const radius = 1.3;
    sphereBody = oimo.RigidBody(
      shapes: [oimo.Sphere(
        oimo.ShapeConfig(
          density: mass, 
        ),
        radius
      )],
      position: vmath.Vector3(0, 5, 0),
      type: RigidBodyType.dynamic
    );
    // sphereBody.linearDamping = 0.9;

    //Create Player
    playerBody = oimo.RigidBody(
      shapes: [oimo.Capsule(
        oimo.ShapeConfig(
          density: mass
        ),
        radius,
        radius
      )],
      type: RigidBodyType.kinematic,
      position: vmath.Vector3(0,20,0)
    );
    world.addRigidBody(playerBody);

    //add fps controller
    fpsControl = three.FirstPersonControls(camera: threeJs.camera, listenableKey: threeJs.globalKey);
    fpsControl.lookSpeed = 1/100;
    fpsControl.movementSpeed = 15.0;
    fpsControl.lookType = three.LookType.position;
    playerVelocity = fpsControl.velocity;
    fpsControl.domElement.addEventListener( three.PeripheralType.keyup, (event){
      if(event.keyId == 32){
        playerVelocity.y = 15;
      }
    }, false );
    fpsControl.domElement.addEventListener( three.PeripheralType.pointerdown, (event){
      mouseTime = DateTime.now().millisecondsSinceEpoch;
    }, false );
    fpsControl.domElement.addEventListener( three.PeripheralType.pointerup, (event){
      throwBall();
    }, false );
    
    threeJs.addAnimationEvent((dt){
      updatePhysics();
      fpsControl.update(lastCallTime!);
      updateVisuals();
      teleportPlayerIfOob();
    });
  }

  void throwBall() {
    double ballRadius = 0.2;
    double shootVelocity = 15 + ( 1 - math.exp((mouseTime-DateTime.now().millisecondsSinceEpoch) * 0.1));
    three.SphereGeometry ballGeometry = three.SphereGeometry(ballRadius, 32, 32);

    three.Vector3 getShootDirection() {
      three.Vector3 vector = three.Vector3(0, 0, 1);
      vector.unproject(threeJs.camera);
      three.Ray ray = three.Ray.originDirection(
        playerBody.position.toVector3(), 
        vector.sub(playerBody.position.toVector3()).normalize()
      );
      return ray.direction;
    }

    three.Mesh ballMesh = three.Mesh(ballGeometry, three.MeshLambertMaterial.fromMap({ 'color': 0xdddddd }));
    ballMesh.castShadow = true;
    ballMesh.receiveShadow = true;
    
    three.Vector3 shootDirection = getShootDirection();
    oimo.RigidBody ballBody = RigidBody(
      shapes: [oimo.Sphere(
        oimo.ShapeConfig(
          density: 1,
        ),
        2
      )],
      type: RigidBodyType.dynamic,
      linearVelocity: vmath.Vector3(
        shootDirection.x * shootVelocity,
        shootDirection.y * shootVelocity,
        shootDirection.z * shootVelocity
      )
    );

    spheres.add(SphereData(
      mesh: ballMesh,
      body: ballBody,
    ));

    const radius = 0.2;
    // Move the ball outside the player sphere
    double x = playerBody.position.x + shootDirection.x * (ballRadius * 1.02 + radius);
    double y = playerBody.position.y + shootDirection.y * (ballRadius * 1.02 + radius);
    double z = playerBody.position.z + shootDirection.z * (ballRadius * 1.02 + radius);
    ballBody.position.setValues(x, y, z);
    ballMesh.position.setFrom(ballBody.position.toVector3());

    world.addRigidBody(ballBody);
    threeJs.scene.add(ballMesh);
  }
  void updatePlayer(){
    final body = playerBody;
    // Interpolated or not?
    vmath.Vector3 position = body.position;
    //vmath.Quaternion quaternion = body.orientation;

    if(paused) {
      position = body.position;
      //quaternion = body.orientation;
    }

    threeJs.camera.position.setFrom(position.toVector3());
    //camera.position.copy(playerCollider.end);
  }
  void updateVisuals(){
    for (int i = 0; i < spheres.length; i++) {
      final body = spheres[i].body;
      final visual = spheres[i].mesh;
      three.Object3D dummy = three.Object3D();

      // Interpolated or not?
      vmath.Vector3 position = body.position;
      vmath.Quaternion quaternion = body.orientation;
      if(paused) {
        position = body.position;
        quaternion = body.orientation;
      }

      if (visual is three.InstancedMesh) {
        dummy.position.setFrom(position.toVector3());
        dummy.quaternion.setFrom(quaternion.toQuaternion());

        dummy.updateMatrix();

        visual.setMatrixAt(body.id, dummy.matrix);
        visual.instanceMatrix!.needsUpdate = true;
      } 
      else {
        visual.position.setFrom(position.toVector3());
        visual.quaternion.setFrom(quaternion.toQuaternion());
      }
    }
    updatePlayer();
  }

  void teleportPlayerIfOob(){
    if(threeJs.camera.position.y <= - 25){
      playerCollider.start.setValues(0,0.35,0);
      playerCollider.end.setValues(0,1,0);
      playerCollider.radius = 0.35;
      threeJs.camera.position.setFrom(playerCollider.end);
      threeJs.camera.rotation.set(0,0,0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return threeJs.build();
  }
}