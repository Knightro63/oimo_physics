import '../../shape/Shape.dart';
import '../../core/RigidBody.dart';
import 'Contact.dart';

/**
* A link list of contacts.
* @author saharan
*/
class ContactLink{
  ContactLink (this.contact);
    
	// The previous contact link.
  ContactLink? prev;
  // The next contact link.
  ContactLink? next;
  // The shape of the contact.
  Shape? shape;
  // The other rigid body.
  RigidBody? body;
  // The contact of the link.
  late Contact contact;
}