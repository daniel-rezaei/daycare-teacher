import 'package:flutter/material.dart';
import 'package:teacher_app/core/constants/app_colors.dart';

class MealTypeSelectorWidget extends StatelessWidget {
  final String title;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final List<String> options;

  const MealTypeSelectorWidget({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.onChanged,
    this.options = const [],
  });

  // Default options if not provided
  List<String> get _options {
    if (options.isNotEmpty) return options;
    
    // Default options based on common meal types and quantities
    if (title == 'Type') {
      return ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    } else if (title == 'Quantity') {
      return ['None', 'Little', 'Some', 'Most', 'All'];
    }
    return [];
  }

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
          children: _options.map((option) {
            final isSelected = selectedValue == option;
            
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onChanged(isSelected ? null : option),
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

