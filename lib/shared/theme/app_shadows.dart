import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  static const List<BoxShadow> field = <BoxShadow>[
    BoxShadow(color: AppColors.o100, offset: Offset(2, 3)),
  ];

  static const List<BoxShadow> errorField = <BoxShadow>[
    BoxShadow(color: AppColors.erreur, offset: Offset(2, 3)),
  ];

  static const List<BoxShadow> primaryButton = <BoxShadow>[
    BoxShadow(color: Color(0x40000000), offset: Offset(2, 3)),
  ];

  // Petite ombre (-2-3-8)
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A1C443B),
      blurRadius: 3,
      spreadRadius: -2,
      offset: Offset(0, 8),
    ),
  ];

  // Ombre moyenne (-2-6-8)
  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A1C443B),
      blurRadius: 6,
      spreadRadius: -2,
      offset: Offset(0, 8),
    ),
  ];

  // Grande ombre (-2-12-8)
  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(
      color: Color(0x140E3B2E),
      blurRadius: 12,
      spreadRadius: -2,
      offset: Offset(0, 8),
    ),
  ];

  // Ombre de carte (variante large)
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x140E3B2E),
      blurRadius: 12,
      spreadRadius: -2,
      offset: Offset(0, 8),
    ),
  ];

  // Ombre de bouton
  static const List<BoxShadow> button = <BoxShadow>[
    BoxShadow(
      color: Color(0x331E6B4D),
      blurRadius: 16,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
  ];

  // Ombre de focus
  static const BoxShadow focus = BoxShadow(
    color: AppColors.v500,
    blurRadius: 0,
    spreadRadius: 2,
    offset: Offset.zero,
  );
}
