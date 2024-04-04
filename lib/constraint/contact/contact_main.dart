import 'dart:math';
import 'contact_link.dart';
import '../../shape/shape_main.dart';
import '../../core/rigid_body.dart';
import 'impulse_buffer.dart';
import 'contact_manifold.dart';
import 'manifold_point.dart';
import 'contact_constraint.dart';
import '../../collision/narrowphase/collision_detector.dart';

/// A contact is a pair of shapes whose axis-aligned bounding boxes are overlapping.
class Contact{
  Contact(){  
    points = manifold.points;
    constraint = ContactConstraint(manifold);

    b1Link = ContactLink(this);
    b2Link = ContactLink(this);
    s1Link = ContactLink(this);
    s2Link = ContactLink(this);
  }

  /// The first shape.
  Shape? shape1;
  /// The second shape.
  Shape? shape2;
  /// The first rigid body.
  RigidBody? body1;
  /// The second rigid body.
  RigidBody? body2;
  /// The previous contact in the world.
  Contact? prev;
  /// The next contact in the world.
  Contact? next;
  /// Internal
  bool persisting = false;
  /// Whether both the rigid bodies are sleeping or not.
  bool sleeping = false;
  /// The collision detector between two shapes.
  CollisionDetector? detector;
  /// Whether the shapes are touching or not.
  bool touching = false;
  /// shapes is very close and touching 
  bool close = false;

  double dist = double.maxFinite;

  late ContactLink b1Link;
  late ContactLink b2Link;
  late ContactLink s1Link;
  late ContactLink s2Link;

  // The contact manifold of the contact.
  ContactManifold manifold = ContactManifold();

  List<ImpulseDataBuffer> buffer = [
    ImpulseDataBuffer(),
    ImpulseDataBuffer(),
    ImpulseDataBuffer(),
    ImpulseDataBuffer()
  ];

  late List<ManifoldPoint> points;
  late ContactConstraint constraint;

  double mixRestitution( restitution1, restitution2 ) {
    return sqrt(restitution1*restitution2);
  }
  double mixFriction( friction1, friction2 ) {
    return sqrt(friction1*friction2);
  }

  /// Update the contact manifold.
  void updateManifold() {
    constraint.restitution = mixRestitution(shape1!.restitution, shape2!.restitution);
    constraint.friction = mixFriction(shape1!.friction,shape2!.friction);
    int numBuffers = manifold.numPoints;
    for(int i=numBuffers-1;i>=0;i--){
      ImpulseDataBuffer b = buffer[i];
      ManifoldPoint p = points[i];
      b.lp1X=p.localPoint1.x;
      b.lp1Y=p.localPoint1.y;
      b.lp1Z=p.localPoint1.z;
      b.lp2X=p.localPoint2.x;
      b.lp2Y=p.localPoint2.y;
      b.lp2Z=p.localPoint2.z;
      b.impulse=p.normalImpulse;
    }

    manifold.numPoints=0;
    detector?.detectCollision( //TODO
      shape1!,
      shape2!,
      manifold
    );
    int num = manifold.numPoints;
    if(num==0){
      touching = false;
      close = false;
      dist = double.maxFinite;
      return;
    }

    if(touching || dist < 0.001 ){ 
      close = true;
    }
    touching=true;

    for(int i=num-1; i>=0; i--){
      ManifoldPoint p= points[i];
      double lp1x=p.localPoint1.x;
      double lp1y=p.localPoint1.y;
      double lp1z=p.localPoint1.z;
      double lp2x=p.localPoint2.x;
      double lp2y=p.localPoint2.y;
      double lp2z=p.localPoint2.z;
      int index = -1;
      double minDistance=0.0004;

      for(int j=numBuffers-1;j>=0;j--){
        ImpulseDataBuffer b = buffer[j];
        double dx = b.lp1X!-lp1x;
        double dy = b.lp1Y!-lp1y;
        double dz = b.lp1Z!-lp1z;
        double distance1=dx*dx+dy*dy+dz*dz;

        dx=b.lp2X!-lp2x;
        dy=b.lp2Y!-lp2y;
        dz=b.lp2Z!-lp2z;

        double distance2 = dx*dx+dy*dy+dz*dz;
        if(distance1<distance2){
          if(distance1<minDistance){
            minDistance=distance1;
            index = j;
          }
        }
        else{
          if(distance2<minDistance){
            minDistance=distance2;
            index=j;
          }
        }

        if( minDistance < dist ){dist = minDistance;}
      }
      if(index!=-1){
        ImpulseDataBuffer tmp = buffer[index];
        buffer[index] = buffer[--numBuffers];
        buffer[numBuffers] = tmp;
        p.normalImpulse = tmp.impulse!;
        p.warmStarted=true;
      }
      else{
        p.normalImpulse=0;
        p.warmStarted=false;
      }
    }
  }

