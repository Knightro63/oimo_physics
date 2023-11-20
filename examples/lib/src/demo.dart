import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:oimo_physics/core/rigid_body.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart/three_dart.dart' hide Texture, Color;
import 'package:three_dart_jsm/three_dart_jsm.dart';
import 'conversion_utils.dart';
import 'package:flutter/services.dart';

enum RenderMode{solid,wireframe}

extension on oimo.Quat{
  Quaternion toQuaternion(){
    return Quaternion(x,y,z,w);
  }
}
extension on oimo.Vec3{
  Vector3 toVector3(){
    return Vector3(x,y,z);
  }
}
extension on three.Vector3{
  oimo.Vec3 toVec3(){
    return oimo.Vec3(x,y,z);
  }
}

/**
 * Demo utility class. If you want to learn how to connect oimo.js with three.js, please look at the examples/threejs_* instead.
 */
class Demo{
  void Function() onSetupComplete;
  Demo({
    required this.onSetupComplete,
    oimo.WorldConfigure? settings, 
    void Function()? updatePhysics
  }){
    world = oimo.World(settings);
    this.updatePhysics = updatePhysics ?? () => _updateCannonPhysics();
    lastCallTime = world.performance?.times.last.toDouble();
    initGeometryCaches();
  }

  final GlobalKey<DomLikeListenableState> globalKey = GlobalKey<DomLikeListenableState>();
  DomLikeListenableState get domElement => globalKey.currentState!;

  Map<String,Function> domElements = {};

  late oimo.World world;
  List<oimo.RigidBody> bodies = [];
  List<three.Object3D> visuals = [];

  bool animationReady = false;
  late FlutterGlPlugin three3dRender;
  WebGLRenderTarget? renderTarget;
  WebGLRenderer? renderer;
  late OrbitControls controls;

  late double width;
  late double height;
  Size? screenSize;
  Scene scene = Scene();
  late Camera camera;
  double dpr = 1.0;
  bool verbose = false;
  bool disposed = false;
  
  dynamic sourceTexture;
  
  double? lastCallTime;
  bool resetCallTime = false;
  double toRad = 0.0174532925199432957;

  late SpotLight _spotLight;
  late AmbientLight _ambientLight;

  RenderMode rendermode = RenderMode.solid;

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
  int mouseTime = 0;
  bool mounted = false;

  MeshBasicMaterial _wireframeMaterial = MeshBasicMaterial({'color': 0xffffff, 'wireframe': true});
  MeshLambertMaterial _solidMaterial = MeshLambertMaterial({'color': 0xdddddd});
  late three.Material _currentMaterial;

  late void Function() updatePhysics;

  bool get paused => world.timer == null;
  oimo.World get getWorld => world;
  set pause(bool p){
    world.stop();
    resetCallTime = true;
  }

  late GeometryCache bboxMeshCache;
  late GeometryCache contactMeshCache;
  late GeometryCache cm2contactMeshCache;
  late GeometryCache distanceConstraintMeshCache;
  late GeometryCache normalMeshCache;
  late GeometryCache axesMeshCache;
  late GeometryCache p2pConstraintMeshCache;

  List<Function(double dt)> events = [];
  Map<String,dynamic> scenes = {};

