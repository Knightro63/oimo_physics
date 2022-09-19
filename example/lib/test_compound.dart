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
class TestCompound extends StatefulWidget {
  const TestCompound({
    Key? key,
    this.offset = const Offset(0,0)
  }) : super(key: key);

  final Offset offset;

  @override
  _TestCompoundPageState createState() => _TestCompoundPageState();
}

class _TestCompoundPageState extends State<TestCompound> {
  FocusNode node = FocusNode();
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

    var geoBox, geoCyl;
    var matBox, matSphere, matBoxSleep, matSphereSleep, matGround;
  late List<OIMO.Shapes> types;
  late THREE.BufferGeometry chairGeometry;

  late List<double> sizes;
  late List<double> positions;

  late THREE.BufferGeometry buffgeoSphere;
  late THREE.BufferGeometry buffgeoBox;


  //oimo var
  OIMO.World? world;
  List<OIMO.RigidBody> bodys = [];

  List<int> fps = [0,0,0,0];
  double ToRad = 0.0174532925199432957;
  int type = 2;

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
    THREE.BufferGeometry buffgeoBack = THREE.IcosahedronGeometry(8000,1);
    Mesh back = THREE.Mesh( buffgeoBack, THREE.MeshLambertMaterial());
    back.geometry!.applyMatrix4(THREE.Matrix4().makeRotationZ(15*ToRad));
    scene.add( back );

    geoBox = THREE.BoxGeometry( 1, 1, 1 );
    geoCyl = THREE.CylinderGeometry( 0.5, 0.5, 1, 6, 1 );

    buffgeoSphere = THREE.SphereGeometry( 1 , 20, 10 );
    buffgeoBox = THREE.BoxGeometry( 1, 1, 1 ) ;

    matSphere = MeshPhongMaterial({'name':'sph','specular': 0xFFFFFF, 'shininess': 120, 'transparent': true, 'opacity': 0.9 });
    matBox = MeshPhongMaterial({'name':'box','color': 0xFFFFFF,'shininess': 10});
    matSphereSleep = MeshPhongMaterial({'name':'ssph','specular': 0xFFFFFF, 'shininess': 120 , 'transparent': true, 'opacity': 0.7});
    matBoxSleep = MeshPhongMaterial( {'name':'sbox','color': 0xFFFFFF,'shininess': 10});
    matGround = MeshPhongMaterial({ 'color': 0x3D4143, 'transparent':true, 'opacity':0.5});

