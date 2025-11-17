import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF42A5F5), // Light Blue
    scaffoldBackgroundColor: const Color(0xFFF0F4F8), // Very Light Gray/Blue
    appBarTheme: const AppBarTheme(
      color: Color(0xFF42A5F5),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    // Line 18 in your screenshot shows CardTheme: CardTheme(...) which is wrong.
// It should be CardThemeData: CardThemeData(...)

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF42A5F5),
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
// ...
    useMaterial3: true,
  );
}

// --- MODEL ---

final uuid = Uuid();

/// Data structure for a single smart home device[cite: 7].
class Device {
  final String id;
  String name; // e.g., “Living Room Light” [cite: 9]
  String type; // e.g., 'Light', 'Fan', 'AC', 'Camera' [cite: 3, 8]
  String room;
  bool isOn; // Status (ON/OFF) [cite: 10]
  double controlValue; // Brightness/speed (0.0 to 1.0) [cite: 16]

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    this.isOn = false,
    this.controlValue = 0.5,
  });

  /// Provides the appropriate icon for the device type[cite: 8].
  IconData get icon {
    switch (type) {
      case 'Light':
        return Icons.lightbulb_outline;
      case 'Fan':
        return Icons.mode_fan_off;
      case 'AC':
        return Icons.air;
      case 'Camera':
        return Icons.videocam_outlined;
      default:
        return Icons.device_hub_outlined;
    }
  }

  /// Provides the current status text[cite: 11].
  String get statusText {
    if (isOn) {
      if (type == 'Light' || type == 'Fan') {
        return '$type is ON (${(controlValue * 100).toInt()}%)';
      }
      return '$type is ON'; // e.g., “Light is ON” [cite: 11]
    } else {
      return '$type is OFF'; // e.g., “Light is OFF” [cite: 11]
    }
  }
}

// --- WIDGETS ---

/// Widget for displaying a single device on the dashboard[cite: 7].
class DeviceCard extends StatefulWidget {
  final Device device;
  final Function(bool) onToggle;
  final VoidCallback onTap;

