import '../../shape/shape_main.dart';
import '../../core/rigid_body.dart';
import 'contact_main.dart';

/// A link list of contacts.
class ContactLink{
  /// A link list of contacts.
  /// 
  /// [contact] The contact of the link.
  ContactLink(this.contact);
    
	/// The previous contact link.
  ContactLink? prev;
  /// The next contact link.
  ContactLink? next;
  /// The shape of the contact.
  Shape? shape;
  /// The other rigid body.
  RigidBody? body;
  /// The contact of the link.
  late Contact contact;
}