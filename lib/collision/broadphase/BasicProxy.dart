import 'Proxy.dart';
import '../../shape/Shape.dart';

/**
* A basic implementation of proxies.
*
* @author saharan
*/
class BasicProxy extends Proxy{
  BasicProxy(Shape shape):super(shape);

  int id = ProxyIdCount();
  @override
  update() {

  }
}