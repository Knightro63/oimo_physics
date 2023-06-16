import '../proxy_broad_phase.dart';
import 'dbvt_node.dart';
import '../../../shape/shape_main.dart';

// * A proxy for dynamic bounding volume tree broad-phase.
class DBVTProxy extends Proxy{
  DBVTProxy(Shape shape ):super(shape){
    leaf.proxy = this;
  }

  // The leaf of the proxy.
  DBVTNode leaf = DBVTNode();

  @override
  void update(){

  }
}