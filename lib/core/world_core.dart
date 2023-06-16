import 'dart:async';

import 'package:oimo_physics/constraint/joint/joint_link.dart';

import '../collision/broadphase/pair_broad_phase.dart';
import '../collision/broadphase/sap/sap_broad_phase.dart';
import '../collision/narrowphase/box_box_collision_detector.dart';
import '../collision/narrowphase/box_cylinder_collision_detector.dart';
import '../collision/narrowphase/box_plane_collision_detector.dart';
import '../collision/narrowphase/collision_detector.dart';
import '../collision/narrowphase/cylinder_cylinder_collision_detector.dart';
import '../collision/narrowphase/sphere_box_collision_detector.dart';
import '../collision/narrowphase/sphere_cylinder_collision_detector.dart';
import '../collision/narrowphase/sphere_plane_collision_detector.dart';
import '../collision/narrowphase/sphere_sphere_collision_detector.dart';
import '../constraint/contact/contact_link.dart';
import '../constraint/joint/ball_and_socket_joint.dart';
import '../constraint/joint/distance_joint.dart';
import '../constraint/joint/hinge_joint.dart';
import '../constraint/joint/joint_config.dart';
import '../constraint/joint/prismatic_joint.dart';
import '../constraint/joint/slider_joint.dart';
import '../constraint/joint/wheel_joint.dart';
import '../shape/box_shape.dart';
import '../shape/cylinder_shape.dart';
import '../shape/plane_shape.dart';
import '../shape/shape_config.dart';
import '../shape/sphere_shape.dart';

import '../collision/broadphase/broad_phase.dart';
import '../collision/broadphase/brute_force_broad_phase.dart';
import '../collision/broadphase/dbvt/dbvt_broad_phase.dart';
import 'utils_core.dart';
import '../shape/shape_main.dart';
import '../math/math.dart';
import '../math/quat.dart';
import '../math/vec3.dart';
import '../constraint/constraint.dart';
import 'core_main.dart';
import 'rigid_body.dart';

import '../constraint/joint/joint_main.dart';
import '../constraint/contact/contact_main.dart';

class ObjectConfigure{
  ObjectConfigure({
    this.type = JointType.none,
    this.shapes = const [Shapes.none],
    this.move = false,
    this.kinematic = false,
    this.neverSleep = false,
    this.sleep = false,
    ShapeConfig? shapeConfig,
    this.name,

    this.massPos = false,
    this.massRot = false,
    this.allowCollision = false,

    double? max,
    double? min,

    this.body1,
    this.body2,

    this.position = const [0,0,0],
    this.position2 = const [0,0,0],
    this.positionShape = const [0,0,0],
    this.rotation = const [0,0,0],
    this.rotationShape = const [0,0,0],
    this.size = const [0,0,0],

    this.axis1 = const [1,0,0],
    this.axis2 = const [1,0,0],

    this.motorSpeed,
    this.motorForce,
    this.springFrequency,
    this.dampingRatio,
    this.lowerMotorLimit,
    this.upperMotorLimit
  }){
    this.shapeConfig = shapeConfig ?? ShapeConfig();

    this.max = max ?? (JointType.distance == type?0:10);
    this.min = min ?? (JointType.distance == type?0:57.29578);
  }


  List<Shapes> shapes;
  JointType type;
  bool move;
  bool kinematic;
  bool neverSleep;

  late List<double> position;
  late List<double> position2;
  late List<double> positionShape;
  late List<double> rotation;
  late List<double> rotationShape;
  late List<double> size;

  late ShapeConfig shapeConfig;
  String? name;

  bool massRot;
  bool massPos;
  bool sleep;

  RigidBody? body1;
  RigidBody? body2; 
  bool allowCollision;

  late double max;
  late double min;

  late List<double> axis1;
  late List<double> axis2;

  double? motorSpeed; 
  double? motorForce;
  int? springFrequency;
  double? dampingRatio;
  double? lowerMotorLimit; 
  double? upperMotorLimit;
}

class WorldConfigure{
  WorldConfigure({
    this.scale = 1,
    this.timeStep = 1/60,
    this.broadPhaseType = BroadPhaseType.sweep,
    this.isStat = false,
    this.enableRandomizer = true,
    this.iterations = 8,
    Vec3? gravity
  }){
    this.gravity = gravity ?? Vec3(0,-9.8,0);
  }

