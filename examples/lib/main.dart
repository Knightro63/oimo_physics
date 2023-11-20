import 'dart:io';

import 'package:oimo_physics_example/pages/basic_physics.dart';
import 'package:oimo_physics_example/pages/body_types.dart';
import 'package:oimo_physics_example/pages/bounce.dart';
import 'package:oimo_physics_example/pages/callback.dart';
import 'package:oimo_physics_example/pages/collision_filter.dart';
import 'package:oimo_physics_example/pages/collisions.dart';
import 'package:oimo_physics_example/pages/compound.dart';
import 'package:oimo_physics_example/pages/constraints.dart';
import 'package:oimo_physics_example/pages/container.dart';
import 'package:oimo_physics_example/pages/events.dart';
import 'package:oimo_physics_example/pages/fixed_rotation.dart';
import 'package:oimo_physics_example/pages/friction.dart';
import 'package:oimo_physics_example/pages/friction_gravity.dart';
// import 'package:oimo_physics_example/pages/games_fps.dart';
import 'package:oimo_physics_example/pages/hinge.dart';
import 'package:oimo_physics_example/pages/impulses.dart';
import 'package:oimo_physics_example/pages/jenga.dart';
import 'package:oimo_physics_example/pages/performance.dart';
import 'package:oimo_physics_example/pages/pile.dart';
import 'package:oimo_physics_example/pages/simple_friction.dart';
import 'package:oimo_physics_example/pages/trigger.dart';
import 'package:oimo_physics_example/pages/ragdoll.dart';
import 'package:oimo_physics_example/pages/shapes.dart';
import 'package:oimo_physics_example/pages/single_body_on_plane.dart';
import 'package:oimo_physics_example/pages/spring.dart';
import 'package:oimo_physics_example/pages/tear.dart';
import 'package:oimo_physics_example/pages/worker.dart';
import 'package:oimo_physics_example/pages/cloth.dart';
import 'package:oimo_physics_example/pages/tween.dart';

import 'package:css/css.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Tween;
import 'src/plugins/plugin.dart';
void main() {
  setPathUrlStrategy();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget{
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
  String onPage = '';
  double pageLocation = 0;

  void callback(String page, [double? location]){
    onPage = page;
    if(location != null){
      pageLocation = location;
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      _navKey.currentState!.popAndPushNamed('/$page');
      setState(() {});
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    widthInifity = MediaQuery.of(context).size.width;
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cannon Physics',
        theme: CSS.darkTheme,
        home: Scaffold(
          appBar: (kIsWeb||!Platform.isAndroid) && onPage != ''? PreferredSize(
            preferredSize: Size(widthInifity,65),
            child:AppBar(callback: callback,page: onPage,)
          ):null,
          body: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Cannon Physics',
            theme: CSS.darkTheme,
            navigatorKey: _navKey,
            routes: {
              '/':(BuildContext context) {
                return Examples(callback: callback,prevLocation: pageLocation,);
              },
              '/cloth':(BuildContext context) {
                return const Cloth();
              },
              '/basic_physics':(BuildContext context) {
                return const BasicPhysics();
              },
              '/body_types':(BuildContext context) {
                return const BodyTypes();
              },
              '/bounce':(BuildContext context) {
                return const Bounce();
              },
              '/callbacks':(BuildContext context) {
                return const Callback();
              },
              '/collision_filter':(BuildContext context) {
                return const CollisionFilter();
              },
              '/collisions':(BuildContext context) {
                return const Collisions();
              },
              '/compound':(BuildContext context) {
                return const Compound();
              },
              '/constraints':(BuildContext context) {
                return const Constraints();
              },
              '/container':(BuildContext context) {
                return const ContainerCP();
              },
              '/events':(BuildContext context) {
                return const Events();
              },
              '/fixed_rotation':(BuildContext context) {
                return const FixedRotation();
              },
              '/friction_gravity':(BuildContext context) {
                return const FrictionGravity();
              },
              '/friction':(BuildContext context) {
                return const Friction();
              },
              // '/games_fps':(BuildContext context) {
              //   return const TestGame();
              // },
              '/hinge':(BuildContext context) {
                return const Hinge();
              },
              '/impulses':(BuildContext context) {
                return const Impulses();
              },
              '/jenga':(BuildContext context) {
                return const Jenga();
              },
              '/performance':(BuildContext context) {
                return const Performance();
              },
              '/pile':(BuildContext context) {
                return const Pile();
              },
              '/ragdoll':(BuildContext context) {
                return const RagDoll();
              },
              // '/rigid_vehicle':(BuildContext context) {
              //   return const RigidVehicle();
              // },
              '/shapes':(BuildContext context) {
                return const Shapes();
              },
              '/single_body_on_plane':(BuildContext context) {
                return const SBOP();
              },
              '/spring':(BuildContext context) {
                return const Spring();
              },
              '/simple_friction':(BuildContext context) {
                return const SimpleFriction();
              },
              '/tear':(BuildContext context) {
                return const Tear();
              },
              '/trigger':(BuildContext context) {
                return const Trigger();
              },
              '/tween':(BuildContext context) {
                return const Tween();
              },
              '/worker':(BuildContext context) {
                return const Worker();
              },
            }
          ),
        )
      )
    );
  }
}

