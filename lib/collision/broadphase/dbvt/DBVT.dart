import '../../../math/AABB.dart';
import './DBVTNode.dart';

/**
 * A dynamic bounding volume tree for the broad-phase algorithm.
 *
 * @author saharan
 * @author lo-th
 */

class DBVT{
  DBVT();

  // The root of the tree.
  DBVTNode? root;
  List<DBVTNode> freeNodes = List.filled(16384, DBVTNode());
  int numFreeNodes = 0;
  AABB aabb = AABB();

  void moveLeaf( leaf ) {
    deleteLeaf( leaf );
    insertLeaf( leaf );
  }

  void insertLeaf(DBVTNode leaf){
    if(root == null){
      root = leaf;
      return;
    }
    AABB lb = leaf.aabb;
    DBVTNode? sibling = root;
    double oldArea;
    double newArea;
    while(sibling?.proxy == null){ // descend the node to search the best pair
      DBVTNode c1 = sibling!.child1!;
      DBVTNode c2 = sibling.child2!;
      AABB b = sibling.aabb;
      AABB c1b = c1.aabb;
      AABB c2b = c2.aabb;
      oldArea = b.surfaceArea();
      aabb.combine(lb,b);
      newArea = aabb.surfaceArea();
      double creatingCost = newArea*2;
      double incrementalCost = (newArea-oldArea)*2; // cost of creating a new pair with the node
      double discendingCost1 = incrementalCost;
      aabb.combine(lb,c1b);
      if(c1.proxy!=null){
        // leaf cost = area(combined aabb)
        discendingCost1+=aabb.surfaceArea();
      }
      else{
        // node cost = area(combined aabb) - area(old aabb)
        discendingCost1+=aabb.surfaceArea()-c1b.surfaceArea();
      }
      double discendingCost2=incrementalCost;
      aabb.combine(lb,c2b);
      if(c2.proxy!=null){
        // leaf cost = area(combined aabb)
        discendingCost2+=aabb.surfaceArea();
      }
      else{
        // node cost = area(combined aabb) - area(old aabb)
        discendingCost2+=aabb.surfaceArea()-c2b.surfaceArea();
      }
      if(discendingCost1<discendingCost2){
        if(creatingCost<discendingCost1){
          break;// stop descending
        }
        else{
          sibling = c1;// descend into first child
        }
      }
      else{
        if(creatingCost<discendingCost2){
          break;// stop descending
        }
        else{
          sibling = c2;// descend into second child
        }
      }
    }
    DBVTNode? oldParent = sibling?.parent;
    DBVTNode? newParent;
    if(numFreeNodes>0){
      newParent = freeNodes[--numFreeNodes];
    }
    else{
      newParent = DBVTNode();
    }

    newParent.parent = oldParent;
    newParent.child1 = leaf;
    newParent.child2 = sibling;
    newParent.aabb.combine(leaf.aabb,sibling!.aabb);
    newParent.height = sibling.height+1;
    sibling.parent = newParent;
    leaf.parent = newParent;
    if(sibling == root){
      // replace root
      root = newParent;
    }
    else{
      // replace child
      if(oldParent!.child1 == sibling){
        oldParent.child1 = newParent;
      }else{
        oldParent.child2 = newParent;
      }
    }
    // update whole tree
    do{
      newParent = balance(newParent!);
      fix(newParent);
      newParent = newParent.parent;
    }while(newParent != null);
  }

  double getBalance(DBVTNode node){
    if(node.proxy!=null)return 0;
    return node.child1!.height-node.child2!.height;
  }

  void deleteLeaf(DBVTNode leaf) {
    if(leaf == root){
      root = null;
      return;
    }
    DBVTNode parent = leaf.parent!;
    DBVTNode sibling;
    if(parent.child1==leaf){
      sibling=parent.child2!;
    }
    else{
      sibling=parent.child1!;
    }
    if(parent==root){
      root=sibling;
      sibling.parent=null;
      return;
    }
    DBVTNode? grandParent = parent.parent;
    sibling.parent = grandParent;
    if(grandParent!.child1 == parent ) {
      grandParent.child1 = sibling;
    }
    else{
      grandParent.child2 = sibling;
    }
    if(numFreeNodes<16384){
      freeNodes[numFreeNodes++] = parent;
    }
    do{
      grandParent = balance(grandParent!);
      fix(grandParent);
      grandParent = grandParent.parent;
    }while( grandParent != null);
  }

