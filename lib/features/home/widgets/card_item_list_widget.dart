import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teacher_app/features/child/domain/entity/child_entity.dart';
import 'package:teacher_app/features/dietary_restriction/domain/entity/dietary_restriction_entity.dart';
import 'package:teacher_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:teacher_app/features/home/widgets/item_widget.dart';
import 'package:teacher_app/features/medication/domain/entity/medication_entity.dart';
import 'package:teacher_app/features/physical_requirement/domain/entity/physical_requirement_entity.dart';
import 'package:teacher_app/features/profile/domain/entity/contact_entity.dart';
import 'package:teacher_app/features/reportable_disease/domain/entity/reportable_disease_entity.dart';
import 'package:teacher_app/gen/assets.gen.dart';

class CardItemListWidget extends StatefulWidget {
  const CardItemListWidget({super.key});

  @override
  State<CardItemListWidget> createState() => _CardItemListWidgetState();
}

class _CardItemListWidgetState extends State<CardItemListWidget> {
  @override
  void initState() {
    super.initState();
    // درخواست داده‌ها در صورت نیاز
    final currentState = context.read<HomeBloc>().state;
    if (currentState.dietaryRestrictions == null) {
      context.read<HomeBloc>().add(const LoadDietaryRestrictionsEvent());
    }
    if (currentState.medications == null) {
      context.read<HomeBloc>().add(const LoadMedicationsEvent());
    }
    if (currentState.physicalRequirements == null) {
      context.read<HomeBloc>().add(const LoadPhysicalRequirementsEvent());
    }
    if (currentState.reportableDiseases == null) {
      context.read<HomeBloc>().add(const LoadReportableDiseasesEvent());
    }
  }

  String _getPhotoUrl(String? photoId) {
    if (photoId == null || photoId.isEmpty) {
      return '';
    }
    return 'http://51.79.53.56:8055/assets/$photoId';
  }

