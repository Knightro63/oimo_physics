import 'package:oimo_physics/shape/plane_shape.dart';

import 'world_core.dart';
import 'core_main.dart';
import '../constraint/contact/contact_link.dart';
import '../constraint/joint/joint_link.dart';
import 'utils_core.dart';
import '../shape/mass_info.dart';
import '../shape/shape_main.dart';
import '../math/math.dart';
import '../math/mat33.dart';
import '../math/quat.dart';
import '../math/vec3.dart';

/// The class of rigid body.
/// Rigid body has the shape of a single or multiple collision processing,
/// I can set the parameters individually.
enum RigidBodyType{none,dynamic,static,kinematic,ghost}

class RigidBody extends Core{
  RigidBody({
    Vec3? position, 
    Quat? orientation,
    List<Shape>? shapes,
    String? name,
    this.type = RigidBodyType.static,
    this.allowSleep = true,
    bool isSleeping = false,
    bool adjustPosition = true,
    Vec3? linearVelocity,
    Vec3? angularVelocity,
    double? mass,
    this.isTrigger = false
  }){
    this.position = position ?? Vec3();
    this.orientation = orientation ?? Quat();
    this.linearVelocity = linearVelocity ?? Vec3();
    this.angularVelocity = angularVelocity ?? Vec3();

    initAngularVelocity = Vec3().copy(this.angularVelocity);
    initLinearVelocity = Vec3().copy(this.linearVelocity);
    initPosition = Vec3().copy(this.position);
    initOrientation = Quat().copy(this.orientation);

    //type = config.type;
    if(shapes!= null && shapes.isNotEmpty){
      for(int i = 0; i < shapes.length;i++){
        addShape(shapes[i]);
      }
    }

    id = RigidBody.idCounter++;
    this.name = name ?? id.toString();
  
    if(isKinematic){ 
      allowSleep = false;
    }

    if(mass == null || mass == 0){
      setupMass(adjustPosition);
    }
    else{
      this.mass = mass;
      type = RigidBodyType.static == type?RigidBodyType.dynamic:type;
      setupInertia(Vec3(),adjustPosition);
    }

    if(isDynamic){
      if(isSleeping){
        sleep();
      }
      else{
        awake();
      }
    }
  }

  void Function(RigidBody body)? collide;//function(){};

  /// Initilized parameters
  late Vec3 initPosition;
  late Vec3 initAngularVelocity;
  late Vec3 initLinearVelocity;
  late Quat initOrientation;

  late Vec3 position;
  late Quat orientation;
  late bool isTrigger;

  double scale = 1;
  double invScale = 1;

  static int idCounter = 0;
  late int id;
  late String name;

  /// The maximum number of shapes that can be added to a one rigid.
  // MAX_SHAPES = 64;
  RigidBody? prev;
  RigidBody? next;

  // I represent the kind of rigid body.
  // Please do not change from the outside this variable.
  // If you want to change the type of rigid body, always
  // Please specify the type you want to set the arguments of setupMass method.
  RigidBodyType type;

  MassInfo massInfo = MassInfo();

  /// Is the translational velocity.
  late Vec3 linearVelocity;
  /// Is the angular velocity.
  late Vec3 angularVelocity;

  //--------------------------------------------
  //  Please do not change from the outside this variables.
  //--------------------------------------------

  /// It is a world that rigid body has been added.
  World? parent;
  ContactLink? contactLink;
  int numContacts = 0;

  /// An array of shapes that are included in the rigid body.
  Shape? shapes;
  /// The number of shapes that are included in the rigid body.
  int numShapes = 0;

  /// It is the link array of joint that is connected to the rigid body.
  JointLink? jointLink;
  /// The number of joints that are connected to the rigid body.
  int numJoints = 0;

  /// It is the world coordinate of the center of gravity in the sleep just before.
  Vec3 sleepPosition = Vec3();
  /// It is a quaternion that represents the attitude of sleep just before.
  Quat sleepOrientation = Quat();

  /// I will show this rigid body to determine whether it is a rigid body static.
  bool get isStatic => RigidBodyType.static == type;
  /// I indicates that this rigid body to determine whether it is a rigid body dynamic.
  bool get isDynamic  => RigidBodyType.dynamic == type;
  bool get isKinematic => RigidBodyType.kinematic == type;

  /// It is a rotation matrix representing the orientation.
  Mat33 rotation = Mat33();

  //--------------------------------------------
  // It will be recalculated automatically from the shape, which is included.
  //--------------------------------------------

  /// This is the weight.
  double mass = 0;
  /// It is the reciprocal of the mass.
  double inverseMass = 0;
  /// It is the inverse of the inertia tensor in the world system.
  Mat33 inverseInertia = Mat33();
  /// It is the inertia tensor in the initial state.
  Mat33 localInertia = Mat33();
  /// It is the inverse of the inertia tensor in the initial state.
  Mat33 inverseLocalInertia = Mat33();

