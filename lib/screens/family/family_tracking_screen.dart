import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class FamilyTrackingScreen extends StatefulWidget {
  const FamilyTrackingScreen({super.key});

  @override
  State<FamilyTrackingScreen> createState() => _FamilyTrackingScreenState();
}

class _FamilyTrackingScreenState extends State<FamilyTrackingScreen> {
  int _selectedTab = 0; // 0: Live, 1: Safe Zones, 2: History

  final String _patientName = 'Margaret Smith';

  // Patient location (simulated)
  _LatLng _patient = const _LatLng(37.3318, -122.0312);
  DateTime _lastUpdated = DateTime.now();

  // Safe zones data
  final List<_SafeZone> _safeZones = [
    _SafeZone(
      name: 'Home',
      address: '123 Oak Street, Springfield',
      lat: 37.3318,
      lng: -122.0312,
      radiusMeters: 200,
      isActive: true,
    ),
    _SafeZone(
      name: 'Park',
      address: 'Central Park, Springfield',
      lat: 37.3333,
      lng: -122.0293,
      radiusMeters: 150,
      isActive: true,
    ),
    _SafeZone(
      name: 'Hospital',
      address: 'Springfield General Hospital',
      lat: 37.3270,
      lng: -122.0305,
      radiusMeters: 100,
      isActive: true,
    ),
    _SafeZone(
      name: 'Church',
      address: 'Community Church, Springfield',
      lat: 37.3345,
      lng: -122.0350,
      radiusMeters: 100,
      isActive: false,
    ),
  ];

  // History data (static)
  final List<_HistoryEntry> _history = [
    _HistoryEntry(
      place: 'Home',
      address: '123 Oak Street, Springfield',
      timeLabel: '2 mins ago',
      durationLabel: 'Current location',
      icon: Icons.home,
      color: Colors.green,
      lat: 37.3318,
      lng: -122.0312,
    ),
    _HistoryEntry(
      place: 'Park',
      address: 'Central Park, Springfield',
      timeLabel: '2 hours ago',
      durationLabel: '45 minutes',
      icon: Icons.park,
      color: AppTheme.teal500,
      lat: 37.3333,
      lng: -122.0293,
    ),
    _HistoryEntry(
      place: 'Hospital',
      address: 'Springfield General Hospital',
      timeLabel: 'Yesterday',
      durationLabel: '2 hours',
      icon: Icons.local_hospital,
      color: Colors.red,
      lat: 37.3270,
      lng: -122.0305,
    ),
    _HistoryEntry(
      place: 'Shopping Center',
      address: 'Main Street Mall',
      timeLabel: '2 days ago',
      durationLabel: '1 hour',
      icon: Icons.shopping_bag,
      color: AppTheme.cyan500,
      lat: 37.3298,
      lng: -122.0330,
    ),
  ];

  // Distance in meters using Haversine
  double _distanceMeters(_LatLng a, _LatLng b) {
    const earthRadius = 6371000.0; // meters
    final dLat = _deg2rad(b.lat - a.lat);
    final dLng = _deg2rad(b.lng - a.lng);
    final aa = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(a.lat)) * cos(_deg2rad(b.lat)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(aa), sqrt(1 - aa));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * pi / 180.0;

  bool _isInsideZone(_SafeZone z) {
    if (!z.isActive) return false;
    final d = _distanceMeters(_patient, _LatLng(z.lat, z.lng));
    return d <= z.radiusMeters;
  }

  bool get _isInsideAnyActiveZone => _safeZones.any(_isInsideZone);

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min${d.inMinutes > 1 ? 's' : ''} ago';
    if (d.inHours < 24) return '${d.inHours} hour${d.inHours > 1 ? 's' : ''} ago';
    return '${d.inDays} day${d.inDays > 1 ? 's' : ''} ago';
  }

  void _refreshLocation() {
    // simulate small move
    final r = Random();
    final deltaLat = (r.nextDouble() - 0.5) / 5000; // tiny move
    final deltaLng = (r.nextDouble() - 0.5) / 5000;
    setState(() {
      _patient = _LatLng(_patient.lat + deltaLat, _patient.lng + deltaLng);
      _lastUpdated = DateTime.now();
    });
  }

  Future<void> _openMapsTo({required double lat, required double lng, String? label}) async {
    final String qLabel = label ?? 'Patient';
    final encodedLabel = Uri.encodeComponent(qLabel);

    // Platform-aware URLs
    final Uri appleMaps = Uri.parse('http://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel');
    final Uri androidGeo = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');
    final Uri googleWeb = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.iOS) {
      if (await canLaunchUrl(appleMaps)) {
        await launchUrl(appleMaps, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
      return;
    } else if (platform == TargetPlatform.android) {
      if (await canLaunchUrl(androidGeo)) {
        await launchUrl(androidGeo, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
      return;
    }
    // Fallback (web/others)
    await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    // Build safe-zone statuses to pass to view
    final zoneStatuses = _safeZones
        .map((z) => _SafeZoneStatus(zone: z, isInside: _isInsideZone(z)))
        .toList();

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppTheme.tealGradient,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live Tracking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _patientName,
                            style: const TextStyle(
                              color: Color(0xFFCFFAFE),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tabs
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'Live',
                          icon: Icons.location_on,
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          label: 'Safe Zones',
                          icon: Icons.shield,
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          label: 'History',
                          icon: Icons.history,
                          isSelected: _selectedTab == 2,
                          onTap: () => setState(() => _selectedTab = 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedTab == 0
                ? _LiveTrackingView(
                    isInsideAny: _isInsideAnyActiveZone,
                    statusText: _isInsideAnyActiveZone ? 'Safe Zone' : 'Outside Zone',
                    statusColor: _isInsideAnyActiveZone ? Colors.green : Colors.red,
                    address: '123 Oak Street, Springfield',
                    lastUpdatedLabel: _timeAgo(_lastUpdated),
                    onRefresh: _refreshLocation,
                    onDirections: () => _openMapsTo(
                      lat: _patient.lat,
                      lng: _patient.lng,
                      label: '$_patientName location',
                    ),
                  )
                : _selectedTab == 1
                    ? _SafeZonesView(statuses: zoneStatuses)
                    : _HistoryView(entries: _history),
          ),
        ],
      ),
    );
  }
}

