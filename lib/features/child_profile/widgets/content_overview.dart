import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_emergency_contact/domain/entity/child_emergency_contact_entity.dart';
import 'package:teacher_app/features/child_emergency_contact/presentation/bloc/child_emergency_contact_bloc.dart';
import 'package:teacher_app/features/child_guardian/domain/entity/child_guardian_entity.dart';
import 'package:teacher_app/features/child_guardian/presentation/bloc/child_guardian_bloc.dart';
import 'package:teacher_app/features/child_profile/widgets/emergency_contacts.dart';
import 'package:teacher_app/features/child_profile/widgets/info_card_overview.dart';
import 'package:teacher_app/features/pickup_authorization/presentation/bloc/pickup_authorization_bloc.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';

class ContentOverview extends StatelessWidget {
  final String childId;

  const ContentOverview({super.key, required this.childId});

  /// پیدا کردن Contact بر اساس contact_id
  /// ارتباط: Contacts.id == Child_Guardian.contact_id
  /// ارتباط: Contacts.id == Child_Emergency_Contact.contact_id
  ContactEntity? _getContactById(
    String? contactId,
    List<ContactEntity> contacts,
  ) {
    if (contactId == null || contactId.isEmpty) return null;
    try {
      // تطابق Contacts.id با contact_id از جداول مختلف
      return contacts.firstWhere((c) => c.id == contactId);
    } catch (e) {
      return null;
    }
  }

  List<ChildGuardianEntity> _getParents(
    List<ChildGuardianEntity> guardians,
  ) {
    return guardians.where((g) {
      final relation = g.relation?.toLowerCase() ?? '';
      return relation == 'mother' || relation == 'father';
    }).toList();
  }

  List<ChildGuardianEntity> _getAuthorizedPickup(
    List<ChildGuardianEntity> guardians,
  ) {
    return guardians
        .where((g) => g.pickupAuthorized == true)
        .take(3)
        .toList();
  }

