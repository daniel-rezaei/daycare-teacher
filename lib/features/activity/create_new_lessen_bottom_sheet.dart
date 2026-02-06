import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:teacher_app/core/constants/app_colors.dart';
import 'package:teacher_app/core/pallete.dart';
import 'package:teacher_app/core/widgets/modal_bottom_sheet_wrapper.dart';
import 'package:teacher_app/features/child_status/widgets/attach_photo_widget.dart';
import 'package:teacher_app/features/child_status/widgets/header_check_out_widget.dart';
import 'package:teacher_app/features/child_status/widgets/note_widget.dart';

/// Bottom sheet for creating a new lesson (Learn activity).
/// Unlike other activities, no children need to be selected beforehand.
class CreateNewLessenBottomSheet extends StatefulWidget {
  const CreateNewLessenBottomSheet({super.key});

  @override
  State<CreateNewLessenBottomSheet> createState() =>
      _CreateNewLessenBottomSheetState();
}

class _CreateNewLessenBottomSheetState extends State<CreateNewLessenBottomSheet> {
  final Map<String, String> _selected = {};
  final TextEditingController _videoLinkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<File> _images = [];
  List<String> _tags = [];

  static const Map<String, List<String>> _filters = {
    'Category': [
      'Art & Craft',
      'Language Development',
      'Outdoor Play',
      'Role Play',
      'Numeracy',
      'Physical Development',
      'Music & Movement',
      'Cultural Awareness',
      'Science & Discovery',
      'Gross Motor Skills',
      'Nature & Environment',
      'Social-Emotional Learning',
      'Sensory Play',
      'Health & Nutrition',
      'Fine Motor Skills',
      'STEM Activities',
    ],
    'Age Band': ['Infant', 'Toddler', 'Preschool', 'Kindergarten'],
    'Class': ['Room A', 'Room B', 'Room C', 'Room D'],
  };

  @override
  void dispose() {
    _videoLinkController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _onImagesChanged(List<File> images) {
    setState(() {
      _images.clear();
      _images.addAll(images);
    });
  }

  void _onTagSubmitted(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _onTagRemoved(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetWrapper(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const HeaderCheckOut(isIcon: false, title: 'Create New Lesson'),
            const Divider(height: 1, color: AppColors.dividerDark),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Lesson Title'),
                  const SizedBox(height: 8),
                  Text(
                    'Storytelling',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Palette.textForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Duration'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/images/ic_calanders.svg'),
                          Text(
                            ' 13 June 2023 - 14 July 2023',
                            style: TextStyle(
                              fontSize: 14,
                              color: Palette.textForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._filters.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Palette.textForeground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: entry.value.map((option) {
                              final isSelected = _selected[entry.key] == option;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selected[entry.key] = option;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Palette.txtTagForeground3
                                            .withOpacity(0.8)
                                        : Palette.borderPrimary20,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Palette.textForeground,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _buildLabel('Video Link'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _videoLinkController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Enter the video link',
                        hintStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tag Section (same as other activities)
                  const Text(
                    'Tag',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Enter tag and press done',
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.divider,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.divider,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    onSubmitted: _onTagSubmitted,
                  ),
                  const SizedBox(height: 12),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: AppColors.primaryLight,
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          onDeleted: () => _onTagRemoved(tag),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  // Description (same as other activities)
                  NoteWidget(
                    title: 'Description',
                    hintText: 'Please enter a description',
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 20),
                  // Attach Photo (same as other activities)
                  AttachPhotoWidget(
                    images: _images,
                    onImagesChanged: _onImagesChanged,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _selected);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.borderPrimary80,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
