import '../Proxy.dart';
import 'DBVTNode.dart';
import '../../../shape/Shape.dart';

/**
* A proxy for dynamic bounding volume tree broad-phase.
* @author saharan
*/
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