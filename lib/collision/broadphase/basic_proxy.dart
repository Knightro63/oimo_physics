import 'proxy.dart';
import '../../shape/shape.dart';

// * A basic implementation of proxies.
class BasicProxy extends Proxy{
  BasicProxy(Shape shape):super(shape);

  int id = proxyIdCount();
  @override
  update() {

  }
}