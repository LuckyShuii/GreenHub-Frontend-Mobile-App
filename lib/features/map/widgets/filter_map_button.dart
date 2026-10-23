import 'package:flutter/material.dart';
import 'package:flutter_frontend/shared/shared.dart';
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
  bool showFiltersBus = false;
  bool showFiltersCar = false;

  @override
  Widget build(BuildContext context) {
    final bool hasfilters = showFilters || showFiltersTrash || showFiltersBike || showFiltersBus || showFiltersCar;
    final bool hasSubfilters = showFiltersTrash || showFiltersBike || showFiltersBus || showFiltersCar;
    const borderColor = Color(0xFFE2E4DF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FABSvgButtonWidget(
          assetPath: showFilters ? 'assets/icons/filter-reset.svg' : 'assets/icons/filter.svg',
          backgroundColor: showFilters ? Color(0xFFE0BF70) : AppColors.o40,
          onPressed: () {
            setState(() {
              if (hasSubfilters) {
                showFilters = true;
              } else {
                showFilters = !showFilters;
              }
            });
          },
        ),

        Container(
          width: 80,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: hasfilters ? BoxDecoration(
            color: AppColors.o40,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: borderColor,
                offset: Offset(2, 3),
                blurRadius: 0,
                spreadRadius: 0,
              )
            ],
          ) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFilters && !hasSubfilters) ...[
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/waste.svg',
                  onPressed: () {
                    setState(() {
                      showFiltersTrash = !showFiltersTrash;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/bus-front.svg',
                  onPressed: () {
                    setState(() {
                      showFiltersBus = !showFiltersBus;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/bicycle.svg',
                  onPressed: () {
                    setState(() {
                      showFiltersBike = !showFiltersBike;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/traffic-jam.svg',
                  onPressed: () {
                    setState(() {
                      showFiltersCar = !showFiltersCar;
                    });
                  },
                ),
              ],
              if (showFiltersTrash) ...[
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/waste.svg',
                  backgroundColor: Color(0x7A4E8A64),
                  onPressed: () {
                    setState(() {
                      showFiltersTrash = !showFiltersTrash;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/banana.svg',
                  onPressed: () => widget.onFilterSelected('organique'),
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/package.svg',
                  onPressed: () => widget.onFilterSelected('carton'),
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/milk-bottle.svg',
                  onPressed: () => widget.onFilterSelected('verre'),
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/waste-restore.svg',
                  onPressed: () => widget.onFilterSelected('autre'),
                ),
              ],
              if (showFiltersBus) ...[
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/bus-front.svg',
                  backgroundColor: Color(0x7A4E8A64),
                  onPressed: () {
                    setState(() {
                      showFiltersBus = !showFiltersBus;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/bus.svg',
                  onPressed: () => {},
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/tram.svg',
                  onPressed: () => {},
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/metro.svg',
                  onPressed: () => {},
                ),
              ],
              if (showFiltersBike) ...[
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/bicycle.svg',
                  backgroundColor: Color(0x7A4E8A64),
                  onPressed: () {
                    setState(() {
                      showFiltersBike = !showFiltersBike;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/velib.svg',
                  onPressed: () => widget.onFilterSelected('velo'),
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/lim.svg',
                  onPressed: () => {},
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/dott.svg',
                  onPressed: () => {},
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/voi.svg',
                  onPressed: () => {},
                ),
              ],
              if (showFiltersCar) ...[
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/traffic-jam.svg',
                  backgroundColor: Color(0x7A4E8A64),
                  onPressed: () {
                    setState(() {
                      showFiltersCar = !showFiltersCar;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/auto-partage.svg',
                  onPressed: () => widget.onFilterSelected('organique'),
                ),
                const SizedBox(height: 12),
                FABSvgButtonWidget(
                  assetPath: 'assets/icons/covoiturage.svg',
                  onPressed: () => widget.onFilterSelected('carton'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
