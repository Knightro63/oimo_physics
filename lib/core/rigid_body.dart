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
import 'package:vector_math/vector_math.dart' hide Plane;

/// The class of rigid body.
/// Rigid body has the shape of a single or multiple collision processing,
/// I can set the parameters individually.
enum RigidBodyType{none,dynamic,static,kinematic,ghost}

class RigidBody extends Core{
  RigidBody({
    Vector3? position, 
    Quaternion? orientation,
    List<Shape>? shapes,
    String? name,
    this.type = RigidBodyType.static,
    this.allowSleep = true,
    bool isSleeping = false,
    bool adjustPosition = true,
    Vector3? linearVelocity,
    Vector3? angularVelocity,
    double? mass,
    this.isTrigger = false
  }){
    this.position = position ?? Vector3.zero();
    this.orientation = orientation ?? Quaternion(0,0,0,1);
    this.linearVelocity = linearVelocity ?? Vector3.zero();
    this.angularVelocity = angularVelocity ?? Vector3.zero();

    initAngularVelocity = Vector3.copy(this.angularVelocity);
    initLinearVelocity = Vector3.copy(this.linearVelocity);
    initPosition = Vector3.copy(this.position);
    initOrientation = Quaternion.copy(this.orientation);

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
      setupInertia(Vector3.zero(),adjustPosition);
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
  late Vector3 initPosition;
  late Vector3 initAngularVelocity;
  late Vector3 initLinearVelocity;
  late Quaternion initOrientation;

  late Vector3 position;
  late Quaternion orientation;
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
  late Vector3 linearVelocity;
  /// Is the angular velocity.
  late Vector3 angularVelocity;

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
  Vector3 sleepPosition = Vector3.zero();
  /// It is a quaternion that represents the attitude of sleep just before.
  Quaternion sleepOrientation = Quaternion(0,0,0,1);

  /// I will show this rigid body to determine whether it is a rigid body static.
  bool get isStatic => RigidBodyType.static == type;
  /// I indicates that this rigid body to determine whether it is a rigid body dynamic.
  bool get isDynamic  => RigidBodyType.dynamic == type;
  bool get isKinematic => RigidBodyType.kinematic == type;

  /// It is a rotation matrix representing the orientation.
  Matrix3 rotation = Matrix3.identity();

  //--------------------------------------------
  // It will be recalculated automatically from the shape, which is included.
  //--------------------------------------------

  /// This is the weight.
  double mass = 0;
  /// It is the reciprocal of the mass.
  double inverseMass = 0;
  /// It is the inverse of the inertia tensor in the world system.
  Matrix3 inverseInertia = Matrix3.identity();
  /// It is the inertia tensor in the initial state.
  Matrix3 localInertia = Matrix3.identity();
  /// It is the inverse of the inertia tensor in the initial state.
  Matrix3 inverseLocalInertia = Matrix3.identity();

  Matrix3 tmpInertia = Matrix3.identity();

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
    localInertia.setValues(0,0,0,0,0,0,0,0,0);

    Matrix3 tmpM = Matrix3.identity();
    Vector3 tmpV = Vector3.zero();

    for(Shape? shape = shapes; shape != null; shape = shape.next){
      shape.calculateMassInfo(massInfo);
      double shapeMass = massInfo.mass;
      tmpV.addScaled(shape.relativePosition, shapeMass);
      mass += shapeMass;
      rotateInertia(shape.relativeRotation, massInfo.inertia, tmpM );
      localInertia.add(tmpM);
      // add offset inertia
      localInertia.addOffset(shapeMass, shape.relativePosition );
    }
    setupInertia(tmpV,adjustPosition);
  }

