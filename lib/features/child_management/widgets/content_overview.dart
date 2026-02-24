import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/core/utils/string_utils.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_emergency_contact_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/child_guardian_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_bloc.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_emergency_contact_bloc.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_guardian_bloc.dart';
import 'package:teacher_app/features/child_management/domain/entity/pickup_authorization_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/pickup_authorization_bloc.dart';
import 'package:teacher_app/features/child_management/domain/entity/allergy_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/immunization_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/child_management/domain/entity/reportable_disease_entity.dart';
import 'package:teacher_app/features/child_management/presentation/bloc/child_profile_bloc.dart';
import 'package:teacher_app/features/child_management/widgets/emergency_contacts.dart';
import 'package:teacher_app/features/child_management/widgets/info_card_overview.dart';
import 'package:teacher_app/features/home/domain/entity/contact_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class ContentOverviewWidget extends StatefulWidget {
  final String childId;

  const ContentOverviewWidget({super.key, required this.childId});

  @override
  State<ContentOverviewWidget> createState() => _ContentOverviewWidgetState();
}

class _ContentOverviewWidgetState extends State<ContentOverviewWidget> {
  String? _lastRequestedChildId;
  String? _lastRequestedPickupChildId;
  bool _hasRequestedGuardians = false;
  bool _hasRequestedPickup = false;

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

  List<ChildGuardianEntity> _getParents(List<ChildGuardianEntity> guardians) {
    return guardians.where((g) {
      final relation = g.relation?.toLowerCase() ?? '';
      return relation == 'mother' || relation == 'father';
    }).toList();
  }

  // Removed _getAuthorizedPickup - now using PickupAuthorization API directly

