import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camso_mobile/screens/dealer_support_screen.dart';
import 'package:camso_mobile/screens/onboarding_screen.dart';

void main() {
  group('Dealer Data & Verification Tests', () {
    test('Dealer network contains 10 dealers with unique IDs', () {
      final dealers = DealerSupportScreen.allDealers;
      expect(dealers.length, 10);

      final ids = dealers.map((d) => d.id).toSet();
      expect(ids.length, 10);
    });

    test('Verified dealers have valid coordinates within geographic bounds', () {
      final dealers = DealerSupportScreen.allDealers;
      final verifiedDealers = dealers.where((d) => d.isVerified).toList();

      // At least 6 dealers have verified exact street coordinates
      expect(verifiedDealers.length, greaterThanOrEqualTo(6));

      for (final dealer in verifiedDealers) {
        expect(dealer.latitude, isNotNull);
        expect(dealer.longitude, isNotNull);
        expect(dealer.latitude!, inInclusiveRange(-90.0, 90.0));
        expect(dealer.longitude!, inInclusiveRange(-180.0, 180.0));
        expect(dealer.address, isNotEmpty);
        expect(dealer.name, isNotEmpty);
      }
    });

    test('Unverified dealers are explicitly identified and flagged', () {
      final dealers = DealerSupportScreen.allDealers;
      final unverifiedDealers = dealers.where((d) => !d.isVerified).toList();

      expect(unverifiedDealers.isNotEmpty, isTrue);
      for (final dealer in unverifiedDealers) {
        expect(dealer.isVerified, isFalse);
        expect(dealer.address, isNotEmpty);
      }
    });
  });

  group('Google Maps Navigation URL Tests', () {
    test('Verified dealer uses exact coordinates in Directions destination', () {
      final chicagoDealer = DealerSupportScreen.allDealers.firstWhere((d) => d.id == 'd005');
      expect(chicagoDealer.isVerified, isTrue);

      final uri = DealerSupportScreen.buildDirectionsUri(chicagoDealer);

      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['api'], '1');
      expect(uri.queryParameters['travelmode'], 'driving');
      expect(uri.queryParameters['destination'], '${chicagoDealer.latitude},${chicagoDealer.longitude}');
      expect(uri.queryParameters['destination'], '41.8302,-87.7275');
    });

    test('Unverified dealer falls back to validated address as destination', () {
      final munichDealer = DealerSupportScreen.allDealers.firstWhere((d) => d.id == 'd001');
      expect(munichDealer.isVerified, isFalse);

      final uri = DealerSupportScreen.buildDirectionsUri(munichDealer);

      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['api'], '1');
      expect(uri.queryParameters['travelmode'], 'driving');
      expect(uri.queryParameters['destination'], munichDealer.address);
      expect(uri.queryParameters['destination'], contains('Industriestraße 45, 80939 Munich, Germany'));
    });

    test('Every dealer generates a unique destination in Google Maps', () {
      final dealers = DealerSupportScreen.allDealers;
      final destinations = <String>{};

      for (final dealer in dealers) {
        final uri = DealerSupportScreen.buildDirectionsUri(dealer);
        final dest = uri.queryParameters['destination']!;
        expect(destinations.contains(dest), isFalse, reason: 'Duplicate destination found: $dest');
        destinations.add(dest);
      }

      expect(destinations.length, 10);
    });
  });

  group('Distance Calculations and Proximity Tests', () {
    test('Calculates actual geographic distance between coordinates in km', () {
      // User in Chicago (41.8781, -87.6298)
      const userLat = 41.8781;
      const userLng = -87.6298;

      final chicagoDealer = DealerSupportScreen.allDealers.firstWhere((d) => d.id == 'd005');
      final meters = Geolocator.distanceBetween(
        userLat,
        userLng,
        chicagoDealer.latitude!,
        chicagoDealer.longitude!,
      );
      final km = meters / 1000.0;

      // Distance from downtown Chicago to 4200 W 35th St is approximately 8 to 12 km
      expect(km, greaterThan(5.0));
      expect(km, lessThan(20.0));
    });

    test('Calculates distance from user in Dallas to Dallas dealership', () {
      // User near Dallas Airport (32.8998, -97.0403)
      const userLat = 32.8998;
      const userLng = -97.0403;

      final dallasDealer = DealerSupportScreen.allDealers.firstWhere((d) => d.id == 'd006');
      final meters = Geolocator.distanceBetween(
        userLat,
        userLng,
        dallasDealer.latitude!,
        dallasDealer.longitude!,
      );
      final km = meters / 1000.0;

      expect(km, greaterThan(10.0));
      expect(km, lessThan(30.0));
    });
  });

  group('DealerSupportScreen Widget Tests', () {
    testWidgets('Renders Find a Dealer screen with search and action buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DealerSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('FIND A DEALER'), findsOneWidget);

      // Search field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search by dealer name, city, state, or country…'), findsOneWidget);

      // Filter chips
      expect(find.text('All Dealers'), findsOneWidget);
      expect(find.text('Nearest 5'), findsOneWidget);

      // Dealer card action buttons
      expect(find.text('Call'), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Directions'), findsWidgets);

      // Verify specific dealer names are displayed
      expect(find.text('Alpine Equipment GmbH'), findsOneWidget);
      expect(find.text('Bauer Baumaschinen Service'), findsOneWidget);

      // Verify that dealer status badges are removed
      expect(find.text('AUTHORIZED DEALER'), findsNothing);
      expect(find.text('DEALER'), findsNothing);
      expect(find.text('DISTRIBUTOR HUB'), findsNothing);
      expect(find.byIcon(Icons.verified), findsNothing);
    });

    testWidgets('Search input filters dealers and displays empty state when no match', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: DealerSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query that matches only Dallas
      await tester.enterText(find.byType(TextField), 'Dallas');
      await tester.pumpAndSettle();

      expect(find.text('Lone Star Industrial Tire & Track'), findsOneWidget);
      expect(find.text('Alpine Equipment GmbH'), findsNothing);

      // Enter search query with no match
      await tester.enterText(find.byType(TextField), 'NonExistentCityXYZ');
      await tester.pumpAndSettle();

      expect(find.text('No Dealers Found'), findsOneWidget);
      expect(find.text('Reset Search & Filters'), findsOneWidget);

      // Tap Reset button
      await tester.tap(find.text('Reset Search & Filters'));
      await tester.pumpAndSettle();

      // Restores list
      expect(find.text('Alpine Equipment GmbH'), findsOneWidget);
      expect(find.text('Lone Star Industrial Tire & Track'), findsOneWidget);
    });

    testWidgets('Location notice pop-up has top-right close option that dismisses on tap', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter.baseflow.com/geolocator'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'isLocationServiceEnabled') {
            return false;
          }
          return null;
        },
      );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/geolocator'),
          null,
        );
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: DealerSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Nearest 5 filter chip to trigger location request
      await tester.tap(find.text('Nearest 5'));
      await tester.pumpAndSettle();

      // Location notice pop-up appears and contains message and close button
      expect(find.text('Please enable GPS / location services in your device settings.'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Tap the close button to dismiss the pop-up
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Notice pop-up is dismissed
      expect(find.text('Please enable GPS / location services in your device settings.'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('DealerSupportScreen can be popped cleanly without ScaffoldMessenger or deactivated widget errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DealerSupportScreen()),
                  );
                },
                child: const Text('Open Dealers'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open DealerSupportScreen
      await tester.tap(find.text('Open Dealers'));
      await tester.pumpAndSettle();
      expect(find.text('FIND A DEALER'), findsOneWidget);

      // Pop DealerSupportScreen (navigate back)
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Ensure we are back on previous screen without throwing
      expect(find.text('Open Dealers'), findsOneWidget);
      expect(find.text('FIND A DEALER'), findsNothing);
    });

    testWidgets('OnboardingScreen renders without overflow on compact screen', (tester) async {
      tester.view.physicalSize = const Size(272.0, 594.4);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Built for the toughest jobs'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
    });
  });
}
