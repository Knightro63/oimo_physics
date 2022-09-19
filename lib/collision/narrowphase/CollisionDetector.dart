import '../../core/Utils.dart';
import '../../shape/Shape.dart';
import '../../constraint/contact/ContactManifold.dart';

class CollisionDetector{
  bool flip = false;

  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold) {
    printError("CollisionDetector", "Inheritance error.");
  }
}