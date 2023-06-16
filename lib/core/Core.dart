import 'utils.dart';
import 'world.dart';

class Core{
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
}