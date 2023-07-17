import 'package:oimo_physics/core/core_main.dart';
import '../../shape/shape_main.dart';
import 'contact_main.dart';

// * A link list of contacts.
class ContactLink{
  ContactLink (this.contact);
    
	// The previous contact link.
  ContactLink? prev;
  // The next contact link.
  ContactLink? next;
  // The shape of the contact.
  Shape? shape;
  // The other rigid body.
  Core? body;
  // The contact of the link.
  late Contact contact;
}