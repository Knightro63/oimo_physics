# oimo\_physics

[![Pub Version](https://img.shields.io/pub/v/oimo_physics)](https://pub.dev/packages/oimo_physics)
[![analysis](https://github.com/Knightro63/oimo_physics/actions/workflows/flutter.yml/badge.svg)](https://github.com/Knightro63/oimo_physics/actions/)
[![License: BSD](https://img.shields.io/badge/license-BSD-purple.svg)](https://opensource.org/licenses/BSD)

A 3D physics engine for dart (based on oimo.js) that allows users to add physics support to their 3d projects.

<picture>
  <img alt="Image of blocks falling onto a surface." src="https://github.com/Knightro63/oimo_physics/blob/9a12df44235fb95c89dc915b7224c25654b584d0/examples/assets/images/basic_physics.png">
</picture>

This is a dart conversion of oimo.js, originally created by Saharan [@saharan](https://github.com/saharan).

## Usage

This project is a basic physics engine for three_dart. This package includes RigidBodies, and Joints.

### Getting started

To get started add oimo_physics, three_dart, and three_dart_jsm to your pubspec.yaml file.

The Oimo World is the main scene that has all of the objects that will be manipulated to the scene. To get started add the oimo world then all of the objects in it.

If there is no shapes or type in the ObjectConfigure class it will not work. If you need a RigidBody use shapes. If you need a Joint use type.

```dart
  world = OIMO.World(OIMO.WorldConfigure(isStat:true, scale:100.0));

  OIMO.ShapeConfig config = OIMO.ShapeConfig(
    friction: 0.4,
    belongsTo: 1,
  );

  world!.add(OIMO.ObjectConfigure(
    shapes: [OIMO.Shapes.box],
    size:[400, 40, 400], 
    position:[0,-20,0], 
    shapeConfig:config
  ));
  
  bodys.add(world!.add(OIMO.ObjectConfigure(
    shapes:[OIMO.Shapes.sphere], 
    size:[w*0.5,w*0.5,w*0.5], 
    position:[x,y,z], 
    move:true, 
    shapeConfig:config,
    name: 'sphere'
  )) as OIMO.RigidBody);
```

## Example

Find the example app [here](https://github.com/Knightro63/oimo_physics/tree/main/example) and the current web version of the code [here](https://knightro63.github.io/oimo_physics/).

## Contributing

Contributions are welcome.
In case of any problems look at [existing issues](https://github.com/Knightro63/oimo_physics/issues), if you cannot find anything related to your problem then open an issue.
Create an issue before opening a [pull request](https://github.com/Knightro63/oimo_physics/pulls) for non trivial fixes.
In case of trivial fixes open a [pull request](https://github.com/Knightro63/oimo_physics/pulls) directly.

## Additional Information

This plugin is only for performing basic physics. While this can be used as a standalone project it does not render scenes.