  const DeviceCard({
    required this.device,
    required this.onToggle,
    required this.onTap,
    super.key,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  // Local state for the visual response when tapped [cite: 26]
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell( // Implements InkWell for visual feedback [cite: 26]
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) => setState(() => _isTapped = false),
        onTapCancel: () => setState(() => _isTapped = false),
        onTap: widget.onTap, // Navigates to details screen [cite: 13]
        borderRadius: BorderRadius.circular(15.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // Slight visual scale on tap [cite: 26]
          transform: Matrix4.identity()..scale(_isTapped ? 0.98 : 1.0),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Device Icon [cite: 8]
              Icon(
                widget.device.icon,
                size: 36.0,
                color: widget.device.isOn
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              // Device Name [cite: 9]
              Text(
                widget.device.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Status Text [cite: 11]
              Text(
                widget.device.statusText,
                style: TextStyle(
                  color: widget.device.isOn ? Theme.of(context).primaryColor : Colors.grey[600],
                  fontWeight: widget.device.isOn ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8.0),
              // Toggle Switch [cite: 10]
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Power'),
                  Switch(
                    value: widget.device.isOn,
                    onChanged: widget.onToggle, // Updates state [cite: 25]
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding a new device when the FAB is pressed[cite: 18, 19].
class AddDeviceDialog extends StatefulWidget {
  final Function(String, String, String) onSave;

  const AddDeviceDialog({required this.onSave, super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _nameController = TextEditingController(); // Device name [cite: 20]
  final _roomController = TextEditingController(); // Room name [cite: 22]
  String? _selectedType; // Device type [cite: 21]

  final List<String> _deviceTypes = ['Light', 'Fan', 'AC', 'Camera'];

  void _save() {
    if (_nameController.text.isEmpty || _roomController.text.isEmpty || _selectedType == null) {
      // Basic validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }
    // New device is added with status OFF by default [cite: 23]
    widget.onSave(_nameController.text, _selectedType!, _roomController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Device'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            // Device Name Input [cite: 20]
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Device Name'),
            ),
            const SizedBox(height: 15),
            // Room Name Input [cite: 22]
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Room Name'),
            ),
            const SizedBox(height: 15),
            // Device Type Dropdown [cite: 21]
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Device Type'),
              value: _selectedType,
              items: _deviceTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
        TextButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}

/// The details screen shown after tapping a device card[cite: 13].
class DeviceDetailsScreen extends StatefulWidget {
  final Device device;
  final Function(Device) onUpdate; // Callback to update state on main dashboard

  const DeviceDetailsScreen({
    required this.device,
    required this.onUpdate,
    super.key,
  });

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  // Local state to manage slider interaction [cite: 25]
  late Device _localDevice;

  @override
  void initState() {
    super.initState();
    _localDevice = widget.device;
  }

  void _handleSliderChange(double newValue) {
    setState(() {
      _localDevice.controlValue = newValue;
    });
    // Update state on the main dashboard [cite: 25]
    widget.onUpdate(_localDevice);
  }

  @override
  Widget build(BuildContext context) {
    bool isControllable = _localDevice.type == 'Light' || _localDevice.type == 'Fan';
    String controlLabel = _localDevice.type == 'Light' ? 'Brightness' : 'Speed';

    return Scaffold(
      appBar: AppBar(
        title: Text('${_localDevice.name} Details'),
        leading: BackButton(onPressed: () => Navigator.pop(context)), // Back button [cite: 17]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Larger device icon/image [cite: 14]
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: _localDevice.isOn ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _localDevice.icon,
                size: 100,
                color: _localDevice.isOn ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Current status [cite: 15]
            Text(_localDevice.statusText, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 40),

            if (isControllable)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controlLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  // Slider to control brightness/speed [cite: 16]
                  Slider.adaptive(
                    value: _localDevice.controlValue,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_localDevice.controlValue * 100).toInt()}%',
                    onChanged: _localDevice.isOn ? _handleSliderChange : null, // Only adjustable if ON
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Power control toggle
            SwitchListTile(
              title: const Text('Device Power'),
              value: _localDevice.isOn,
              onChanged: (bool newValue) {
                setState(() {
                  _localDevice.isOn = newValue;
                  // If turned OFF, reset control value
                  if (!newValue && isControllable) {
                    _localDevice.controlValue = 0.0;
                  }
                });
                widget.onUpdate(_localDevice); // Update main dashboard state
              },
            ),
          ],
        ),
      ),
    );
  }
}


// --- SCREENS ---

/// Main screen of the application - Stateful to manage device list[cite: 6, 25].
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Initial list of devices
  final List<Device> _devices = [
    Device(id: uuid.v4(), name: 'Living Room Light', type: 'Light', room: 'Living Room', isOn: true, controlValue: 0.8),
    Device(id: uuid.v4(), name: 'Bedroom Fan', type: 'Fan', room: 'Bedroom', isOn: false, controlValue: 0.0),
    Device(id: uuid.v4(), name: 'Kitchen AC', type: 'AC', room: 'Kitchen', isOn: true),
    Device(id: uuid.v4(), name: 'Front Door Cam', type: 'Camera', room: 'Outside', isOn: true),
  ];

  /// Function to handle adding a new device dynamically[cite: 24].
  void _addNewDevice(String name, String type, String room) {
    final newDevice = Device(
      id: uuid.v4(),
      name: name,
      type: type,
      room: room,
      isOn: false, // Default OFF [cite: 23]
    );

    setState(() {
      _devices.add(newDevice); // Update the main screen dynamically [cite: 24]
    });
  }

  /// Function to update device state from any source (Card Toggle or Details Screen)[cite: 25].
  void _updateDeviceStatus(Device updatedDevice, {bool? toggleValue}) {
    final index = _devices.indexWhere((d) => d.id == updatedDevice.id);
    if (index != -1) {
      setState(() {
        if (toggleValue != null) {
          // Update the isOn state from the toggle switch [cite: 10]
          _devices[index].isOn = toggleValue;
        } else {
          // Update the entire device (used by details screen for slider/status) [cite: 15, 16]
          _devices[index] = updatedDevice;
        }
      });
    }
  }

  /// Shows the dialog to add a new device[cite: 19].
  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddDeviceDialog(onSave: _addNewDevice),
    );
  }

  /// Navigates to the details screen[cite: 13].
  void _navigateToDetails(Device device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailsScreen(
          device: device,
          onUpdate: (updatedDevice) => _updateDeviceStatus(updatedDevice),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsiveness using MediaQuery [cite: 28]
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate cross-axis count based on screen size (responsive layout) [cite: 27, 28]
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home Dashboard'), // AppBar Title [cite: 12]
        leading: IconButton(
          icon: const Icon(Icons.menu), // Menu Icon [cite: 12]
          onPressed: () {},
        ),
        actions: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person), // Profile Picture Icon [cite: 12]
            ),
          ),
        ],
      ),
      // Device arrangement using GridView [cite: 6]
      body: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return DeviceCard(
                  device: device,
                  onToggle: (bool newValue) => _updateDeviceStatus(device, toggleValue: newValue),
                  onTap: () => _navigateToDetails(device),
                );
              },
            ),
      // Floating Action Button to add a new device [cite: 18]
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        tooltip: 'Add Device',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- MAIN FUNCTION ---

void main() {
  runApp(const SmartHomeApp());
}

/// The main entry widget for the application.
class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Dashboard',
      theme: AppTheme.lightTheme, // Apply custom theming [cite: 29]
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}