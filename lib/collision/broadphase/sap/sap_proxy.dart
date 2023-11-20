import '../proxy_broad_phase.dart';
import 'sap_broad_phase.dart';
import '../../../core/rigid_body.dart';
import '../../../shape/shape_main.dart';
import 'sap_element.dart';

/// A proxy for sweep and prune broad-phase.
class SAPProxy extends Proxy{

  /// A proxy for sweep and prune broad-phase.
  /// 
  /// [sap] the broard phase used in the proxy
  /// [shape] The shape applied to the proxy
  SAPProxy(this.sap, Shape shape):super(shape){
    min = List.filled(3, SAPElement(this, false));
    max = List.filled(3, SAPElement(this, true));

    max[0].pair = min[0];
    max[1].pair = min[1];
    max[2].pair = min[2];
    min[0].min1 = min[1];
    min[0].max1 = max[1];
    min[0].min2 = min[2];
    min[0].max2 = max[2];
    min[1].min1 = min[0];
    min[1].max1 = max[0];
    min[1].min2 = min[2];
    min[1].max2 = max[2];
    min[2].min1 = min[0];
    min[2].max1 = max[0];
    min[2].min2 = min[1];
    min[2].max2 = max[1];
  }
  // Type of the axis to which the proxy belongs to. [0:none, 1:dynamic, 2:static]
  int belongsTo = 0;
  // The maximum elements on each axis.
  List<SAPElement> max = [];
  // The minimum elements on each axis.
  List<SAPElement> min = [];
  
  SAPBroadPhase sap;

  // Returns whether the proxy is dynamic or not.
  bool isDynamic() {
    RigidBody body = shape.parent!;
    return body.isDynamic && !body.sleeping;
  }

  @override
  void update(){
    List<double> te = aabb.elements;
    min[0].value = te[0];
    min[1].value = te[1];
    min[2].value = te[2];
    max[0].value = te[3];
    max[1].value = te[4];
    max[2].value = te[5];

    if(belongsTo == 1 && !isDynamic() || belongsTo == 2 && isDynamic() ){
      sap.removeProxy(this);
      sap.addProxy(this);
    }
  }
}