  double scale;
  double timeStep;
  int iterations;
  bool enableRandomizer;
  bool isStat;
  BroadPhaseType broadPhaseType;
  late Vec3 gravity;
}

//  * The class of physical computing world.
//  * You must be added to the world physical all computing objects
 // timestep, broadphase, iterations, worldscale, random, stat
class World{
  World([WorldConfigure? worldConfigure]){
    this.worldConfigure = worldConfigure ?? WorldConfigure();
    scale = this.worldConfigure.scale;
    invScale = 1/scale;
    timeStep = this.worldConfigure.timeStep; // 1/60;
    timerate = (timeStep * 1000).toInt();
    numIterations = this.worldConfigure.iterations;
    enableRandomizer = this.worldConfigure.enableRandomizer;
    isStat = this.worldConfigure.isStat;
    broadPhaseType = this.worldConfigure.broadPhaseType;
    gravity = this.worldConfigure.gravity;

     // It is a wide-area collision judgment that is used in order to reduce as much as possible a detailed collision judgment.
    switch(broadPhaseType){
      case BroadPhaseType.force: 
        broadPhase = BruteForceBroadPhase(); 
        break;
      case BroadPhaseType.sweep: 
        broadPhase = SAPBroadPhase(); 
        break;
      case BroadPhaseType.volume: 
        broadPhase = DBVTBroadPhase(); 
        break;
      default:
    }

    if(isStat) performance = InfoDisplay(this);

    detectors['Shapes.sphere Shapes.sphere'] = SphereSphereCollisionDetector();
    detectors['Shapes.sphere Shapes.box'] = SphereBoxCollisionDetector();
    detectors['Shapes.box Shapes.sphere'] = SphereBoxCollisionDetector();
    detectors['Shapes.box Shapes.box'] = BoxBoxCollisionDetector();

    // CYLINDER add
    detectors['Shapes.cylinder Shapes.cylinder'] = CylinderCylinderCollisionDetector();
    detectors['Shapes.cylinder Shapes.box'] = BoxCylinderCollisionDetector();
    detectors['Shapes.box Shapes.cylinder'] = BoxCylinderCollisionDetector();
    detectors['Shapes.cylinder Shapes.sphere'] = SphereCylinderCollisionDetector();
    detectors['Shapes.sphere Shapes.cylinder'] = SphereCylinderCollisionDetector();

    // PLANE add
    detectors['Shapes.plane Shapes.sphere'] = SpherePlaneCollisionDetector();
    detectors['Shapes.sphere Shapes.plane'] = SpherePlaneCollisionDetector();
    detectors['Shapes.plane Shapes.box'] = BoxPlaneCollisionDetector();
    detectors['Shapes.box Shapes.plane'] = BoxPlaneCollisionDetector();

    // TETRA add
    //this.detectors[SHAPE_TETRA][SHAPE_TETRA] = TetraTetraCollisionDetector();
  }

  late WorldConfigure worldConfigure;
  // this world scale defaut is 0.1 to 10 meters max for dynamique body
  late double scale;
  late double invScale;

    // The time between each step
  late double timeStep; // 1/60;
  late int timerate;
  Timer? timer;

  void Function()? preLoop;//function(){};
  void Function()? postLoop;//function(){};

  // The number of iterations for constraint solvers.
  late int numIterations;
  late BroadPhaseType broadPhaseType;
  late BroadPhase broadPhase;

  // This is the detailed information of the performance.
  InfoDisplay? performance;
  late bool isStat;
    

  // * Whether the constraints randomizer is enabled or not.
  late bool enableRandomizer;

  // The rigid body list
  RigidBody? rigidBodies;
  // number of rigid body
  int numRigidBodies=0;
  // The contact list
  Contact? contacts;
  Contact? unusedContacts;
  // The number of contact
  int numContacts=0;
  // The number of contact points
  int numContactPoints=0;
  //  The joint list
  Joint? joints;
  // The number of joints.
  int numJoints=0;
  // The number of simulation islands.
  int numIslands=0;


  // The gravity in the world.
  late Vec3 gravity;
  
  int numShapeTypes = 5;//4;//3;
  Map<String,CollisionDetector> detectors={};


  int randX = 65535;
  int randA = 98765;
  int randB = 123456789;

