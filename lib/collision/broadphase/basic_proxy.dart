import 'proxy_broad_phase.dart';
import '../../shape/shape_main.dart';

/// A basic implementation of proxies.
class BasicProxy extends Proxy{
  /// A basic implementation of proxies.
  /// 
  /// [shape] the shape of the proxy
  BasicProxy(Shape shape):super(shape);

  /// id of the proxy
  int id = proxyIdCount();

  @override
  void update() {}
}