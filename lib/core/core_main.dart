import 'utils_core.dart';
import 'world_core.dart';
import '../constraint/contact/contact_link.dart';
import '../shape/mass_info.dart';
import '../shape/shape_main.dart';
import '../math/mat33.dart';
import '../math/quat.dart';
import '../math/vec3.dart';

/// Types of Rigid Bodies Available.
enum BodyType{none,dynamic,static,kinematic,ghost}
enum CoreType{soft,rigid,cloth}

class Core{
  Core([Vec3? position, Quat? orientation]){
    this.position = position ?? Vec3();
    this.orientation = orientation ?? Quat();
  }

  World? parent;
  late Vec3 position;
  late Quat orientation;
  ContactLink? contactLink;

  // I will show this rigid body to determine whether it is a rigid body static.
  bool isStatic = false;
  // I indicates that this rigid body to determine whether it is a rigid body dynamic.
  bool isDynamic = false;
  bool isKinematic = false;

  // I indicates rigid body whether it has been added to the simulation Island.
  bool addedToIsland = false;
  // It shows how to sleep rigid body.
  bool allowSleep = true;
  // This is the time from when the rigid body at rest.
  double sleepTime = 0;
  // I shows rigid body to determine whether it is a sleep state.
  bool sleeping = false;
  int numContacts = 0;

  double scale = 1;
  double invScale = 1;

  /// possible link to three Mesh; dart(todo) add three_dart
  dynamic mesh;

  int? id;
  String name = "";

  // I represent the kind of rigid body.
  // Please do not change from the outside this variable.
  // If you want to change the type of rigid body, always
  // Please specify the type you want to set the arguments of setupMass method.
  BodyType bodyType = BodyType.none;


  MassInfo massInfo = MassInfo();
  Vec3 newPosition = Vec3();
  bool controlPos = false;
  Quat newOrientation = Quat();
  Vec3 newRotation = Vec3();
  Vec3 currentRotation = Vec3();
  bool controlRot = false;
  bool controlRotInTime = false;

  Quat quaternion = Quat();
  Vec3 pos = Vec3();

  // Is the translational velocity.
  Vec3 linearVelocity = Vec3();
  // Is the angular velocity.
  Vec3 angularVelocity = Vec3();

  // An array of shapes that are included in the rigid body.
  Shape? shapes;
  // The number of shapes that are included in the rigid body.
  int numShapes = 0;

  // It is the world coordinate of the center of gravity in the sleep just before.
  Vec3 sleepPosition = Vec3();
  // It is a quaternion that represents the attitude of sleep just before.
  Quat sleepOrientation = Quat();

  // It is a rotation matrix representing the orientation.
  Mat33 rotation = Mat33();


  //--------------------------------------------
  // It will be recalculated automatically from the shape, which is included.
  //--------------------------------------------

  // This is the weight.
  double mass = 0;
  // It is the reciprocal of the mass.
  double inverseMass = 0;
  // It is the inverse of the inertia tensor in the world system.
  Mat33 inverseInertia = Mat33();
  // It is the inertia tensor in the initial state.
  Mat33 localInertia = Mat33();
  // It is the inverse of the inertia tensor in the initial state.
  Mat33 inverseLocalInertia = Mat33();

  Mat33 tmpInertia = Mat33();
  void dispose(){
    printError("Core", "Dispose error.");
  }
  void awake(){
    printError("Core", "Awake error.");
  }
  void sleep(){
    printError("Core", "Sleep error.");
  }
  void remove(){
    printError("Core", "Remove error.");
  }
  void setParent(World world){
    printError("Core", "Set Parent error.");
  }
  void testWakeUp(){
    printError("Core", "test Wake Up error.");
  }
  void addShape(Shape shape){

  }
  void setupMass([BodyType? bodyType, bool adjustPosition = true]){

  }
  void updatePosition(double timeStep) {
    printError("Core", "Update Position error.");
  }
  bool isLonely() {
    throw("isLonely is not implimented.");
  }
}