  Map<int,RigidBody?> islandRigidBodies = {};
  Map<int,RigidBody?> islandStack = {};
  Map<int,Constraint?> islandConstraints = {};


  void play(){
    if(timer != null) return;
    World world = this;
    timer = Timer(Duration(milliseconds: timerate), () {
      world.step();
    });
    //timer = setInterval((){ _this.step();} , timerate);
  }
  void stop(){
    if(timer == null) return;
    timer?.cancel();
    timer = null;
  }
  void setGravity ( ar ) {
    gravity.fromArray( ar );
  }
  String getInfo(){
    return isStat?(performance?.show() ?? '') : '';
  }
  List<double> toNew(List<double> old, double mul){
    List<double> temp = []; 
    for(int i = 0; i < old.length;i++){
      double x = old[i];
      temp.add(x*mul);
    }
    // old.forEach((x){ 
    //   temp.add(x * mul);
    // });
    return temp;
  }
  // Reset the world and remove all rigid bodies, shapes, joints and any object from the world.
  void clear(){
    stop();
    preLoop = null;
    postLoop = null;
    randX = 65535;

    while(joints!=null){
      removeJoint(joints!);
    }
    while(contacts!=null){
      removeContact(contacts!);
    }
    while(rigidBodies!=null){
      removeRigidBody(rigidBodies!);
    }
  }

  // * I'll add a rigid body to the world.
  // * Rigid body that has been added will be the operands of each step.
  // * @param  rigidBody  Rigid body that you want to add
  void addRigidBody(RigidBody rigidBody){
    if(rigidBody.parent != null){
      printError("World", "It is not possible to be added to more than one world one of the rigid body");
    }

    rigidBody.setParent(this);
    //rigidBody.awake();
    
    for(Shape? shape = rigidBody.shapes; shape != null; shape = shape.next){
      addShape(shape);
    }
    if(rigidBodies!=null)(rigidBodies!.prev=rigidBody).next=rigidBodies;
    rigidBodies = rigidBody;
    numRigidBodies++;
  }

  // * I will remove the rigid body from the world.
  // * Rigid body that has been deleted is excluded from the calculation on a step-by-step basis.
  // * @param  rigidBody  Rigid body to be removed
  void removeRigidBody(RigidBody rigidBody ){
    RigidBody remove = rigidBody;
    if(remove.parent != this)return;
    remove.awake();
    JointLink? js = remove.jointLink;
    while(js!=null){
      Joint joint=js.joint;
      js=js.next;
      removeJoint(joint);
    }
    for(Shape? shape = rigidBody.shapes; shape!=null; shape=shape.next){
      removeShape(shape);
    }
    RigidBody? prev = remove.prev;
    RigidBody? next = remove.next;
    if(prev!=null) prev.next=next;
    if(next!=null) next.prev=prev;
    if(rigidBodies==remove) rigidBodies=next;
    remove.prev=null;
    remove.next=null;
    remove.parent=null;
    numRigidBodies--;
  }

  Core? getByName(String name){
    RigidBody? body = rigidBodies;
    while(body != null){
      if( body.name == name ){ return body;}
      body=body.next;
    }

    Joint? joint = joints;
    while( joint != null ){
      if(joint.name == name){ return joint;}
      joint = joint.next;
    }

    return null;
  }


  // * I'll add a shape to the world..
  // * Add to the rigid world, and if you add a shape to a rigid body that has been added to the world,
  // * Shape will be added to the world automatically, please do not call from outside this method.
  // * @param  shape  Shape you want to add
  void addShape(Shape shape){
    if(shape.parent == null || shape.parent!.parent == null){
      printError("World", "It is not possible to be added alone to shape world");
    }

    shape.proxy = broadPhase.createProxy(shape);
    shape.updateProxy();
    broadPhase.addProxy(shape.proxy!);
  }


  // * I will remove the shape from the world.
  // * Add to the rigid world, and if you add a shape to a rigid body that has been added to the world,
  // * Shape will be added to the world automatically, please do not call from outside this method.
  // * @param  shape  Shape you want to delete
  void removeShape(Shape shape){
    broadPhase.removeProxy(shape.proxy!);
    shape.proxy = null;
  }

