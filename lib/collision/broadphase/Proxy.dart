import '../../core/Utils.dart';
import '../../math/AABB.dart';
import '../../shape/Shape.dart';

int count = 0;
int ProxyIdCount() { return count++; }

/**
 * A proxy is used for broad-phase collecting pairs that can be colliding.
 *
 * @author lo-th
 */

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