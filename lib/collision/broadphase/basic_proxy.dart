import 'proxy_broad_phase.dart';
import '../../shape/shape_main.dart';

// * A basic implementation of proxies.
class BasicProxy extends Proxy{
  BasicProxy(Shape shape):super(shape);

  int id = proxyIdCount();
  @override
  update() {

  }
}