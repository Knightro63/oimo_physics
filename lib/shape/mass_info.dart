import '../math/mat33.dart';

// * This class holds mass information of a shape.
class MassInfo{
  // Mass of the shape.
  double mass = 0;
  // The moment inertia of the shape.
   Mat33 inertia = Mat33();
}