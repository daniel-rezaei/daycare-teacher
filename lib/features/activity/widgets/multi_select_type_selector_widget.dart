import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

class MultiSelectTypeSelectorWidget extends StatelessWidget {
  final String title;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final List<String> options; // REQUIRED - must be provided from backend

  const MultiSelectTypeSelectorWidget({
    super.key,
    required this.title,
    required this.selectedValues,
    required this.onChanged,
    required this.options, // REQUIRED - no fallback options
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  final newList = List<String>.from(selectedValues);
                  if (isSelected) {
                    newList.remove(option);
                  } else {
                    newList.add(option);
                  }
                  onChanged(newList);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.backgroundGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    option,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.backgroundLight
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

