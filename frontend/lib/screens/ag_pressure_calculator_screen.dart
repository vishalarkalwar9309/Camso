import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class AgPressureCalculatorScreen extends StatefulWidget {
  const AgPressureCalculatorScreen({super.key});

  @override
  State<AgPressureCalculatorScreen> createState() =>
      _AgPressureCalculatorScreenState();
}

class _AgPressureCalculatorScreenState
    extends State<AgPressureCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _loadController = TextEditingController();
  final _tyreCountController = TextEditingController();

  @override
  void dispose() {
    _loadController.dispose();
    _tyreCountController.dispose();
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
        title: const Text('AG Pressure Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agricultural Pressure',
                style: AppTypography.heading(
                  20,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the required information to calculate '
                'the result once the approved formula is configured.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _loadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Load',
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
                controller: _tyreCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of tyres',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Enter a valid tyre count.';
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
                  _tyreCountController.clear();
                },
                child: const Text('Reset'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Calculation not yet configured. Do not use this screen '
                'for operational pressure recommendations.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}