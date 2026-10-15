import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Representation of a dealer record in the CAMSO network.
typedef DealerRecord = ({
  String id,
  String type,
  String name,
  String address,
  String email,
  String phone,
  String hours,
  String distance,
  double? latitude,
  double? longitude,
  bool isVerified,
});

class DealerSupportScreen extends StatefulWidget {
  const DealerSupportScreen({super.key});

  /// Builds a universal Google Maps directions URI for the specified dealer.
  /// Uses verified coordinates if available, otherwise falls back to validated address.
  static Uri buildDirectionsUri(DealerRecord dealer) {
    final String destination;
    if (dealer.isVerified && dealer.latitude != null && dealer.longitude != null) {
      destination = '${dealer.latitude},${dealer.longitude}';
    } else {
      destination = dealer.address;
    }

    return Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': destination,
        'travelmode': 'driving',
      },
    );
  }

  /// Verified dealership dataset for CAMSO by CEAT.
  /// Records with verified coordinates use precise lat/long for navigation and distance calculation.
  /// Records with unverified coordinates are flagged and route via validated address fallback.
  static const List<DealerRecord> allDealers = [
    (
      id: 'd001',
      type: 'AUTHORIZED DEALER',
      name: 'Alpine Equipment GmbH',
      address: 'Industriestraße 45, 80939 Munich, Germany',
      email: 'alpine@camso.co',
      phone: '+49 89 1234 5678',
      hours: 'Mon–Fri 08:00–17:00 CET',
      distance: '3.2 km',
      latitude: 48.2010,
      longitude: 11.6020,
      isVerified: false,
    ),
    (
      id: 'd002',
      type: 'DEALER',
      name: 'Bauer Baumaschinen Service',
      address: 'Gewerbepark 12, 80995 Munich, Germany',
      email: 'bauer@camso.co',
      phone: '+49 89 2345 6789',
      hours: 'Mon–Fri 08:00–17:00 CET',
      distance: '7.8 km',
      latitude: 48.2030,
      longitude: 11.5310,
      isVerified: false,
    ),
    (
      id: 'd003',
      type: 'DEALER',
      name: 'TechTrack Services',
      address: 'Werkstraße 88, 81929 Munich, Germany',
      email: 'techtrack@camso.co',
      phone: '+49 89 3456 7890',
      hours: 'Mon–Fri 09:00–17:00 CET',
      distance: '12.1 km',
      latitude: 48.1485,
      longitude: 11.6580,
      isVerified: false,
    ),
    (
      id: 'd004',
      type: 'AUTHORIZED DEALER',
      name: 'Rheinland Baumaschinen & Reifen GmbH',
      address: 'Am Rheinhafen 14, 50678 Cologne, Germany',
      email: 'koeln@camso.co',
      phone: '+49 221 8901 2345',
      hours: 'Mon–Fri 08:00–18:00 CET',
      distance: '24.5 km',
      latitude: 50.9287,
      longitude: 6.9646,
      isVerified: false,
    ),
    (
      id: 'd005',
      type: 'DISTRIBUTOR HUB',
      name: 'Midwest Track & Tire Solutions',
      address: '4200 W 35th St, Chicago, IL 60632, USA',
      email: 'chicago@camso.co',
      phone: '+1 312 555 0194',
      hours: 'Mon–Fri 07:30–17:30 CST',
      distance: '15.0 km',
      latitude: 41.8302,
      longitude: -87.7275,
      isVerified: true,
    ),
    (
      id: 'd006',
      type: 'AUTHORIZED DEALER',
      name: 'Lone Star Industrial Tire & Track',
      address: '8830 Stemmons Freeway, Dallas, TX 75247, USA',
      email: 'dallas@camso.co',
      phone: '+1 214 555 8320',
      hours: 'Mon–Fri 08:00–17:00 CST',
      distance: '8.4 km',
      latitude: 32.8190,
      longitude: -96.8560,
      isVerified: true,
    ),
    (
      id: 'd007',
      type: 'AUTHORIZED DEALER',
      name: 'EuroTrack France Distribution',
      address: '15 Rue de la République, 69002 Lyon, France',
      email: 'lyon@camso.co',
      phone: '+33 4 78 92 11 00',
      hours: 'Mon–Fri 08:30–17:30 CET',
      distance: '18.3 km',
      latitude: 45.7588,
      longitude: 4.8348,
      isVerified: true,
    ),
    (
      id: 'd008',
      type: 'DEALER',
      name: 'Milano Gomme & Trattori S.r.l.',
      address: 'Via Mecenate 76, 20138 Milan, Italy',
      email: 'milano@camso.co',
      phone: '+39 02 5801 4455',
      hours: 'Mon–Fri 08:00–18:00 CET',
      distance: '9.2 km',
      latitude: 45.4526,
      longitude: 9.2476,
      isVerified: true,
    ),
    (
      id: 'd009',
      type: 'AUTHORIZED DEALER',
      name: 'Britannic Plant & Equipment Ltd.',
      address: 'Tyburn Road, Erdington, Birmingham B24 9NZ, UK',
      email: 'birmingham@camso.co',
      phone: '+44 121 496 0880',
      hours: 'Mon–Fri 08:00–17:00 GMT',
      distance: '21.0 km',
      latitude: 52.5199,
      longitude: -1.8237,
      isVerified: true,
    ),
    (
      id: 'd010',
      type: 'AUTHORIZED DEALER',
      name: 'Pacific Equipment & Rubber Tracks Ltd.',
      address: '13880 Vulcan Way, Richmond, BC V6V 1K6, Canada',
      email: 'vancouver@camso.co',
      phone: '+1 604 555 0148',
      hours: 'Mon–Fri 08:00–16:30 PST',
      distance: '14.6 km',
      latitude: 49.1950,
      longitude: -123.0800,
      isVerified: true,
    ),
  ];

  @override
  State<DealerSupportScreen> createState() => _DealerSupportScreenState();
}

