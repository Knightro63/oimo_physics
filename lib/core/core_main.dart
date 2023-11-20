import 'utils_core.dart';
import 'world_core.dart';

/// The core component of the system.
class Core{

  /// Dispose of the body
  void dispose(){
    printError("Core", "Dispose error.");
  }

  /// wake the body
  void awake(){
    printError("Core", "Awake error.");
  }

  /// Run the sleep function
  void sleep(){
    printError("Core", "Sleep error.");
  }

  /// Remove the body
  void remove(){
    printError("Core", "Remove error.");
  }

  /// Set the parent of the body
  void setParent(World world){
    printError("Core", "Set Parent error.");
  }
}