    animationReady = true;
  }

  void addStaticBox(List<double> size,List<double> position,List<double> rotation, [bool spec = false]) {
    Mesh mesh = THREE.Mesh(buffgeoBox, matGround);
    mesh.scale.set( size[0], size[1], size[2] );
    mesh.position.set( position[0], position[1], position[2] );
    mesh.rotation.set( rotation[0]*ToRad, rotation[1]*ToRad, rotation[2]*ToRad );
    scene.add( mesh );
    grounds.add(mesh);
    mesh.castShadow = true;
    mesh.receiveShadow = true;
  }
  void initChairGeometry() {
    types = [OIMO.Shapes.box,OIMO.Shapes.box,OIMO.Shapes.box,OIMO.Shapes.box,OIMO.Shapes.box,OIMO.Shapes.box,OIMO.Shapes.box,OIMO.Shapes.box];
    sizes = [ 30,5,30,  40,30,4,  4,30,4,  4,30,4,  4,30,4,  4,30,4,  4,30,4,  23,10,3 ];
    positions = [ 0,0,0,  12,-16,12,  -12,-16,12,  12,-16,-12,  -12,-16,-12,  12,16,-12,  -12,16,-12,  0,25,-12 ];

    THREE.BufferGeometry g = THREE.BufferGeometry();
    for(int i=0; i<types.length; i++){
      int n = i*3;
      THREE.Matrix4 m = THREE.Matrix4().makeTranslation( positions[n+0], positions[n+1], positions[n+2] );
      m.scale(THREE.Vector3(sizes[n+0]*10, sizes[n+1]*10, sizes[n+2]*10));
      
      if(i != 0 && i < 7){ 
        g.merge(geoCyl).applyMatrix4(m);
      }
      else{ 
        g.merge(geoBox).applyMatrix4(m);
      }
    }
    chairGeometry = geoBox;
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
    initChairGeometry();
    populate();
  }

  void populate() {
    int max = 20;

    // reset old
    clearMesh();
    world!.clear();

    bodys=[];

    var b;

    if(type==1){// DEMO 1
      world!.add(OIMO.ObjectConfigure(
        shapes: [OIMO.Shapes.box],
        size:[100, 40, 390], 
        position:[0,-20,0]
      ));
      world!.add(OIMO.ObjectConfigure(
        shapes: [OIMO.Shapes.box],
        size:[400, 40, 400], 
        position:[0,-60,0]
      ));
      //var ground = new OIMO.Body({size:[100, 40, 390], pos:[0,-20,0], world:world});
      //var ground2 = new OIMO.Body({size:[400, 40, 400], pos:[0,-60,0], world:world});

      addStaticBox([100, 40, 390], [0,-20,0], [0,0,0]);
      addStaticBox([400, 40, 400], [0,-60,0], [0,0,0]);

      int j;

      for(int i = 0; i < max; i++){
        bodys.add(world!.add(OIMO.ObjectConfigure(
          shapes:types,
          size:sizes,
          position:[0,300+(i*160),0],
          positionShape:positions,
          move:true, 
          name:'box$i',
          shapeConfig: OIMO.ShapeConfig(
            restitution: 0.4,
            density: 0.1
          ),
        )) as OIMO.RigidBody);

        j = Math.round(Math.random()*2);

        if(j==1){
          meshs.add(THREE.Mesh( chairGeometry, matBox ));
        }
        else{ 
          //meshs.add(THREE.Mesh( chairGeometry, matSphere ));
        }

        meshs[i].castShadow = true;
        meshs[i].receiveShadow = true;

        scene.add(meshs[i]);
      }
    } 
    else if(type==2){// DEMO 2
      world!.add(OIMO.ObjectConfigure(shapes:[OIMO.Shapes.box],size:[1000, 40, 1000], position:[0,-20,0]));
      addStaticBox([1000, 40, 1000], [0,-20,0], [0,0,0]);
      world!.add(OIMO.ObjectConfigure(shapes:[OIMO.Shapes.box],size:[400, 40, 400], position:[0,130,-600], rotation:[45,0,0]));
      addStaticBox([400, 40, 400], [0,130,-600], [45,0,0]);

      int j, k=0, l=0;

      for(int i = 0; i < max; i++){
        l++;
        if(l>16){
          k++; 
          l=0;
        }
        //b = new OIMO.Body({
        bodys.add(world!.add(OIMO.ObjectConfigure(
          shapes:types,
          size:sizes,
          position:[-400.0+(50*l),50,-400.0+(50*k)],
          positionShape:positions,
          move:true,  
          name:'box$i', 
          shapeConfig: OIMO.ShapeConfig(
            restitution: 0.4,
            density: 0.1
          ),
        )) as OIMO.RigidBody);

        //bodys[i] = b.body;

        j = Math.round(Math.random()*2);

        if(j==1){
          meshs.add(THREE.Mesh( chairGeometry, matBox ));
        }
        else {
          meshs.add(THREE.Mesh( chairGeometry, matSphere ));
        }

        meshs[i].castShadow = true;
        meshs[i].receiveShadow = true;

        scene.add(meshs[i]);
      }

      //b = new OIMO.Body({type:'sphere', size:[80], pos:[0,1000,-600], move:true, world:world});
      //bodys[max] = b.body;
      bodys.add(world!.add(
        OIMO.ObjectConfigure(
          shapes:[OIMO.Shapes.sphere], 
          size:[80,80,80], 
          position:[0,1000,-600], 
          move:true
        ))as OIMO.RigidBody
      );
      meshs.add(THREE.Mesh( buffgeoSphere, matSphere ));
      meshs[max].scale.set( 80, 80, 80 );
      scene.add(meshs[max]);

      meshs[max].castShadow = true;
      meshs[max].receiveShadow = true;
    } 
  }

  void updateOimoPhysics() {
    if(world == null) return;

    world!.step();

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
          x = -100 + Math.random()*200.0;
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