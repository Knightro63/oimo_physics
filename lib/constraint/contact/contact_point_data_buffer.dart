import '../../math/vec3.dart';

class ContactPointDataBuffer{
  Vec3 nor = Vec3();
  Vec3 tan = Vec3();
  Vec3 bin = Vec3();

  Vec3 norU1 = Vec3();
  Vec3 tanU1 = Vec3();
  Vec3 binU1 = Vec3();

  Vec3 norU2 = Vec3();
  Vec3 tanU2 = Vec3();
  Vec3 binU2 = Vec3();

  Vec3 norT1 = Vec3();
  Vec3 tanT1 = Vec3();
  Vec3 binT1 = Vec3();

  Vec3 norT2 = Vec3();
  Vec3 tanT2 = Vec3();
  Vec3 binT2 = Vec3();

  Vec3 norTU1 = Vec3();
  Vec3 tanTU1 = Vec3();
  Vec3 binTU1 = Vec3();

  Vec3 norTU2 = Vec3();
  Vec3 tanTU2 = Vec3();
  Vec3 binTU2 = Vec3();

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