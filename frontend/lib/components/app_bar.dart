import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class CamsoAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool dark;
  final Widget? right;
  final VoidCallback? onBack;

  const CamsoAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.dark = false,
    this.right,
    this.onBack,
  });

  @override
  Size get preferredSize =>
      const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        dark ? AppColors.blue : Colors.white;

    final foregroundColor =
        dark
            ? Colors.white
            : const Color(0xFF333333);

    final subtitleColor =
        dark
            ? Colors.white70
            : const Color(0xFF6B7280);

    final borderColor =
        dark
            ? Colors.transparent
            : AppColors.border;

    return Container(
      height: 72,

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: backgroundColor,

        border: Border(
          bottom: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),
      ),

      child: Row(
        children: [

          // ========================================================
          // BACK BUTTON
          // ========================================================

          SizedBox(
            width: 40,
            height: 40,

            child: Material(
              color: dark
                  ? Colors.white.withValues(
                      alpha: 0.12,
                    )
                  : AppColors.bg,

              shape: const CircleBorder(),

              child: InkWell(
                customBorder:
                    const CircleBorder(),

                onTap: onBack ??
                    () {
                      Navigator.pop(context);
                    },

                child: Icon(
                  Icons
                      .arrow_back_ios_new,
                  size: 18,
                  color: foregroundColor,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          // ========================================================
          // TITLE + SUBTITLE
          // ========================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Text(
                  title,

                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      AppTypography.heading(
                    20,
                    color:
                        foregroundColor,
                    weight:
                        FontWeight.w700,
                  ).copyWith(
                    height: 1.1,
                    letterSpacing: 0.4,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    subtitle!,

                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        AppTypography.body(
                      11,
                      color:
                          subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ========================================================
          // RIGHT ACTION
          // ========================================================

          if (right != null) ...[
            const SizedBox(
              width: 12,
            ),
            right!,
          ],
        ],
      ),
    );
  }
}