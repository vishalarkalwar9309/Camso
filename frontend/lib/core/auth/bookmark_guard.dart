import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/login_screen.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';

/// Helper to guard bookmarking actions across the app so only signed-in users can bookmark.
class BookmarkGuard {
  static void toggle(
    BuildContext context,
    String itemId, {
    String itemName = 'item',
  }) {
    final state = context.read<AppState>();
    if (!state.loggedIn) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in required to bookmark this $itemName'),
          backgroundColor: const Color(0xFF1F2937),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'SIGN IN',
            textColor: AppColors.orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    state.toggleBookmark(itemId);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.isBookmarked(itemId)
              ? 'Added to bookmarks'
              : 'Removed from bookmarks',
        ),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
