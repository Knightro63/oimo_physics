import 'package:flutter/material.dart';
import 'package:oimo_physics_example/src/conversion_utils.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import '../src/demo.dart';
import 'dart:math' as math;
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:three_js/three_js.dart' as three;

class BasicPhysics extends StatefulWidget {
  const BasicPhysics({
    Key? key,
    this.offset = const Offset(0,0),
  }) : super(key: key);

  final Offset offset;

  @override
  _BasicPhysicsState createState() => _BasicPhysicsState();
}

class _BasicPhysicsState extends State<BasicPhysics> {
  late Demo demo;
  Map<String,three.Material> mats = {};

  @override
  void initState() {
    demo = Demo(
      onSetupComplete: (){setState(() {});},
      updatePhysics: () => updateoimoPhysics(),
      settings: oimo.WorldConfigure(
        gravity: vmath.Vector3(0,-20,0),
        iterations: 20,
        broadPhaseType: oimo.BroadPhaseType.force
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

  void populate(n) {
    int max = 200;
    int type = n;

    final b1 = oimo.ObjectConfigure(
      shapes: [oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box),2, 2, 39.0/2)],
      position:vmath.Vector3(-9.0,-1.0,0.0), 
    );
    demo.addVisual(b1,material: mats['ground']);
    final b2 = oimo.ObjectConfigure(
      shapes: [oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box),2, 2, 39.0/2)],
      position:vmath.Vector3(9.0,-1.0,0.0), 
    );
    demo.addVisual(b2,material: mats['ground']);
    final b3 = oimo.ObjectConfigure(
      shapes: [oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box),20, 4, 20)],
      position:vmath.Vector3(0.0,-4.0,0.0), 
    );
    demo.addVisual(b3,material: mats['ground']);

    //add object
    double x, y, z, w, h, d;
    int t;
    for(int i = 0; i < max;i++){
      if(type==4) {
        t = (math.Random().nextDouble()*3).floor()+1;
      }
      else {
        t = type;
      }
      x = -5 + math.Random().nextDouble()*10;
      z = -5 + math.Random().nextDouble()*10;
      y = 10 + math.Random().nextDouble()*100;
      w = 1 + math.Random().nextDouble()*0.1;
      h = 1 + math.Random().nextDouble()*0.1;
      d = 1 + math.Random().nextDouble()*0.1;
      three.Color randColor = three.Color()..setFromHex32((math.Random().nextDouble() * 0xFFFFFF).toInt());

      if(t==1){
        three.Material mat = mats['sph']!;
        mat.color = randColor;
        oimo.ObjectConfigure sbody = oimo.ObjectConfigure(
          shapes:[oimo.Sphere(oimo.ShapeConfig(geometry: oimo.Shapes.sphere, density: 1.0),w*0.5)], 
          position:vmath.Vector3(x,y,z), 
          move:true,
        );
        demo.addVisual(sbody,material: mat);
      } 
      else if(t==2){
        three.Material mat = mats['box']!;
        mat.color = randColor;
        oimo.ObjectConfigure sbody = oimo.ObjectConfigure(
          shapes: [oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box, density: 1.0),w,h,d)],
          position:vmath.Vector3(x,y,z),
          move:true
        );
        demo.addVisual(sbody,material: mat);
      } 
      else if(t==3){
        three.Material mat = mats['cyl']!;
        mat.color = randColor;
        oimo.ObjectConfigure sbody = oimo.ObjectConfigure(
          shapes: [oimo.Cylinder(oimo.ShapeConfig(geometry: oimo.Shapes.cylinder, density: 1.0),w*0.5,h)],
          position:vmath.Vector3(x,y,z),
          move:true
        );
        demo.addVisual(sbody, material: mat);
      }
    }
  }

  void updateoimoPhysics() {
    demo.world.step();

    double x, y, z;
    three.Object3D mesh; 
    oimo.RigidBody body;
    for(int i = 0; i < demo.bodies.length;i++){
      body = demo.bodies[i];
      mesh = demo.visuals[i];

      if(body.sleeping && mesh.material?.name != null){
        
        mesh.position.setFrom(body.position.toVector3());
        mesh.quaternion.setFrom(body.orientation.toQuaternion());

        // change material
        if(mesh.material?.name == 'sbox') mesh.material = mats['box'];
        if(mesh.material?.name == 'ssph') mesh.material = mats['sph'];
        if(mesh.material?.name == 'scyl') mesh.material = mats['cyl']; 

        // reset position
        if(mesh.position.y<-100){
          x = -100 + math.Random().nextDouble() *200;
          z = -100 + math.Random().nextDouble() *200;
          y = 100 + math.Random().nextDouble() *1000;
          body.position = vmath.Vector3(x,y,z);
        }
      } 
      else if(mesh.material?.name != null){
        if(mesh.material?.name == 'box') mesh.material = mats['sbox'];
        if(mesh.material?.name == 'sph') mesh.material = mats['ssph'];
        if(mesh.material?.name == 'cyl') mesh.material = mats['scyl'];
      }
    }
  }
  void setupWorld(){
    mats['sph']    = three.MeshPhongMaterial.fromMap({'shininess': 10, 'name':'sph'});
    mats['box']    = three.MeshPhongMaterial.fromMap({'shininess': 10, 'name':'box'});
    mats['cyl']    = three.MeshPhongMaterial.fromMap({'shininess': 10, 'name':'cyl'});
    mats['ssph']   = three.MeshPhongMaterial.fromMap({'shininess': 10, 'name':'ssph'});
    mats['sbox']   = three.MeshPhongMaterial.fromMap({'shininess': 10, 'name':'sbox'});
    mats['scyl']   = three.MeshPhongMaterial.fromMap({'shininess': 10, 'name':'scyl'});
    mats['ground'] = three.MeshPhongMaterial.fromMap({'shininess': 10, 'color':0x3D4143, 'transparent':true, 'opacity':0.5, 'name': 'ground'});

    populate(4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: demo.threeDart(),
    );
  }
}