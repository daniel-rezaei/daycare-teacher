import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:teacher_app/core/palette.dart';

class TagSelectorWidget extends StatefulWidget {
  final List<String> initialTags;
  final List<String> suggestions;
  final bool hasBackground;
  final bool showSuggestions;

  const TagSelectorWidget({
    super.key,
    required this.initialTags,
    this.suggestions = const [],
    this.hasBackground = true,
    this.showSuggestions = true,
  });

  @override
  State<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends State<TagSelectorWidget> {
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    selectedTags = [...widget.initialTags];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tag",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: widget.hasBackground
              ? BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,

          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...selectedTags.map((tag) => _buildTag(tag)),

              if (widget.showSuggestions) ...[
                const SizedBox(height: 8),
                ...widget.suggestions.map(
                  (s) => GestureDetector(
                    onTap: () {
                      if (!selectedTags.contains(s)) {
                        setState(() {
                          selectedTags.add(s);
                        });
                      }
                    },
                    child: Text(
                      s,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Palette.borderPrimary20,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: Palette.borderPrimary80,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedTags.remove(tag);
              });
            },
            child: SvgPicture.asset('assets/images/X-fill.svg'),
          ),
        ],
      ),
    );
  }
}
