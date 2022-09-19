import 'package:flutter/material.dart';
import 'package:oimo_physics_example/game.dart';
import 'package:oimo_physics_example/test_basic.dart';
import 'package:oimo_physics_example/test_collision.dart';
import 'package:oimo_physics_example/test_compound.dart';
import 'package:oimo_physics_example/test_compound2.dart';
import 'package:oimo_physics_example/test_moving.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TestMoving(),
    );
  }
}