  void dispose(){
    disposed = true;
    three3dRender.dispose();
  }
  // void addEventListener(String type,Function(dynamic) listener){
  //   world.addEventListener('postStep', listener);
  // }
  void addAnimationEvent(Function(double dt) event){
    events.add(event);
  }
  void addDomListener(String type, Function function){
    domElements[type] = function;
  }
  void addScene(String name,newScene){
    scenes[name] = newScene;
  }
  void initGeometryCaches(){
    // Material
    int materialColor = 0xdddddd;
    if(rendermode == RenderMode.solid){
      _currentMaterial = _solidMaterial;
    }
    else{
      _currentMaterial = _wireframeMaterial;
    }

    three.MeshBasicMaterial contactDotMaterial = three.MeshBasicMaterial({ 'color': 0xffffff });

    final contactPointGeometry = three.SphereGeometry(0.1, 6, 6);
    contactMeshCache = GeometryCache(scene, (){
      return three.Mesh(contactPointGeometry, contactDotMaterial);
    });

    cm2contactMeshCache = GeometryCache(scene, (){
      BufferGeometry geometry = BufferGeometry();
      geometry.setAttribute(
        'position',
          Float32BufferAttribute(Float32Array.from([0,0,0,1,1,1]), 3, false)
      );
      return three.Line(geometry, three.LineBasicMaterial({ 'color': 0xff0000 }));
    });

    three.BoxGeometry bboxGeometry = three.BoxGeometry(1, 1, 1);
    three.MeshBasicMaterial bboxMaterial = three.MeshBasicMaterial({
      'color': materialColor,
      'wireframe': true,
    });

    bboxMeshCache = GeometryCache(scene, (){
      return three.Mesh(bboxGeometry, bboxMaterial);
    });

    distanceConstraintMeshCache = GeometryCache(scene, (){
      BufferGeometry geometry = three.BufferGeometry();
      geometry.setAttribute(
        'position',
          Float32BufferAttribute(Float32Array.from([0,0,0,1,1,1]), 3, false)
      );
      return three.Line(geometry, three.LineBasicMaterial({ 'color': 0xff0000 }));
    });

    p2pConstraintMeshCache = GeometryCache(scene, () {
      BufferGeometry geometry = three.BufferGeometry();
      geometry.setAttribute(
        'position',
          Float32BufferAttribute(Float32Array.from([0,0,0,1,1,1]), 3, false)
      );
      return three.Line(geometry, three.LineBasicMaterial({ 'color': 0xff0000 }));
    });

    normalMeshCache = GeometryCache(scene, (){
      BufferGeometry geometry = three.BufferGeometry();
      geometry.setAttribute(
        'position',
          Float32BufferAttribute(Float32Array.from([0,0,0,1,1,1]), 3, false)
      );
      return three.Line(geometry, three.LineBasicMaterial({ 'color': 0x00ff00 }));
    });

    axesMeshCache = GeometryCache(scene, (){
      three.Object3D mesh = three.Object3D();
      List<double> origin = [0, 0, 0];
      BufferGeometry gX = BufferGeometry();
      BufferGeometry gY = BufferGeometry();
      BufferGeometry gZ = BufferGeometry();
      gX.setAttribute(
        'position',
          Float32BufferAttribute(Float32Array.from(origin+[1,0,0]), 3, false)
      );
      gY.setAttribute(
        'position',
          Float32BufferAttribute(Float32Array.from(origin+[0,1,0]), 3, false)
      );
      gZ.setAttribute(
        'position',
          Float32BufferAttribute(Float32Array.from(origin+[0,0,1]), 3, false)
      );
      three.Line lineX = three.Line(gX, three.LineBasicMaterial({ 'color': 0xff0000 }));
      three.Line lineY = three.Line(gY, three.LineBasicMaterial({ 'color': 0x00ff00 }));
      three.Line lineZ = three.Line(gZ, three.LineBasicMaterial({ 'color': 0x0000ff }));
      mesh.add(lineX);
      mesh.add(lineY);
      mesh.add(lineZ);
      return mesh;
    });
  }

  void restartGeometryCaches () {
    contactMeshCache.restart();
    contactMeshCache.hideCached();

    cm2contactMeshCache.restart();
    cm2contactMeshCache.hideCached();

    distanceConstraintMeshCache.restart();
    distanceConstraintMeshCache.hideCached();

    normalMeshCache.restart();
    normalMeshCache.hideCached();
  }
  void initSize(BuildContext context){
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

   initPlatformState();
  }
  
  void animate() {
    if (!mounted || disposed) {
      return;
    }
    render();
    Future.delayed(const Duration(milliseconds: 1000~/60), () {
      if(!paused){
        updatePhysics();
        for(int i = 0; i < events.length;i++){
          events[i].call(world.timeStep);
        }
        updateVisuals();
      }
      animate();
    });
  }

