import 'mass_info.dart';
import 'shape_config.dart';
import '../math/aabb.dart';
import 'shape_main.dart';

//  * Box shape.
class Box extends Shape{
  Box(ShapeConfig config, this.width,this.height,this.depth):super(config){
    halfWidth = width * 0.5;
    halfHeight = height * 0.5;
    halfDepth = depth * 0.5;
    type = Shapes.box;
  } 

  late double width;
  late double height;
  late double depth;

  late double halfWidth;
  late double halfHeight;
  late double halfDepth;

  List<double> dimentions = List.filled( 18,0 );
  List<double> elements = List.filled( 24,0 );

  @override
	void calculateMassInfo(MassInfo out ) {
		var mass = width * height * depth * density;
		var divid = 1/12;
		out.mass = mass;
		out.inertia.set(
			mass * ( height * height + depth * depth ) * divid, 0, 0,
			0, mass * ( width * width + depth * depth ) * divid, 0,
			0, 0, mass * ( width * width + height * height ) * divid
		);
	}
  @override
	void updateProxy() {
		List<double> te = rotation.elements;
		List<double> di = dimentions;
		// Width
		di[0] = te[0];
		di[1] = te[3];
		di[2] = te[6];
		// Height
		di[3] = te[1];
		di[4] = te[4];
		di[5] = te[7];
		// Depth
		di[6] = te[2];
		di[7] = te[5];
		di[8] = te[8];
		// half Width
		di[9] = te[0] * halfWidth;
		di[10] = te[3] * halfWidth;
		di[11] = te[6] * halfWidth;
		// half Height
		di[12] = te[1] * halfHeight;
		di[13] = te[4] * halfHeight;
		di[14] = te[7] * halfHeight;
		// half Depth
		di[15] = te[2] * halfDepth;
		di[16] = te[5] * halfDepth;
		di[17] = te[8] * halfDepth;

		double wx = di[9];
		double wy = di[10];
		double wz = di[11];
		double hx = di[12];
		double hy = di[13];
		double hz = di[14];
		double dx = di[15];
		double dy = di[16];
		double dz = di[17];

		double x = position.x;
		double y = position.y;
		double z = position.z;

		List<double> v = elements;
		//v1
		v[0] = x + wx + hx + dx;
		v[1] = y + wy + hy + dy;
		v[2] = z + wz + hz + dz;
		//v2
		v[3] = x + wx + hx - dx;
		v[4] = y + wy + hy - dy;
		v[5] = z + wz + hz - dz;
		//v3
		v[6] = x + wx - hx + dx;
		v[7] = y + wy - hy + dy;
		v[8] = z + wz - hz + dz;
		//v4
		v[9] = x + wx - hx - dx;
		v[10] = y + wy - hy - dy;
		v[11] = z + wz - hz - dz;
		//v5
		v[12] = x - wx + hx + dx;
		v[13] = y - wy + hy + dy;
		v[14] = z - wz + hz + dz;
		//v6
		v[15] = x - wx + hx - dx;
		v[16] = y - wy + hy - dy;
		v[17] = z - wz + hz - dz;
		//v7
		v[18] = x - wx - hx + dx;
		v[19] = y - wy - hy + dy;
		v[20] = z - wz - hz + dz;
		//v8
		v[21] = x - wx - hx - dx;
		v[22] = y - wy - hy - dy;
		v[23] = z - wz - hz - dz;

		double w = di[9] < 0 ? -di[9] : di[9];
		double h = di[10] < 0 ? -di[10] : di[10];
		double d = di[11] < 0 ? -di[11] : di[11];

		w = di[12] < 0 ? w - di[12] : w + di[12];
		h = di[13] < 0 ? h - di[13] : h + di[13];
		d = di[14] < 0 ? d - di[14] : d + di[14];

		w = di[15] < 0 ? w - di[15] : w + di[15];
		h = di[16] < 0 ? h - di[16] : h + di[16];
		d = di[17] < 0 ? d - di[17] : d + di[17];

		double p = aabbProx;

		aabb.set(
			position.x - w - p, position.x + w + p,
			position.y - h - p, position.y + h + p,
			position.z - d - p, position.z + d + p
		);

		if ( this.proxy != null ) this.proxy!.update();
	}
}