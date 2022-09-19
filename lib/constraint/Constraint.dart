import '../core/RigidBody.dart';
import '../core/Utils.dart';
import '../core/Core.dart';
import '../core/World.dart';

/**
 * The base class of all type of the constraints.
 *
 * @author saharan
 * @author lo-th
 */

class Constraint extends Core{
  Constraint();
  // parent world of the constraint.
  World? parent;
  // first body of the constraint.
  RigidBody? body1;
  // second body of the constraint.
  RigidBody? body2;
  // Internal
  bool addedToIsland = false;

  // Prepare for solving the constraint
  void preSolve(double timeStep,double invTimeStep){
    printError("Constraint", "Inheritance error.");
  }

  // Solve the constraint. This is usually called iteratively.
  void solve(){
    printError("Constraint", "Inheritance error.");
  }

  // Do the post-processing.
  void postSolve(){
    printError("Constraint", "Inheritance error.");
  }
}