  // * I'll add a joint to the world.
  // * Joint that has been added will be the operands of each step.
  // * @param  shape Joint to be added
  void addJoint(Joint joint) {
    if(joint.parent != null){
      printError("World", "It is not possible to be added to more than one world one of the joint");
    }
    if(joints!=null)(joints!.prev=joint).next=joints;
    joints=joint;
    joint.setParent(this);
    numJoints++;
    joint.awake();
    joint.attach();
  }

  // * I will remove the joint from the world.
  // * Joint that has been added will be the operands of each step.
  // * @param  shape Joint to be deleted
  void removeJoint (Joint joint ) {
    Joint remove=joint;
    Joint? prev=remove.prev;
    Joint? next=remove.next;
    if(prev!=null)prev.next=next;
    if(next!=null)next.prev=prev;
    if(joints==remove)joints=next;
    remove.prev=null;
    remove.next=null;
    numJoints--;
    remove.awake();
    remove.detach();
    remove.parent=null;
  }

  void addContact(Shape s1, Shape s2){
    Contact newContact;
    if(unusedContacts!=null){
      newContact=unusedContacts!;
      unusedContacts=unusedContacts!.next;
    }
    else{
      newContact = Contact();
    }
    newContact.attach(s1,s2);
    
    newContact.detector = detectors['${s1.type} ${s2.type}'];
    if(contacts != null)(contacts!.prev = newContact).next = contacts;
    contacts = newContact;
    numContacts++;
  }
  void removeContact(Contact contact) {
    Contact? prev = contact.prev;
    Contact? next = contact.next;
    if(next != null) next.prev = prev;
    if(prev != null) prev.next = next;
    if(contacts == contact) contacts = next;
    contact.prev = null;
    contact.next = null;
    contact.detach();
    contact.next = unusedContacts;
    unusedContacts = contact;
    numContacts--;
  }

  Contact? getContact(RigidBody body1,RigidBody body2) {
    String b1 = body1.name;
    String b2 = body2.name;

    String n1, n2;
    Contact? contact = contacts;
    while(contact != null){
      n1 = contact.body1!.name;
      n2 = contact.body2!.name;
      if((n1 == b1 && n2 == b2) || (n2 == b1 && n1 == b2)){ 
        if(contact.touching){
          return contact;
        } 
        else{
          return null;
        }
      }
      else{
        contact = contact.next!;
      }
    }
    return null;
  }

  bool checkContact(String name1, String name2 ) {
    String n1, n2;
    Contact? contact = contacts;
    while(contact!=null){
        n1 = contact.body1?.name ?? ' ';
        n2 = contact.body2?.name ?? ' ';
        if((n1==name1 && n2==name2) || (n2==name1 && n1==name2)){ 
          if(contact.touching){ return true;} 
          else{return false;}
        }
        else{ 
          contact = contact.next;
        }
    }
    return false;
  }

  bool callSleep(RigidBody body) {
    if( !body.allowSleep ) return false;
    if( body.linearVelocity.lengthSq() > 0.04 ) return false;
    if( body.angularVelocity.lengthSq() > 0.25 ) return false;
    return true;
  }

