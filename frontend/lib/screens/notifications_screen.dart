import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(
          'NOTIFICATIONS',
          style: AppTypography.heading(
            24,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: state.markAllRead,
            child: Text(
              'Mark all read',
              style: AppTypography.body(
                11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.refreshNotifications,
        color: AppColors.orange,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${state.unreadCount} unread',
              style: AppTypography.body(
                11,
                color: AppColors.body,
              ),
            ),
            const SizedBox(height: 12),
            if (state.notificationItems.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        size: 48,
                        color: AppColors.textSubtle,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No notifications yet',
                        style: AppTypography.body(14,
                            color: AppColors.textSubtle),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...state.notificationItems.map(
            (notification) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  state.markRead(notification.id);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? Colors.white
                        : AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notification.isRead
                          ? AppColors.border
                          : const Color(0xFFC8CEDF),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =====================================================
                      // NOTIFICATION ICON
                      // =====================================================

                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _iconColor(
                            notification.icon,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconData(
                            notification.icon,
                          ),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // =====================================================
                      // NOTIFICATION CONTENT
                      // =====================================================

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: AppTypography.body(
                                12,
                                weight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              notification.body,
                              maxLines: 3,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: AppTypography.body(
                                11,
                                color: AppColors.body,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              _formatDate(
                                notification.date,
                              ),
                              style: AppTypography.body(
                                9,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =====================================================
                      // UNREAD INDICATOR
                      // =====================================================

                      if (!notification.isRead)
                        Container(
                          width: 9,
                          height: 9,
                          margin:
                              const EdgeInsets.only(
                            top: 3,
                          ),
                          decoration:
                              const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ============================================================
  // ICON COLOR
  // ============================================================

  Color _iconColor(String icon) {
    switch (icon) {
      case 'alert':
        return const Color(0xFFEF4444);

      case 'info':
        return const Color(0xFF3B82F6);

      case 'update':
        return AppColors.orange;

      case 'promo':
        return const Color(0xFF10B981);

      case 'new':
      default:
        return AppColors.blue;
    }
  }

  // ============================================================
  // ICON
  // ============================================================

  IconData _iconData(String icon) {
    switch (icon) {
      case 'alert':
        return Icons.priority_high;

      case 'info':
        return Icons.info_outline;

      case 'update':
        return Icons.refresh;

      case 'promo':
        return Icons.favorite_border;

      case 'new':
      default:
        return Icons.star;
    }
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      final now = DateTime.now();

      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      final yesterday = today.subtract(
        const Duration(days: 1),
      );

      final notificationDay = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      if (notificationDay == today) {
        return 'Today · ${_formatTime(parsedDate)}';
      }

      if (notificationDay == yesterday) {
        return 'Yesterday · ${_formatTime(parsedDate)}';
      }

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year} · '
          '${_formatTime(parsedDate)}';
    } catch (_) {
      // Preserve the original behaviour if the stored
      // notification date isn't a valid ISO date.
      if (date.length >= 10) {
        return date.substring(0, 10);
      }

      return date;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}