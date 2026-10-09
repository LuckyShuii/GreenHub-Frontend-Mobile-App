import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import 'home_colors.dart';

class HomeShadows {
  static const List<BoxShadow> surface = <BoxShadow>[
    BoxShadow(color: AppColors.o100, offset: Offset(2, 3)),
  ];
  static const List<BoxShadow> eco = <BoxShadow>[
    BoxShadow(color: Color(0x40000000), offset: Offset(2, 3)),
  ];
  static const List<BoxShadow> progress = <BoxShadow>[
    BoxShadow(color: HomeColors.progressBorder, offset: Offset(2, 3)),
  ];
  static const List<BoxShadow> thumb = <BoxShadow>[
    BoxShadow(color: HomeColors.ecoCard, offset: Offset(2, 3)),
  ];
  static const List<BoxShadow> navigation = <BoxShadow>[
    BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  const HomeShadows._();
}