  DBVTNode balance(DBVTNode node) {
    double nh = node.height;
    if(nh<2){
      return node;
    }
    var p = node.parent;
    DBVTNode l = node.child1!;
    DBVTNode r = node.child2!;
    double lh = l.height;
    double rh = r.height;
    double balance = lh-rh;
    int t;// for bit operation

    //          [ N ]
    //         /     \
    //    [ L ]       [ R ]
    //     / \         / \
    // [L-L] [L-R] [R-L] [R-R]

    // Is the tree balanced?
    if(balance>1){
      DBVTNode ll = l.child1!;
      DBVTNode lr = l.child2!;
      double llh = ll.height;
      double lrh = lr.height;

      // Is L-L higher than L-R?
      if(llh>lrh){
        // set N to L-R
        l.child2 = node;
        node.parent = l;

        //          [ L ]
        //         /     \
        //    [L-L]       [ N ]
        //     / \         / \
        // [...] [...] [ L ] [ R ]
        
        // set L-R
        node.child1 = lr;
        lr.parent = node;

        //          [ L ]
        //         /     \
        //    [L-L]       [ N ]
        //     / \         / \
        // [...] [...] [L-R] [ R ]
        
        // fix bounds and heights
        node.aabb.combine( lr.aabb, r.aabb );
        t = (lrh-rh).toInt();
        node.height=lrh-(t&t>>31)+1;
        l.aabb.combine(ll.aabb,node.aabb);
        t=(llh-nh).toInt();
        l.height=llh-(t&t>>31)+1;
      }
      else{
        // set N to L-L
        l.child1=node;
        node.parent=l;

        //          [ L ]
        //         /     \
        //    [ N ]       [L-R]
        //     / \         / \
        // [ L ] [ R ] [...] [...]
        
        // set L-L
        node.child1 = ll;
        ll.parent = node;

        //          [ L ]
        //         /     \
        //    [ N ]       [L-R]
        //     / \         / \
        // [L-L] [ R ] [...] [...]
        
        // fix bounds and heights
        node.aabb.combine(ll.aabb,r.aabb);
        t = (llh - rh).toInt();
        node.height=llh-(t&t>>31)+1;

        l.aabb.combine(node.aabb,lr.aabb);
        t=(nh-lrh).toInt();
        l.height=nh-(t&t>>31)+1;
      }
      // set new parent of L
      if(p!=null){
        if(p.child1==node){
          p.child1=l;
        }
        else{
          p.child2=l;
        }
      }
      else{
        root=l;
      }
      l.parent=p;
      return l;
    }
    else if(balance<-1){
      DBVTNode rl = r.child1!;
      DBVTNode rr = r.child2!;
      double rlh = rl.height;
      double rrh = rr.height;

      // Is R-L higher than R-R?
      if( rlh > rrh ) {
        // set N to R-R
        r.child2 = node;
        node.parent = r;

        //          [ R ]
        //         /     \
        //    [R-L]       [ N ]
        //     / \         / \
        // [...] [...] [ L ] [ R ]
        
        // set R-R
        node.child2 = rr;
        rr.parent = node;

        //          [ R ]
        //         /     \
        //    [R-L]       [ N ]
        //     / \         / \
        // [...] [...] [ L ] [R-R]
        
        // fix bounds and heights
        node.aabb.combine(l.aabb,rr.aabb);
        t = (lh-rrh).toInt();
        node.height = lh-(t&t>>31)+1;
        r.aabb.combine(rl.aabb,node.aabb);
        t =( rlh-nh).toInt();
        r.height = rlh-(t&t>>31)+1;
      }
      else{
        // set N to R-L
        r.child1 = node;
        node.parent = r;
        //          [ R ]
        //         /     \
        //    [ N ]       [R-R]
        //     / \         / \
        // [ L ] [ R ] [...] [...]
        
        // set R-L
        node.child2 = rl;
        rl.parent = node;

        //          [ R ]
        //         /     \
        //    [ N ]       [R-R]
        //     / \         / \
        // [ L ] [R-L] [...] [...]
        
        // fix bounds and heights
        node.aabb.combine(l.aabb,rl.aabb);
        t=(lh-rlh).toInt();
        node.height=lh-(t&t>>31)+1;
        r.aabb.combine(node.aabb,rr.aabb);
        t=(nh-rrh).toInt();
        r.height=nh-(t&t>>31)+1;
      }
      // set new parent of R
      if(p!=null){
        if(p.child1==node){
          p.child1=r;
        }
        else{
          p.child2=r;
        }
      }
      else{
          root=r;
      }
      r.parent=p;
      return r;
    }
    return node;
  }

  void fix(DBVTNode node){
    DBVTNode c1 = node.child1!;
    DBVTNode c2 = node.child2!;
    node.aabb.combine( c1.aabb, c2.aabb );
    node.height = c1.height < c2.height ? c2.height+1 : c1.height+1; 
  }
}