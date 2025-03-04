import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:oimo_physics/core/rigid_body.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:three_js/three_js.dart' as three;
import 'conversion_utils.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as vmath;

enum RenderMode{solid,wireframe}

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

    threeJs = three.ThreeJS(
      onSetupComplete: onSetupComplete, 
      setup: setup,
      settings: three.Settings(
        //useSourceTexture: true
      )
    );
    threeJs.scene = three.Scene();
    world = oimo.World(settings);
    this.updatePhysics = updatePhysics ?? () => _updateCannonPhysics();
    lastCallTime = world.performance?.times.last.toDouble();
    initGeometryCaches();
  }

  Map<three.PeripheralType,Function> domElements = {};

  late final three.ThreeJS threeJs;
  late oimo.World world;
  List<oimo.RigidBody> bodies = [];
  List<three.Object3D> visuals = [];

  bool animationReady = false;

  late three.OrbitControls controls;
  
  dynamic sourceTexture;
  
  double? lastCallTime;
  bool resetCallTime = false;
  double toRad = 0.0174532925199432957;

  late three.SpotLight _spotLight;
  late three.AmbientLight _ambientLight;

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

  final three.MeshBasicMaterial _wireframeMaterial = three.MeshBasicMaterial.fromMap({'color': 0xffffff, 'wireframe': false});
  final three.MeshLambertMaterial _solidMaterial = three.MeshLambertMaterial.fromMap({'color': 0xdddddd});
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
    threeJs.dispose();
  }
  // void addEventListener(String type,Function(dynamic) listener){
  //   world.addEventListener('postStep', listener);
  // }
  void addAnimationEvent(Function(double dt) event){
    events.add(event);
  }
  void addDomListener(three.PeripheralType type, Function function){
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

    three.MeshBasicMaterial contactDotMaterial = three.MeshBasicMaterial.fromMap({ 'color': 0xffffff });

    final contactPointGeometry = three.SphereGeometry(0.1, 6, 6);
    contactMeshCache = GeometryCache(threeJs.scene, (){
      return three.Mesh(contactPointGeometry, contactDotMaterial);
    });

    cm2contactMeshCache = GeometryCache(threeJs.scene, (){
      three.BufferGeometry geometry = three.BufferGeometry();
      geometry.setAttributeFromString(
        'position',
          three.Float32BufferAttribute(three.Float32Array.fromList([0,0,0,1,1,1]), 3, false)
      );
      return three.Line(geometry, three.LineBasicMaterial.fromMap({ 'color': 0xff0000 }));
    });

    three.BoxGeometry bboxGeometry = three.BoxGeometry(1, 1, 1);
    three.MeshBasicMaterial bboxMaterial = three.MeshBasicMaterial.fromMap({
      'color': materialColor,
      'wireframe': false,
    });

    bboxMeshCache = GeometryCache(threeJs.scene, (){
      return three.Mesh(bboxGeometry, bboxMaterial);
    });

    distanceConstraintMeshCache = GeometryCache(threeJs.scene, (){
      three.BufferGeometry geometry = three.BufferGeometry();
      geometry.setAttributeFromString(
        'position',
          three.Float32BufferAttribute(three.Float32Array.fromList([0,0,0,1,1,1]), 3, false)
      );
      return three.Line(geometry, three.LineBasicMaterial.fromMap({ 'color': 0xff0000 }));
    });

    p2pConstraintMeshCache = GeometryCache(threeJs.scene, () {
      three.BufferGeometry geometry = three.BufferGeometry();
      geometry.setAttributeFromString(
        'position',
          three.Float32BufferAttribute(three.Float32Array.fromList([0,0,0,1,1,1]), 3, false)
      );
      return three.Line(geometry, three.LineBasicMaterial.fromMap({ 'color': 0xff0000 }));
    });

    normalMeshCache = GeometryCache(threeJs.scene, (){
      three.BufferGeometry geometry = three.BufferGeometry();
      geometry.setAttributeFromString(
        'position',
          three.Float32BufferAttribute(three.Float32Array.fromList([0,0,0,1,1,1]), 3, false)
      );
      return three.Line(geometry, three.LineBasicMaterial.fromMap({ 'color': 0x00ff00 }));
    });

    axesMeshCache = GeometryCache(threeJs.scene, (){
      three.Object3D mesh = three.Object3D();
      List<double> origin = [0, 0, 0];
      three.BufferGeometry gX = three.BufferGeometry();
      three.BufferGeometry gY = three.BufferGeometry();
      three.BufferGeometry gZ = three.BufferGeometry();
      gX.setAttributeFromString(
        'position',
          three.Float32BufferAttribute(three.Float32Array.fromList(origin+[1,0,0]), 3, false)
      );
      gY.setAttributeFromString(
        'position',
          three.Float32BufferAttribute(three.Float32Array.fromList(origin+[0,1,0]), 3, false)
      );
      gZ.setAttributeFromString(
        'position',
          three.Float32BufferAttribute(three.Float32Array.fromList(origin+[0,0,1]), 3, false)
      );
      three.Line lineX = three.Line(gX, three.LineBasicMaterial.fromMap({ 'color': 0xff0000 }));
      three.Line lineY = three.Line(gY, three.LineBasicMaterial.fromMap({ 'color': 0x00ff00 }));
      three.Line lineZ = three.Line(gZ, three.LineBasicMaterial.fromMap({ 'color': 0x0000ff }));
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


  Future<void> setup() async {
    threeJs.scene.fog = three.Fog(0x222222, 1000, 2000);

    threeJs.camera = three.PerspectiveCamera(24, threeJs.width/threeJs.height, 5, 2000);
    threeJs.camera.position.setValues(0,20,40);
    threeJs.camera.lookAt(three.Vector3(0, 0, 0));

    controls = three.OrbitControls(threeJs.camera, threeJs.globalKey);
    controls.rotateSpeed = 1.0;
    controls.zoomSpeed = 1.2;
    controls.enableDamping = true;
    controls.enablePan = false;
    controls.dampingFactor = 0.2;
    controls.minDistance = 10;
    controls.maxDistance = 500;

    _ambientLight = three.AmbientLight(0xffffff, 0.1);
    threeJs.scene.add(_ambientLight);

    three.DirectionalLight directionalLight = three.DirectionalLight( 0xffffff , 0.15);
    directionalLight.position.setValues(-30, 40, 30);
    directionalLight.target!.position.setValues( 0, 0, 0 );
    threeJs.scene.add(directionalLight);

    _spotLight = three.SpotLight(0xffffff, 0.9, 0.0, math.pi / 8, 1.0);
    _spotLight.position.setValues(-30, 40, 30);
    _spotLight.target!.position.setValues(0, 0, 0);

    //_spotLight.castShadow = true;

    _spotLight.shadow!.camera!.near = 10;
    _spotLight.shadow!.camera!.far = 100;
    _spotLight.shadow!.camera!.fov = 30;

    // spotLight.shadow.bias = -0.0001
    _spotLight.shadow!.mapSize.width = 2048;
    _spotLight.shadow!.mapSize.height = 2048;

    threeJs.scene.add(_spotLight);

    for(three.PeripheralType type in domElements.keys){
      threeJs.domElement.addEventListener(type, domElements[type]!);
    }

    threeJs.addAnimationEvent((dt){
      controls.update();
      updatePhysics();
      for(int i = 0; i < events.length;i++){
        events[i].call(world.timeStep);
      }
      updateVisuals();
    });

    start();
  }
  void setRenderMode(RenderMode mode){
    switch(mode) {
      case RenderMode.solid:
        _currentMaterial = _solidMaterial;
        _spotLight.intensity = 1;
        _ambientLight.color!.setFromHex32(0x222222);
        break;
      case RenderMode.wireframe:
        _currentMaterial = _wireframeMaterial;
        _spotLight.intensity = 0;
        _ambientLight.color!.setFromHex32(0xffffff);
        break;
    }

    // set the materials
    visuals.forEach((visual){
      if (visual.material != null) {
        visual.material = _currentMaterial;
      }
      visual.traverse((child){
        if (child.material != null) {
          child.material = _currentMaterial;
        }
      });
    });

    rendermode = mode;
  }
  void addRigidBody(oimo.RigidBody config, {three.Mesh? mesh, three.Material? material}){
    three.MeshLambertMaterial particleMaterial = three.MeshLambertMaterial.fromMap({ 'color': 0xff0000 });
    // if it's a particle paint it red, if it's a trigger paint it as green, otherwise just gray
    final isParticle = config.shapes is oimo.Particle;
    final mat = material ?? (isParticle ? particleMaterial :  _currentMaterial);

    // get the correspondant three.js mesh
    final me = mesh?.clone() ?? ConversionUtils.bodyToMesh(config, mat);

    world.addRigidBody(config);
    bodies.add(config);
    visuals.add(me);
    threeJs.scene.add(me);
  }
  void addVisual(oimo.ObjectConfigure config, {three.Mesh? mesh, three.Material? material}){
    three.MeshLambertMaterial particleMaterial = three.MeshLambertMaterial.fromMap({ 'color': 0xff0000 });
    // if it's a particle paint it red, if it's a trigger paint it as green, otherwise just gray
    final isParticle = config.shapes is oimo.Particle;
    final mat = material ?? (isParticle ? particleMaterial :  _currentMaterial);

    // get the correspondant three.js mesh
    final me = mesh?.clone() ?? ConversionUtils.objectToMesh(config, mat);

    bodies.add(world.add(config) as RigidBody);
    visuals.add(me);
    threeJs.scene.add(me);
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

    bodies.removeAt(index);
    visuals.removeAt(index);

    threeJs.scene.remove(visual);
  }
  void removeAllVisuals() {
    while (bodies.isNotEmpty) {
      removeVisual(bodies[0]);
    }
  }

  void start(){
    resetCallTime = true;
    world.play();
    if(scenes.keys.isNotEmpty){
      buildScene(scenes.keys.first);
    }
  }

  void _updateCannonPhysics() {
    // Step world
    world.step();
  }

  void updateVisuals(){
    // Copy position data into visuals
    for (int i = 0; i < bodies.length; i++) {
      final body = bodies[i];
      final visual = visuals[i];
      three.Object3D dummy = three.Object3D();

      // Interpolated or not?
      vmath.Vector3 position = body.position;
      vmath.Quaternion quaternion = body.orientation;
      if (paused) {
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
      body.position.setFrom(body.initPosition);
      body.linearVelocity.setFrom(body.initLinearVelocity);
      body.angularVelocity.setFrom(body.initAngularVelocity);
      body.orientation.setFrom(body.initOrientation);
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
      return Stack(
        children:[
          threeJs.build(),
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