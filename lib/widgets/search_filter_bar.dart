import 'package:flutter/material.dart';

import '../models/campus_event.dart';

/// Title search field plus "All" and category chips.
///
/// The same bar (and the same settings) is used on Explore, Favorites and
/// My Events, because it lives in [HomeScreen] above the tab content.
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.selectedCategory,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onCategorySelected,
  });

  final TextEditingController controller;
  final EventCategory? selectedCategory;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<EventCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            key: const Key('search-field'),
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search events by title',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      key: const Key('clear-search'),
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: onClearQuery,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              filled: true,
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _chip(context, label: 'All', category: null),
              for (final c in EventCategory.values)
                _chip(context, label: c.label, category: c, icon: c.icon),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required EventCategory? category,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        key: Key('chip-$label'),
        label: Text(label),
        avatar: icon == null ? null : Icon(icon, size: 18),
        selected: selectedCategory == category,
        onSelected: (_) => onCategorySelected(category),
      ),
    );
  }
}
