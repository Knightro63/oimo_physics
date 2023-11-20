import '../core/rigid_body.dart';
import '../core/utils_core.dart';
import '../core/core_main.dart';
import '../core/world_core.dart';


/// The base class of all type of the constraints.
class Constraint extends Core{
  Constraint();
  /// parent world of the constraint.
  World? parent;
  /// first body of the constraint.
  RigidBody? body1;
  /// second body of the constraint.
  RigidBody? body2;
  /// Internal
  bool addedToIsland = false;

  /// Prepare for solving the constraint
  void preSolve(double timeStep,double invTimeStep){
    printError("Constraint", "Inheritance error.");
  }

  /// Solve the constraint. This is usually called iteratively.
  void solve(){
    printError("Constraint", "Inheritance error.");
  }

  /// Do the post-processing.
  void postSolve(){
    printError("Constraint", "Inheritance error.");
  }
}