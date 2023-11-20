import 'sap_element.dart';

/// A projection axis for sweep and prune broad-phase.
class SAPAxis{
  SAPAxis (){
    //elements = List.filled(bufferSize, null,growable: true);
  }

  int numElements = 0;
  int bufferSize = 256;
  Map<int,SAPElement?> elements = {};
  List<double> stack = List.filled(64, 0);//Float32Array( 64 );

  /// add new min and max elements to the sweep and prune axis
  void addElements(SAPElement min,SAPElement max ) {
    if(numElements+2>=bufferSize){
      //this.bufferSize<<=1;
      bufferSize*=2;
      List<SAPElement?> newElements = [];
      for(int i = 0; i < numElements; i++){ 
        newElements.add(elements[i]);
      }
    }
    elements[numElements++] = min;
    elements[numElements++] = max;
  }

  /// remove min and max elements to the sweep and prune axis
  void removeElements(SAPElement min,SAPElement max ) {
    int minIndex=-1;
    int maxIndex=-1;

    for(int i=0; i<numElements; i++){
      SAPElement? e = elements[i];
      if(e==min||e==max){
        if(minIndex==-1){
          minIndex=i;
        }
        else{
          maxIndex=i;
          break;
        }
      }
    }
    for(int i = minIndex+1, l = maxIndex; i < l; i++){
      elements[i-1] = elements[i];
    }
    for(int i = maxIndex+1, l = numElements; i < l; i++){
      elements[i-2] = elements[i];
    }
    elements[--numElements] = null;
    elements[--numElements] = null;
  }

  /// Sort the elements in the sweep and prune
  void sort() {
    int count = 0;
    int threshold = 1;
    while((numElements >> threshold) != 0 ){ 
      threshold++;
    }
    threshold = threshold * numElements >> 2;
    count = 0;

    bool giveup = false;
    Map<int,SAPElement?> elements = this.elements;
    for(int i = 1; i < numElements; i++){ // try insertion sort
      SAPElement? tmp=elements[i];
      double pivot=tmp?.value ?? 0;
      SAPElement? tmp2=elements[i-1];
      double pivot2=tmp2?.value ?? 0;

      if(pivot2 > pivot){
        int j=i;
        do{
          elements[j]=tmp2;
          if(--j==0)break;
          tmp2=elements[j-1];
          pivot2=tmp2?.value ?? 0;
        }while(pivot2 > pivot);

        elements[j]=tmp;
        count+=i-j;
        if(count>threshold){
          giveup=true; // stop and use quick sort
          break;
        }
      }
    }
    if(!giveup)return;
    count=2;
    List<double> stack = this.stack;
    stack[0]=0;
    stack[1]=numElements-1;
    while(count>0){
      int right=stack[--count].toInt();
      int left=stack[--count].toInt();
      int diff=right-left;

      if(diff>16){  // quick sort
        //var mid=left+(diff>>1);
        int mid = left + ((diff*0.5).floor());
        SAPElement? tmp = elements[mid];
        elements[mid] = elements[right];
        elements[right] = tmp;
        double pivot = tmp?.value ?? 0;
        int i = left-1;
        int j = right;

        while( true ){
          SAPElement? ei;
          SAPElement? ej;
          do{ ei = elements[++i]; } while(ei != null && ei.value < pivot);
          do{ ej = elements[--j]; } while(ej != null && pivot < ej.value && j != left );
          if(i >= j) break;
          elements[i] = ej;
          elements[j] = ei;
        }

        elements[right] = elements[i];
        elements[i] = tmp;
        if( i - left > right - i ) {
          stack[count++] = left.toDouble();
          stack[count++] = i - 1;
          stack[count++] = i + 1;
          stack[count++] = right.toDouble();
        }
        else{
          stack[count++] = i + 1;
          stack[count++] = right.toDouble();
          stack[count++] = left.toDouble();
          stack[count++] = i - 1;
        }
      }
      else{
        for(int i = left + 1; i <= right; i++ ) {
          SAPElement? tmp = elements[i];
          double pivot = tmp?.value ?? 0;
          SAPElement? tmp2 = elements[i-1];
          double pivot2 = tmp2?.value ?? 0;
          if( pivot2> pivot) {
            int j = i;
            do{
              elements[j] = tmp2;
              if( --j == 0 ) break;
              tmp2 = elements[j-1];
              pivot2=tmp2?.value ?? 0;
            }while( pivot2> pivot );
            elements[j] = tmp;
          }
        }
      }
    }
  }

  /// Gat test count of all the elements
  int calculateTestCount() {
    int num = 1;
    int sum = 0;
    for(int i = 1; i<numElements; i++){
      if(elements[i]!.max){
        num--;
      }
      else{
        sum += num;
        num++;
      }
    }
    return sum;
  }
}