import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:oimo_physics/core/rigid_body.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart/three_dart.dart' hide Texture, Color;
import 'package:three_dart_jsm/three_dart_jsm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TestBasic(),
    );
  }
}

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
class TestBasic extends StatefulWidget {
  const TestBasic({
    Key? key,
    this.offset = const Offset(0,0)
  }) : super(key: key);

  final Offset offset;

  @override
  _TestBasicPageState createState() => _TestBasicPageState();
}

class _TestBasicPageState extends State<TestBasic> {
  FocusNode node = FocusNode();
  // gl values
  //late Object3D object;
  bool animationReady = false;
  late FlutterGlPlugin three3dRender;
  WebGLRenderTarget? renderTarget;
  WebGLRenderer? renderer;
  late OrbitControls controls;
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

  Map<String,BufferGeometry> geos = {};
  Map<String,THREE.Material> mats = {};

  //oimo var
  oimo.World? world;
  List<oimo.Core?> bodys = [];

  List<int> fps = [0,0,0,0];
  double ToRad = 0.0174532925199432957;
  int type = 4;

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

    camera = PerspectiveCamera(60, width / height, 1, 10000);
    camera.position.set(0,160,400);
    camera.rotation.order = 'YXZ';

    controls = OrbitControls(camera, _globalKey);
    //controls.target.set(0,20,0);
    //controls.update();
    
    scene.add(AmbientLight( 0x3D4143 ) );
    DirectionalLight light = DirectionalLight( 0xffffff , 1.4);
    light.position.set( 300, 1000, 500 );
    light.target!.position.set( 0, 0, 0 );
    light.castShadow = true;

    int d = 300;
    light.shadow!.camera = OrthographicCamera( -d, d, d, -d,  500, 1600 );
    light.shadow!.bias = 0.0001;
    light.shadow!.mapSize.width = light.shadow!.mapSize.height = 1024;

    scene.add( light );

    // background
    BufferGeometry buffgeoBack = THREE.IcosahedronGeometry(3000,2);
    Mesh back = THREE.Mesh( 
      buffgeoBack, 
      THREE.MeshLambertMaterial()
    );
    scene.add( back );

    // geometrys
    geos['sphere'] = THREE.SphereGeometry(1,16,10);
    geos['box'] =  THREE.BoxGeometry(1,1,1);
    geos['cylinder'] = THREE.CylinderGeometry(1,1,1);
    
    // materials
    mats['sph']    = MeshPhongMaterial({'shininess': 10, 'name':'sph'});
    
    mats['box']    = MeshPhongMaterial({'shininess': 10, 'name':'box'});
    mats['cyl']    = MeshPhongMaterial({'shininess': 10, 'name':'cyl'});
    mats['ssph']   = MeshPhongMaterial({'shininess': 10, 'name':'ssph'});
    mats['sbox']   = MeshPhongMaterial({'shininess': 10, 'name':'sbox'});
    mats['scyl']   = MeshPhongMaterial({'shininess': 10, 'name':'scyl'});
    mats['ground'] = MeshPhongMaterial({'shininess': 10, 'color':0x3D4143, 'transparent':true, 'opacity':0.5});

