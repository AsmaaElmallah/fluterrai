import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DoctorTrackingScreen extends StatefulWidget {
  const DoctorTrackingScreen({super.key});

  @override
  State<DoctorTrackingScreen> createState() => _DoctorTrackingScreenState();
}

class _DoctorTrackingScreenState extends State<DoctorTrackingScreen> {
  String selectedPatient = 'Margaret Smith';
  
  final List<Map<String, dynamic>> patients = [
    {
      'name': 'Margaret Smith',
      'status': 'safe',
      'location': 'At Home',
      'lastUpdate': '2 mins ago',
    },
    {
      'name': 'John Davis',
      'status': 'safe',
      'location': 'Park',
      'lastUpdate': '5 mins ago',
    },
    {
      'name': 'Mary Taylor',
      'status': 'alert',
      'location': 'Outside Safe Zone',
      'lastUpdate': 'Just now',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentPatient = patients.firstWhere(
      (p) => p['name'] == selectedPatient,
      orElse: () => patients[0],
    );
    
    return SafeArea(
      child: Column(
        children: [
          // Header with Patient Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppTheme.tealGradient,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Live Tracking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
                
                // Patient Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedPatient,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: AppTheme.teal600,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: patients.map((patient) {
                      return DropdownMenuItem<String>(
                        value: patient['name'],
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: patient['status'] == 'safe'
                                    ? Colors.green
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(patient['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedPatient = value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Map Area
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
                  // Map illustration
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Safe zone indicator
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: currentPatient['status'] == 'safe'
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              width: 3,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: currentPatient['status'] == 'safe'
                                    ? Colors.green
                                    : Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: currentPatient['status'] == 'safe'
                                        ? Colors.green
                                        : Colors.red,
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: currentPatient['status'] == 'safe'
                            ? Colors.green
                            : Colors.red,
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
                            currentPatient['status'] == 'safe'
                                ? 'Safe Zone'
                                : 'Alert',
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
                // Current Location
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.teal50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.teal600,
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
                            currentPatient['location'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last updated: ${currentPatient['lastUpdate']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh),
                      color: AppTheme.teal600,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.directions),
                        label: const Text('Get Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.teal500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history),
                        label: const Text('History'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyan500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Safe Zone Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showSafeZoneDialog(context);
                    },
                    icon: const Icon(Icons.edit_location),
                    label: const Text('Edit Safe Zones'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.teal600,
                      side: const BorderSide(color: AppTheme.teal500),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSafeZoneDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Safe Zones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.teal900,
              ),
            ),
            const SizedBox(height: 16),
            _SafeZoneItem(
              name: 'Home',
              address: '123 Oak Street, Springfield',
              radius: '200m',
              isActive: true,
            ),
            const SizedBox(height: 12),
            _SafeZoneItem(
              name: 'Park',
              address: 'Central Park, Springfield',
              radius: '150m',
              isActive: true,
            ),
            const SizedBox(height: 12),
            _SafeZoneItem(
              name: 'Hospital',
              address: 'Springfield General Hospital',
              radius: '100m',
              isActive: false,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add New Safe Zone'),
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
    );
  }
}

class _SafeZoneItem extends StatelessWidget {
  final String name;
  final String address;
  final String radius;
  final bool isActive;

  const _SafeZoneItem({
    required this.name,
    required this.address,
    required this.radius,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.teal50 : AppTheme.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.teal500 : AppTheme.gray500,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isActive ? Icons.check_circle : Icons.location_off,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.teal900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Radius: $radius',
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? AppTheme.teal600 : AppTheme.gray500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {},
            activeColor: AppTheme.teal500,
          ),
        ],
      ),
    );
  }
}
