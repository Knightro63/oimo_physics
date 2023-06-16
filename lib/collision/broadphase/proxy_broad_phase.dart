import '../../core/utils_core.dart';
import '../../math/aabb.dart';
import '../../shape/shape_main.dart';

int count = 0;
int proxyIdCount() { return count++; }

//  * A proxy is used for broad-phase collecting pairs that can be colliding.
class Proxy{
  Proxy(this.shape){
    aabb = shape.aabb;
  }

	//The parent shape.
  Shape shape;

  //The axis-aligned bounding box.
  late AABB aabb;

	// Update the proxy. Must be inherited by a child.
  update(){
    printError("Proxy","Inheritance error.");
  }
}