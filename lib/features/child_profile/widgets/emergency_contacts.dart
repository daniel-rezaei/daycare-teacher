import 'package:flutter/material.dart';
import 'package:teacher_app/features/child_emergency_contact/domain/entity/child_emergency_contact_entity.dart';
import 'package:teacher_app/features/child_profile/widgets/phone_widget.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class EmergencyContactsWidget extends StatelessWidget {
  final List<ChildEmergencyContactEntity> emergencyContacts;
  final List<ContactEntity> contacts;

  const EmergencyContactsWidget({
    super.key,
    required this.emergencyContacts,
    required this.contacts,
  });

  /// پیدا کردن Contact بر اساس contact_id
  /// ارتباط: Contacts.id == Child_Emergency_Contact.contact_id
  ContactEntity? _getContactById(String? contactId) {
    if (contactId == null || contactId.isEmpty) return null;
    try {
      // تطابق Contacts.id با Child_Emergency_Contact.contact_id
      return contacts.firstWhere((c) => c.id == contactId);
    } catch (e) {
      return null;
    }
  }

  String _getName(ChildEmergencyContactEntity emergencyContact) {
    // استفاده از contact_id برای پیدا کردن Contact
    // Contacts.id == Child_Emergency_Contact.contact_id
    final contact = _getContactById(emergencyContact.contactId);
    if (contact != null) {
      return '${contact.firstName ?? ''} ${contact.lastName ?? ''}'.trim();
    }
    return emergencyContact.relationToChild ?? 'Unknown';
  }

  String? _getPhone(ChildEmergencyContactEntity emergencyContact) {
    // استفاده از contact_id برای پیدا کردن Contact
    // Contacts.id == Child_Emergency_Contact.contact_id
    final contact = _getContactById(emergencyContact.contactId);
    return contact?.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: EdgeInsets.zero,
          collapsedBackgroundColor: Color(0xffEFEEF0),
          backgroundColor: Color(0xffEFEEF0),
          iconColor: Color(0xff444349),
          collapsedIconColor: Color(0xff444349),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          // ---------------- HEADER ----------------
          title: Container(
            decoration: BoxDecoration(
              color: Color(0xffEFEEF0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffFFFFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Assets.images.emergencyContacts.svg(),
                ),
                SizedBox(width: 12),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: Color(0xff444349),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ---------------- EXPANDED CONTENT ----------------
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xffF7F7F8),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.all(12),
              child: emergencyContacts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No emergency contacts available',
                        style: TextStyle(
                          color: Color(0xff71717A),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: emergencyContacts.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final emergencyContact = emergencyContacts[index];
                        final name = _getName(emergencyContact);
                        final phone = _getPhone(emergencyContact);

                        return Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFEE5F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(width: 2, color: Color(0xffFAFAFA)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffE4D3FF).withValues(alpha: .5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          margin: EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name.isNotEmpty ? name : 'Unknown',
                                style: TextStyle(
                                  color: Color(0xff444349),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              PhoneWidget(phone: phone),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
