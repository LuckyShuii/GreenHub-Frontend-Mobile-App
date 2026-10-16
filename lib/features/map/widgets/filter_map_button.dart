import 'package:flutter/material.dart';
import 'package:flutter_frontend/shared/widgets/fab_svg_button_widget.dart';

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
              FABSvgButtonWidget(
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
                assetPath: showFilters ? 'assets/icons/filter-reset.svg' : 'assets/icons/filter.svg',
              ),
              if (showFilters && !showFiltersTrash) ...[
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/bicycle.svg',
                  onPressed: () => widget.onFilterSelected('velo'),
                ),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/waste.svg',
                  onPressed: () {
                    setState(() {
                      showFiltersTrash = !showFiltersTrash;
                    });
                  },
                ),
              ],
              if (showFiltersTrash) ...[
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/banana.svg',
                  onPressed: () => widget.onFilterSelected('organique'),
                ),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/package.svg',
                  onPressed: () => widget.onFilterSelected('carton'),
                ),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/milk-bottle.svg',
                  onPressed: () => widget.onFilterSelected('verre'),
                ),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/waste-restore.svg',
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
