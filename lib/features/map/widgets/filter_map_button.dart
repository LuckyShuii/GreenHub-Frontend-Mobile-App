import 'package:flutter/material.dart';
import 'package:flutter_frontend/shared/shared.dart';

class MapFilters extends StatefulWidget {
  final Future<void> Function(String type) onFilterSelected;

  const MapFilters({super.key, required this.onFilterSelected});

  @override
  State<MapFilters> createState() => _MapFiltersState();
}

class _MapFiltersState extends State<MapFilters> {
  bool showFilters = false;
  bool showFiltersTrash = false;
  bool showFiltersBike = false;
  final Set<String> selectedFilters = {};

  Widget filterButton({required IconData icon, required String label}) {
    final selected = selectedFilters.contains(label);

    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: label,
          backgroundColor: selected ? Colors.blue : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black,
          onPressed: () {
            setState(() {
              if (selected) {
                selectedFilters.remove(label);
              } else {
                selectedFilters.add(label);
              }
            });
          },
          child: Icon(icon),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSubfilters =
        showFilters || showFiltersTrash || showFiltersBike;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(10),
          decoration: hasSubfilters ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FABButtonWidget(
                onPressed: () {
                  setState(() {
                    if (showFiltersTrash) {
                      showFiltersTrash = false;
                      showFilters = true;
                    } else {
                      showFilters = !showFilters;
                    }
                  });
                },
                icon: showFilters ? Icons.close : Icons.filter_alt_outlined,
              ),
              if (showFilters && !showFiltersTrash) ...[
                FABButtonWidget(
                  icon: Icons.pedal_bike,
                  onPressed: () => widget.onFilterSelected('velo'),
                ),
                FABButtonWidget(
                  icon: Icons.delete,
                  onPressed: () {
                    setState(() {
                      showFiltersTrash = !showFiltersTrash;
                    });
                  },
                ),
              ],
              if (showFiltersTrash) ...[
                FABButtonWidget(
                  icon: Icons.apple,
                  onPressed: () => widget.onFilterSelected('organique'),
                ),
                FABButtonWidget(
                  icon: Icons.inbox,
                  onPressed: () => widget.onFilterSelected('carton'),
                ),
                FABButtonWidget(
                  icon: Icons.wine_bar,
                  onPressed: () => widget.onFilterSelected('verre'),
                ),
                FABButtonWidget(
                  icon: Icons.delete_outline,
                  onPressed: () => widget.onFilterSelected('autre'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
