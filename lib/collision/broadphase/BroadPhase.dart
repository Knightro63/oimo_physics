import '../../core/RigidBody.dart';

import '../../core/Utils.dart';
import 'Pair.dart';
import '../../shape/Shape.dart';
import 'Proxy.dart';
import '../../constraint/joint/JointLink.dart';
import '../../constraint/joint/Joint.dart';

/**
* The broad-phase is used for collecting all possible pairs for collision.
*/

enum BroadPhaseType{none,force,sweep,volume}

class BroadPhase{
  BroadPhase();

  BroadPhaseType types = BroadPhaseType.none;
  int numPairChecks = 0;
  int numPairs = 0;
  List<Pair> pairs = [];

  // Create a new proxy.
  Proxy? createProxy(Shape shape ) {
    printError("BroadPhase","Inheritance error.");
    return null;
  }

  // Add the proxy into the broad-phase.
  void addProxy(Proxy proxy ) {
    printError("BroadPhase","Inheritance error.");
  }

  // Remove the proxy from the broad-phase.
  void removeProxy(Proxy proxy ) {
    printError("BroadPhase","Inheritance error.");
  }

  // Returns whether the pair is available or not.
  bool isAvailablePair(Shape s1,Shape s2 ) {
    RigidBody b1 = s1.parent!;
    RigidBody b2 = s2.parent!;

    if( b1 == b2 || // same parents
      (!b1.isDynamic && !b2.isDynamic) || // static or kinematic object
      (s1.belongsTo&s2.collidesWith)==0 ||
      (s2.belongsTo&s1.collidesWith)==0 // collision filtering
    ){ 
      return false; 
    }

    JointLink? js;
    if(b1.numJoints < b2.numJoints){ 
      js = b1.jointLink;
    }
    else{ 
      js = b2.jointLink;
    }

    while(js!=null){
      Joint joint = js.joint;
      if( !joint.allowCollision && ((joint.body1==b1 && joint.body2==b2) || (joint.body1==b2 && joint.body2==b1)) ){ 
        return false; 
      }
      js = js.next;
    }

    return true;
  }

  // Detect overlapping pairs.
  void detectPairs() {
    // clear old
    pairs = [];
    numPairs = 0;
    numPairChecks = 0;
    collectPairs();
  }

  void collectPairs() {
    printError("BroadPhase", "Inheritance error.");
  }

  void addPair(Shape s1,Shape s2 ) {
    Pair pair = Pair( s1, s2 );
    pairs.add(pair);
    numPairs++;
  }

}