  ContactEntity? _getContactForChild(
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

  String _getChildName(ContactEntity? contact) {
    if (contact == null) return 'Unknown';
    
    final firstName = contact.firstName ?? '';
    final lastName = contact.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();
    
    return fullName.isNotEmpty ? fullName : 'Unknown';
  }

  // پیدا کردن بچه‌هایی که تولد آن‌ها امروز است (فقط امروز - نه فردا یا دیروز)
  List<ChildEntity> _getTodaysBirthdays(
    List<ChildEntity> children,
    List<ContactEntity> contacts,
  ) {
    final now = DateTime.now(); // Local timezone
    final todayMonth = now.month;
    final todayDay = now.day;
    
    // فیلتر کردن فقط بچه‌هایی که تولد آن‌ها امروز است (همان روز و ماه)
    final todaysBirthdays = children.where((child) {
      if (child.dob == null || child.dob!.isEmpty) return false;
      
      try {
        // Parse dob - handle both date-only strings (e.g., "2000-01-15") 
        // and full ISO strings with timezone (convert to local for comparison)
        final dobParsed = DateTime.parse(child.dob!);
        // Convert to local time if it's a full ISO string with timezone
        // For date-only strings, DateTime.parse already creates local time
        final dobLocal = dobParsed.isUtc ? dobParsed.toLocal() : dobParsed;
        
        // مقایسه فقط روز و ماه - سال را نادیده می‌گیریم
        final isBirthdayToday = dobLocal.month == todayMonth && dobLocal.day == todayDay;
        return isBirthdayToday;
      } catch (e) {
        debugPrint('[BIRTHDAY_DEBUG] Error parsing birthday for child ${child.id}: $e');
        return false;
      }
    }).toList();

    // NO SORTING - فقط لیست بچه‌هایی که تولد آن‌ها امروز است
    return todaysBirthdays;
  }

  // پیدا کردن بچه‌هایی که محدودیت غذایی دارند
  List<ChildEntity> _getChildrenWithDietaryRestrictions(
    List<ChildEntity> children,
    List<DietaryRestrictionEntity> dietaryRestrictions,
    List<ContactEntity> contacts,
  ) {
    final childIdsWithRestrictions = dietaryRestrictions
        .where((restriction) => restriction.childId != null && restriction.childId!.isNotEmpty)
        .map((restriction) => restriction.childId!)
        .toSet();

    return children
        .where((child) => childIdsWithRestrictions.contains(child.id))
        .take(3)
        .toList();
  }

  // پیدا کردن بچه‌هایی که دارو دارند
  List<ChildEntity> _getChildrenWithMedications(
    List<ChildEntity> children,
    List<MedicationEntity> medications,
    List<ContactEntity> contacts,
  ) {
    final childIdsWithMedications = medications
        .where((medication) => 
            medication.childId != null && 
            medication.childId!.isNotEmpty &&
            medication.archived != true)
        .map((medication) => medication.childId!)
        .toSet();

    return children
        .where((child) => childIdsWithMedications.contains(child.id))
        .take(3)
        .toList();
  }

  // پیدا کردن بچه‌هایی که آلرژی دارند (بر اساس allergyId در ChildEntity)
  List<ChildEntity> _getChildrenWithAllergies(
    List<ChildEntity> children,
    List<ContactEntity> contacts,
  ) {
    return children
        .where((child) => 
            child.allergyId != null && 
            child.allergyId!.isNotEmpty)
        .take(3)
        .toList();
  }

  // پیدا کردن بچه‌هایی که نیازمندی فیزیکی دارند
  List<ChildEntity> _getChildrenWithPhysicalRequirements(
    List<ChildEntity> children,
    List<PhysicalRequirementEntity> physicalRequirements,
    List<ContactEntity> contacts,
  ) {
    final childIdsWithRequirements = physicalRequirements
        .where((requirement) => 
            requirement.childId != null && 
            requirement.childId!.isNotEmpty)
        .map((requirement) => requirement.childId!)
        .toSet();

    return children
        .where((child) => childIdsWithRequirements.contains(child.id))
        .take(3)
        .toList();
  }

  // پیدا کردن بچه‌هایی که بیماری قابل گزارش دارند
  List<ChildEntity> _getChildrenWithReportableDiseases(
    List<ChildEntity> children,
    List<ReportableDiseaseEntity> reportableDiseases,
    List<ContactEntity> contacts,
  ) {
    final childIdsWithDiseases = reportableDiseases
        .where((disease) => 
            disease.childId != null && 
            disease.childId!.isNotEmpty)
        .map((disease) => disease.childId!)
        .toSet();

    return children
        .where((child) => childIdsWithDiseases.contains(child.id))
        .take(3)
        .toList();
  }

  String _formatBirthdayText(List<ChildEntity> children, List<ContactEntity> contacts) {
    if (children.isEmpty) return 'No birthdays today';
    
    final names = children
        .map((child) {
          final contact = _getContactForChild(child.contactId, contacts);
          return _getChildName(contact);
        })
        .where((name) => name != 'Unknown')
        .take(3)
        .toList();

    if (names.isEmpty) return 'Birthdays today';
    if (names.length == 1) return "${names[0]}'s Birthday";
    if (names.length == 2) return "${names[0]}'s & ${names[1]}'s Birthday";
    return "${names[0]}'s, ${names[1]} & ${names[2]} Birthday";
  }

  String _formatDietaryRestrictionText(
    List<ChildEntity> children,
    List<DietaryRestrictionEntity> dietaryRestrictions,
    List<ContactEntity> contacts,
  ) {
    if (children.isEmpty) return 'No dietary restrictions';
    
    // Collect full names of all children with dietary restrictions
    final childNames = children
        .map((child) {
          final contact = _getContactForChild(child.contactId, contacts);
          return _getChildName(contact);
        })
        .where((name) => name != 'Unknown')
        .toList();

    if (childNames.isEmpty) return 'No dietary restrictions';
    
    // Join all names with comma
    return childNames.join(', ');
  }

  String _formatMedicationText(
    List<ChildEntity> children,
    List<MedicationEntity> medications,
    List<ContactEntity> contacts,
  ) {
    if (children.isEmpty) return 'No medications';
    
    // Collect full names of all children with medications
    final childNames = children
        .map((child) {
          final contact = _getContactForChild(child.contactId, contacts);
          return _getChildName(contact);
        })
        .where((name) => name != 'Unknown')
        .toList();

    if (childNames.isEmpty) return 'No medications';
    
    // Join all names with comma
    return childNames.join(', ');
  }

  String _formatAllergyText(
    List<ChildEntity> children,
    List<ContactEntity> contacts,
  ) {
    if (children.isEmpty) return 'No allergies';
    
    // Collect full names of all children with allergies
    final childNames = children
        .map((child) {
          final contact = _getContactForChild(child.contactId, contacts);
          return _getChildName(contact);
        })
        .where((name) => name != 'Unknown')
        .toList();

    if (childNames.isEmpty) return 'No allergies';
    
    // Join all names with comma
    return childNames.join(', ');
  }

  String _formatPhysicalRequirementText(
    List<ChildEntity> children,
    List<ContactEntity> contacts,
  ) {
    if (children.isEmpty) return 'No physical requirements';
    
    // Collect full names of all children with physical requirements
    final childNames = children
        .map((child) {
          final contact = _getContactForChild(child.contactId, contacts);
          return _getChildName(contact);
        })
        .where((name) => name != 'Unknown')
        .toList();

    if (childNames.isEmpty) return 'No physical requirements';
    
    // Join all names with comma
    return childNames.join(', ');
  }

  String _formatReportableDiseaseText(
    List<ChildEntity> children,
    List<ContactEntity> contacts,
  ) {
    if (children.isEmpty) return 'No reportable diseases';
    
    // Collect full names of all children with reportable diseases
    final childNames = children
        .map((child) {
          final contact = _getContactForChild(child.contactId, contacts);
          return _getChildName(contact);
        })
        .where((name) => name != 'Unknown')
        .toList();

    if (childNames.isEmpty) return 'No reportable diseases';
    
    // Join all names with comma
    return childNames.join(', ');
  }

  List<Widget> _buildChildAvatars(
    List<ChildEntity> children,
    List<ContactEntity> contacts,
  ) {
    return children.take(3).map((child) {
      final photoUrl = _getPhotoUrl(child.photo);
      
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color(0xffFAFAFA)),
          shape: BoxShape.circle,
        ),
        child: photoUrl.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: photoUrl,
                  httpHeaders: const {
                    'Authorization': 'Bearer ONtKFTGW3t9W0ZSkPDVGQqwXUrUrEmoM',
                  },
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey.shade200,
                    child: const CupertinoActivityIndicator(radius: 8),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 24,
                    height: 24,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                ),
              )
            : ClipOval(
                child: Container(
                  width: 24,
                  height: 24,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
              ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final children = state.children ?? [];
        final contacts = state.contacts ?? [];
        final dietaryRestrictions = state.dietaryRestrictions ?? [];
        final medications = state.medications ?? [];
        final physicalRequirements = state.physicalRequirements ?? [];
        final reportableDiseases = state.reportableDiseases ?? [];

        // اگر داده‌ها هنوز لود نشده‌اند، loading نشان بده
        if (state.isLoadingChildren || 
            state.isLoadingContacts ||
            state.isLoadingDietaryRestrictions ||
            state.isLoadingMedications ||
            state.isLoadingPhysicalRequirements ||
            state.isLoadingReportableDiseases) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        // پیدا کردن بچه‌های مربوطه
        final birthdayChildren = _getTodaysBirthdays(children, contacts);
        final dietaryRestrictionChildren = _getChildrenWithDietaryRestrictions(
          children,
          dietaryRestrictions,
          contacts,
        );
        final medicationChildren = _getChildrenWithMedications(
          children,
          medications,
          contacts,
        );
        final allergyChildren = _getChildrenWithAllergies(children, contacts);
        final physicalRequirementChildren = _getChildrenWithPhysicalRequirements(
          children,
          physicalRequirements,
          contacts,
        );
        final reportableDiseaseChildren = _getChildrenWithReportableDiseases(
          children,
          reportableDiseases,
          contacts,
        );

        return Column(
          children: [
            ItemWidget(
              colorIcon: const Color(0xffF9F5FF),
              title: 'Birthday',
              dec: _formatBirthdayText(birthdayChildren, contacts),
              icon: Assets.images.birthday.svg(),
              childAvatars: _buildChildAvatars(birthdayChildren, contacts),
            ),
            const SizedBox(height: 12),
            ItemWidget(
              colorIcon: const Color(0xffFEF1F8),
              title: 'Dietary Restriction',
              dec: _formatDietaryRestrictionText(
                dietaryRestrictionChildren,
                dietaryRestrictions,
                contacts,
              ),
              icon: Assets.images.dietaryRestrictions.svg(),
              childAvatars: _buildChildAvatars(dietaryRestrictionChildren, contacts),
            ),
            const SizedBox(height: 12),
            ItemWidget(
              colorIcon: const Color(0xffEFFEF5),
              title: 'Medicine',
              dec: _formatMedicationText(medicationChildren, medications, contacts),
              icon: Assets.images.medication.svg(),
              childAvatars: _buildChildAvatars(medicationChildren, contacts),
            ),
            const SizedBox(height: 12),
            ItemWidget(
              colorIcon: const Color(0xffFFF4E6),
              title: 'Allergy',
              dec: _formatAllergyText(allergyChildren, contacts),
              icon: Assets.images.allergy.svg(),
              childAvatars: _buildChildAvatars(allergyChildren, contacts),
            ),
            const SizedBox(height: 12),
            ItemWidget(
              colorIcon: const Color(0xffF0F9FF),
              title: 'Physical Requirements',
              dec: _formatPhysicalRequirementText(physicalRequirementChildren, contacts),
              icon: Assets.images.physicalRequirements.svg(),
              childAvatars: _buildChildAvatars(physicalRequirementChildren, contacts),
            ),
            const SizedBox(height: 12),
            ItemWidget(
              colorIcon: const Color(0xffFEF2F2),
              title: 'Reportable Diseases',
              dec: _formatReportableDiseaseText(reportableDiseaseChildren, contacts),
              icon: Assets.images.reportableDiseases.svg(),
              childAvatars: _buildChildAvatars(reportableDiseaseChildren, contacts),
            ),
          ],
        );
      },
    );
  }
}
