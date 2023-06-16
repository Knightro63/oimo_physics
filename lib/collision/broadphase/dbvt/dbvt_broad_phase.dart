import '../broad_phase.dart';
import 'dbvt_main.dart';
import 'dbvt_proxy.dart';
import 'dbvt_node.dart';
import '../proxy_broad_phase.dart';
import '../../../shape/shape_main.dart';

//  * A broad-phase algorithm using dynamic bounding volume tree.
class DBVTBroadPhase extends BroadPhase{
  DBVTBroadPhase(){
    types = BroadPhaseType.volume;
  }

  DBVT tree = DBVT();
  Map<int,DBVTNode> stack = {};
  List<DBVTNode> leaves = [];
  int numLeaves = 0;

  @override
  DBVTProxy createProxy(Shape shape ) {
    return DBVTProxy(shape);
  }
  @override
  void addProxy(Proxy proxy) {
    if(proxy is DBVTProxy){
      tree.insertLeaf(proxy.leaf );
      leaves.add( proxy.leaf );
      numLeaves++;
    }
  }
  @override
  void removeProxy(Proxy proxy) {
    if(proxy is DBVTProxy){
      tree.deleteLeaf(proxy.leaf);
      int n = leaves.indexOf(proxy.leaf);
      if ( n > -1 ) {
        leaves.removeAt(n);
        numLeaves--;
      }
    }
  }
  @override
  void collectPairs() {
    if(numLeaves < 2) return;
    DBVTNode leaf;
    double margin = 0.1;
    for(int i = 0; i < leaves.length; i++){
      leaf = leaves[i];
      if ( leaf.proxy!.aabb.intersectTestTwo(leaf.aabb)){
        leaf.aabb.copy(leaf.proxy!.aabb, margin);
        tree.deleteLeaf(leaf);
        tree.insertLeaf(leaf);
        collide(leaf, tree.root!);
      }
    }
  }

  void collide(DBVTNode node1, DBVTNode node2) {
    int stackCount = 2;
    Shape s1, s2;
    DBVTNode n1, n2;
    bool l1, l2;
    stack[0] = node1;
    stack[1] = node2;

    while( stackCount > 0 ){
      n1 = stack[--stackCount]!;
      n2 = stack[--stackCount]!;
      l1 = n1.proxy != null;
      l2 = n2.proxy != null;
      
      numPairChecks++;

      if( l1 && l2 ){
        s1 = n1.proxy!.shape;
        s2 = n2.proxy!.shape;
        if ( s1 == s2 || s1.aabb.intersectTest( s2.aabb ) || !isAvailablePair( s1, s2 ) ) continue;

        addPair(s1,s2);
      }
      else{
        if ( n1.aabb.intersectTest( n2.aabb ) ) continue;
        if( l2 || !l1 && (n1.aabb.surfaceArea() > n2.aabb.surfaceArea()) ){
          stack[stackCount++] = n1.child1!;
          stack[stackCount++] = n2;
          stack[stackCount++] = n1.child2!;
          stack[stackCount++] = n2;
        }
        else{
          stack[stackCount++] = n1;
          stack[stackCount++] = n2.child1!;
          stack[stackCount++] = n1;
          stack[stackCount++] = n2.child2!;
        }
      }
    }
  }

}