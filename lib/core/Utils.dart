import '../collision/broadphase/BroadPhase.dart';

import '../math/Math.dart';
import '../constants.dart';
import '../core/World.dart';

void printError(String clazz,String msg ){
  print("[OIMO] $clazz: $msg");
}

// A performance evaluator
class InfoDisplay{
  InfoDisplay(world){
    parent = world;
    broadPhase = parent.broadPhase;
  }

  late World parent;

  List<double> infos = List.filled(13,0);
  List<int> f = [0,0,0];

  List<int> times = [0,0,0,0];

  late BroadPhase broadPhase;

  String version = REVISION;

  double fps = 0;
  int tt = 0;

  int broadPhaseTime = 0;
  int narrowPhaseTime = 0;
  int solvingTime = 0;
  int totalTime = 0;
  int updateTime = 0;

  int MaxBroadPhaseTime = 0;
  int MaxNarrowPhaseTime = 0;
  int MaxSolvingTime = 0;
  int MaxTotalTime = 0;
  int MaxUpdateTime = 0;

  void setTime([int? n]){
    times[ n ?? 0 ] = DateTime.now().millisecondsSinceEpoch;
  }

  void resetMax(){
    MaxBroadPhaseTime = 0;
    MaxNarrowPhaseTime = 0;
    MaxSolvingTime = 0;
    MaxTotalTime = 0;
    MaxUpdateTime = 0;
  }

  void calcBroadPhase () {
    setTime( 2 );
    broadPhaseTime = times[ 2 ] - times[ 1 ];
  }

  void calcNarrowPhase () {
    setTime( 3 );
    narrowPhaseTime = times[ 3 ] - times[ 2 ];
  }

  void calcEnd () {
    setTime( 2 );
    solvingTime = times[ 2 ] - times[ 1 ];
    totalTime = times[ 2 ] - times[ 0 ];
    updateTime = totalTime - (broadPhaseTime + narrowPhaseTime + solvingTime );

    if(tt == 100 )resetMax();

    if(tt > 100 ){
      if(broadPhaseTime > MaxBroadPhaseTime ) MaxBroadPhaseTime = broadPhaseTime;
      if(narrowPhaseTime > MaxNarrowPhaseTime ) MaxNarrowPhaseTime = narrowPhaseTime;
      if(solvingTime > MaxSolvingTime ) MaxSolvingTime = solvingTime;
      if(totalTime > MaxTotalTime ) MaxTotalTime = totalTime;
      if(updateTime > MaxUpdateTime ) MaxUpdateTime = updateTime;
    }

    upfps();

    tt ++;
    if(tt > 500)tt = 0;
  }


  void upfps (){
    f[1] = DateTime.now().millisecondsSinceEpoch;
    if (f[1]-1000>f[0]){ f[0] = f[1]; fps = f[2].toDouble(); f[2] = 0;} f[2]++;
  }

  String show(){
    String info =[
      "Oimo.js $version<br>",
      "$broadPhase<br><br>",
      "FPS: $fps fps<br><br>",
      "rigidbody ${parent.numRigidBodies}<br>",
      "contact &nbsp;&nbsp;${parent.numContacts}<br>",
      "ct-point &nbsp;${parent.numContactPoints}<br>",
      "paircheck ${parent.broadPhase.numPairChecks}<br>",
      "island &nbsp;&nbsp;&nbsp;${parent.numIslands}<br><br>",
      "Time in milliseconds<br><br>",
      "broadphase &nbsp;${Math.fix(broadPhaseTime.toDouble())} | ${Math.fix(MaxBroadPhaseTime.toDouble())}<br>",
      "narrowphase ${Math.fix(narrowPhaseTime.toDouble())} | ${Math.fix(MaxNarrowPhaseTime.toDouble())}<br>",
      "solving &nbsp;&nbsp;&nbsp;&nbsp;${Math.fix(solvingTime.toDouble())} |  ${Math.fix(MaxSolvingTime.toDouble())}<br>",
      "total &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${Math.fix(totalTime.toDouble())} | ${Math.fix(MaxTotalTime.toDouble())}<br>",
      "updating &nbsp;&nbsp;&nbsp;${Math.fix(updateTime.toDouble())} |  ${Math.fix(MaxUpdateTime.toDouble())}<br>"
    ].join("\n");
    return info;
  }

  List<double> toArray(){
    infos[0] = parent.broadPhase.types.index.toDouble();
    infos[1] = parent.numRigidBodies.toDouble();
    infos[2] = parent.numContacts.toDouble();
    infos[3] = parent.broadPhase.numPairChecks.toDouble();
    infos[4] = parent.numContactPoints.toDouble();
    infos[5] = parent.numIslands.toDouble();
    infos[6] = broadPhaseTime.toDouble();
    infos[7] = narrowPhaseTime.toDouble();
    infos[8] = solvingTime.toDouble();
    infos[9] = updateTime.toDouble();
    infos[10] = totalTime.toDouble();
    infos[11] = fps;
    return infos;
  }
}