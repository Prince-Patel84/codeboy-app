import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../../main.dart'; // To access themeNotifier

class CustomNavBar extends StatelessWidget {
  final String handle;

  const CustomNavBar({super.key, required this.handle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'CODEBOY',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              _navItem("Courses", context),
              _navItem("Community", context),
              _navItem("About", context),
              const SizedBox(width: 20),
              // Dark Mode Toggle
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) {
                  final isDark = mode == ThemeMode.dark;
                  return IconButton(
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                      themeNotifier.value = newMode;
                      await prefs.setBool('is_dark_mode', newMode == ThemeMode.dark);
                    },
                  );
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(handle: handle),
                    ),
                  );
                },
                icon: const Icon(Icons.person),
                label: const Text("Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextButton(
        onPressed: () {},
        child: Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
      ),
    );
  }
}
