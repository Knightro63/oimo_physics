import 'proxy_broad_phase.dart';
import 'broad_phase.dart';
import 'basic_proxy.dart';
import '../../shape/shape_main.dart';

/// A broad-phase algorithm with brute-force search.
/// This always checks for all possible pairs.
class BruteForceBroadPhase extends BroadPhase{
  BruteForceBroadPhase(){
    types = BroadPhaseType.force;
  }

  List<Proxy> proxies = [];

  @override
  Proxy createProxy(Shape shape ) {
    return BasicProxy( shape );
  }
  @override
  void addProxy(Proxy proxy ) {
    proxies.add(proxy);
  }
  @override
  void removeProxy( proxy ) {
    int n = proxies.indexOf( proxy );
    if ( n > -1 ){
      proxies.removeAt(n);
    }
  }
  @override
  void collectPairs() {
    int i = 0, j;
    Proxy p1, p2;
    List<Proxy> px = proxies;
    int l = px.length;//this.numProxies;

    numPairChecks = l*(l-1)>>1;
    //this.numPairChecks=this.numProxies*(this.numProxies-1)*0.5;

    while(i < l){
      p1 = px[i++];
      j = i + 1;
      while( j < l ){
        p2 = px[j++];
        if(p1.aabb.intersectTest( p2.aabb ) || !isAvailablePair(p1.shape, p2.shape)){ 
          continue;
        }
        addPair( p1.shape, p2.shape );
      }
    }
  }

}