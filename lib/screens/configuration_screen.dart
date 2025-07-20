import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../widgets/aquaforge_header.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  String? _selectedDevice;
  // Theme selection state
  AppThemeMode? _themeMode;
  Color? _primaryColor;
  Color? _accentColor;

  @override
  void initState() {
    super.initState();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _themeMode = themeProvider.mode;
    _primaryColor = themeProvider.primaryColor;
    _accentColor = themeProvider.accentColor;
  }

  void _showDeviceDialog() async {
    final device = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Select Device Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.shield),
                title: const Text('Pond Guard'),
                onTap: () => Navigator.pop(context, 'Pond Guard'),
              ),
              ListTile(
                leading: const Icon(Icons.power),
                title: const Text('Power Master'),
                onTap: () => Navigator.pop(context, 'Power Master'),
              ),
              ListTile(
                leading: const Icon(Icons.remove_red_eye),
                title: const Text('Shrimp Watcher'),
                onTap: () => Navigator.pop(context, 'Shrimp Watcher'),
              ),
              ListTile(
                leading: const Icon(Icons.opacity),
                title: const Text('Volumizer'),
                onTap: () => Navigator.pop(context, 'Volumizer'),
              ),
              ListTile(
                leading: const Icon(Icons.flight),
                title: const Text('Bird catcher'),
                onTap: () => Navigator.pop(context, 'Bird catcher'),
              ),
            ],
          ),
        );
      },
    );
    if (device != null) {
      setState(() {
        _selectedDevice = device;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected: $device')),
      );
    }
  }

  void _showColorPicker({required bool isPrimary}) async {
    Color initialColor = isPrimary ? _primaryColor! : _accentColor!;
    Color picked = initialColor;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick ${isPrimary ? 'Primary' : 'Accent'} Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: initialColor,
              onColorChanged: (color) => picked = color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isPrimary) {
                    _primaryColor = picked;
                  } else {
                    _accentColor = picked;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
    if (_themeMode == AppThemeMode.custom) {
      Provider.of<ThemeProvider>(context, listen: false)
          .setCustomColors(_primaryColor!, _accentColor!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const AquaForgeHeader(),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: true, // Show back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Device Selection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.devices),
                title: Text(_selectedDevice == null ? 'Select Device' : _selectedDevice!),
                subtitle: const Text('Choose a device to configure'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showDeviceDialog,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Device Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                subtitle: const Text('Configure device parameters'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {}, // TODO: Implement device settings
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Device Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Information'),
                subtitle: const Text('View device details'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {}, // TODO: Implement device information
              ),
            ),
            const SizedBox(height: 24),
            const Text('Theme', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  RadioListTile<AppThemeMode>(
                    title: const Text('Light'),
                    value: AppThemeMode.light,
                    groupValue: themeProvider.mode,
                    onChanged: (val) {
                      themeProvider.setThemeMode(AppThemeMode.light);
                      setState(() => _themeMode = AppThemeMode.light);
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: const Text('Dark'),
                    value: AppThemeMode.dark,
                    groupValue: themeProvider.mode,
                    onChanged: (val) {
                      themeProvider.setThemeMode(AppThemeMode.dark);
                      setState(() => _themeMode = AppThemeMode.dark);
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: const Text('Custom'),
                    value: AppThemeMode.custom,
                    groupValue: themeProvider.mode,
                    onChanged: (val) {
                      themeProvider.setThemeMode(AppThemeMode.custom);
                      setState(() => _themeMode = AppThemeMode.custom);
                    },
                  ),
                  if (themeProvider.mode == AppThemeMode.custom)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          const Text('Primary:'),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _showColorPicker(isPrimary: true),
                            child: CircleAvatar(backgroundColor: _primaryColor, radius: 16),
                          ),
                          const SizedBox(width: 30),
                          const Text('Accent:'),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _showColorPicker(isPrimary: false),
                            child: CircleAvatar(backgroundColor: _accentColor, radius: 16),
                          ),
                        ],
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
