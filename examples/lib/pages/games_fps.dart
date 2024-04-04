import 'dart:async';
import 'dart:io';

import 'package:oimo_physics/core/rigid_body.dart';
import 'package:oimo_physics_example/src/conversion_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart/three_dart.dart' hide Texture, Color;
import 'package:three_dart_jsm/three_dart_jsm.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;

extension on oimo.Vec3{
  Vector3 toVector3(){
    return Vector3(x,y,z);
  }
}
extension on oimo.Quat{
  Quaternion toQuaternion(){
    return Quaternion(x,y,z,w);
  }
}
class SphereData{
  SphereData({
    required this.mesh,
    required this.body,
  });

  Mesh mesh;
  oimo.RigidBody body;
}

class TestGame extends StatefulWidget {
  const TestGame({Key? key,}):super(key: key);

  @override
  _TestGamePageState createState() => _TestGamePageState();
}

class _TestGamePageState extends State<TestGame> {
  late FirstPersonControls fpsControl;
  // gl values
  //late Object3D object;
  bool animationReady = false;
  late FlutterGlPlugin three3dRender;
  WebGLRenderTarget? renderTarget;
  WebGLRenderer? renderer;
  int? fboId;
  late double width;
  late double height;
  Size? screenSize;
  late Scene scene;
  late Camera camera;
  double dpr = 1.0;
  bool verbose = false;
  bool disposed = false;
  final GlobalKey<DomLikeListenableState> _globalKey = GlobalKey<DomLikeListenableState>();
  dynamic sourceTexture;

  int stepsPerFrame = 5;
  Clock clock = Clock();

  double gravity = 30;

  List<oimo.RigidBody> balls = [];
  int sphereIdx = 0;

  Capsule playerCollider = Capsule(Vector3( 0, 0.35, 0 ), Vector3( 0, 1, 0 ), 0.35);
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

  Vector3 vector1 = Vector3();
  Vector3 vector2 = Vector3();
  Vector3 vector3 = Vector3();

  late final Vector3 playerVelocity;
  
  late oimo.RigidBody sphereBody;