    animationReady = true;
  }

  void addStaticBox(List<double> size,List<double> position,List<double> rotation) {
    Mesh mesh = THREE.Mesh( geos['box'], mats['ground'] );
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
  //  oimo PHYSICS
  //----------------------------------

  void initOimoPhysics(){
    world = oimo.World(oimo.WorldConfigure(isStat:true, scale:100.0));
    populate(type);
  }

  void populate(n) {
    int max = 200;

    if(n==1){ 
      type = 1;
    }
    else if(n==2){ 
      type = 2;
    }
    else if(n==3){ 
      type = 3;
    }
    else if(n==4) {
      type = 4;
    }

    // reset old
    clearMesh();
    world!.clear();
    bodys=[];

    //add ground
    world!.add(
      oimo.ObjectConfigure(
      shapes: [oimo.Shape(oimo.ShapeConfig(geometry: oimo.Shapes.box))],
      size:[40.0, 40.0, 390.0], 
      position:oimo.Vec3(-180.0,20.0,0.0), 
    )) as oimo.RigidBody;
    world!.add(
      oimo.ObjectConfigure(
      shapes: [oimo.Shape(oimo.ShapeConfig(geometry: oimo.Shapes.box))],
      size:[40.0, 40.0, 390.0], 
      position:oimo.Vec3(180.0,20.0,0.0), 
    )) as oimo.RigidBody;
    world!.add(
      oimo.ObjectConfigure(
      shapes: [oimo.Shape(oimo.ShapeConfig(geometry: oimo.Shapes.box))],
      size:[400.0, 80.0, 400.0], 
      position:oimo.Vec3(0.0,-40.0,0.0), 
    )) as oimo.RigidBody;

    addStaticBox([40, 40, 390], [-180,20,0], [0,0,0]);
    addStaticBox([40, 40, 390], [180,20,0], [0,0,0]);
    addStaticBox([400, 80, 400], [0,-40,0], [0,0,0]);

    //add object
    double x, y, z, w, h, d;
    int t;
    for(int i = 0; i < max;i++){
      if(type==4) {
        t = Math.floor(Math.random()*3)+1;
      }
      else {
        t = type;
      }
      x = -100 + Math.random()*200;
      z = -100 + Math.random()*200;
      y = 100 + Math.random()*1000;
      w = 10 + Math.random()*10;
      h = 10 + Math.random()*10;
      d = 10 + Math.random()*10;
      THREE.Color randColor = THREE.Color().setHex((Math.random() * 0xFFFFFF).toInt());

      if(t==1){
        THREE.Material mat = mats['sph']!;
        mat.color = randColor;
        bodys.add(world!.add(oimo.ObjectConfigure(
          shapes:[oimo.Shape(oimo.ShapeConfig(geometry: oimo.Shapes.sphere))], 
          size:[w*0.5,w*0.5,w*0.5], 
          position:oimo.Vec3(x,y,z), 
          move:true,
        )));
        meshs.add(THREE.Mesh( geos['sphere'], mat));
        meshs[i].scale.set( w*0.5, w*0.5, w*0.5 );
      } 
      else if(t==2){
        THREE.Material mat = mats['box']!;
        mat.color = randColor;
        bodys.add(world!.add(oimo.ObjectConfigure(
          shapes:[oimo.Shape(oimo.ShapeConfig(geometry: oimo.Shapes.box))], 
          size:[w,h,d], 
          position:oimo.Vec3(x,y,z), 
          move:true,
        )) as oimo.RigidBody);
        meshs.add(THREE.Mesh( geos['box'], mat ));
        meshs[i].scale.set( w, h, d );
      } 
      else if(t==3){
        THREE.Material mat = mats['cyl']!;
        mat.color = randColor;
        bodys.add(world!.add(oimo.ObjectConfigure(
          shapes:[oimo.Shape(oimo.ShapeConfig(geometry: oimo.Shapes.cylinder))], 
          size:[w*0.5,h,w*0.5], 
          position:oimo.Vec3(x,y,z), 
          move:true, 
        )));
        meshs.add(THREE.Mesh( geos['cylinder'], mat));
        meshs[i].scale.set( w*0.5, h, w*0.5 );
      }

      meshs[i].castShadow = true;
      meshs[i].receiveShadow = true;

      scene.add( meshs[i] );
    }
  }

  void updateOimoPhysics() {
    if(world==null) return;

    world!.step();

    var x, y, z;
    Mesh mesh; 
    oimo.RigidBody body;
    //print(bodys[0].getPosition());
    for(int i = 0; i < bodys.length;i++){
      body = bodys[i] as RigidBody;
      mesh = meshs[i];

      if(!body.sleeping){
        
        mesh.position.copy(body.getPosition().toVector3());
        mesh.quaternion.copy(body.getQuaternion().toQuaternion());

        // change material
        if(mesh.material.name == 'sbox') mesh.material = mats['box'];
        if(mesh.material.name == 'ssph') mesh.material = mats['sph'];
        if(mesh.material.name == 'scyl') mesh.material = mats['cyl']; 

        // reset position
        if(mesh.position.y<-100){
          x = -100 + Math.random()*200;
          z = -100 + Math.random()*200;
          y = 100 + Math.random()*1000;
          body.resetPosition(x,y,z);
        }
      } 
      else {
        if(mesh.material.name == 'box') mesh.material = mats['sbox'];
        if(mesh.material.name == 'sph') mesh.material = mats['ssph'];
        if(mesh.material.name == 'cyl') mesh.material = mats['scyl'];
      }
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
        child: DomLikeListenable(
          key: _globalKey,
          builder: (BuildContext context) {
            FocusScope.of(context).requestFocus(node);
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
          }
        ),
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