  /// Format language list for display
  /// - Never casts to String
  /// - Capitalizes each language: "english" → "English"
  /// - Joins multiple languages with comma: ["english", "french"] → "English, French"
  /// - Returns "No language specified" if null or empty
  String _formatLanguage(List<String>? languages) {
    if (languages == null || languages.isEmpty) {
      return 'No language specified';
    }

    // Capitalize each language and join with comma
    final capitalizedLanguages = languages.map((lang) {
      // Capitalize first letter, keep rest lowercase
      if (lang.isEmpty) return lang;
      if (lang.length == 1) return lang.toUpperCase();
      return lang[0].toUpperCase() + lang.substring(1).toLowerCase();
    }).toList();

    final displayText = capitalizedLanguages.join(', ');
    return displayText;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildBloc, ChildState>(
      builder: (context, childState) {
        return BlocBuilder<ChildBloc, ChildState>(
          builder: (context, contactsState) {
            return BlocBuilder<ChildGuardianBloc, ChildGuardianState>(
              builder: (context, guardianState) {
                return BlocBuilder<
                  ChildEmergencyContactBloc,
                  ChildEmergencyContactState
                >(
                  builder: (context, emergencyState) {
                    return BlocBuilder<
                      PickupAuthorizationBloc,
                      PickupAuthorizationState
                    >(
                      builder: (context, pickupState) {
                        return BlocBuilder<ChildProfileBloc, ChildProfileState>(
                          builder: (context, profileState) {
                            // دریافت contacts
                            List<ContactEntity> contacts = [];
                            if (contactsState.contacts != null) {
                              contacts = contactsState.contacts!;
                            }

                            // دریافت child
                            ChildEntity? child;
                            if (childState is GetChildByIdSuccess ||
                                childState is GetChildByContactIdSuccess) {
                              child = childState.child;
                            } else if (childState.children != null &&
                                childState.children!.isNotEmpty) {
                              // Try to find child from children list
                              final foundChild = childState.children!
                                  .firstWhere(
                                    (c) => c.contactId == widget.childId,
                                  );
                              child = foundChild;
                            }

                            // پیدا کردن Child.id از لیست children بر اساس contactId
                            // child_id در Child_Guardian و Child_Emergency_Contact به Child.id اشاره می‌کند، نه Child.contactId
                            String? actualChildId;
                            if (child != null && child.id != null) {
                              actualChildId = child.id;
                            } else if (childState.children != null) {
                              // اگر child null است، از لیست children استفاده کن
                              final foundChild = childState.children!
                                  .firstWhere(
                                    (c) => c.contactId == widget.childId,
                                  );
                              actualChildId = foundChild.id;
                            }

                            // دریافت guardians - اگر actualChildId پیدا شد و با childId متفاوت است، دوباره دریافت کن
                            List<ChildGuardianEntity> guardians = [];
                            if (guardianState
                                is GetChildGuardianByChildIdSuccess) {
                              guardians = guardianState.guardianList;
                            }

                            // اگر actualChildId پیدا شده و با childId متفاوت است و هنوز درخواست ندادیم، درخواست بده
                            if (actualChildId != null &&
                                actualChildId.isNotEmpty &&
                                actualChildId != widget.childId &&
                                !_hasRequestedGuardians &&
                                _lastRequestedChildId != actualChildId) {
                              _lastRequestedChildId = actualChildId;
                              _hasRequestedGuardians = true;
                              final childIdToRequest = actualChildId;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  context.read<ChildGuardianBloc>().add(
                                    GetChildGuardianByChildIdEvent(
                                      childId: childIdToRequest,
                                    ),
                                  );
                                }
                              });
                            }

                            // دریافت emergency contacts و فیلتر بر اساس Child.id
                            List<ChildEmergencyContactEntity>
                            allEmergencyContacts = [];
                            if (emergencyState
                                is GetAllChildEmergencyContactsSuccess) {
                              allEmergencyContacts =
                                  emergencyState.emergencyContactList;
                            }

                            // فیلتر emergency contacts بر اساس Child.id
                            // child_id در Child_Emergency_Contact به Child.id اشاره می‌کند
                            final List<ChildEmergencyContactEntity>
                            emergencyContacts =
                                actualChildId != null &&
                                    actualChildId.isNotEmpty
                                ? allEmergencyContacts.where((ec) {
                                    final matches =
                                        ec.childId == actualChildId &&
                                        (ec.isActive == true ||
                                            ec.isActive == null);
                                    return matches;
                                  }).toList()
                                : [];

                            // دریافت pickup authorizations - اگر actualChildId پیدا شد و با childId متفاوت است، دوباره دریافت کن
                            // توجه: PickupAuthorization.child_id به Child.id اشاره می‌کند
                            if (actualChildId != null &&
                                actualChildId.isNotEmpty &&
                                actualChildId != widget.childId &&
                                !_hasRequestedPickup &&
                                _lastRequestedPickupChildId != actualChildId) {
                              _lastRequestedPickupChildId = actualChildId;
                              _hasRequestedPickup = true;
                              final pickupChildIdToRequest = actualChildId;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  context.read<PickupAuthorizationBloc>().add(
                                    GetPickupAuthorizationByChildIdEvent(
                                      childId: pickupChildIdToRequest,
                                    ),
                                  );
                                }
                              });
                            }

                            // فیلتر والدین
                            final parents = _getParents(guardians);

                            // دریافت authorized pickup از PickupAuthorization API
                            List<PickupAuthorizationEntity>
                            authorizedPickupList = [];
                            if (pickupState
                                is GetPickupAuthorizationByChildIdSuccess) {
                              // فیلتر بر اساس actualChildId
                              authorizedPickupList = pickupState
                                  .pickupAuthorizationList
                                  .where((pa) => pa.childId == actualChildId)
                                  .toList();
                            }

                            // دریافت داده‌های پزشکی از ChildProfileBloc (preloaded state)
                            // این داده‌ها قبلاً قبل از navigation لود شده‌اند
                            List<AllergyEntity> allergies = [];
                            List<DietaryRestrictionEntity> dietaryRestrictions =
                                [];
                            List<MedicationEntity> medications = [];
                            List<ImmunizationEntity> immunizations = [];
                            List<PhysicalRequirementEntity>
                            physicalRequirements = [];
                            List<ReportableDiseaseEntity> reportableDiseases =
                                [];

                            if (profileState is ChildProfileDataLoaded) {
                              // Use preloaded data from ChildProfileBloc ONLY
                              allergies = profileState.allergies;
                              dietaryRestrictions =
                                  profileState.dietaryRestrictions;
                              medications = profileState.medications;
                              immunizations = profileState.immunizations;
                              physicalRequirements =
                                  profileState.physicalRequirements;
                              reportableDiseases =
                                  profileState.reportableDiseases;
                            }

                            // NOTE: Medical data is now preloaded BEFORE navigation via ChildProfileBloc
                            // We no longer call APIs here - we only read from preloaded state
                            // NO fallback to ChildBloc or HomeBloc

                            return Container(
                              decoration: BoxDecoration(
                                color: Color(0xffFFFFFF),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 16,
                                    offset: Offset(0, -4),
                                    color: Color(
                                      0xff95939D,
                                    ).withValues(alpha: .2),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (parents.isNotEmpty)
                                          InfoCardOverviewWidget(
                                            guardian: parents[0],
                                            contact: _getContactById(
                                              parents[0].contactId,
                                              contacts,
                                            ),
                                          ),
                                        if (parents.isNotEmpty)
                                          SizedBox(width: 12),
                                        if (parents.length >= 2)
                                          InfoCardOverviewWidget(
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
                                  EmergencyContactsWidget(
                                    emergencyContacts: emergencyContacts,
                                    contacts: contacts,
                                  ),
                                  SizedBox(height: 34),
                                  // نمایش Authorized Pick-up
                                  Text(
                                    'Authorized Pick-up',
                                    style: TextStyle(
                                      color: Color(0xff444349),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  if (pickupState
                                      is GetPickupAuthorizationByChildIdLoading)
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CupertinoActivityIndicator(),
                                      ),
                                    )
                                  else if (authorizedPickupList.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'No authorized pick-up people',
                                        style: TextStyle(
                                          color: Color(0xff71717A),
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  else
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          for (
                                            int i = 0;
                                            i < authorizedPickupList.length;
                                            i++
                                          ) ...[
                                            if (i > 0) SizedBox(width: 12),
                                            AuthorizedPickupItemWidget(
                                              pickupAuthorization:
                                                  authorizedPickupList[i],
                                              contact: _getContactById(
                                                authorizedPickupList[i]
                                                    .authorizedContactId,
                                                contacts,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 32),
                                  // Show loading indicator if medical data is still loading
                                  if (profileState is ChildProfileLoading)
                                    const Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else ...[
                                    // Medical sections - only shown when data is loaded
                                    // Allergy section - TOP of medical block
                                    _ExpandableInfoSection(
                                      title: Row(
                                        children: [
                                          Assets.images.allergy.svg(),
                                          SizedBox(width: 8),
                                          const Text(
                                            'Allergy',
                                            style: TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      items: allergies,
                                      itemBuilder: (context, item) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF7F7F8),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              width: 2,
                                              color: const Color(0xffFAFAFA),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            item.allergenName ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    // Dietary Restrictions section
                                    _ExpandableInfoSection(
                                      title: Row(
                                        children: [
                                          Assets.images.dietaryRestrictions
                                              .svg(),
                                          SizedBox(width: 8),
                                          const Text(
                                            'Dietary Restrictions',
                                            style: TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      items: dietaryRestrictions,
                                      itemBuilder: (context, item) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF7F7F8),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              width: 2,
                                              color: const Color(0xffFAFAFA),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            item.restrictionName ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    _ExpandableInfoSection(
                                      title: Row(
                                        children: [
                                          Assets.images.medication.svg(),
                                          SizedBox(width: 8),
                                          const Text(
                                            'Medication',
                                            style: TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      items: medications,
                                      itemBuilder: (context, item) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF7F7F8),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              width: 2,
                                              color: const Color(0xffFAFAFA),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            item.medicationName ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    _ExpandableInfoSection(
                                      title: Row(
                                        children: [
                                          Assets.images.immunization.svg(),
                                          SizedBox(width: 8),
                                          const Text(
                                            'Immunization',
                                            style: TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      items: immunizations,
                                      itemBuilder: (context, item) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF7F7F8),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              width: 2,
                                              color: const Color(0xffFAFAFA),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            item.vaccineName ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    _ExpandableInfoSection(
                                      title: Row(
                                        children: [
                                          Assets.images.physicalRequirements
                                              .svg(),
                                          SizedBox(width: 8),
                                          const Text(
                                            'Physical Requirements',
                                            style: TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      items: physicalRequirements,
                                      itemBuilder: (context, item) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF7F7F8),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              width: 2,
                                              color: const Color(0xffFAFAFA),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            item.requirementName ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    _ExpandableInfoSection(
                                      title: Row(
                                        children: [
                                          Assets.images.reportableDiseases
                                              .svg(),
                                          SizedBox(width: 8),
                                          const Text(
                                            'Reportable Diseases',
                                            style: TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      items: reportableDiseases,
                                      itemIcon: Icons.sick_rounded,
                                      itemBuilder: (context, item) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF7F7F8),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              width: 2,
                                              color: const Color(0xffFAFAFA),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            item.diseaseName ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Color(0xff444349),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ], // Close the else block for medical sections
                                  SizedBox(height: 12),
                                  // نمایش زبان
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(
                                        0xffF4F4F5,
                                      ).withValues(alpha: .9),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        width: 2,
                                        color: Color(0xffFAFAFA),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Language Spoken',
                                          style: TextStyle(
                                            color: Color(
                                              0xff71717A,
                                            ).withValues(alpha: .8),
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
      },
    );
  }
}

class _InfoSectionRow extends StatelessWidget {
  final Widget title;
  final int itemCount;

  const _InfoSectionRow({required this.title, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        title,
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

class _ExpandableInfoSection<T> extends StatelessWidget {
  final Widget title;
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final IconData? itemIcon;

  const _ExpandableInfoSection({
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.itemIcon,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = items.length;

    if (itemCount == 0) {
      return _InfoSectionRow(title: title, itemCount: 0);
    }

    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: const Color(0xff444349),
        collapsedIconColor: const Color(0xff444349),
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        title: Row(
          children: [
            title,
            const Spacer(),
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
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ListView.builder(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = items[index];
                final widget = itemBuilder(context, item);

                // اگر itemIcon مشخص شده، آیکون را اضافه کن
                if (itemIcon != null) {
                  if (widget is Container && widget.child != null) {
                    return Container(
                      decoration: widget.decoration,
                      padding: widget.padding,
                      margin: widget.margin,
                      child: Row(
                        children: [
                          Icon(
                            itemIcon,
                            color: const Color(0xff444349),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: widget.child!),
                        ],
                      ),
                    );
                  } else {
                    return Row(
                      children: [
                        Icon(
                          itemIcon,
                          color: const Color(0xff444349),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: widget),
                      ],
                    );
                  }
                }

                return widget;
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for displaying authorized pick-up person
class AuthorizedPickupItemWidget extends StatelessWidget {
  final PickupAuthorizationEntity pickupAuthorization;
  final ContactEntity? contact;

  const AuthorizedPickupItemWidget({
    super.key,
    required this.pickupAuthorization,
    this.contact,
  });

  String _getPhotoUrl(String? photoId) {
    if (photoId == null || photoId.isEmpty) {
      return '';
    }
    return 'http://51.79.53.56:8055/assets/$photoId';
  }

  @override
  Widget build(BuildContext context) {
    final name = contact != null
        ? '${contact!.firstName ?? ''} ${contact!.lastName ?? ''}'.trim()
        : 'Unknown';
    final capitalizedRelation = StringUtils.capitalizeFirstLetter(
      pickupAuthorization.relationToChild,
    );
    final relation = capitalizedRelation.isEmpty
        ? 'Unknown'
        : capitalizedRelation;
    final photo = contact?.photo;

    return Container(
      width: 140, // Fixed width for horizontal scroll
      decoration: BoxDecoration(
        color: Color(0xffF7F7F8),
        border: Border.all(width: 2, color: Color(0xffFAFAFA)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          SizedBox(
            height: 40,
            width: 40,
            child: photo != null && photo.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _getPhotoUrl(photo),
                      httpHeaders: const {
                        'Authorization':
                            'Bearer ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM',
                      },
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: const CupertinoActivityIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          Assets.images.image.image(),
                    ),
                  )
                : Assets.images.image.image(),
          ),
          SizedBox(height: 8),
          // Name
          Text(
            name.isNotEmpty ? name : 'Unknown',
            style: TextStyle(
              color: Color(0xff444349),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          // Relationship
          Text(
            relation,
            style: TextStyle(
              color: Color(0xff71717A).withValues(alpha: .8),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
