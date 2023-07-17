import 'world_core.dart';
import 'core_main.dart';
import '../constraint/contact/contact_link.dart';
import 'utils_core.dart';
import '../shape/shape_main.dart';
import '../math/math.dart';
import '../math/mat33.dart';
import '../math/quat.dart';
import '../math/vec3.dart';

/// The class of rigid body.
/// Rigid body has the shape of a single or multiple collision processing,
/// I can set the parameters individually.
class SoftBody extends Core{
  SoftBody([Vec3? position, Quat? orientation]):super(position,orientation){
    this.position = position ?? Vec3();
    this.orientation = orientation ?? Quat();
  }

  SoftBody? next;
  SoftBody? prev;

  @override
  void setParent(World world){
    parent = world;
    scale = parent!.scale;
    invScale = parent!.invScale;
    id = parent!.numRigidBodies;
    if(name != '') name = id.toString();

    updateMesh();
  }

  /// **
  /// * I'll add a shape to rigid body.
  /// * If you add a shape, please call the setupMass method to step up to the start of the next.
  /// * @param   shape shape to Add
  /// *
  @override
  void addShape(Shape shape){
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

  /// **
  ///  * I will delete the shape from the rigid body.
  ///  * If you delete a shape, please call the setupMass method to step up to the start of the next.
  ///  * @param shape {Shape} to delete
  ///  * @return void
  ///  *
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
    parent!.removeSoftBody(this);
  }

  void checkContact( name ) {
    parent!.checkContact( this.name, name );
  }

  /// **
  ///  * Calulates mass datas(center of gravity, mass, moment inertia, etc...).
  ///  * If the parameter type is set to BODY_STATIC, the rigid body will be fixed to the space.
  ///  * If the parameter adjustPosition is set to true, the shapes' relative positions and
  ///  * the rigid body's position will be adjusted to the center of gravity.
  ///  * @param type
  ///  * @param adjustPosition
  ///  * @return void
  ///  *
  @override
  void setupMass([BodyType? bodyType, bool adjustPosition = true]) {
    this.bodyType = bodyType ?? BodyType.static;
    isDynamic = this.bodyType == BodyType.dynamic;
    isStatic = this.bodyType == BodyType.static;

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

    inverseMass = 1 / mass;
    tmpV.scaleEqual(inverseMass );

    if(adjustPosition){
      position.add(tmpV);
      for(Shape? shape = shapes; shape != null; shape = shape.next){
        shape.relativePosition.subEqual(tmpV);
      }

      // subtract offset inertia
      localInertia.subOffset(mass, tmpV );
    }

    inverseLocalInertia.invert(localInertia );

    //}

    if(this.bodyType == BodyType.static ){
      inverseMass = 0;
      inverseLocalInertia.set(0,0,0,0,0,0,0,0,0);
    }

    syncShapes();
    awake();
  }
  // * Awake the rigid body.
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
    for(Shape? shape = shapes; shape != null; shape = shape.next ) {
      shape.updateProxy();
    }
  }

  // * Sleep the rigid body.
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
  @override
  void testWakeUp(){
    if(linearVelocity.testZero() || angularVelocity.testZero() || position.testDiff(sleepPosition) || orientation.testDiff(sleepOrientation)) awake(); // awake the body
  }

  // * Get whether the rigid body has not any connection with others.
  @override
  bool isLonely() {
    return numContacts==0;
  }

  //  * The time integration of the motion of a rigid body, you can update the information such as the shape.
  //  * This method is invoked automatically when calling the step of the World,
  //  * There is no need to call from outside usually.
  @override
  void updatePosition(double timeStep) {
    switch(bodyType){
      case BodyType.static:
        linearVelocity.set(0,0,0);
        angularVelocity.set(0,0,0);

        // ONLY FOR TEST
        if(controlPos){
          position.copy(newPosition);
          controlPos = false;
        }
        if(controlRot){
          orientation.copy(newOrientation);
          controlRot = false;
        }
        break;
      case BodyType.dynamic:
        if(isKinematic ){
          linearVelocity.set(0,0,0);
          angularVelocity.set(0,0,0);
        }
        if(controlPos){
          linearVelocity.subVectors(newPosition, position ).multiplyScalar(1/timeStep);
          controlPos = false;
        }
        if(controlRot){
          angularVelocity.copy(getAxis() );
          orientation.copy(newOrientation );
          controlRot = false;
        }

        position.addScaledVector(linearVelocity, timeStep.toDouble());
        orientation.addTime(angularVelocity, timeStep.toDouble());
        updateMesh();
        break;
      default: printError("RigidBody", "Invalid type.");
    }

    syncShapes();
    updateMesh();
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
      // add by QuaziKb
      shape.rotation.multiplyMatrices(rotation, shape.relativeRotation );
      shape.updateProxy();
    }
  }


  //---------------------------------------------
  // APPLY IMPULSE FORCE
  //---------------------------------------------

  void applyImpulse(Vec3 position, Vec3 force){
    linearVelocity.addScaledVector(force, inverseMass);
    Vec3 rel = Vec3().copy( position ).sub( this.position ).cross( force ).applyMatrix3(inverseInertia, true );
    angularVelocity.add( rel );
  }


  //---------------------------------------------
  // SET DYNAMIQUE POSITION AND ROTATION
  //---------------------------------------------

  void setPosition(Vec3 pos){
    newPosition.copy( pos ).multiplyScalar( invScale );
    controlPos = true;
    if( !isKinematic ) isKinematic = true;
  }

  void setQuaternion(Quat q){
    newOrientation.set(q.x, q.y, q.z, q.w);
    controlRot = true;
    if( !isKinematic ) isKinematic = true;
  }

  void setRotation(Quat rot){
    newOrientation = Quat().setFromEuler( rot.x * Math.degtorad, rot.y * Math.degtorad, rot.z * Math.degtorad );
    controlRot = true;
  }

  //---------------------------------------------
  // RESET DYNAMIQUE POSITION AND ROTATION
  //---------------------------------------------

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

  //---------------------------------------------
  // GET POSITION AND ROTATION
  //---------------------------------------------

  Vec3 getPosition () {
    return pos;
  }

  Quat getQuaternion() {
    return quaternion;
  }

  //---------------------------------------------
  // AUTO UPDATE THREE MESH
  //---------------------------------------------

  void connectMesh( mesh) {
    mesh = mesh;
    updateMesh();
  }

  void updateMesh(){
    pos.scale( position, scale );
    quaternion.copy( orientation );
    if( mesh == null ) return;
    mesh.position.copy( getPosition() );
    mesh.quaternion.copy( getQuaternion() );
  }
}