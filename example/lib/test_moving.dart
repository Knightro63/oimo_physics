import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:oimo_physics/oimo_physics.dart' as OIMO;
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart/three_dart.dart' hide Texture, Color;
import 'package:three_dart_jsm/three_dart_jsm.dart';

extension on OIMO.Quat{
  Quaternion toQuaternion(){
    return Quaternion(x,y,z,w);
  }
}
extension on OIMO.Vec3{
  Vector3 toVector3(){
    return Vector3(x,y,z);
  }
}

extension on THREE.Quaternion{
  OIMO.Quat toQuat(){
    return OIMO.Quat(x.toDouble(),y.toDouble(),z.toDouble(),w.toDouble());
  }
}
extension on Vector3{
  OIMO.Vec3 toVec3(){
    return OIMO.Vec3(x,y,z);
  }
}

class TestMoving extends StatefulWidget {
  const TestMoving({
    Key? key,
    this.offset = const Offset(0,0)
  }) : super(key: key);

  final Offset offset;

  @override
  _TestCollisionPageState createState() => _TestCollisionPageState();
}

class _TestCollisionPageState extends State<TestMoving> {
  FocusNode node = FocusNode();
  // gl values
  //late Object3D object;
  bool animationReady = false;
  late FlutterGlPlugin three3dRender;
  WebGLRenderTarget? renderTarget;
  WebGLRenderer? renderer;
  late TrackballControls controls;
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

  List<Mesh> meshs = [];
  List<Mesh> grounds = [];

  var matBox, matSphere, matBoxSleep, matSphereSleep, matGround, matGroundTrans;

  late THREE.BufferGeometry buffgeoSphere;
  late THREE.BufferGeometry buffgeoBox;

  bool usingMouse = false;
  Vector2 mouse = Vector2();

  //oimo var
  OIMO.World? world;
  List<OIMO.RigidBody> bodys = [];
  Object3D paddel = THREE.Object3D();
  THREE.Object3D content = THREE.Object3D();
  THREE.Raycaster ray = THREE.Raycaster();

  List<int> fps = [0,0,0,0];
  double ToRad = 0.0174532925199432957;
  int type = 1;

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
  