  //* I will proceed only time step seconds time of World.
  void step(){
    //this.timeStep = timeStep ?? this.timeStep;
    bool stat = isStat;
    if(stat){
      performance?.setTime(0);
    }
    RigidBody? body = rigidBodies;
    
    while(body != null){
      body.addedToIsland = false;
      if( body.sleeping ){
        body.testWakeUp();
      }
      body = body.next;
    }

    //------------------------------------------------------
    //   UPDATE BROADPHASE CONTACT
    //------------------------------------------------------
    if(stat){
      performance?.setTime( 1 );
    }
    broadPhase.detectPairs();
    List<Pair> pairs = broadPhase.pairs;
    for(int i = 0; i < broadPhase.numPairs;i++){
      Pair pair = pairs[i];
      Shape s1;
      Shape s2;
      if(pair.shape1!.id < pair.shape2!.id){
        s1 = pair.shape1!;
        s2 = pair.shape2!;
      }
      else{
        s1 = pair.shape2!;
        s2 = pair.shape1!;
      }

      ContactLink? link;
      if( s1.numContacts < s2.numContacts ){ 
        link = s1.contactLink;
      }
      else{ 
        link = s2.contactLink;
      }

      bool exists = false;
      while(link != null){
        Contact contact = link.contact;
        if( contact.shape1 == s1 && contact.shape2 == s2 ){
          contact.persisting = true;
          exists = true;// contact already exists
          break;
        }
        link = link.next;
      }
      if(!exists){
        addContact( s1, s2 );
      }
    }

    if(stat) {
      performance?.calcBroadPhase();
    }

    //------------------------------------------------------
    //   UPDATE NARROWPHASE CONTACT
    //------------------------------------------------------

    // update & narrow phase
    numContactPoints = 0;
    Contact? contact = contacts;
    while(contact!=null){
      if(!contact.persisting){
        if(contact.shape1!.aabb.intersectTest(contact.shape2!.aabb)){
          Contact? next = contact.next;
          removeContact(contact);
          contact = next;
          continue;
        }
      }
      RigidBody b1 = contact.body1!;
      RigidBody b2 = contact.body2!;

      if(b1.isDynamic && !b1.sleeping || b2.isDynamic && !b2.sleeping ) contact.updateManifold();

      numContactPoints += contact.manifold.numPoints;
      contact.persisting = false;
      contact.constraint.addedToIsland = false;
      contact = contact.next;
    }

    if(stat){ 
      performance?.calcNarrowPhase();
    }

    //------------------------------------------------------
    //   SOLVE ISLANDS
    //------------------------------------------------------

    double invTimeStep = 1 / timeStep;
    Constraint? constraint;

    for(Joint? joint = joints; joint != null; joint = joint.next){
      joint.addedToIsland = false;
    }
    // clear old island array
    islandRigidBodies = {};
    islandConstraints = {};
    islandStack = {};

    if(stat){ 
      performance?.setTime(1);
    }

    numIslands = 0;

    // build and solve simulation islands

    for(RigidBody? base = rigidBodies; base != null; base = base.next ){
      if( base.addedToIsland || base.isStatic || base.sleeping ) continue;// ignore
      if( base.isLonely() ){// update single body
        if(base.isDynamic){
          base.linearVelocity.addScaledVector(gravity, timeStep);
        }
        if( callSleep( base ) ) {
          base.sleepTime += timeStep;
          if( base.sleepTime > 0.5 ){ 
            base.sleep();
          }
          else {
            base.updatePosition( timeStep );
          }
        }
        else{
          base.sleepTime = 0;
          base.updatePosition(timeStep);
        }
        numIslands++;
        continue;
      }

      int islandNumRigidBodies = 0;
      int islandNumConstraints = 0;
      int stackCount = 1;
      // add rigid body to stack
      islandStack[0] = base;
      base.addedToIsland = true;

      // build an island
      do{
        // get rigid body from stack
        body = islandStack[--stackCount]!;
        islandStack[stackCount] = null;
        body.sleeping = false;
        // add rigid body to the island
        islandRigidBodies[islandNumRigidBodies++] = body;
        if(body.isStatic) continue;

        // search connections
        for(ContactLink? cs = body.contactLink; cs != null; cs = cs.next ) {
          Contact contact = cs.contact;
          constraint = contact.constraint;
          if( constraint.addedToIsland || !contact.touching ) continue;// ignore

          // add constraint to the island
          islandConstraints[islandNumConstraints++] = constraint;
          constraint.addedToIsland = true;
          RigidBody next = cs.body!;

          if(next.addedToIsland) continue;

          // add rigid body to stack
          islandStack[stackCount++] = next;
          next.addedToIsland = true;
        }
        for(JointLink? js = body.jointLink; js != null; js = js.next ) {
          constraint = js.joint;

          if(constraint.addedToIsland) continue;// ignore

          // add constraint to the island
          islandConstraints[islandNumConstraints++] = constraint;
          constraint.addedToIsland = true;
          RigidBody next = js.body!;
          if( next.addedToIsland || !next.isDynamic ) continue;

          // add rigid body to stack
          islandStack[stackCount++] = next;
          next.addedToIsland = true;
        }
      } while( stackCount != 0 );

      // update velocities
      Vec3 gVel = Vec3().addScaledVector(gravity, timeStep);
      for(int j=0; j< islandNumRigidBodies; j++){
        body = islandRigidBodies[j];
        if(body!.isDynamic){
          body.linearVelocity.addEqual(gVel);
        }
      }

      // randomizing order
      if(enableRandomizer){
        for(int j=1; j < islandNumConstraints; j++){
          int swap = (randX=(randX*randA+randB&0x7fffffff))~/2147483648*j|0;
          constraint = islandConstraints[j];
          islandConstraints[j] = islandConstraints[swap];
          islandConstraints[swap] = constraint;
        }
      }

      // solve contraints
      for(int j=0; j< islandNumConstraints; j++){
        islandConstraints[j]!.preSolve(timeStep, invTimeStep);// pre-solve
      }

      for(int k=0; k<numIterations; k++){
        for(int j=islandNumConstraints-1; j>=0; j--){
          islandConstraints[j]!.solve();// main-solve
        }
      }

      for(int j=0; j<islandNumConstraints; j++){
        islandConstraints[j]!.postSolve();// post-solve
        islandConstraints[j] = null;// gc
      }

      // sleeping check

      double sleepTime = 10;
      for(int j=0;j<islandNumRigidBodies;j++){
        body = islandRigidBodies[j];
        if(body != null){
          if(callSleep(body)){
            body.sleepTime += timeStep;
            if( body.sleepTime < sleepTime ){ 
              sleepTime = body.sleepTime;
            }
          }
          else{
            body.sleepTime = 0;
            sleepTime = 0;
            continue;
          }
        }
      }
      if(sleepTime > 0.5){
        // sleep the island
        for(int j=0;j<islandNumRigidBodies;j++){
          islandRigidBodies[j]!.sleep();
          islandRigidBodies[j] = null;// gc
        }
      }
      else{
        // update positions
        for(int j=0;j<islandNumRigidBodies;j++){
          islandRigidBodies[j]!.updatePosition(timeStep);
          islandRigidBodies[j] = null;// gc
        }
      }
      numIslands++;
    }

    //------------------------------------------------------
    //   END SIMULATION
    //------------------------------------------------------

    if(stat){
      performance?.calcEnd();
    }
    if( postLoop != null ){ 
      postLoop!();
    }
  }

