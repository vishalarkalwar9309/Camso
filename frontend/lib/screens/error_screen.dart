import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

enum ErrorType {
  noInternet,
  serverError,
  generic,
}

/// Comprehensive, branded error and connection status screen for CAMSO app.
class ErrorScreen extends StatefulWidget {
  final ErrorType type;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? errorCode;

  const ErrorScreen({
    super.key,
    this.type = ErrorType.generic,
    this.title,
    this.message,
    this.onRetry,
    this.errorCode,
  });

  const ErrorScreen.noInternet({
    super.key,
    this.onRetry,
    this.title = 'No Internet Connection',
    this.message =
        'It looks like your connection is unstable or offline. Please check your Wi-Fi or mobile cellular network and try again.',
    this.errorCode = 'ERR_NO_CONNECTION',
  }) : type = ErrorType.noInternet;

  const ErrorScreen.serverError({
    super.key,
    this.onRetry,
    this.title = 'Server Temporarily Unavailable',
    this.message =
        'We are currently experiencing difficulty communicating with the CAMSO API server. Please try again in a few moments.',
    this.errorCode = 'ERR_SERVER_503',
  }) : type = ErrorType.serverError;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool _isRetrying = false;
  bool _showDetails = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null) return;
    setState(() => _isRetrying = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isRetrying = false);
      widget.onRetry!();
    }
  }

  void _goHome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.read<AppState>().setTab(0);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======================================================
            // BRANDED APP BAR
            // ======================================================
            Container(
              width: double.infinity,
              color: AppColors.blue,
              padding: const EdgeInsets.fromLTRB(12, 10, 20, 14),
              child: Row(
                children: [
                  if (Navigator.of(context).canPop()) ...[
                    IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CONNECTION STATUS',
                          style: AppTypography.heading(20,
                                  color: Colors.white, weight: FontWeight.w800)
                              .copyWith(letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'CAMSO Diagnostics',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.type == ErrorType.noInternet
                          ? 'OFFLINE'
                          : widget.type == ErrorType.serverError
                              ? '503'
                              : 'NOTICE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Orange accent divider
            Container(
              width: double.infinity,
              height: 2,
              color: AppColors.orange,
            ),

            // ======================================================
            // MAIN CONTENT
            // ======================================================
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Icon
                        _buildStatusIcon(),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          widget.title ?? _defaultTitle,
                          style:
                              AppTypography.heading(20, weight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        // Description
                        Text(
                          widget.message ?? _defaultMessage,
                          style: AppTypography.body(13,
                              color: const Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Primary Action (Retry)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isRetrying ? null : _handleRetry,
                            icon: _isRetrying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.refresh, size: 20),
                            label: Text(
                              _isRetrying ? 'RECONNECTING…' : 'TRY AGAIN',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Secondary Action (Go to Home)
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () => _goHome(context),
                            icon: const Icon(Icons.home_outlined, size: 18),
                            label: const Text(
                              'RETURN TO HOME',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.blue,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Collapsible Diagnostics
                        InkWell(
                          onTap: () =>
                              setState(() => _showDetails = !_showDetails),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _showDetails
                                      ? 'Hide Technical Info'
                                      : 'Show Technical Info',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _showDetails
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_showDetails) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CODE: ${widget.errorCode ?? "UNKNOWN_ERROR"}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TIMESTAMP: ${DateTime.now().toUtc().toIso8601String()}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'HOST: http://127.0.0.1:8080 (Client Local Session)',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildStatusIcon() {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (widget.type) {
      case ErrorType.noInternet:
        icon = Icons.wifi_off_rounded;
        iconColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFEF3C7);
        break;
      case ErrorType.serverError:
        icon = Icons.cloud_off_rounded;
        iconColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEE2E2);
        break;
      case ErrorType.generic:
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.blue;
        bgColor = AppColors.lightBlue;
        break;
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 36,
        color: iconColor,
      ),
    );
  }

  String get _defaultTitle {
    switch (widget.type) {
      case ErrorType.noInternet:
        return 'No Internet Connection';
      case ErrorType.serverError:
        return 'Server Unavailable';
      case ErrorType.generic:
        return 'Something Went Wrong';
    }
  }

  String get _defaultMessage {
    switch (widget.type) {
      case ErrorType.noInternet:
        return 'Please verify your network connection and tap below to retry.';
      case ErrorType.serverError:
        return 'The CAMSO server is temporarily unreachable. Please retry shortly.';
      case ErrorType.generic:
        return 'An unexpected issue occurred while loading this page. Please try again.';
    }
  }
}