  void initPage() async {
    scene.fog = three.Fog(0x222222, 1000, 2000);

    camera = PerspectiveCamera(24, width/height, 5, 2000);
    camera.position.set(0,20,40);
    camera.lookAt(three.Vector3(0, 0, 0));

    controls = OrbitControls(camera, globalKey);
    controls.rotateSpeed = 1.0;
    controls.zoomSpeed = 1.2;
    controls.enableDamping = true;
    controls.enablePan = false;
    controls.dampingFactor = 0.2;
    controls.minDistance = 10;
    controls.maxDistance = 500;

    _ambientLight = AmbientLight(0xffffff, 0.1);
    scene.add(_ambientLight);

    DirectionalLight directionalLight = DirectionalLight( 0xffffff , 0.15);
    directionalLight.position.set(-30, 40, 30);
    directionalLight.target!.position.set( 0, 0, 0 );
    scene.add(directionalLight);

    _spotLight = three.SpotLight(0xffffff, 0.9, 0.0, Math.PI / 8, 1.0);
    _spotLight.position.set(-30, 40, 30);
    _spotLight.target!.position.set(0, 0, 0);

    _spotLight.castShadow = true;

    _spotLight.shadow!.camera!.near = 10;
    _spotLight.shadow!.camera!.far = 100;
    _spotLight.shadow!.camera!.fov = 30;

    // spotLight.shadow.bias = -0.0001
    _spotLight.shadow!.mapSize.width = 2048;
    _spotLight.shadow!.mapSize.height = 2048;

    scene.add(_spotLight);

    for(String type in domElements.keys){
      domElement.addEventListener(type, domElements[type]!);
    }

    start();
  }
  void setRenderMode(RenderMode mode){
    switch(mode) {
      case RenderMode.solid:
        _currentMaterial = _solidMaterial;
        _spotLight.intensity = 1;
        _ambientLight.color!.setHex(0x222222);
        break;
      case RenderMode.wireframe:
        _currentMaterial = _wireframeMaterial;
        _spotLight.intensity = 0;
        _ambientLight.color!.setHex(0xffffff);
        break;
    }

    // set the materials
    visuals.forEach((visual){
      if (visual.material != null) {
        visual.material = _currentMaterial;
      }
      visual.traverse((child){
        if (child.material) {
          child.material = _currentMaterial;
        }
      });
    });

    rendermode = mode;
  }
  void addRigidBody(oimo.RigidBody config, {three.Mesh? mesh, three.Material? material}){
    MeshLambertMaterial particleMaterial = MeshLambertMaterial({ 'color': 0xff0000 });
    // if it's a particle paint it red, if it's a trigger paint it as green, otherwise just gray
    final isParticle = config.shapes is oimo.Particle;
    final mat = material ?? (isParticle ? particleMaterial :  _currentMaterial);

    // get the correspondant three.js mesh
    final me = mesh?.clone() ?? ConversionUtils.bodyToMesh(config, mat);

    world.addRigidBody(config);
    bodies.add(config);
    visuals.add(me);
    scene.add(me);
  }
  void addVisual(oimo.ObjectConfigure config, {three.Mesh? mesh, three.Material? material}){
    MeshLambertMaterial particleMaterial = MeshLambertMaterial({ 'color': 0xff0000 });
    // if it's a particle paint it red, if it's a trigger paint it as green, otherwise just gray
    final isParticle = config.shapes is oimo.Particle;
    final mat = material ?? (isParticle ? particleMaterial :  _currentMaterial);

    // get the correspondant three.js mesh
    final me = mesh?.clone() ?? ConversionUtils.objectToMesh(config, mat);

    bodies.add(world.add(config) as RigidBody);
    visuals.add(me);
    scene.add(me);
  }
  void addVisuals(List<oimo.ObjectConfigure> bodies) {
    bodies.forEach((body){
      addVisual(body);
    });
  }
  void removeVisual(oimo.RigidBody body) {
    final index = bodies.indexOf(body);// .findIndex((b) => b.id === body.id);

    if (index == -1) {
      return;
    }

    final visual = visuals[index];

    bodies.splice(index, 1);
    visuals.splice(index, 1);

    scene.remove(visual);
  }
  void removeAllVisuals() {
    while (bodies.isNotEmpty) {
      removeVisual(bodies[0]);
    }
  }

