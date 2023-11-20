import '../../shape/shape_main.dart';

/// A pair of shapes that may collide.
class Pair{
  /// A pair of shapes that may collide.
  Pair([this.shape1,this.shape2]);
  /// The first shape.
  Shape? shape1;
  /// The second shape.
  Shape? shape2;
}