  void initSize(BuildContext context) {
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
      updateOimoPhysics();
      animate();
    });
  }
  Future<void> initPage() async {
    
    scene = Scene();

    camera = PerspectiveCamera(70, width / height, 1, 10000);
    camera.position.set(0,160,400);

    controls = TrackballControls(camera, _globalKey);
    //controls.target.set(0,20,0);
    //controls.update();

    scene.add(content);
    
    scene.add(AmbientLight( 0x3D4143 ) );
    DirectionalLight light = DirectionalLight( 0xffffff , 1);
    light.position.set( 300, 1000, 500 );
    light.target!.position.set( 0, 0, 0 );
    light.castShadow = true;

    int d = 300;
    light.shadow!.camera = OrthographicCamera( -d, d, d, -d,  500, 1600 );
    light.shadow!.bias = 0.0001;
    light.shadow!.mapSize.width = light.shadow!.mapSize.height = 1024;

    scene.add( light );

    // background
    THREE.BufferGeometry buffgeoBack = THREE.IcosahedronGeometry(8000,1);
    Mesh back = THREE.Mesh( buffgeoBack, THREE.MeshLambertMaterial());
    back.geometry!.applyMatrix4(THREE.Matrix4().makeRotationZ(15*ToRad));
    scene.add( back );

    buffgeoSphere = THREE.SphereGeometry( 1 , 20, 10 );
    buffgeoBox = THREE.BoxGeometry( 1, 1, 1 ) ;

    matSphere = MeshPhongMaterial({'name':'sph'});
    matBox = MeshPhongMaterial({'name':'box'});
    matSphereSleep = MeshPhongMaterial({'name':'ssph'});
    matBoxSleep = MeshPhongMaterial( {'name':'sbox'});
    matGround = MeshPhongMaterial({ 'color': 0x3D4143, 'transparent':true, 'opacity':0.5});
    matGroundTrans = MeshPhongMaterial({ 'color': 0x3D4143, 'transparent':true, 'opacity':0.6});

    animationReady = true;
  }

  void addStaticBox(List<double> size,List<double> position,List<double> rotation, [bool spec = false]) {
    Mesh mesh;
    if(spec){ 
      mesh = THREE.Mesh(buffgeoBox, matGroundTrans);
    }
    else{ 
      mesh = THREE.Mesh(buffgeoBox, matGround);
    }
    mesh.scale.set( size[0], size[1], size[2] );
    mesh.position.set( position[0], position[1], position[2] );
    mesh.rotation.set( rotation[0]*ToRad, rotation[1]*ToRad, rotation[2]*ToRad );
    scene.add( mesh );
    grounds.add(mesh);
    mesh.castShadow = true;
    mesh.receiveShadow = true;
  }

  void clearMesh(){
    for(int i = 0; i < meshs.length;i++){ 
      scene.remove(meshs[i]);
    }

    for(int i = 0; i < grounds.length;i++){ 
      scene.remove(grounds[ i ]);
    }
    grounds = [];
    meshs = [];
  }

  //----------------------------------
  //  OIMO PHYSICS
  //----------------------------------

  void initOimoPhysics(){
    world = OIMO.World(OIMO.WorldConfigure(isStat:true, scale:100.0));
    populate(type);
  }

  void populate(n) {
    int group1 = 1 << 0;  // 00000000 00000000 00000000 00000001
    int group2 = 1 << 1;  // 00000000 00000000 00000000 00000010
    int group3 = 1 << 2;  // 00000000 00000000 00000000 00000100
    int all = 0xffffffff; // 11111111 11111111 11111111 11111111

    int max = 200;

    // reset old
    clearMesh();
    world!.clear();
    bodys = [];

    OIMO.ShapeConfig config = OIMO.ShapeConfig(
      friction: 0.4,
      belongsTo: 1,
    );

    //add ground
    world!.add(OIMO.ObjectConfigure(
      shapes: [OIMO.Shapes.box],
      size:[400, 40, 400], 
      position:[0,-20,0], 
      shapeConfig:config
    ));
    addStaticBox([400, 40, 400], [0,-20,0], [0,0,0]);

     world!.add(OIMO.ObjectConfigure(
      shapes: [OIMO.Shapes.box],
      size:[200, 30, 390], 
      position:[130,40,0], 
      rotation:[0,0,32], 
      shapeConfig:config
    ));
    addStaticBox([200, 30, 390], [130,40,0], [0,0,32]);

    config.belongsTo = group1;
    config.collidesWith = all & ~group2; // all exepte groupe2
    
    world!.add(OIMO.ObjectConfigure(
      shapes: [OIMO.Shapes.box],
      size:[5, 100, 390], 
      position:[0,40,0], 
      rotation:[0,0,0], 
      shapeConfig:config
    ));
    addStaticBox([5, 100, 390], [0,40,0], [0,0,0], true);

    // now add object
    double x, y, z, w, h, d;
    int t = type;
    for(int i = 0; i < max; i++){
      if(type==3){ 
        t = Math.floor(Math.random()*2)+1;
      }
      x = 150;
      z = -100 + Math.random()*200;
      y = 100 + Math.random()*1000;
      w = 10 + Math.random()*10;
      h = 10 + Math.random()*10;
      d = 10 + Math.random()*10;

      config.collidesWith = all;
      if(t==1){
        config.belongsTo = group2;
        bodys.add(world!.add(OIMO.ObjectConfigure(
          shapes:[OIMO.Shapes.sphere], 
          size:[w*0.5,w*0.5,w*0.5], 
          position:[x,y,z], 
          move:true, 
          shapeConfig:config,
          name: 'sphere'
        )) as OIMO.RigidBody);
        meshs.add(THREE.Mesh( buffgeoSphere, matSphere));
        meshs[i].scale.set( w*0.5, w*0.5, w*0.5 );
      } 
      else if(t==2){
        config.belongsTo = group3;
        bodys.add(world!.add(OIMO.ObjectConfigure(
          shapes:[OIMO.Shapes.box], 
          size:[w,h,d], 
          position:[x,y,z], 
          move:true, 
          shapeConfig:config ,
          name: 'box'
        )) as OIMO.RigidBody);
        meshs.add(THREE.Mesh(buffgeoBox, matBox));
        meshs[i].scale.set( w, h, d );
      }

      meshs[i].castShadow = true;
      meshs[i].receiveShadow = true;

      scene.add( meshs[i] );
    }

    config.belongsTo = 1;
    config.collidesWith = all;
    bodys.add(world!.add(OIMO.ObjectConfigure(
      shapes: [OIMO.Shapes.box],
      size:[20, 40, 60], 
      position:[-150,20,0], 
      rotation:[0,0,0], 
      move:true, 
      neverSleep:true, 
      shapeConfig:config, 
      name:'paddle', 
      kinematic:true 
    )) as OIMO.RigidBody);
    meshs.add(THREE.Mesh( buffgeoBox, matBox ));
    meshs[max].scale.set( 20, 40, 60 );
    scene.add( meshs[max] );
  }

  void updateOimoPhysics() {
    if(world == null) return;

    world!.step();

    // apply new position on last rigidbody
    bodys[bodys.length-1].setPosition(paddel.position.toVec3());

    paddel.lookAt(THREE.Vector3(100,paddel.position.y, 0));
    paddel.rotation.y += 90*ToRad;

    // apply new rotation on last rigidbody
    bodys[bodys.length-1].setQuaternion(paddel.quaternion.toQuat());

    double x, y, z;
    Mesh mesh;
    OIMO.RigidBody body;

    for(int i = 0; i < bodys.length;i++){
      body = bodys[i];
      mesh = meshs[i];

      if(!body.sleeping){
        mesh.position.copy(body.getPosition().toVector3());
        mesh.quaternion.copy(body.getQuaternion().toQuaternion());

        // change material
        if(mesh.material.name == 'sbox') mesh.material = matBox;
        if(mesh.material.name == 'ssph') mesh.material = matSphere; 

        // reset position
        if(mesh.position.y<-100){
          x = 150.0;
          z = -100 + Math.random()*200.0;
          y = 100 + Math.random()*1000.0;
          body.resetPosition(x,y,z);
        }
      } 
      else {
        if(mesh.material.name == 'box') mesh.material = matBoxSleep;
        if(mesh.material.name == 'sph') mesh.material = matSphereSleep;
      }
    }
    // contact test
    if(world!.checkContact('paddle', 'sphere')){ 
      meshs[bodys.length-1].material = matSphere;
    }
    else if(world!.checkContact('paddle', 'box')){
      meshs[bodys.length-1].material = matBox;
    }
    else{ 
      meshs[bodys.length-1].material = matBoxSleep;
    }
  }
  void rayTest() {
    Vector2 convertPosition(Vector2 location){
      double _x = ( location.x / (width-widget.offset.dx)) * 2 - 1;
      double _y = - ( location.y / (height-widget.offset.dy)) * 2 + 1;
      return Vector2(_x,_y);
    }
    ray.setFromCamera(convertPosition(mouse), camera);
    List<Intersection> intersects = ray.intersectObjects(scene.children, true );
    if(intersects.isNotEmpty) {
      paddel.position.copy(intersects[0].point.add(THREE.Vector3( 0, 20, 0 )));
    }
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
    renderer!.shadowMap.type = THREE.PCFShadowMap;
    //renderer!.outputEncoding = THREE.sRGBEncoding;

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
    await initPage();
    initRenderer();
    initOimoPhysics();
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

  Widget threeDart() {
    return Builder(builder: (BuildContext context) {
      initSize(context);
      return Container(
        width: screenSize!.width,
        height: screenSize!.height,
        color: Theme.of(context).canvasColor,
        child: Listener(
          onPointerMove: (PointerMoveEvent details) {
            usingMouse = true;
            mouse = Vector2(details.localPosition.dx, details.localPosition.dy);
            //rayTest();
          },
          onPointerUp: (PointerUpEvent details) {
            mouse = Vector2(details.localPosition.dx, details.localPosition.dy);
            rayTest();
          },
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              mouse = Vector2(details.localPosition.dx, details.localPosition.dy);
            },
            onLongPressEnd: (LongPressEndDetails details) {
              mouse = Vector2(details.localPosition.dx, details.localPosition.dy);
            },
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
          )
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          threeDart(),
        ],
      )
    );
  }
}