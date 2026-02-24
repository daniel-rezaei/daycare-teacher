import 'package:teacher_app/core/constants/app_constants.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';

class ContactUtils {
  ContactUtils._();

  /// Get contact by ID from list
  static ContactEntity? getContactById(
    String? contactId,
    List<ContactEntity> contacts,
  ) {
    if (contactId == null || contactId.isEmpty) return null;
    try {
      return contacts.firstWhere((contact) => contact.id == contactId);
    } catch (e) {
      return null;
    }
  }

  /// Get full name from contact
  static String getContactName(ContactEntity? contact) {
    if (contact == null) return AppConstants.unknownName;
    
    final firstName = contact.firstName ?? '';
    final lastName = contact.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    return fullName.isNotEmpty ? fullName : AppConstants.unknownName;
  }
}