class AppBar extends StatelessWidget{
  const AppBar({
    Key? key,
    required this.page,
    required this.callback
  }):super(key: key);
  final String page;
  final void Function(String page,[double? loc]) callback;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: const EdgeInsets.only(left: 10),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          InkWell(
            onTap: (){
              callback('');
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded
            ),
          ),
          const SizedBox(width: 20,),
          Text(
            (page[0].toUpperCase()+page.substring(1)).replaceAll('_', ' '),
            style: Theme.of(context).primaryTextTheme.bodyLarge,
          )
        ],
      ),
    );
  }
}

class Examples extends StatefulWidget{
  const Examples({
    Key? key,
    required this.callback,
    required this.prevLocation
  }) : super(key: key);

  final void Function(String page,[double? location]) callback;
  final double prevLocation;

  @override
  ExamplesPageState createState() => ExamplesPageState();
}

class ExamplesPageState extends State<Examples> {
  List<String> ex = [
    'cloth',
    'basic_physics',
    'body_types',
    'bounce',
    'callbacks',
    'collision_filter',
    'collisions',
    'compound',
    'constraints',
    'container',
    'events',
    'fixed_rotation',
    'friction_gravity',
    'friction',
    //'games_fps',
    'hinge',
    'impulses',
    'jenga',
    'performance',
    'pile',
    'ragdoll',
    'shapes',
    'simple_friction',
    'single_body_on_plane',
    'spring',
    'tear',
    'trigger',
    'tween',
    'worker',
  ];
  double deviceHeight = double.infinity;
  double deviceWidth = double.infinity;

  ScrollController controller = ScrollController();

  List<Widget> displayExamples(){
    List<Widget> widgets = [];

    double response = CSS.responsive(width: 480);

    for(int i = 0;i < ex.length;i++){
      widgets.add(
        InkWell(
          onTap: (){
            widget.callback(ex[i],controller.offset);
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            width: response-65,
            height: response,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ]
            ),
            child: Column(
              children:[
                Container(
                  width: response,
                  height: response-65,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage('assets/images/${ex[i]}.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.only(topRight:Radius.circular(10),topLeft:Radius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  ex[i].replaceAll('_',' ').toUpperCase(),
                  style: Theme.of(context).primaryTextTheme.bodyLarge,
                )
              ]
            )
          )
        )
      );
    }

    return widgets;
  }
  
  @override
  void initState(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      controller.jumpTo(widget.prevLocation);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    
    return SingleChildScrollView(
      controller: controller,
      child: Wrap(
        runAlignment: WrapAlignment.spaceBetween,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: displayExamples(),
      )
    );
  }
}