  void setupInertia(Vector3 tmpV,bool adjustPosition){
    inverseMass = 1 / mass;
    tmpV.scale(inverseMass);

    if(adjustPosition){
      position.add(tmpV);
      for(Shape? shape = shapes; shape != null; shape = shape.next){
        shape.relativePosition.sub(tmpV);
      }

      // subtract offset inertia
      localInertia.subOffset(mass, tmpV );
    }

    inverseLocalInertia.invert2(localInertia );

    if(isStatic){
      inverseMass = 0;
      inverseLocalInertia.setValues(0,0,0,0,0,0,0,0,0);
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
    linearVelocity.setValues(0,0,0);
    angularVelocity.setValues(0,0,0);
    sleepPosition.setFrom(position );
    sleepOrientation.setFrom(orientation );

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
        linearVelocity.setValues(0,0,0);
        angularVelocity.setValues(0,0,0);
        break;
      case RigidBodyType.dynamic:
        position.addScaled(linearVelocity, timeStep.toDouble());
        if(fixedRotation){
          angularVelocity.setValues(0,0,0);
        }
        else{
          orientation.addTime(angularVelocity, timeStep.toDouble());
        }
        break;
      case RigidBodyType.kinematic:
        // linearVelocity.set(0,0,0);
        if(fixedRotation){
          angularVelocity.setValues(0,0,0);
        }
        else{
          orientation.addTime(angularVelocity, timeStep.toDouble());
        }
        position.addScaled(linearVelocity, timeStep.toDouble());
        break;
      default: printError("RigidBody", "Invalid type.");
    }

    syncShapes();
  }

  Vector3 getAxis() {
    return Vector3( 0,1,0 )..applyMatrix3Transpose(inverseLocalInertia )..normalize();
  }

  void rotateInertia(Matrix3 rot,Matrix3 inertia, Matrix3 out) {
    tmpInertia.multiplyMatrices(rot, inertia);
    out.multiplyMatrices(tmpInertia, rot, true);
  }

  void syncShapes() {
    rotation.setQuat(orientation );
    rotateInertia(rotation, inverseLocalInertia, inverseInertia );
    
    for(Shape? shape = shapes; shape!=null; shape = shape.next){
      shape.position..setFrom( shape.relativePosition )..applyMatrix3Transpose(rotation)..add(position );
      //shape.relativePosition.applyMatrix3(rotation, true ).add(position );
      // add by QuaziKb
      shape.rotation.multiplyMatrices(rotation, shape.relativeRotation );
      shape.updateProxy();
    }
  }


  ///---------------------------------------------
  /// APPLY IMPULSE FORCE
  ///---------------------------------------------
  void applyImpulse(Vector3 position, Vector3 force){
    linearVelocity.addScaled(force, inverseMass);
    position..sub( this.position )..cross( force )..applyMatrix3Transpose(inverseInertia );
    angularVelocity.add( position );
  }

  ///---------------------------------------------
  /// APPLY IMPULSE FORCE
  ///---------------------------------------------
  void applyTorque(Vector3 torque){
    torque..multiply(Vector3(5,5,5))..applyMatrix3Transpose(inverseInertia );
    angularVelocity.add(torque);
  }

  ///---------------------------------------------
  /// SET DYNAMIQUE POSITION AND ROTATION
  ///---------------------------------------------
  void setPosition(Vector3 pos){
    position..setFrom( pos )..scale( invScale );
  }

  void setQuaternion(Quaternion q){
    orientation.setValues(q.x, q.y, q.z, q.w);
  }

  void setRotation(Quaternion rot){
    orientation = Quaternion(0,0,0,1).eulerFromXYZ( rot.x * Math.degtorad, rot.y * Math.degtorad, rot.z * Math.degtorad );
  }

  ///---------------------------------------------
  /// RESET DYNAMIQUE POSITION AND ROTATION
  ///---------------------------------------------
  void resetPosition(double x,double y,double z){
    linearVelocity.setValues( 0, 0, 0 );
    angularVelocity.setValues( 0, 0, 0 );
    position..setValues( x, y, z )..scale( invScale );
    awake();
  }

  void resetQuaternion(Quaternion q ){
    angularVelocity.setValues(0,0,0);
    orientation = Quaternion( q.x, q.y, q.z, q.w );
    awake();
  }

  void resetRotation(double x,double y,double z){
    angularVelocity.setValues(0,0,0);
    orientation = Quaternion(0,0,0,1).eulerFromXYZ( x * Math.degtorad, y * Math.degtorad,  z * Math.degtorad );//this.rotationVectToQuad( Vector3(x,y,z) );
    awake();
  }
}