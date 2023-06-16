import '../../core/utils.dart';
import '../../shape/shape.dart';
import '../../constraint/contact/contact_manifold.dart';

class CollisionDetector{
  bool flip = false;

  void detectCollision(Shape shape1,Shape shape2,ContactManifold manifold) {
    printError("CollisionDetector", "Inheritance error.");
  }
}