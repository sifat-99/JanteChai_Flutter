import 'package:flutter/material.dart';
import 'package:jante_chai/providers/theme_provider.dart';
import 'package:jante_chai/widgets/theme_option_widget.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            ThemeOptionWidget(
              title: 'Light Mode',
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
              backgroundColor: Colors.white,
              textColor: Colors.black,
              iconData: Icons.wb_sunny,
            ),
            ThemeOptionWidget(
              title: 'Dark Mode',
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
              backgroundColor: Colors.grey[850]!,
              textColor: Colors.white,
              iconData: Icons.nightlight_round,
            ),
            ThemeOptionWidget(
              title: 'System Default',
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
              backgroundColor: Colors.grey[400]!,
              textColor: Colors.black,
              iconData: Icons.settings,
            ),
          ],
        ),
      ),
    );
  }
}
