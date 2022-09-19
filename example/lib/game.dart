import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_gl/flutter_gl.dart';
import 'package:oimo_physics_example/oimoPhysics.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart/three_dart.dart' hide Texture, Color;
import 'package:three_dart_jsm/three_dart_jsm.dart';

class Physics extends StatefulWidget {
  const Physics({
    Key? key,
    this.offset = const Offset(0,0)
  }) : super(key: key);

  final Offset offset;

  @override
  _PhysicsPageState createState() => _PhysicsPageState();
}

class _PhysicsPageState extends State<Physics> {
  FocusNode node = FocusNode();
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

  late OimoPhysics physics;
  late Vector3 position;

  late THREE.InstancedMesh boxes; 
  late THREE.InstancedMesh spheres;

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
      animate();
      physics.step();
    });
  }
  Future<void> initPage() async {
		physics = await OimoPhysics();
		position = Vector3();

    scene = Scene();
    scene.background = THREE.Color(0x666666);

    camera = PerspectiveCamera(50, width / height, 0.1, 100);
    camera.position.set(-1,1.5,2);
    camera.lookAt(Vector3(0,0.5,0));

    // lights
    HemisphereLight hemiLight = HemisphereLight( 0x4488bb, 0x002244, 0.35 );
    scene.add(hemiLight);

    DirectionalLight dirLight = DirectionalLight( 0xffffff, 0.8 );
    dirLight.position.set(5,5,5);
    dirLight.castShadow = true;
    dirLight.shadow!.camera!.zoom = 2;
    scene.add(dirLight);

    Mesh floor = Mesh(
      THREE.BoxGeometry( 10, 1, 10 ),
      THREE.ShadowMaterial({'color': 0x111111 })
    );
    floor.position.y = - 2.5;
    floor.receiveShadow = true;
    scene.add( floor );
    physics.addMesh( floor );

    //

    MeshLambertMaterial material = THREE.MeshLambertMaterial();

    THREE.Matrix4 matrix = THREE.Matrix4();
    THREE.Color color = THREE.Color();

    // Boxes

    THREE.BoxGeometry geometryBox = THREE.BoxGeometry( 0.1, 0.1, 0.1 );
    boxes = THREE.InstancedMesh( geometryBox, material, 100 );
    boxes.instanceMatrix?.setUsage( THREE.DynamicDrawUsage ); // will be updated every frame
    boxes.castShadow = true;
    boxes.receiveShadow = true;
    scene.add( boxes );

    for(int i = 0; i < boxes.count!; i++) {
      matrix.setPosition( Math.random() - 0.5, Math.random() * 2, Math.random() - 0.5 );
      boxes.setMatrixAt( i, matrix );
      boxes.setColorAt( i, color.setHex((math.Random().nextDouble() * 0xFFFFFF).toInt()));
    }

    physics.addMesh( boxes, 1 );

    // Spheres
    THREE.SphereGeometry geometrySphere = THREE.SphereGeometry( 0.075);
    spheres = THREE.InstancedMesh( geometrySphere, material, 100 );
    spheres.instanceMatrix?.setUsage( THREE.DynamicDrawUsage ); // will be updated every frame
    spheres.castShadow = true;
    spheres.receiveShadow = true;
    scene.add( spheres );

    for(int i = 0; i < spheres.count!; i ++ ) {
      matrix.setPosition( Math.random() - 0.5, Math.random() * 2, Math.random() - 0.5 );
      spheres.setMatrixAt( i, matrix );
      spheres.setColorAt(i, color.setHex((math.Random().nextDouble() * 0xFFFFFF).toInt()));
    }

    physics.addMesh( spheres, 1 );

    //stats = new Stats();

    OrbitControls controls = OrbitControls(camera, _globalKey);
    controls.target.y = 0.5;
    controls.update();

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
    renderer!.outputEncoding = THREE.sRGBEncoding;

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