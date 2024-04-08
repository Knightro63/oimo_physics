import 'package:vector_math/vector_math.dart';

class ContactPointDataBuffer{
  Vector3 nor = Vector3.zero();
  Vector3 tan = Vector3.zero();
  Vector3 bin = Vector3.zero();

  Vector3 norU1 = Vector3.zero();
  Vector3 tanU1 = Vector3.zero();
  Vector3 binU1 = Vector3.zero();

  Vector3 norU2 = Vector3.zero();
  Vector3 tanU2 = Vector3.zero();
  Vector3 binU2 = Vector3.zero();

  Vector3 norT1 = Vector3.zero();
  Vector3 tanT1 = Vector3.zero();
  Vector3 binT1 = Vector3.zero();

  Vector3 norT2 = Vector3.zero();
  Vector3 tanT2 = Vector3.zero();
  Vector3 binT2 = Vector3.zero();

  Vector3 norTU1 = Vector3.zero();
  Vector3 tanTU1 = Vector3.zero();
  Vector3 binTU1 = Vector3.zero();

  Vector3 norTU2 = Vector3.zero();
  Vector3 tanTU2 = Vector3.zero();
  Vector3 binTU2 = Vector3.zero();

  double norImp = 0;
  double tanImp = 0;
  double binImp = 0;

  double norDen = 0;
  double tanDen = 0;
  double binDen = 0;

  double norTar = 0;

  ContactPointDataBuffer? next;
  bool last = false;
}