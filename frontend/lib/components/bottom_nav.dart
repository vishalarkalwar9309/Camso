import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';

class CamsoBottomNav extends StatelessWidget {
  const CamsoBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final tabs = [
      (
        Icons.home_outlined,
        'Home',
      ),
      (
        Icons.radio_button_unchecked,
        'Products',
      ),
      (
        Icons.search,
        'Search',
      ),
      (
        Icons.description_outlined,
        'Support',
      ),
      (
  Icons.calculate_outlined,
  'Calculators',
),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Row(
          children: [
            for (int i = 0; i < tabs.length; i++)
              Expanded(
                child: _navItem(
                  context,
                  icon: tabs[i].$1,
                  label: tabs[i].$2,
                  index: i,
                  active: state.tab == i,
                  unreadCount:
                      i == 0 ? state.unreadCount : 0,
                  onTap: () {
                    state.setTab(i);

                    Navigator.of(context).popUntil(
                      (route) => route.isFirst,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // NAV ITEM
  // ==============================================================

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool active,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: SizedBox(
        height: 62,

        child: Stack(
          children: [

            // ======================================================
            // ACTIVE TOP INDICATOR
            // ======================================================

            if (active)
              Positioned(
                top: 0,
                left: 0,
                right: 0,

                child: Center(
                  child: Container(
                    width: 32,
                    height: 2,

                    decoration:
                        const BoxDecoration(
                      color: AppColors.blue,

                      borderRadius:
                          BorderRadius.only(
                        bottomLeft:
                            Radius.circular(4),
                        bottomRight:
                            Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

            // ======================================================
            // ICON + LABEL
            // ======================================================

            Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  // ------------------------------------------------
                  // ICON + BADGE
                  // ------------------------------------------------

                  Stack(
                    clipBehavior:
                        Clip.none,

                    children: [
                      Icon(
                        icon,
                        size: 23,

                        color: active
                            ? AppColors.blue
                            : AppColors.muted,
                      ),

                      // ----------------------------------------------
                      // UNREAD BADGE
                      // ----------------------------------------------

                      if (unreadCount > 0)
                        Positioned(
                          top: -5,
                          right: -7,

                          child: Container(
                            width: 16,
                            height: 16,

                            alignment:
                                Alignment.center,

                            decoration:
                                const BoxDecoration(
                              color:
                                  AppColors.orange,
                              shape:
                                  BoxShape.circle,
                            ),

                            child: Text(
                              unreadCount
                                  .toString(),

                              style:
                                  const TextStyle(
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  // ------------------------------------------------
                  // LABEL
                  // ------------------------------------------------

                  Text(
                    label,

                    style: TextStyle(
                      fontSize: 11,

                      fontWeight: active
                          ? FontWeight.w600
                          : FontWeight.w500,

                      color: active
                          ? AppColors.blue
                          : AppColors.muted,

                      fontFamily:
                          'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}