  String _formatLanguage(List<String>? languages) {
    if (languages == null || languages.isEmpty) return 'Not available';
    return languages.join(' & ');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, childState) {
        return BlocBuilder<ChildBloc, ChildState>(
          builder: (context, contactsState) {
            return BlocBuilder<ChildGuardianBloc, ChildGuardianState>(
              builder: (context, guardianState) {
                return BlocBuilder<ChildEmergencyContactBloc,
                    ChildEmergencyContactState>(
                  builder: (context, emergencyState) {
                    return BlocBuilder<PickupAuthorizationBloc,
                        PickupAuthorizationState>(
                      builder: (context, pickupState) {
                        // دریافت contacts
                        List<ContactEntity> contacts = [];
                        if (contactsState.contacts != null) {
                          contacts = contactsState.contacts!;
                        }

                        // دریافت child
                        ChildEntity? child;
                        if (childState is GetChildByIdSuccess || childState is GetChildByContactIdSuccess) {
                          child = childState.child;
                        }

                        // پیدا کردن Child.id از لیست children بر اساس contactId
                        // child_id در Child_Emergency_Contact به Child.id اشاره می‌کند، نه Child.contactId
                        String? actualChildId;
                        if (child != null && child.id != null) {
                          actualChildId = child.id;
                        } else if (childState.children != null) {
                          // اگر child null است، از لیست children استفاده کن
                          try {
                            final foundChild = childState.children!.firstWhere(
                              (c) => c.contactId == childId,
                            );
                            actualChildId = foundChild.id;
                            debugPrint('[CONTENT_OVERVIEW_DEBUG] Found child.id=${actualChildId} from children list for contactId=$childId');
                          } catch (e) {
                            debugPrint('[CONTENT_OVERVIEW_DEBUG] Child not found in children list for contactId: $childId');
                          }
                        }

                        // دریافت guardians
                        List<ChildGuardianEntity> guardians = [];
                        if (guardianState is GetChildGuardianByChildIdSuccess) {
                          guardians = guardianState.guardianList;
                        }

                        // دریافت emergency contacts و فیلتر بر اساس Child.id
                        List<ChildEmergencyContactEntity> allEmergencyContacts = [];
                        if (emergencyState
                            is GetAllChildEmergencyContactsSuccess) {
                          allEmergencyContacts =
                              emergencyState.emergencyContactList;
                        }
                        
                        // فیلتر emergency contacts بر اساس Child.id
                        // child_id در Child_Emergency_Contact به Child.id اشاره می‌کند
                        debugPrint('[CONTENT_OVERVIEW_DEBUG] actualChildId: $actualChildId, allEmergencyContacts: ${allEmergencyContacts.length}');
                        final List<ChildEmergencyContactEntity> emergencyContacts = 
                            actualChildId != null && actualChildId.isNotEmpty
                                ? allEmergencyContacts
                                    .where((ec) {
                                      final matches = ec.childId == actualChildId && 
                                          (ec.isActive == true || ec.isActive == null);
                                      debugPrint('[CONTENT_OVERVIEW_DEBUG] EmergencyContact: childId=${ec.childId}, contactId=${ec.contactId}, isActive=${ec.isActive}, matches=$matches');
                                      return matches;
                                    })
                                    .toList()
                                : [];
                        debugPrint('[CONTENT_OVERVIEW_DEBUG] Filtered emergencyContacts: ${emergencyContacts.length}');

                        // دریافت pickup authorizations (برای استفاده آینده)
                        // List<PickupAuthorizationEntity> pickupAuthorizations = [];
                        // if (pickupState is GetPickupAuthorizationByChildIdSuccess) {
                        //   pickupAuthorizations = pickupState.authorizationList;
                        // }

                        // فیلتر والدین
                        final parents = _getParents(guardians);

                        // فیلتر authorized pickup
                        final authorizedPickup = _getAuthorizedPickup(guardians);

                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                MediaQuery.of(context).padding.bottom -
                                200, // ارتفاع تقریبی header و tabs
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xffFFFFFF),
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 16,
                                  offset: Offset(0, -4),
                                  color: Color(0xff95939D).withValues(alpha: .2),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.fromLTRB(16, 20, 16, 36),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // نمایش والدین
                              if (parents.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (parents.length >= 1)
                                      InfoCardOverview(
                                        guardian: parents[0],
                                        contact: _getContactById(
                                          parents[0].contactId,
                                          contacts,
                                        ),
                                      ),
                                    if (parents.length >= 1) SizedBox(width: 12),
                                    if (parents.length >= 2)
                                      InfoCardOverview(
                                        guardian: parents[1],
                                        contact: _getContactById(
                                          parents[1].contactId,
                                          contacts,
                                        ),
                                      )
                                    else if (parents.length == 1)
                                      Expanded(child: SizedBox()),
                                  ],
                                ),
                              if (parents.isNotEmpty) SizedBox(height: 12),
                              // نمایش شماره‌های اضطراری
                              EmergencyContacts(
                                emergencyContacts: emergencyContacts,
                                contacts: contacts,
                              ),
                              SizedBox(height: 34),
                              // نمایش Authorized Pick-up
                              if (authorizedPickup.isNotEmpty) ...[
                                Text(
                                  'Authorized Pick-up',
                                  style: TextStyle(
                                    color: Color(0xff444349),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    for (int i = 0;
                                        i < authorizedPickup.length && i < 3;
                                        i++) ...[
                                      if (i > 0) SizedBox(width: 12),
                                      PickUpWidget(
                                        guardian: authorizedPickup[i],
                                        contact: _getContactById(
                                          authorizedPickup[i].contactId,
                                          contacts,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 32),
                              ],
                              // نمایش زبان
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffF4F4F5).withValues(alpha: .9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      width: 2, color: Color(0xffFAFAFA)),
                                ),
                                padding:
                                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Language Spoken',
                                      style: TextStyle(
                                        color: Color(0xff71717A)
                                            .withValues(alpha: .8),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      _formatLanguage(child?.language),
                                      style: TextStyle(
                                        color: Color(0xff444349),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class PickUpWidget extends StatelessWidget {
  final ChildGuardianEntity guardian;
  final ContactEntity? contact;

  const PickUpWidget({
    super.key,
    required this.guardian,
    this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final name = contact != null
        ? '${contact!.firstName ?? ''} ${contact!.lastName ?? ''}'.trim()
        : 'Unknown';
    final relation = guardian.relation ?? 'Unknown';

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffF7F7F8),
          border: Border.all(width: 2, color: Color(0xffFAFAFA)),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.isNotEmpty ? name : 'Unknown',
              style: TextStyle(
                color: Color(0xff444349),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              relation,
              style:
                  TextStyle(color: Color(0xff71717A).withValues(alpha: .8)),
            ),
          ],
        ),
      ),
    );
  }
}
