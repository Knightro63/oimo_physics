import '../../core/utils_core.dart';
import '../../shape/shape_main.dart';
import '../../constraint/contact/contact_manifold.dart';

class CollisionDetector{
  bool flip = false;

  /// Detect collision of the shapes provided
  void detectCollision(Shape shape1,Shape shape2, ContactManifold manifold) {
    printError("CollisionDetector", "Inheritance error.");
  }
}