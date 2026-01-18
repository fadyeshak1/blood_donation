import 'package:blood_donation/features/requests/presentation/widgets/filter_chip_widget.dart';
import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onFilterChanged;

  const FilterSection({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = options[index];
              return FilterChipWidget(
                label: option,
                isSelected: selectedOption == option,
                onTap: () => onFilterChanged(option),
              );
            },
          ),
        ),
      ],
    );
  }
}