  /// Attach the contact to the shapes.
  /// 
  /// [shape1] First shape of the attached contact
  /// [shape2] Second shape of the attached contact
  void attach(Shape shape1,Shape shape2){
    this.shape1 = shape1;
    this.shape2 = shape2;
    body1 = shape1.parent;
    body2 = shape2.parent;

    manifold.body1 = body1;
    manifold.body2 = body2;
    constraint.body1 = body1;
    constraint.body2 = body2;
    constraint.attach();

    s1Link.shape = shape2;
    s1Link.body = body2;
    s2Link.shape = shape1;
    s2Link.body = body1;

    if(shape1.contactLink != null){
      (s1Link.next = shape1.contactLink)!.prev = s1Link;
    }
    else{ 
      s1Link.next=null;
    }
    shape1.contactLink = s1Link;
    shape1.numContacts++;

    if(shape2.contactLink !=null ){
      (s2Link.next=shape2.contactLink)!.prev = s2Link;
    }
    else{
      s2Link.next = null;
    }
    shape2.contactLink = s2Link;
    shape2.numContacts++;

    b1Link.shape = shape2;
    b1Link.body = body2;
    b2Link.shape = shape1;
    b2Link.body = body1;

    if(body1!.contactLink!=null){
      (b1Link.next = body1!.contactLink)!.prev = b1Link;
    }
    else{
      b1Link.next=null;
    }
    body1!.contactLink = b1Link;
    body1!.numContacts++;

    if(body2!.contactLink!=null){
      (b2Link.next=body2!.contactLink)!.prev = b2Link;
    }
    else{
      b2Link.next=null;
    }
    body2!.contactLink = b2Link;
    body2!.numContacts++;

    prev = null;
    next = null;

    persisting = true;
    sleeping = body1!.sleeping&&body2!.sleeping;
    manifold.numPoints=0;
  }

  //* Detach the contact from the shapes.
  void detach(){
    ContactLink? prev = s1Link.prev;
    ContactLink? next = s1Link.next;
    if(prev!=null)prev.next=next;
    if(next!=null)next.prev=prev;
    if(shape1!.contactLink==s1Link)shape1!.contactLink=next;
    s1Link.prev=null;
    s1Link.next=null;
    s1Link.shape=null;
    s1Link.body=null;
    shape1!.numContacts--;

    prev=s2Link.prev;
    next=s2Link.next;
    if(prev!=null)prev.next=next;
    if(next!=null)next.prev=prev;
    if(shape2!.contactLink==s2Link)shape2!.contactLink=next;
    s2Link.prev=null;
    s2Link.next=null;
    s2Link.shape=null;
    s2Link.body=null;
    shape2!.numContacts--;

    prev=b1Link.prev;
    next=b1Link.next;
    if(prev!=null)prev.next=next;
    if(next!=null)next.prev=prev;
    if(body1!.contactLink==b1Link)body1!.contactLink=next;
    b1Link.prev=null;
    b1Link.next=null;
    b1Link.shape=null;
    b1Link.body=null;
    body1!.numContacts--;

    prev=b2Link.prev;
    next=b2Link.next;
    if(prev!=null)prev.next=next;
    if(next!=null)next.prev=prev;
    if(body2!.contactLink==b2Link)body2!.contactLink=next;
    b2Link.prev=null;
    b2Link.next=null;
    b2Link.shape=null;
    b2Link.body=null;
    body2!.numContacts--;

    manifold.body1=null;
    manifold.body2=null;
    constraint.body1=null;
    constraint.body2=null;
    constraint.detach();

    shape1=null;
    shape2=null;
    body1=null;
    body2=null;
  }
}