  late oimo.World world;
  List<SphereData> spheres = [];
  double? lastCallTime;
  bool split = false;
  bool paused = false;

  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    disposed = true;
    three3dRender.dispose();
    super.dispose();
  }
  //----------------------------------
  //  oimo PHYSICS
  //----------------------------------
  void initoimoPhysics(){
    world = oimo.World();
    lastCallTime = world.time;
    world.gravity.set(0, -gravity, 0);
  }
  void initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    initPlatformState();
  }
  void updatePhysics() {
    world.step();
  }
  void animate() {
    if (!mounted || disposed) {
      return;
    }
    render();
    Future.delayed(const Duration(milliseconds: 1000~/60), () {
      if(!paused){
        updatePhysics();
        fpsControl.update(lastCallTime!);
        updateVisuals();
        teleportPlayerIfOob();
      }
      animate();
    });
  }
  Future<void> initPage() async {
    scene = Scene();
    scene.background = three.Color(0x88ccee);

    camera = PerspectiveCamera(70, width / height, 0.1, 1000);
    camera.rotation.order = 'YXZ';

    // lights
    HemisphereLight fillLight1 = HemisphereLight( 0x4488bb, 0x002244, 0.5 );
    fillLight1.position.set( 2, 1, 1 );
    scene.add(fillLight1);

    DirectionalLight directionalLight = DirectionalLight( 0xffffff, 0.8 );
    directionalLight.position.set( - 5, 25, - 1 );
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

    scene.add(directionalLight);

    GLTFLoader().setPath('assets/models/').load('collision-world.glb', (gltf){
      Object3D object = gltf["scene"];
      oimo.Octree triShape = ConversionUtils.fromGraphNode(object,oimo.ShapeConfig());
      final triBody = oimo.RigidBody(
        shapes: [triShape],
        name: 'trimesh',
        orientation: oimo.Quat(),
      );
      world.addRigidBody(triBody);

      // MeshBasicMaterial triggerMaterial = MeshBasicMaterial({'color': 0x00ff00, 'wireframe': false, 'wireframeLinewidth':1.0});
      // final geometry = three.BufferGeometry();
      // geometry.setIndex(triShape.indices);
      // geometry.setAttribute('position', Float32BufferAttribute(Float32Array.from(triShape.vertices), 3));
      // scene.add(three.Mesh(geometry, triggerMaterial));

      scene.add(object);

      object.traverse((child){
        if(child.type == 'Mesh'){
          Mesh part = child;
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
      position: oimo.Vec3(0, 5, 0),
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
      type: RigidBodyType.dynamic,
    );
    world.addRigidBody(playerBody);

    //add fps controller
    fpsControl = FirstPersonControls(camera, _globalKey);
    fpsControl.lookSpeed = 1/100;
    fpsControl.movementSpeed = 15.0;
    fpsControl.lookType = LookType.position;
    playerVelocity = fpsControl.velocity;
    fpsControl.domElement.addEventListener( 'keyup', (event){
      if(event.keyId == 32){
        playerVelocity.y = 15;
      }
    }, false );
    fpsControl.domElement.addEventListener( 'pointerdown', (event){
      mouseTime = DateTime.now().millisecondsSinceEpoch;
    }, false );
    fpsControl.domElement.addEventListener( 'pointerup', (event){
      throwBall();
    }, false );
    animationReady = true;
  }
  void render() {
    final _gl = three3dRender.gl;
    renderer!.render(scene, camera);
    _gl.flush();
    if(!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }
  void initRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element,
    };

    if(!kIsWeb && Platform.isAndroid){
      _options['logarithmicDepthBuffer'] = true;
    }

    renderer = WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = true;

    if(!kIsWeb){
      WebGLRenderTargetOptions pars = WebGLRenderTargetOptions({"format": RGBAFormat,"samples": 8});
      renderTarget = WebGLRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderTarget!.samples = 8;
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget!);
    }
    else{
      renderTarget = null;
    }
  }
  void initScene() async{
    initoimoPhysics();
    await initPage();
    initRenderer();
    animate();
  }
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": true,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr,
      'precision': 'highp'
    };
    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();
      initScene();
    });
  }

  void throwBall() {
    double ballRadius = 0.2;
    double shootVelocity = 15 + ( 1 - Math.exp((mouseTime-DateTime.now().millisecondsSinceEpoch) * 0.1));
    three.SphereGeometry ballGeometry = three.SphereGeometry(ballRadius, 32, 32);

    three.Vector3 getShootDirection() {
      three.Vector3 vector = three.Vector3(0, 0, 1);
      vector.unproject(camera);
      three.Ray ray = three.Ray(sphereBody.position.toVector3(), vector.sub(sphereBody.position).normalize());
      return ray.direction;
    }

    three.Mesh ballMesh = three.Mesh(ballGeometry, three.MeshLambertMaterial({ 'color': 0xdddddd }));

    ballMesh.castShadow = true;
    ballMesh.receiveShadow = true;
    three.Vector3 shootDirection = getShootDirection();
    oimo.RigidBody ballBody = RigidBody(
      shapes: [oimo.Sphere(
        oimo.ShapeConfig(
          density: 1,
        ),
        0.2
      )],
      type: RigidBodyType.dynamic,
      linearVelocity: oimo.Vec3(
        shootDirection.x * shootVelocity,
        shootDirection.y * shootVelocity,
        shootDirection.z * shootVelocity
      )
    );

    spheres.add(SphereData(
      mesh: ballMesh,
      body: ballBody,
    ));

    const radius = 1.3;
    // Move the ball outside the player sphere
    double x = sphereBody.position.x + shootDirection.x * (ballRadius * 1.02 + radius);
    double y = sphereBody.position.y + shootDirection.y * (ballRadius * 1.02 + radius);
    double z = sphereBody.position.z + shootDirection.z * (ballRadius * 1.02 + radius);
    ballBody.position.set(x, y, z);
    ballMesh.position.copy(ballBody.position.toVector3());

    world.addRigidBody(ballBody);
    scene.add(ballMesh);
  }
  void updatePlayer(){
    final body = playerBody;
    // Interpolated or not?
    oimo.Vec3 position = body.position;
    oimo.Quat quaternion = body.orientation;

    if(paused) {
      position = body.position;
      quaternion = body.orientation;
    }

    camera.position.copy(position.toVector3());
    camera.position.copy(playerCollider.end);
  }
  void updateVisuals(){
    for (int i = 0; i < spheres.length; i++) {
      final body = spheres[i].body;
      final visual = spheres[i].mesh;
      Object3D dummy = Object3D();

      // Interpolated or not?
      oimo.Vec3 position = body.position;
      oimo.Quat quaternion = body.orientation;
      if(paused) {
        position = body.position;
        quaternion = body.orientation;
      }

      if (visual is InstancedMesh) {
        dummy.position.copy(position.toVector3());
        dummy.quaternion.copy(quaternion.toQuaternion());

        dummy.updateMatrix();

        visual.setMatrixAt(body.id, dummy.matrix);
        visual.instanceMatrix!.needsUpdate = true;
      } 
      else {
        visual.position.copy(position.toVector3());
        visual.quaternion.copy(quaternion.toQuaternion());
      }
    }
    updatePlayer();
  }

  void teleportPlayerIfOob(){
    if(camera.position.y <= - 25){
      playerCollider.start.set(0,0.35,0);
      playerCollider.end.set(0,1,0);
      playerCollider.radius = 0.35;
      camera.position.copy(playerCollider.end);
      camera.rotation.set(0,0,0);
    }
  }

  Widget threeDart() {
    return Builder(builder: (BuildContext context) {
      initSize(context);
      return Container(
        width: screenSize!.width,
        height: screenSize!.height,
        color: Theme.of(context).canvasColor,
        child: DomLikeListenable(
          key: _globalKey,
          builder: (BuildContext context) {
            return Container(
              width: width,
              height: height,
              color: Theme.of(context).canvasColor,
              child: Builder(builder: (BuildContext context) {
                if (kIsWeb) {
                  return three3dRender.isInitialized
                      ? HtmlElementView(
                          viewType:
                              three3dRender.textureId!.toString())
                      : Container();
                } else {
                  return three3dRender.isInitialized
                      ? Texture(textureId: three3dRender.textureId!)
                      : Container();
                }
              })
            );
          }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return threeDart();
  }
}