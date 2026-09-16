import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/utils/no_overscroll_scroll_behavior.dart';
import 'auth_back_button_widget.dart';
import '../theme/auth_sizes.dart';

class AuthFormLayoutWidget extends StatelessWidget {
  const AuthFormLayoutWidget({
    required this.title,
    required this.formKey,
    required this.onBack,
    required this.children,
    this.footer,
    this.subtitle,
    this.scrollController,
    this.titleTopSpacing,
    this.formTopSpacing,
    super.key,
  });
  final String title;
  final String? subtitle;
  final GlobalKey<FormState> formKey;
  final VoidCallback onBack;
  final List<Widget> children;
  final List<Widget>? footer;
  final ScrollController? scrollController;
  final double? titleTopSpacing;
  final double? formTopSpacing;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.o50,
        systemNavigationBarColor: AppColors.o50,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AuthSizes.contentMaxWidthMobile,
              ),
              child: ScrollConfiguration(
                behavior: const NoOverscrollScrollBehavior(),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(
                        AuthSizes.formContentPadding,
                        AuthSizes.formTopPadding,
                        AuthSizes.formContentPadding,
                        AppSpacing.xl,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Form(
                          key: formKey,
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: AuthBackButtonWidget(onPressed: onBack),
                                ),
                                SizedBox(
                                  height: titleTopSpacing ?? AppSpacing.md,
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AuthSizes.formTitleInset,
                                      ),
                                      child: Text(
                                        title,
                                        style: AppTextStyles.formTitle,
                                      ),
                                    ),
                                    if (subtitle != null) ...<Widget>[
                                      SizedBox(height: AppSpacing.md),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs,
                                        ),
                                        child: Text(
                                          subtitle!,
                                          style: AppTextStyles.formSubtitle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(
                                  height: formTopSpacing ?? AppSpacing.xs,
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: children,
                                ),
                                if (footer != null) const Spacer(),
                                if (footer != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: footer!,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