  // remove someting to world
  remove( obj ){

  }

  // add someting to world
  Core? add(ObjectConfigure config){
    if(config.type != JointType.none){ 
      return initJoint(config.type, config);
    }
    else {
      return initBody(config.shapes, config);
    }
  }

  RigidBody? initBody(List<Shapes> type, ObjectConfigure config){
    double invScale = this.invScale;

    // body position
    List<double> p = config.position;
    p = toNew(p, invScale);//p.map( function(x) { return x * invScale; } );

    // shape position
    List<double> p2 = config.positionShape;
    p2 = toNew(p2, invScale);//p2.map( function(x) { return x * invScale; } );

    // ROTATION

    // body rotation in degree
    List<double> r = config.rotation;
    r = toNew(r, invScale);//r.map( function(x) { return x * Math.degtorad; } );

    // shape rotation in degree
    List<double> r2 = config.rotationShape;
    r2 = toNew(r2, invScale);//r.map( function(x) { return x * Math.degtorad; } );

    // shape size
    List<double> s = config.size;
    if( s.length == 1 ){ s[1] = s[0]; }
    if( s.length == 2 ){ s[2] = s[0]; }
    s = toNew(s, invScale);//s.map( function(x) { return x * invScale; } );

    // body physics settings
    ShapeConfig sc = config.shapeConfig;
    Vec3 position = Vec3( p[0], p[1], p[2] );
    Quat rotation = Quat().setFromEuler( r[0], r[1], r[2] );

    // rigidbody
    RigidBody body = RigidBody( 
      position,
      rotation
    );
    //var body = RigidBody( p[0], p[1], p[2], r[0], r[1], r[2], r[3], this.scale, this.invScale );
  
    for(int i = 0; i<type.length; i++){
      late Shape shape;
      int n = i * 3;

      if(p2.length > n){ 
        sc.relativePosition.set( p2[n], p2[n+1], p2[n+2] );
      }
      if(r2.length > n){ 
        sc.relativeRotation.setQuat( Quat().setFromEuler( r2[n], r2[n+1], r2[n+2] ) );
      }
      
      switch(type[i]){
        case Shapes.sphere: 
          shape = Sphere( sc, s[n] ); 
          break;
        case Shapes.cylinder: 
          shape = Cylinder( sc, s[n], s[n+1] ); 
          break;
        case Shapes.box: 
          shape = Box( sc, s[n], s[n+1], s[n+2] ); 
          break;
        case Shapes.plane: 
          shape = Plane(sc); 
          break;
        default:
      }

      body.addShape(shape);
    }

    // body can sleep or not
    if(config.neverSleep || config.kinematic){ 
      body.allowSleep = false;
    }
    else{ 
      body.allowSleep = true;
    }

    body.isKinematic = config.kinematic;

    // body static or dynamic
    if(config.move){
      if(config.massPos || config.massRot) {
        body.setupMass(RigidBodyType.dynamic, false);
      }
      else {
        body.setupMass(RigidBodyType.dynamic);
      }
    } 
    else {
      body.setupMass(RigidBodyType.static);
    }

    if(config.name != null ){ 
      body.name = config.name!;
    }
    else if(config.move){ 
      body.name = numRigidBodies.toString();
    }

    // finaly add to physics world
    addRigidBody(body);

    // force sleep on not
    if(config.move){
      if(config.sleep) {
        body.sleep();
      }
      else{ 
        body.awake();
      }
    }

    return body;
  }

