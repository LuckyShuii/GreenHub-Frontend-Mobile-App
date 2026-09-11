class AppSizes {
  static const double rem = 16;

  static const double minTouchTarget = 48;
  static final double inputFieldHeight = toRem(3.125);
  static final double disabledButtonBorderWidth = toRem(0.125);

  const AppSizes._();
}

double toRem(double value) => value * AppSizes.rem;
