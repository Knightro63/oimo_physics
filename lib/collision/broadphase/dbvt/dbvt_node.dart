import '../../../math/aabb.dart';
import '../proxy_broad_phase.dart';

/// A node of the dynamic bounding volume tree.
class DBVTNode{
  /// The first child node of this node.
  DBVTNode? child1;
  /// The second child node of this node.
  DBVTNode? child2;
  ///  The parent node of this tree.
  DBVTNode? parent;
  /// The proxy of this node. This has no value if this node is not leaf.
  Proxy? proxy;
  /// The maximum distance from leaf nodes.
  double height = 0;
  /// The AABB of this node.
  AABB aabb = AABB();
}