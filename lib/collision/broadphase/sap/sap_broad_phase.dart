import '../broad_phase.dart';
import '../proxy_broad_phase.dart';
import 'sap_axis.dart';
import 'sap_element.dart';
import 'sap_proxy.dart';
import '../../../shape/shape_main.dart';

// A broad-phase collision detection algorithm using sweep and prune.
class SAPBroadPhase extends BroadPhase{
  SAPBroadPhase () {
    types = BroadPhaseType.sweep;
  }

  int numElementsD = 0;
  int numElementsS = 0;

  /// dynamic proxies in the swee and prune broadphase
  List<SAPAxis> axesD = [
    SAPAxis(),
    SAPAxis(),
    SAPAxis()
  ];
  /// static or sleeping proxies in the swee and prune broadphase
  List<SAPAxis> axesS = [
    SAPAxis(),
    SAPAxis(),
    SAPAxis()
  ];

  int index1 = 0;
  int index2 = 1;

  @override
  SAPProxy? createProxy(Shape shape ) {
    return SAPProxy(this, shape);
  }

  @override
  void addProxy(Proxy proxy) {
    SAPProxy p = proxy as SAPProxy;
    if(p.isDynamic()){
      axesD[0].addElements( p.min[0], p.max[0] );
      axesD[1].addElements( p.min[1], p.max[1] );
      axesD[2].addElements( p.min[2], p.max[2] );
      p.belongsTo = 1;
      numElementsD += 2;
    } 
    else {
      axesS[0].addElements( p.min[0], p.max[0] );
      axesS[1].addElements( p.min[1], p.max[1] );
      axesS[2].addElements( p.min[2], p.max[2] );
      p.belongsTo = 2;
      numElementsS += 2;
    }
  }

  @override
  void removeProxy(Proxy proxy) {
    SAPProxy p = proxy as SAPProxy;
    if (p.belongsTo == 0) return;

    /*else if ( p.belongsTo == 1 ) {
        this.axesD[0].removeElements( p.min[0], p.max[0] );
        this.axesD[1].removeElements( p.min[1], p.max[1] );
        this.axesD[2].removeElements( p.min[2], p.max[2] );
        this.numElementsD -= 2;
    } else if ( p.belongsTo == 2 ) {
        this.axesS[0].removeElements( p.min[0], p.max[0] );
        this.axesS[1].removeElements( p.min[1], p.max[1] );
        this.axesS[2].removeElements( p.min[2], p.max[2] );
        this.numElementsS -= 2;
    }*/

    switch( p.belongsTo ){
      case 1:
        axesD[0].removeElements( p.min[0], p.max[0] );
        axesD[1].removeElements( p.min[1], p.max[1] );
        axesD[2].removeElements( p.min[2], p.max[2] );
        numElementsD -= 2;
        break;
      case 2:
        axesS[0].removeElements( p.min[0], p.max[0] );
        axesS[1].removeElements( p.min[1], p.max[1] );
        axesS[2].removeElements( p.min[2], p.max[2] );
        numElementsS -= 2;
        break;
    }

    p.belongsTo = 0;
  }

  @override
  void collectPairs() {
    if(numElementsD == 0 ) return;

    SAPAxis axis1 = axesD[index1];
    SAPAxis axis2 = axesD[index2];

    axis1.sort();
    axis2.sort();

    int count1 = axis1.calculateTestCount();
    int count2 = axis2.calculateTestCount();
    Map<int,SAPElement?> elementsD;
    Map<int,SAPElement?> elementsS;

    if( count1 <= count2 ){// select the best axis
      axis2 = axesS[index1];
      axis2.sort();
      elementsD = axis1.elements;
      elementsS = axis2.elements;
    }
    else{
      axis1 = axesS[index2];
      axis1.sort();
      elementsD = axis2.elements;
      elementsS = axis1.elements;
      index1 ^= index2;
      index2 ^= index1;
      index1 ^= index2;
    }

    SAPElement? activeD;
    SAPElement? activeS;
    int p = 0;
    int q = 0;

    while( p < numElementsD ){
      SAPElement? e1;
      bool dyn;
      if (q == numElementsS){
        e1 = elementsD[p];
        dyn = true;
        p++;
      }
      else{
        SAPElement? d = elementsD[p];
        SAPElement? s = elementsS[q];
        if(d != null && s != null && d.value < s.value){
          e1 = d;
          dyn = true;
          p++;
        }
        else{
          e1 = s;
          dyn = false;
          q++;
        }
      }
      if(e1 != null && !e1.max){
        Shape s1 = e1.proxy.shape;
        double min1 = e1.min1?.value ?? 0;
        double max1 = e1.max1?.value ?? 0;
        double min2 = e1.min2?.value ?? 0;
        double max2 = e1.max2?.value ?? 0;
        
        for(SAPElement? e2 = activeD; e2 != null; e2 = e2.pair){// test for dynamic
          Shape s2 = e2.proxy.shape;

          numPairChecks++;
          if( min1 > e2.max1!.value || max1 < e2.min1!.value || min2 > e2.max2!.value || max2 < e2.min2!.value || !isAvailablePair( s1, s2 ) ) continue;
          addPair( s1, s2 );
        }
        if( dyn ){
          for(SAPElement? e2 = activeS; e2 != null; e2 = e2.pair) {// test for static
            Shape s2 = e2.proxy.shape;

            numPairChecks++;

            if( min1 > e2.max1!.value || max1 < e2.min1!.value|| min2 > e2.max2!.value || max2 < e2.min2!.value || !isAvailablePair(s1,s2) ) continue;
            addPair( s1, s2 );
          }
          e1.pair = activeD;
          activeD = e1;
        }
        else{
          e1.pair = activeS;
          activeS = e1;
        }
      }
      else{
        SAPElement? min = e1?.pair!;
        if( dyn ){
          if( min == activeD ){
            activeD = activeD?.pair;
            continue;
          }
          else{
            e1 = activeD;
          }
        }
        else{
          if( min == activeS ){
            activeS = activeS?.pair;
            continue;
          }
          else{
            e1 = activeS;
          }
        }
        while(e1 != null) {
          SAPElement? e2 = e1.pair;
          if(e2 == min ){
            e1.pair = e2!.pair;
            break;
          }
          e1 = e2;
        }
      }
    }
    index2 = (index1|index2)^3;
  }
}