// Models
class _LatLng {
  final double lat;
  final double lng;
  const _LatLng(this.lat, this.lng);
}

class _SafeZone {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double radiusMeters;
  final bool isActive;

  const _SafeZone({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    required this.isActive,
  });
}

class _SafeZoneStatus {
  final _SafeZone zone;
  final bool isInside;
  const _SafeZoneStatus({required this.zone, required this.isInside});
}

class _HistoryEntry {
  final String place;
  final String address;
  final String timeLabel;
  final String durationLabel;
  final IconData icon;
  final Color color;
  final double lat;
  final double lng;

  const _HistoryEntry({
    required this.place,
    required this.address,
    required this.timeLabel,
    required this.durationLabel,
    required this.icon,
    required this.color,
    required this.lat,
    required this.lng,
  });
}

// UI widgets
class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.teal600 : Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.teal600 : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTrackingView extends StatelessWidget {
  final bool isInsideAny;
  final String statusText;
  final Color statusColor;
  final String address;
  final String lastUpdatedLabel;
  final VoidCallback onRefresh;
  final VoidCallback onDirections;

  const _LiveTrackingView({
    required this.isInsideAny,
    required this.statusText,
    required this.statusColor,
    required this.address,
    required this.lastUpdatedLabel,
    required this.onRefresh,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map Area (illustration)
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.teal100, AppTheme.cyan100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Illustration
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Info Panel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isInsideAny ? Colors.green[100] : Colors.red[100]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: isInsideAny ? Colors.green[600] : Colors.red[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.teal900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last updated: $lastUpdatedLabel',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    color: AppTheme.teal600,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions to Patient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.teal500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SafeZonesView extends StatelessWidget {
  final List<_SafeZoneStatus> statuses;

  const _SafeZonesView({required this.statuses});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.lightGradient),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Safe Zones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.teal900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Locations where Margaret is safe',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 16),
          ...statuses.map((s) {
            final z = s.zone;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SafeZoneCard(
                name: z.name,
                address: z.address,
                radius: '${z.radiusMeters.toInt()}m',
                isActive: z.isActive,
                isInside: s.isInside,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SafeZoneCard extends StatelessWidget {
  final String name;
  final String address;
  final String radius;
  final bool isActive;
  final bool isInside;

  const _SafeZoneCard({
    required this.name,
    required this.address,
    required this.radius,
    required this.isActive,
    required this.isInside,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isInside
                    ? Colors.green.withOpacity(0.2)
                    : isActive
                        ? AppTheme.teal50
                        : AppTheme.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isInside
                    ? Icons.check_circle
                    : isActive
                        ? Icons.shield
                        : Icons.shield_outlined,
                color: isInside
                    ? Colors.green
                    : isActive
                        ? AppTheme.teal500
                        : AppTheme.gray500,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.teal900,
                          ),
                        ),
                      ),
                      if (isInside)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Inside',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Radius: $radius',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? AppTheme.teal600 : AppTheme.gray500,
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

class _HistoryView extends StatelessWidget {
  final List<_HistoryEntry> entries;

  const _HistoryView({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.lightGradient),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Location History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.teal900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Places visited recently',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 16),
          ...entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HistoryItem(
                  place: e.place,
                  address: e.address,
                  time: e.timeLabel,
                  duration: e.durationLabel,
                  icon: e.icon,
                  color: e.color,
                ),
              )),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String place;
  final String address;
  final String time;
  final String duration;
  final IconData icon;
  final Color color;

  const _HistoryItem({
    required this.place,
    required this.address,
    required this.time,
    required this.duration,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.teal900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppTheme.gray500),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.timelapse, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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