  void start(){
    resetCallTime = true;
    world.play();
    buildScene(scenes.keys.first);
  }

  void _updateCannonPhysics() {
    // Step world
    world.step();
  }

  void render() {
    final _gl = three3dRender.gl;
    renderer!.render(scene, camera);
    _gl.flush();
    controls.update();
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
    renderer!.shadowMap.type = three.PCFShadowMap;

    if(!kIsWeb){
      WebGLRenderTargetOptions pars = WebGLRenderTargetOptions({"format": RGBAFormat,"samples": 8});
      renderTarget = WebGLRenderTarget((width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget!);
    }
    else{
      renderTarget = null;
    }
  }

  void initScene() async{
    initPage();
    initRenderer();
    // setupWorld();
    mounted = true;
    animate();
    onSetupComplete();
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

    // TODO web wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();
      initScene();
    });
  }

  void updateVisuals(){
    // Copy position data into visuals
    for (int i = 0; i < bodies.length; i++) {
      final body = bodies[i];
      final visual = visuals[i];
      Object3D dummy = Object3D();

      // Interpolated or not?
      oimo.Vec3 position = body.position;
      oimo.Quat quaternion = body.orientation;
      if (paused) {
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
    bboxMeshCache.hideCached();
  }
  void makeSureNotZero(vector) {
    if (vector.x == 0) {
      vector.x = 1e-6;
    }
    if (vector.y == 0) {
      vector.y = 1e-6;
    }
    if (vector.z == 0) {
      vector.z = 1e-6;
    }
  }
  void changeScene(String n){
    world.play();
    buildScene(n);
  }
  void buildScene(n){
    // Remove current bodies
    bodies.forEach((body){
      world.removeRigidBody(body);
    });

    // Remove all visuals
    removeAllVisuals();

    // Remove all constraints
    while (world.numContacts != 0) {
      world.removeContact(world.contacts!);
    }

    // Run the user defined "build scene" function
    scenes[n].call();

    restartGeometryCaches();
  }
  void restartCurrentScene() {
    bodies.forEach((body){
      body.position.copy(body.initPosition);
      body.linearVelocity.copy(body.initLinearVelocity);
      body.angularVelocity.copy(body.initAngularVelocity);
      body.orientation.copy(body.initOrientation);
    });
  }

  List<Widget> selectScene(BuildContext context){
    List<Widget> widgets = [];

    for(String key in scenes.keys){
      widgets.add(
        InkWell(
          onTap: (){
            changeScene(key);
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(5,5,5,0),
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Theme.of(context).dividerColor)
            ),
            child: Text(
              key,
              style: Theme.of(context).primaryTextTheme.bodySmall,
            ),
          ),
        )
      );
    }

    return widgets;
  }

  Widget threeDart() {
    return Builder(builder: (BuildContext context) {
      initSize(context);
      return Stack(
        children:[
          Container(
            width: screenSize!.width,
            height: screenSize!.height,
            color: Theme.of(context).canvasColor,
            child: DomLikeListenable(
              key: globalKey,
              builder: (BuildContext context) {
                return Container(
                  width: width,
                  height: height,
                  color: Theme.of(context).canvasColor,
                  child: Builder(builder: (BuildContext context) {
                    if (kIsWeb) {
                      return three3dRender.isInitialized? HtmlElementView(viewType:three3dRender.textureId!.toString()):Container();
                    } 
                    else {
                      return three3dRender.isInitialized?Texture(textureId: three3dRender.textureId!):Container();
                    }
                  })
                );
              }
            ),
          ),
          if(scenes.isNotEmpty)Positioned(
            top: 20,
            right: 20,
            child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: ListView(
                  children: selectScene(context),
                ),
              )
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: InkWell(
              onTap: (){
                restartCurrentScene();
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(45/2)
                ),
                child: const Icon(
                  Icons.refresh
                ),
              )
            )
          )
        ]
      );
    });
  }
}