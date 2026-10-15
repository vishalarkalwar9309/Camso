import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class TkphCalculatorScreen extends StatefulWidget {
  const TkphCalculatorScreen({super.key});

  @override
  State<TkphCalculatorScreen> createState() =>
      _TkphCalculatorScreenState();
}

class _TkphCalculatorScreenState
    extends State<TkphCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _loadController = TextEditingController();
  final _speedController = TextEditingController();

  @override
  void dispose() {
    _loadController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  Future<void> _saveResult() async {
    final appState = context.read<AppState>();
    if (!appState.loggedIn) {
      final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Sign in required'),
          content: const Text(
            'Sign in to save calculator results. You can still use the '
            'calculator as a guest.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sign in'),
            ),
          ],
        ),
      );
      if (shouldSignIn == true && mounted) {
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Saving will be available once the approved calculation formula '
          'and result storage are configured.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('TKPH Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tonne-Kilometres Per Hour',
                style: AppTypography.heading(
                  20,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the required operating information. '
                'The approved TKPH formula must be configured '
                'before results can be calculated.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _loadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Average load (tonnes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Enter a valid positive load.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _speedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Average speed (km/h)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Enter a valid positive speed.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Calculation requires an approved formula.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Calculate'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _saveResult,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save result'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  _formKey.currentState?.reset();
                  _loadController.clear();
                  _speedController.clear();
                },
                child: const Text('Reset'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Calculation not yet configured. Do not use this screen '
                'for operational tyre recommendations.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}