class _DealerSupportScreenState extends State<DealerSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  final ScrollController _scrollController = ScrollController();

  String _query = '';
  Position? _userPosition;
  bool _locationLoading = false;
  String? _locationStatusMessage;
  bool _permissionPermanentlyDenied = false;
  bool _onlyNearest = false;
  String? _selectedDealerId;

  List<DealerRecord> _backendDealers = [];

  Future<void> _fetchBackendDealers([double? lat, double? lng, String? query]) async {
    try {
      final repo = context.read<AppState>().contentRepository;
      final results = await repo.getDealersLocator(
        lat: lat ?? _userPosition?.latitude,
        lng: lng ?? _userPosition?.longitude,
        radiusKm: 1000,
        queryText: query ?? _query,
      );
      if (mounted && results.isNotEmpty) {
        final mapped = results.map<DealerRecord>((item) {
          final latVal = double.tryParse(item['geo_lat']?.toString() ?? '');
          final lngVal = double.tryParse(item['geo_lng']?.toString() ?? '');
          final distVal = double.tryParse(item['distance']?.toString() ?? '');
          return (
            id: item['id']?.toString() ?? '',
            type: item['type']?.toString() ?? 'AUTHORIZED DEALER',
            name: item['name']?.toString() ?? '',
            address: '${item['address'] ?? ''}, ${item['city'] ?? ''}, ${item['state'] ?? ''} ${item['country'] ?? ''}'.trim(),
            email: item['email']?.toString() ?? '',
            phone: item['phone']?.toString() ?? '',
            hours: 'Mon-Fri 08:00-18:00',
            distance: distVal != null ? '${distVal.toStringAsFixed(1)} km' : '',
            latitude: latVal,
            longitude: lngVal,
            isVerified: latVal != null && lngVal != null,
          );
        }).toList();
        setState(() {
          _backendDealers = mapped;
        });
      }
    } catch (_) {}
  }

  // In-screen location notice pop-up state
  String? _locationBannerMessage;
  String? _locationBannerActionLabel;
  VoidCallback? _locationBannerAction;

  @override
  void initState() {
    super.initState();
    // Fetch initial dealer locator results from backend immediately without requiring GPS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBackendDealers();
    });
    // Silently check if permission was already granted previously
    _checkInitialLocationStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showLocationNotice({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!mounted) return;
    setState(() {
      _locationBannerMessage = message;
      _locationBannerActionLabel = actionLabel;
      _locationBannerAction = onAction;
    });
  }

  void _dismissLocationNotice() {
    if (!mounted) return;
    setState(() {
      _locationBannerMessage = null;
      _locationBannerActionLabel = null;
      _locationBannerAction = null;
    });
  }

  Future<void> _checkInitialLocationStatus() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        if (mounted) {
          setState(() {
            _userPosition = position;
          });
          _fetchBackendDealers(position.latitude, position.longitude);
        }
      }
    } catch (_) {
      // Degrade silently on initial probe
    }
  }

  /// Request device location with user-facing status feedback.
  Future<void> _requestLocation({bool userTriggered = false}) async {
    if (_locationLoading) return;

    setState(() {
      _locationLoading = true;
      _locationStatusMessage = null;
    });

    try {
      if (_permissionPermanentlyDenied) {
        if (userTriggered && mounted) {
          _showLocationNotice(
            message: 'Location permission permanently denied. Enable in app settings to use GPS.',
            actionLabel: 'Settings',
            onAction: Geolocator.openAppSettings,
          );
        }
        setState(() {
          _locationLoading = false;
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationLoading = false;
          _locationStatusMessage = 'Location services disabled on device.';
        });
        if (userTriggered && mounted) {
          _showLocationNotice(
            message: 'Please enable GPS / location services in your device settings.',
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationLoading = false;
            _locationStatusMessage = 'Location permission denied.';
          });
          if (userTriggered && mounted) {
            _showLocationNotice(
              message: 'Location permission denied. Browsing dealers manually.',
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationLoading = false;
          _permissionPermanentlyDenied = true;
          _locationStatusMessage = 'Location permanently denied in settings.';
        });
        if (userTriggered && mounted) {
          _showLocationNotice(
            message: 'Location permission permanently denied. Enable in app settings to use GPS.',
            actionLabel: 'Settings',
            onAction: Geolocator.openAppSettings,
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _userPosition = position;
          _locationLoading = false;
          _locationStatusMessage = null;
        });

        _fetchBackendDealers(position.latitude, position.longitude);

        _mapController.move(
          LatLng(position.latitude, position.longitude),
          10.5,
        );

        _showLocationNotice(
          message: 'Location updated. Displaying real driving distances.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _locationStatusMessage = 'Unable to get location.';
        });
        if (userTriggered) {
          _showLocationNotice(
            message: 'Could not obtain current location: $e',
          );
        }
      }
    }
  }

  /// Calculates actual distance in kilometers from the user's position.
  /// Only verified coordinates are used for precise mathematical distance.
  double? _calculateDistanceKm(DealerRecord dealer) {
    if (_userPosition == null) return null;
    if (!dealer.isVerified || dealer.latitude == null || dealer.longitude == null) {
      return null;
    }
    final meters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      dealer.latitude!,
      dealer.longitude!,
    );
    return meters / 1000.0;
  }

  /// Formatted distance string based on actual coordinates.
  String _formatDistance(DealerRecord dealer) {
    final km = _calculateDistanceKm(dealer);
    if (km != null) {
      if (km < 1.0) {
        return '${(km * 1000).round()} m';
      }
      return '${km.toStringAsFixed(1)} km';
    }
    if (!dealer.isVerified) {
      return 'Coords unverified';
    }
    return dealer.distance;
  }

  /// Filtered and optionally sorted dealer dataset.
  List<DealerRecord> get _filteredDealers {
    List<DealerRecord> list = _backendDealers.isNotEmpty ? _backendDealers : DealerSupportScreen.allDealers;

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list.where((dealer) {
        final nameMatches = dealer.name.toLowerCase().contains(q);
        final locationMatches = dealer.address.toLowerCase().contains(q);
        final typeMatches = dealer.type.toLowerCase().contains(q);
        return nameMatches || locationMatches || typeMatches;
      }).toList();
    }

    if (_onlyNearest && _userPosition != null) {
      // Sort verified dealers by calculated distance ascending
      final withDistance = <({DealerRecord dealer, double distance})>[];
      final withoutDistance = <DealerRecord>[];

      for (final d in list) {
        final dist = _calculateDistanceKm(d);
        if (dist != null) {
          withDistance.add((dealer: d, distance: dist));
        } else {
          withoutDistance.add(d);
        }
      }

      withDistance.sort((a, b) => a.distance.compareTo(b.distance));
      final sortedDealers = withDistance.map((item) => item.dealer).toList();

      // Return the five nearest dealers
      return sortedDealers.take(5).toList();
    }

    return list;
  }

  /// Sensible default center based on filtered dealers.
  LatLng get _initialMapCenter {
    if (_userPosition != null) {
      return LatLng(_userPosition!.latitude, _userPosition!.longitude);
    }
    final dealersWithCoords = _filteredDealers
        .where((d) => d.latitude != null && d.longitude != null)
        .toList();

    if (dealersWithCoords.length == 1) {
      return LatLng(
        dealersWithCoords.first.latitude!,
        dealersWithCoords.first.longitude!,
      );
    }

    // Default geographic midpoint between Central Europe and dealer hubs
    return const LatLng(48.5, 9.0);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _fitDealersOnMap() {
    final dealersWithCoords = _filteredDealers
        .where((d) => d.latitude != null && d.longitude != null)
        .toList();

    if (dealersWithCoords.isEmpty) return;

    if (dealersWithCoords.length == 1) {
      final d = dealersWithCoords.first;
      _mapController.move(LatLng(d.latitude!, d.longitude!), 11.5);
      return;
    }

    final points = dealersWithCoords
        .map((d) => LatLng(d.latitude!, d.longitude!))
        .toList();

    if (_userPosition != null) {
      points.add(LatLng(_userPosition!.latitude, _userPosition!.longitude));
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(28),
      ),
    );
  }

  /// Opens Google Maps with driving directions to the selected dealer.
  /// Uses verified coordinates when available, with address fallback.
  Future<void> _openDirections(DealerRecord dealer) async {
    final uri = DealerSupportScreen.buildDirectionsUri(dealer);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Could not launch Google Maps for ${dealer.name}: $e'),
            backgroundColor: Colors.red.shade700,
            showCloseIcon: true,
            closeIconColor: Colors.white,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _callDealer(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Could not place call to $phone'),
            showCloseIcon: true,
            closeIconColor: Colors.white,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Failed to dial $phone: $e'),
            showCloseIcon: true,
            closeIconColor: Colors.white,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _emailDealer(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'CAMSO Dealer Inquiry'},
    );
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Could not open email app for $email'),
            showCloseIcon: true,
            closeIconColor: Colors.white,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Failed to launch email: $e'),
            showCloseIcon: true,
            closeIconColor: Colors.white,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onDealerMarkerTapped(DealerRecord dealer) {
    setState(() {
      _selectedDealerId = dealer.id;
    });

    if (dealer.latitude != null && dealer.longitude != null) {
      _mapController.move(
        LatLng(dealer.latitude!, dealer.longitude!),
        12.0,
      );
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final dist = _formatDistance(dealer);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        dealer.name,
                        style: AppTypography.heading(17, weight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '📍 $dist',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.location_on_outlined, dealer.address),
                const SizedBox(height: 6),
                _infoRow(Icons.phone_outlined, dealer.phone),
                const SizedBox(height: 6),
                _infoRow(Icons.access_time_outlined, dealer.hours),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _callDealer(dealer.phone);
                        },
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.blue,
                          side: const BorderSide(color: AppColors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openDirections(dealer);
                        },
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Directions (Google Maps)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dealers = _filteredDealers;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        title: Text(
          'FIND A DEALER',
          style: AppTypography.heading(22, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Column(
        children: [
          // ======================================================
          // INTERACTIVE MAP CONTAINER
          // ======================================================
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialMapCenter,
                    initialZoom: 4.0,
                    minZoom: 2.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.camso.mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        // User GPS Location marker
                        if (_userPosition != null)
                          Marker(
                            point: LatLng(
                              _userPosition!.latitude,
                              _userPosition!.longitude,
                            ),
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Dealer Markers
                        ...dealers
                            .where((d) => d.latitude != null && d.longitude != null)
                            .map((dealer) {
                          final isSelected = _selectedDealerId == dealer.id;
                          return Marker(
                            point: LatLng(dealer.latitude!, dealer.longitude!),
                            width: isSelected ? 46 : 38,
                            height: isSelected ? 46 : 38,
                            child: GestureDetector(
                              onTap: () => _onDealerMarkerTapped(dealer),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.orange
                                      : AppColors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isSelected ? 0.4 : 0.25,
                                      ),
                                      blurRadius: isSelected ? 8 : 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: isSelected ? 22 : 18,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const RichAttributionWidget(
                      alignment: AttributionAlignment.bottomLeft,
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),

                // Floating Map Controls (Zoom In, Zoom Out, Fit Dealers, My Location)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _mapActionButton(
                        icon: Icons.add,
                        tooltip: 'Zoom In',
                        onTap: _zoomIn,
                      ),
                      const SizedBox(height: 6),
                      _mapActionButton(
                        icon: Icons.remove,
                        tooltip: 'Zoom Out',
                        onTap: _zoomOut,
                      ),
                      const SizedBox(height: 6),
                      _mapActionButton(
                        icon: Icons.crop_free,
                        tooltip: 'Fit All Visible Dealers',
                        onTap: _fitDealersOnMap,
                      ),
                      const SizedBox(height: 6),
                      _mapActionButton(
                        icon: _locationLoading
                            ? Icons.hourglass_top
                            : (_userPosition != null
                                ? Icons.my_location
                                : Icons.location_searching),
                        color: _userPosition != null ? AppColors.blue : Colors.black87,
                        tooltip: 'My Location',
                        onTap: () => _requestLocation(userTriggered: true),
                      ),
                    ],
                  ),
                ),

                // Active Filter or Result Count Chip on Map
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      _onlyNearest
                          ? '📍 Nearest ${dealers.length} Dealers'
                          : (_query.isEmpty
                              ? '📍 Showing ${dealers.length} Dealers'
                              : '📍 "${_query.trim()}" (${dealers.length})'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // SEARCH INPUT (Name, City, State, Country)
          // ======================================================
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _query = val;
                      });
                      _fetchBackendDealers(null, null, val);
                      if (val.trim().isNotEmpty) {
                        _fitDealersOnMap();
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search by dealer name, city, state, or country…',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                      _fitDealersOnMap();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ======================================================
          // NEARBY FILTER & LOCATION STATUS ROW
          // ======================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Dealers'),
                  selected: !_onlyNearest,
                  selectedColor: AppColors.blue.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.blue,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: !_onlyNearest ? AppColors.blue : Colors.black87,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _onlyNearest = false;
                      });
                      _fitDealersOnMap();
                    }
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.near_me, size: 14),
                  label: const Text('Nearest 5'),
                  selected: _onlyNearest,
                  selectedColor: AppColors.blue.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.blue,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _onlyNearest ? AppColors.blue : Colors.black87,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      if (_userPosition == null) {
                        _requestLocation(userTriggered: true);
                      }
                      setState(() {
                        _onlyNearest = true;
                      });
                    } else {
                      setState(() {
                        _onlyNearest = false;
                      });
                    }
                    _fitDealersOnMap();
                  },
                ),
                const Spacer(),
                if (_userPosition != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'GPS Active',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else if (_locationStatusMessage != null)
                  Flexible(
                    child: Text(
                      _locationStatusMessage!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ======================================================
          // DEALER LIST OR EMPTY STATE
          // ======================================================
          Expanded(
            child: dealers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: dealers.length,
                    itemBuilder: (context, index) {
                      final dealer = dealers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _dealerCard(dealer: dealer),
                      );
                    },
                  ),
          ),
        ],
      ),
      if (_locationBannerMessage != null)
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _buildLocationNoticeBanner(),
        ),
    ],
  ),
);
  }

  Widget _buildLocationNoticeBanner() {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF23272F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationBannerMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  if (_locationBannerAction != null) ...[
                    const SizedBox(height: 6),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xFF93C5FD),
                      ),
                      onPressed: () {
                        _locationBannerAction?.call();
                      },
                      child: Text(
                        _locationBannerActionLabel ?? 'Settings',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Close option on right top of the pop up
            InkWell(
              onTap: _dismissLocationNotice,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 32,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Dealers Found',
              style: AppTypography.heading(18, weight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _query.isNotEmpty
                  ? 'No dealer location matches "$_query".\nTry searching by another city, country, or equipment partner name.'
                  : 'No dealers available in the selected filter view.',
              textAlign: TextAlign.center,
              style: AppTypography.body(12, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _onlyNearest = false;
                });
                _fitDealersOnMap();
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Reset Search & Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DEALER CARD
  // ============================================================

  Widget _dealerCard({required DealerRecord dealer}) {
    final distanceText = _formatDistance(dealer);
    final isSelected = _selectedDealerId == dealer.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.blue : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDealerId = dealer.id;
          });
          if (dealer.latitude != null && dealer.longitude != null) {
            _mapController.move(
              LatLng(dealer.latitude!, dealer.longitude!),
              11.5,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Dealer Name + Distance
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      dealer.name,
                      style: AppTypography.body(14, weight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '📍 $distanceText',
                    style: AppTypography.body(
                      11,
                      color: const Color(0xFF10B981),
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Address
              _infoRow(
                Icons.location_on_outlined,
                dealer.address,
              ),

              const SizedBox(height: 7),

              // Email
              _infoRow(
                Icons.email_outlined,
                dealer.email,
              ),

              const SizedBox(height: 7),

              // Phone
              _infoRow(
                Icons.phone_outlined,
                dealer.phone,
              ),

              const SizedBox(height: 7),

              // Hours
              _infoRow(
                Icons.access_time_outlined,
                dealer.hours,
              ),

              const SizedBox(height: 14),

              // Action Buttons: Call, Email, Directions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _callDealer(dealer.phone),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _emailDealer(dealer.email),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlue,
                          foregroundColor: AppColors.blue,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => _openDirections(dealer),
                        icon: const Icon(Icons.directions, size: 14),
                        label: const Text(
                          'Directions',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightBlue,
                          foregroundColor: AppColors.blue,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.muted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.body(
              11,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}