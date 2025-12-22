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

class ContentOverview extends StatefulWidget {
  final String childId;

  const ContentOverview({super.key, required this.childId});

  @override
  State<ContentOverview> createState() => _ContentOverviewState();
}

class _ContentOverviewState extends State<ContentOverview> {
  String? _lastRequestedChildId;
  String? _lastRequestedPickupChildId;
  bool _hasRequestedGuardians = false;
  bool _hasRequestedPickup = false;
  bool _hasRequestedChildData = false;

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
                        // child_id در Child_Guardian و Child_Emergency_Contact به Child.id اشاره می‌کند، نه Child.contactId
                        String? actualChildId;
                        if (child != null && child.id != null) {
                          actualChildId = child.id;
                        } else if (childState.children != null) {
                          // اگر child null است، از لیست children استفاده کن
                          try {
                            final foundChild = childState.children!.firstWhere(
                              (c) => c.contactId == widget.childId,
                            );
                            actualChildId = foundChild.id;
                            debugPrint('[CONTENT_OVERVIEW_DEBUG] Found child.id=$actualChildId from children list for contactId=${widget.childId}');
                          } catch (e) {
                            debugPrint('[CONTENT_OVERVIEW_DEBUG] Child not found in children list for contactId: ${widget.childId}');
                          }
                        }

                        // دریافت guardians - اگر actualChildId پیدا شد و با childId متفاوت است، دوباره دریافت کن
                        List<ChildGuardianEntity> guardians = [];
                        if (guardianState is GetChildGuardianByChildIdSuccess) {
                          guardians = guardianState.guardianList;
                        }
                        
                        // اگر actualChildId پیدا شده و با childId متفاوت است و هنوز درخواست ندادیم، درخواست بده
                        if (actualChildId != null && 
                            actualChildId.isNotEmpty && 
                            actualChildId != widget.childId &&
                            !_hasRequestedGuardians &&
                            _lastRequestedChildId != actualChildId) {
                          debugPrint('[CONTENT_OVERVIEW_DEBUG] Requesting guardians with actualChildId: $actualChildId');
                          _lastRequestedChildId = actualChildId;
                          _hasRequestedGuardians = true;
                          final childIdToRequest = actualChildId;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              context.read<ChildGuardianBloc>().add(
                                GetChildGuardianByChildIdEvent(childId: childIdToRequest),
                              );
                            }
                          });
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

                        // دریافت pickup authorizations - اگر actualChildId پیدا شد و با childId متفاوت است، دوباره دریافت کن
                        // توجه: PickupAuthorization.child_id به Child.id اشاره می‌کند
                        if (actualChildId != null && 
                            actualChildId.isNotEmpty && 
                            actualChildId != widget.childId &&
                            !_hasRequestedPickup &&
                            _lastRequestedPickupChildId != actualChildId) {
                          debugPrint('[CONTENT_OVERVIEW_DEBUG] Requesting pickup authorization with actualChildId: $actualChildId');
                          _lastRequestedPickupChildId = actualChildId;
                          _hasRequestedPickup = true;
                          final pickupChildIdToRequest = actualChildId;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              context.read<PickupAuthorizationBloc>().add(
                                GetPickupAuthorizationByChildIdEvent(childId: pickupChildIdToRequest),
                              );
                            }
                          });
                        }

                        // فیلتر والدین
                        final parents = _getParents(guardians);

                        // فیلتر authorized pickup
                        final authorizedPickup = _getAuthorizedPickup(guardians);

                        // دریافت و فیلتر داده‌های child
                        // Dietary Restrictions
                        final dietaryRestrictions = childState.dietaryRestrictions
                                ?.where((dr) => dr.childId == actualChildId)
                                .toList() ??
                            [];
                        final dietaryRestrictionsCount = dietaryRestrictions.length;

                        // Medications
                        final medications = childState.medications
                                ?.where((m) => m.childId == actualChildId)
                                .toList() ??
                            [];
                        final medicationsCount = medications.length;

                        // Physical Requirements
                        final physicalRequirements = childState.physicalRequirements
                                ?.where((pr) => pr.childId == actualChildId)
                                .toList() ??
                            [];
                        final physicalRequirementsCount = physicalRequirements.length;

                        // Reportable Diseases
                        final reportableDiseases = childState.reportableDiseases
                                ?.where((rd) => rd.childId == actualChildId)
                                .toList() ??
                            [];
                        final reportableDiseasesCount = reportableDiseases.length;

                        // درخواست داده‌ها اگر هنوز درخواست نشده
                        if (actualChildId != null && 
                            actualChildId.isNotEmpty && 
                            !_hasRequestedChildData) {
                          _hasRequestedChildData = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              context.read<ChildBloc>().add(const GetAllDietaryRestrictionsEvent());
                              context.read<ChildBloc>().add(const GetAllMedicationsEvent());
                              context.read<ChildBloc>().add(const GetAllPhysicalRequirementsEvent());
                              context.read<ChildBloc>().add(const GetAllReportableDiseasesEvent());
                            }
                          });
                        }

                        return Container(
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              // نمایش والدین
                              if (parents.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (parents.isNotEmpty)
                                      InfoCardOverview(
                                        guardian: parents[0],
                                        contact: _getContactById(
                                          parents[0].contactId,
                                          contacts,
                                        ),
                                      ),
                                    if (parents.isNotEmpty) SizedBox(width: 12),
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
                              _InfoSectionRow(
                                title: 'Dietary Restrictions',
                                itemCount: dietaryRestrictionsCount,
                              ),
                              SizedBox(height: 12),
                              _InfoSectionRow(
                                title: 'Medication',
                                itemCount: medicationsCount,
                              ),
                              SizedBox(height: 12),
                              _InfoSectionRow(
                                title: 'Immunization',
                                itemCount: 0, // TODO: Add when API is available
                              ),
                              SizedBox(height: 12),
                              _InfoSectionRow(
                                title: 'Physical Requirements',
                                itemCount: physicalRequirementsCount,
                              ),
                              SizedBox(height: 12),
                              _InfoSectionRow(
                                title: 'Reportable Diseases',
                                itemCount: reportableDiseasesCount,
                              ),
                              SizedBox(height: 12),
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

class _InfoSectionRow extends StatelessWidget {
  final String title;
  final int itemCount;

  const _InfoSectionRow({
    required this.title,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xff444349),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (itemCount == 0)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffDBDADD), width: 2),
              borderRadius: BorderRadius.circular(9999),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: const Text('No Items'),
          )
        else
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffF9F5FF),
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text(
                  '$itemCount Items',
                  style: const TextStyle(
                    color: Color(0xff9C5CFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
      ],
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
