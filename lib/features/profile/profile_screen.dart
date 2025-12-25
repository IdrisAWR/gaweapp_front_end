// lib/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:coba_1/shared_widgets/app_drawer.dart';
import 'package:coba_1/services/api_service.dart'; // Import API Service
import 'package:coba_1/features/job/my_jobs_screen.dart'; // Import MyJobsScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  
  // Status Loading
  bool _isLoading = true;

  // Variabel Data User (Default kosong)
  String _fullname = "";
  String _jobTitle = "";
  String _bio = "";
  String _phone = ""; // Disimpan untuk kebutuhan edit, meski tidak ditampilkan di UI utama

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // 1. FUNGSI AMBIL DATA (READ)
  void _fetchProfileData() async {
    final data = await _apiService.getProfile();
    if (data != null) {
      if (mounted) {
        setState(() {
          _fullname = data['fullname'] ?? "No Name";
          _jobTitle = data['job_title'] ?? "Job Seeker";
          _bio = data['bio'] ?? "No bio available.";
          _phone = data['phone'] ?? "";
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. FUNGSI TAMPILKAN POPUP EDIT (UPDATE)
  void _showEditDialog() {
    // Siapkan controller dengan teks yang sudah ada
    final TextEditingController nameCtrl = TextEditingController(text: _fullname);
    final TextEditingController jobCtrl = TextEditingController(text: _jobTitle);
    final TextEditingController bioCtrl = TextEditingController(text: _bio);
    final TextEditingController phoneCtrl = TextEditingController(text: _phone);
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Butuh ini agar loading di dalam dialog jalan
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Edit Profile"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Full Name")),
                    TextField(controller: jobCtrl, decoration: const InputDecoration(labelText: "Job Title (e.g Engineer)")),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number"), keyboardType: TextInputType.phone),
                    TextField(controller: bioCtrl, decoration: const InputDecoration(labelText: "Bio"), maxLines: 3),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: isUpdating ? null : () async {
                    setStateDialog(() => isUpdating = true);
                    
                    // Panggil API Update
                    bool success = await _apiService.updateProfile(
                      nameCtrl.text,
                      phoneCtrl.text,
                      jobCtrl.text,
                      bioCtrl.text
                    );

                    setStateDialog(() => isUpdating = false);

                    if (success) {
                      Navigator.pop(context); // Tutup Dialog
                      _fetchProfileData();    // Refresh Tampilan UI
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update")));
                    }
                  },
                  child: isUpdating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Text("Save"),
                )
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color titleColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final Color subtitleColor = Theme.of(context).hintColor;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Profile",
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          // TOMBOL EDIT (BARU)
          IconButton(
            icon: Icon(Icons.edit, color: primaryColor),
            tooltip: "Edit Profile",
            onPressed: _showEditDialog, // Panggil fungsi edit
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: subtitleColor),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          // Di dalam Actions AppBar atau di Body ProfileScreen
          IconButton(
            icon: const Icon(Icons.business_center_outlined, color: Colors.blue),
            tooltip: "Manage Jobs",
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const MyJobsScreen()) // Jangan lupa import my_jobs_screen.dart
              );
            },
          ),
        ],
      ),
      // Tampilkan Loading jika data belum siap
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Foto Profil ---
                const CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('assets/images/user1.jpg'), // Pastikan aset ini ada
                ),
                const SizedBox(height: 15),

                // --- Nama (Dinamis) ---
                Text(
                  _fullname, // Variabel
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                
                // --- Job Title (Dinamis) ---
                Text(
                  _jobTitle, // Variabel
                  style: TextStyle(color: subtitleColor, fontSize: 16),
                ),
                const SizedBox(height: 20),

                // --- Bio (Dinamis) ---
                Text(
                  _bio, // Variabel
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtitleColor, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 30),

                // --- Tombol My Resume ---
                _buildResumeButton(context, primaryColor),
                const SizedBox(height: 30),

                // --- Judul Skills ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Skills",
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Daftar Skills (Masih Statis untuk kemudahan) ---
                _buildSkillBar(context, "Problem Solving", 70),
                _buildSkillBar(context, "Drawing", 35),
                _buildSkillBar(context, "Illustration", 80),
                _buildSkillBar(context, "Photoshop", 34),
              ],
            ),
          ),
    );
  }

  // Widget helper untuk tombol resume
  Widget _buildResumeButton(BuildContext context, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        // Logika buka resume nanti
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Resume",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  "david_resume.pdf", // Bisa dibuat dinamis juga nanti
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
            const Icon(Icons.file_upload_outlined, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk satu skill bar
  Widget _buildSkillBar(BuildContext context, String skillName, int percentage) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color titleColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skillName,
                style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                "$percentage%",
                style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}