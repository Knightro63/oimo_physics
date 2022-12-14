# oimo_physics

A Flutter plugin designed for three_dart and three_dart_jsm to allow users to add a simple physics engine to their 3D  project.

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
## Contributing

Feel free to propose changes by creating a pull request.

## Additional Information

This plugin is only for performing basic physics. While this can be used as a standalone project it does not render scenes.
