import 'dart:async';

import 'package:oimo_physics/collision/narrowphase/octree_capsule_collision_detector.dart';
import 'package:oimo_physics/collision/narrowphase/octree_sphere_collision_detection.dart';
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

import '../shape/shape_config.dart';

import '../collision/broadphase/broad_phase.dart';
import '../collision/broadphase/brute_force_broad_phase.dart';
import '../collision/broadphase/dbvt/dbvt_broad_phase.dart';
import 'utils_core.dart';
import '../shape/shape_main.dart';
import '../math/math.dart';
import 'package:vector_math/vector_math.dart';
import '../constraint/constraint_main.dart';
import 'core_main.dart';
import 'rigid_body.dart';

import '../constraint/joint/joint_main.dart';
import '../constraint/contact/contact_main.dart';

/// The configuration class for the objects
class ObjectConfigure{
  ObjectConfigure({
    this.type = JointType.none,
    this.shapes = const [],
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

    Vector3? position,
    Vector3? position2,
    Vector3? positionShape,
    Quaternion? rotation,
    Quaternion? rotationShape,
    //this.size = const [0,0,0],

    Vector3? axis1,
    Vector3? axis2,

    this.motorSpeed,
    this.motorForce,
    this.springFrequency,
    this.dampingRatio,
    this.lowerMotorLimit,
    this.upperMotorLimit
  }){
    this.position = position?.clone() ?? Vector3.zero();
    this.position2 = position2?.clone() ?? Vector3.zero();
    this.positionShape = positionShape?.clone() ?? Vector3.zero();
    this.rotation = rotation?.clone() ?? Quaternion(0,0,0,1);
    this.rotationShape = rotationShape?.clone() ?? Quaternion(0,0,0,1);

    this.axis1 = axis1?.clone() ?? Vector3.zero();
    this.axis2 = axis2?.clone() ?? Vector3.zero();

    this.shapeConfig = shapeConfig ?? ShapeConfig();

    this.max = max ?? (JointType.distance == type?0:10);
    this.min = min ?? (JointType.distance == type?0:57.29578);
  }


  List<Shape> shapes;
  JointType type;
  bool move;
  bool kinematic;
  bool neverSleep;

  late Vector3 position;
  late Vector3 position2;
  late Vector3 positionShape;
  late Quaternion rotation;
  late Quaternion rotationShape;
  //late List<double> size;

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

  late Vector3 axis1;
  late Vector3 axis2;

  double? motorSpeed; 
  double? motorForce;
  int? springFrequency;
  double? dampingRatio;
  double? lowerMotorLimit; 
  double? upperMotorLimit;
}

/// The configuration class for the world
class WorldConfigure {
  WorldConfigure({
    this.scale = 1,
    this.timeStep = 1/60,
    this.broadPhaseType = BroadPhaseType.sweep,
    this.isStat = false,
    this.enableRandomizer = true,
    this.iterations = 8,
    this.setPerformance = false,
    Vector3? gravity
  }){
    this.gravity = gravity ?? Vector3(0,-9.8,0);
  }

  double scale;
  double timeStep;
  int iterations;
  bool enableRandomizer;
  bool isStat;
  BroadPhaseType broadPhaseType;
  bool setPerformance;
  late Vector3 gravity;
}