  Mat33 tmpInertia = Mat33();

  /// I indicates rigid body whether it has been added to the simulation Island.
  bool addedToIsland = false;
  /// It shows how to sleep rigid body.
  bool allowSleep;
  /// This is the time from when the rigid body at rest.
  double sleepTime = 0;
  /// I shows rigid body to determine whether it is a sleep state.
  bool sleeping = false;

  bool fixedRotation = false;

  @override
  void setParent(World world){
    parent = world;
    scale = parent!.scale;
    invScale = parent!.invScale;
    id = parent!.numRigidBodies;
    if(name != '') name = id.toString();

    //updateMesh();
  }

  /// I'll add a shape to rigid body.
  /// If you add a shape, please call the setupMass method to step up to the start of the next.
  /// [shape] shape to Add
  void addShape(Shape shape){
    if(shape is Plane){
      shape.computeNormal(orientation);
    }
    if(shape.parent != null){
      printError("RigidBody", "It is not possible that you add a shape which already has an associated body.");
    }
    if(shapes != null)(shapes!.prev = shape).next = shapes;
    shapes = shape;
    shape.parent = this;
    if(parent != null){ 
      parent!.addShape(shape);
    }
    numShapes++;
  }

  /// I will delete the shape from the rigid body.
  /// If you delete a shape, please call the setupMass method to step up to the start of the next.
  /// [shape] shape to delete
  void removeShape(Shape shape){
    Shape remove = shape;
    if(remove.parent != this)return;
    Shape? prev = remove.prev;
    Shape? next = remove.next;
    if(prev != null) prev.next = next;
    if(next != null) next.prev = prev;
    if(shapes == remove)shapes = next;
    remove.prev = null;
    remove.next = null;
    remove.parent = null;
    if(parent != null)parent!.removeShape(remove);
    numShapes--;
  }
  @override
  void remove() {
    dispose();
  }
  @override
  void dispose() {
    parent!.removeRigidBody( this );
  }

  void checkContact( name ) {
    parent!.checkContact( this.name, name );
  }

  /// Calulates mass datas(center of gravity, mass, moment inertia, etc...).
  /// If the parameter type is set to BODY_STATIC, the rigid body will be fixed to the space.
  /// If the parameter adjustPosition is set to true, the shapes' relative positions and
  /// the rigid body's position will be adjusted to the center of gravity.
  /// [type] type of rigid body
  /// [adjustPosition]
  void setupMass([bool adjustPosition = true]) {
    mass = 0;
    localInertia.set(0,0,0,0,0,0,0,0,0);

    Mat33 tmpM = Mat33();
    Vec3 tmpV = Vec3();

    for(Shape? shape = shapes; shape != null; shape = shape.next){
      shape.calculateMassInfo(massInfo);
      double shapeMass = massInfo.mass;
      tmpV.addScaledVector(shape.relativePosition, shapeMass);
      mass += shapeMass;
      rotateInertia(shape.relativeRotation, massInfo.inertia, tmpM );
      localInertia.add(tmpM);
      // add offset inertia
      localInertia.addOffset(shapeMass, shape.relativePosition );
    }
    setupInertia(tmpV,adjustPosition);
  }

  void setupInertia(Vec3 tmpV,bool adjustPosition){
    inverseMass = 1 / mass;
    tmpV.scaleEqual(inverseMass);

    if(adjustPosition){
      position.add(tmpV);
      for(Shape? shape = shapes; shape != null; shape = shape.next){
        shape.relativePosition.subEqual(tmpV);
      }

      // subtract offset inertia
      localInertia.subOffset(mass, tmpV );
    }

    inverseLocalInertia.invert(localInertia );

    if(isStatic){
      inverseMass = 0;
      inverseLocalInertia.set(0,0,0,0,0,0,0,0,0);
    }

    syncShapes();
    awake();
  }

  /// Awake the rigid body.
  @override
  void awake(){
    if(!allowSleep || !sleeping ) return;
    sleeping = false;
    sleepTime = 0;
    // awake connected constraints
    ContactLink? cs = contactLink;
    while(cs != null){
      cs.body!.sleepTime = 0;
      cs.body!.sleeping = false;
      cs = cs.next;
    }
    JointLink? js = jointLink;
    while(js != null){
      js.body!.sleepTime = 0;
      js.body!.sleeping = false;
      js = js.next;
    }
    for(Shape? shape = shapes; shape != null; shape = shape.next ) {
      shape.updateProxy();
    }
  }

