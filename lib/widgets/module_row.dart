import 'package:flutter/material.dart';

class ModuleRow extends StatelessWidget {
  final void Function(String module)? onModuleTap;
  final String selectedModule;

  const ModuleRow({super.key, this.onModuleTap, required this.selectedModule});

  @override
  Widget build(BuildContext context) {
    final modules = [
      'Configuration',
      'Reports',
      'Dashboards',
      'Pond Health',
      'AI Analysis',
      'Alerts',
      'Location', // Added Location module
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: modules.map((module) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Semantics(
            label: 'Module: $module',
            button: true,
            child: Tooltip(
              message: 'Go to $module',
              child: ElevatedButton(
                onPressed: () {
                  if (onModuleTap != null) {
                    onModuleTap!(module);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedModule == module ? Theme.of(context).primaryColor : null,
                ),
                child: Text(
                  module,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: selectedModule == module ? Colors.white : null,
                  ),
                ),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}