/// The class of physical computing world.
/// You must be added to the world physical all computing objects
/// timestep, broadphase, iterations, worldscale, random, stat
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

    // Octree
    detectors['Shapes.octree Shapes.sphere'] = OctreeSphereCollisionDetector();
    detectors['Shapes.sphere Shapes.octree'] = OctreeSphereCollisionDetector();
    detectors['Shapes.octree Shapes.capsule'] = OctreeCapsuleCollisionDetector();
    detectors['Shapes.capsule Shapes.octree'] = OctreeCapsuleCollisionDetector();
    // TETRA add
    //this.detectors[SHAPE_TETRA][SHAPE_TETRA] = TetraTetraCollisionDetector();

    bool getInfo = worldConfigure?.setPerformance ?? false;
    if(getInfo){
      performance = InfoDisplay(this);
      performance!.setTime();
    }
    time = InfoDisplay.now().toDouble();
  }

  late WorldConfigure worldConfigure;
  /// this world scale defaut is 0.1 to 10 meters max for dynamique body
  late double scale;
  late double invScale;

  /// The wall-clock time since simulation start.
  double time = 0.0;

  /// The time between each step
  late double timeStep; // 1/60;
  late int timerate;
  
  Timer? timer;

  void Function()? preLoop;//function(){};
  void Function()? postLoop;//function(){};

  /// The number of iterations for constraint solvers.
  late int numIterations;
  late BroadPhaseType broadPhaseType;
  late BroadPhase broadPhase;

  /// This is the detailed information of the performance.
  InfoDisplay? performance;
  late bool isStat;

  /// Whether the constraints randomizer is enabled or not.
  late bool enableRandomizer;

  /// The rigid body list
  RigidBody? rigidBodies;
  /// number of rigid body
  int numRigidBodies=0;
  /// The contact list
  Contact? contacts;
  Contact? unusedContacts;
  /// The number of contact
  int numContacts=0;
  /// The number of contact points
  int numContactPoints=0;
  ///  The joint list
  Joint? joints;
  /// The number of joints.
  int numJoints=0;
  /// The number of simulation islands.
  int numIslands=0;

  /// The gravity in the world.
  late Vector3 gravity;
  
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
  }
  void stop(){
    if(timer == null) return;
    timer?.cancel();
    timer = null;
  }
  void setGravity(List<double> ar){
    gravity.copyFromArray( ar );
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

  /// Reset the world and remove all rigid bodies, shapes, joints and any object from the world.
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

  /// I'll add a rigid body to the world.
  /// Rigid body that has been added will be the operands of each step.
  /// [rigidBody]  Rigid body that you want to add
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

  /// I will remove the rigid body from the world.
  /// Rigid body that has been deleted is excluded from the calculation on a step-by-step basis.
  /// [rigidBody]  Rigid body to be removed
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


  /// I'll add a shape to the world..
  /// Add to the rigid world, and if you add a shape to a rigid body that has been added to the world,
  /// Shape will be added to the world automatically, please do not call from outside this method.
  /// [shape]  Shape you want to add
  void addShape(Shape shape){
    if(shape.parent == null || shape.parent!.parent == null){
      printError("World", "It is not possible to be added alone to shape world");
    }

    shape.proxy = broadPhase.createProxy(shape);
    shape.updateProxy();
    broadPhase.addProxy(shape.proxy!);
  }


  /// I will remove the shape from the world.
  /// Add to the rigid world, and if you add a shape to a rigid body that has been added to the world,
  /// Shape will be added to the world automatically, please do not call from outside this method.
  /// [shape]  Shape you want to delete
  void removeShape(Shape shape){
    broadPhase.removeProxy(shape.proxy!);
    shape.proxy = null;
  }

  /// I'll add a joint to the world.
  /// Joint that has been added will be the operands of each step.
  /// [shape] Joint to be added
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

  /// I will remove the joint from the world.
  /// Joint that has been added will be the operands of each step.
  /// [shape] Joint to be deleted
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

  /// Add contact with 2 shapes
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

  /// Remove a contact
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

  /// Get a contact from 2 rigid bodies
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

  /// Chack to see if it is a contact
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

  /// Should call sleep
  bool callSleep(RigidBody body) {
    if( !body.allowSleep ) return false;
    if( body.linearVelocity.length2 > 0.04 ) return false;
    if( body.angularVelocity.length2 > 0.25 ) return false;
    return true;
  }

  /// I will proceed only time step seconds time of World.
  void step(){
    time = InfoDisplay.now();
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

    ///------------------------------------------------------
    ///   UPDATE BROADPHASE CONTACT
    ///------------------------------------------------------
    if(stat){
      performance?.setTime(1);
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

    /// update & narrow phase
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
          base.linearVelocity.addScaled(gravity, timeStep);
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
          if( constraint.addedToIsland || !contact.touching) continue;// ignore
          RigidBody next = cs.body!;
          body.collide?.call(next);
          next.collide?.call(body);
          
          if(next.isTrigger) continue;
          

          // add constraint to the island
          islandConstraints[islandNumConstraints++] = constraint;
          constraint.addedToIsland = true;
          

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
      Vector3 gVel = Vector3.copy(gravity)..scale(timeStep);
      for(int j=0; j< islandNumRigidBodies; j++){
        body = islandRigidBodies[j];
        if(body!.isDynamic){
          body.linearVelocity.add(gVel);
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

  /// remove someting to world
  void remove( obj ){

  }

  /// add someting to world
  Core? add(ObjectConfigure config){
    if(config.type != JointType.none){ 
      return initJoint(config);
    }
    else {
      return initBody(config);
    }
  }

  /// Init the body added
  RigidBody? initBody(ObjectConfigure config){
    double invScale = this.invScale;

    // rigidbody
    final body = RigidBody( 
      position: Vector3.copy(config.position)..scale(invScale),
      orientation: Quaternion.copy(config.rotation)..scale(invScale),
      type: config.kinematic?RigidBodyType.kinematic:config.move?RigidBodyType.dynamic:RigidBodyType.static,
      allowSleep: !config.neverSleep,
      name: config.name,
      shapes: config.shapes,
      isSleeping: config.sleep,
      adjustPosition: (config.massPos || config.massRot)?false:true
    );

    // finaly add to physics world
    addRigidBody(body);
    return body;
  }

  /// Initlize the joint added
  Joint? initJoint(ObjectConfigure config){
    //var type = type;
    double invScale = this.invScale;

    final axe1 = config.axis1;
    final axe2 = config.axis2;
    final pos1 = Vector3.copy(config.position)..scale(invScale);
    final pos2 = Vector3.copy(config.position2)..scale(invScale);

    double min = config.min;
    double max = config.max;
    if(config.type == JointType.distance){
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
    jc.localAxis1.setFrom( axe1 );
    jc.localAxis2.setFrom( axe2 );
    jc.localAnchorPoint1.setFrom( pos1 );
    jc.localAnchorPoint2.setFrom( pos2 );

    RigidBody? b1 = config.body1;
    RigidBody? b2 = config.body2;

    if(b1 == null || b2 == null){
      printError('World', "Can't add joint attach rigidbodys not find !" ); 
      return null;
    }

    jc.body1 = b1;
    jc.body2 = b2;

    late Joint joint;
    switch(config.type){
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