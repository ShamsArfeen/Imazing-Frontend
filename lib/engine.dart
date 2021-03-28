import 'dart:math';

class Point {
  double X, Y, Z;
}
class Triangle {
  int P1, P2, P3;
}
class Engine {
  int PointNum = 0, TriangleNum = 0;
  List<Point> PointArr, PointTransform;
  List<Triangle> TriangleArr;

  void RotateMatrix( double Raw, double Pitch) {
    double sinRAW = sin(Raw), cosRAW = cos(Raw), sinPCH = sin(Pitch), cosPCH = cos(Pitch);
    for (int i = 0; i < PointNum; i++) {
      double Z = PointArr[i].Z * cosRAW - PointArr[i].X * sinRAW;
      PointTransform[i].Z = Z * cosPCH + PointArr[i].Y * sinPCH;
      PointTransform[i].Y = PointArr[i].Y * cosPCH - Z * sinPCH;
      PointTransform[i].X = PointArr[i].X * cosRAW + PointArr[i].Z * sinRAW;
    }
  }
}