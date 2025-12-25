// lib/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:coba_1/features/home/home_screen.dart';
import 'package:coba_1/features/job/recent_job_screen.dart';
import 'package:coba_1/features/auth/pilih_peran_screen.dart'; 
import 'package:coba_1/features/job/find_job_screen.dart';
import 'package:coba_1/features/notifications/notifications_screen.dart';
import 'package:coba_1/features/profile/profile_screen.dart';
import 'package:coba_1/features/messages/messages_screen.dart';
import 'package:coba_1/features/settings/elements_screen.dart';
import 'package:coba_1/features/settings/setting_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil warna dari tema yang aktif
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color titleColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color subtitleColor = Theme.of(context).hintColor;
    final Color backgroundColor = Theme.of(context).drawerTheme.backgroundColor ?? Theme.of(context).cardColor;
    
    final Color logoColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : primaryColor;

    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header Drawer (tetap sama)
          SizedBox(
            height: 140,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: backgroundColor,
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/logo-icon.png', width: 40),
                  const SizedBox(width: 15),
                  Text(
                    'Gawee',
                    style: TextStyle(
                      color: logoColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: titleColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
          
          // Daftar Menu (tetap sama)
          _buildDrawerItem(
            icon: Icons.home_rounded,
            text: 'Home',
            color: primaryColor,
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.history_rounded,
            text: 'Recent Job',
            color: subtitleColor,
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecentJobScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.search_rounded,
            text: 'Find Job',
            color: subtitleColor,
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FindJobScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications_rounded,
            text: 'Notifications (2)',
            color: subtitleColor,
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.person_rounded,
            text: 'Profile',
            color: subtitleColor,
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.message_rounded,
            text: 'Message',
            color: subtitleColor,
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessagesScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.layers_rounded,
            text: 'Elements',
            color: subtitleColor,
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ElementsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_rounded,
            text: 'Setting',
            color: subtitleColor,
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),

          _buildDrawerItem(
            icon: Icons.logout_rounded,
            text: 'Logout',
            color: subtitleColor,
            onTap: () {
              // Hapus semua halaman dan kembali ke PilihPeranScreen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const PilihPeranScreen(),
                ),
                (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
              );
            },
          ),
          // --- BATAS PERUBAHAN ---
          
          // Footer Drawer (tetap sama)
          const SizedBox(height: 80),
          Center(
            child: Text(
              'Gawee Job Portal',
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              'App Version 1.3',
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget helper (tetap sama)
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}