  Joint? initJoint(JointType type, ObjectConfigure config){
    //var type = type;
    double invScale = this.invScale;

    List<double> axe1 = config.axis1;
    List<double> axe2 = config.axis2;
    List<double> pos1 = config.position;
    List<double> pos2 = config.position2;

    pos1 = toNew(pos1, invScale);
    pos2 = toNew(pos2, invScale);//pos2.map(function(x){ return x * invScale; });

    double min = config.min;
    double max = config.max;
    if(type == JointType.distance){
      min = min * invScale;
      max = max * invScale;
    }
    else{
      min = min * Math.degtorad;
      max = max * Math.degtorad;
    }

    // joint setting
    JointConfig jc = JointConfig();
    jc.scale = scale;
    jc.invScale = this.invScale;
    jc.allowCollision = config.allowCollision;
    jc.localAxis1.set( axe1[0], axe1[1], axe1[2] );
    jc.localAxis2.set( axe2[0], axe2[1], axe2[2] );
    jc.localAnchorPoint1.set( pos1[0], pos1[1], pos1[2] );
    jc.localAnchorPoint2.set( pos2[0], pos2[1], pos2[2] );

    RigidBody? b1 = config.body1;
    RigidBody? b2 = config.body2;

    if(b1 == null || b2 == null){
      printError('World', "Can't add joint attach rigidbodys not find !" ); 
      return null;
    }

    jc.body1 = b1;
    jc.body2 = b2;

    late Joint joint;
    switch( type){
      case JointType.distance: 
        joint = DistanceJoint(jc, min, max);
        if(joint is DistanceJoint){
          if(config.springFrequency != null && config.dampingRatio != null) joint.limitMotor.setSpring(config.springFrequency!, config.dampingRatio!);
          if(config.motorSpeed != null && config.motorSpeed != null) joint.limitMotor.setMotor(config.motorSpeed!, config.motorForce!);
        }
        break;
      case JointType.hinge: 
        joint = HingeJoint(jc, min, max);
        if(joint is HingeJoint){
          if(config.springFrequency != null && config.dampingRatio != null) joint.limitMotor.setSpring(config.springFrequency!, config.dampingRatio!);
          if(config.motorSpeed != null && config.motorSpeed != null) joint.limitMotor.setMotor(config.motorSpeed!, config.motorForce!);
        }
        break;
      case JointType.prismatic: 
        joint = PrismaticJoint(jc, min, max); 
        break;
      case JointType.slider: 
        joint = SliderJoint(jc, min, max); 
        break;
      case JointType.socket:  
        joint = BallAndSocketJoint(jc); 
        break;
      case JointType.wheel: 
        joint = WheelJoint(jc);
        if(joint is WheelJoint){
          if(config.lowerMotorLimit != null && config.upperMotorLimit != null) joint.rotationalLimitMotor1.setLimit(config.lowerMotorLimit!,config.upperMotorLimit!);
          if(config.springFrequency != null && config.dampingRatio != null) joint.rotationalLimitMotor1.setSpring(config.springFrequency!, config.dampingRatio!);
          if(config.motorSpeed != null && config.motorSpeed != null) joint.rotationalLimitMotor1.setMotor(config.motorSpeed!, config.motorForce!);
        }
        break;
      default:
    }

    joint.name = config.name ?? '';
    // finaly add to physics world
    addJoint( joint );

    return joint;
  }
}