  /// Sleep the rigid body.
  @override
  void sleep(){
    if(!allowSleep || sleeping ) return;
    linearVelocity.set(0,0,0);
    angularVelocity.set(0,0,0);
    sleepPosition.copy(position );
    sleepOrientation.copy(orientation );

    sleepTime = 0;
    sleeping = true;
    for(Shape? shape = shapes; shape != null; shape = shape.next ) {
      shape.updateProxy();
    }
  }

  void testWakeUp(){
    if(linearVelocity.testZero() || angularVelocity.testZero() || position.testDiff(sleepPosition) || orientation.testDiff(sleepOrientation)) awake(); // awake the body
  }

  /// Get whether the rigid body has not any connection with others.
  bool isLonely() {
    return numJoints==0 && numContacts==0;
  }

  /// The time integration of the motion of a rigid body, you can update the information such as the shape.
  /// This method is invoked automatically when calling the step of the World,
  /// There is no need to call from outside usually.
  void updatePosition(double timeStep) {
    switch(type){
      case RigidBodyType.static:
        linearVelocity.set(0,0,0);
        angularVelocity.set(0,0,0);
        break;
      case RigidBodyType.dynamic:
        position.addScaledVector(linearVelocity, timeStep.toDouble());
        if(fixedRotation){
          angularVelocity.set(0,0,0);
        }
        else{
          orientation.addTime(angularVelocity, timeStep.toDouble());
        }
        break;
      case RigidBodyType.kinematic:
        // linearVelocity.set(0,0,0);
        if(fixedRotation){
          angularVelocity.set(0,0,0);
        }
        else{
          orientation.addTime(angularVelocity, timeStep.toDouble());
        }
        position.addScaledVector(linearVelocity, timeStep.toDouble());
        break;
      default: printError("RigidBody", "Invalid type.");
    }

    syncShapes();
  }

  Vec3 getAxis() {
    return Vec3( 0,1,0 ).applyMatrix3(inverseLocalInertia, true ).normalize();
  }

  void rotateInertia(Mat33 rot,Mat33 inertia, Mat33 out) {
    tmpInertia.multiplyMatrices(rot, inertia);
    out.multiplyMatrices(tmpInertia, rot, true);
  }

  void syncShapes() {
    rotation.setQuat(orientation );
    rotateInertia(rotation, inverseLocalInertia, inverseInertia );
    
    for(Shape? shape = shapes; shape!=null; shape = shape.next){
      shape.position.copy( shape.relativePosition ).applyMatrix3(rotation, true ).add(position );
      //shape.relativePosition.applyMatrix3(rotation, true ).add(position );
      // add by QuaziKb
      shape.rotation.multiplyMatrices(rotation, shape.relativeRotation );
      shape.updateProxy();
    }
  }


  ///---------------------------------------------
  /// APPLY IMPULSE FORCE
  ///---------------------------------------------
  void applyImpulse(Vec3 position, Vec3 force){
    linearVelocity.addScaledVector(force, inverseMass);
    position.sub( this.position ).cross( force ).applyMatrix3(inverseInertia, true );
    angularVelocity.add( position );
  }

  ///---------------------------------------------
  /// APPLY IMPULSE FORCE
  ///---------------------------------------------
  void applyTorque(Vec3 torque){
    torque.multiply(Vec3(5,5,5)).applyMatrix3(inverseInertia, true );
    angularVelocity.add(torque);
  }

  ///---------------------------------------------
  /// SET DYNAMIQUE POSITION AND ROTATION
  ///---------------------------------------------
  void setPosition(Vec3 pos){
    position.copy( pos ).multiplyScalar( invScale );
  }

  void setQuaternion(Quat q){
    orientation.set(q.x, q.y, q.z, q.w);
  }

  void setRotation(Quat rot){
    orientation = Quat().setFromEuler( rot.x * Math.degtorad, rot.y * Math.degtorad, rot.z * Math.degtorad );
  }

  ///---------------------------------------------
  /// RESET DYNAMIQUE POSITION AND ROTATION
  ///---------------------------------------------
  void resetPosition(double x,double y,double z){
    linearVelocity.set( 0, 0, 0 );
    angularVelocity.set( 0, 0, 0 );
    position.set( x, y, z ).multiplyScalar( invScale );
    awake();
  }

  void resetQuaternion(Quat q ){
    angularVelocity.set(0,0,0);
    orientation = Quat( q.x, q.y, q.z, q.w );
    awake();
  }

  void resetRotation(double x,double y,double z){
    angularVelocity.set(0,0,0);
    orientation = Quat().setFromEuler( x * Math.degtorad, y * Math.degtorad,  z * Math.degtorad );//this.rotationVectToQuad( Vec3(x,y,z) );
    awake();
  }
}