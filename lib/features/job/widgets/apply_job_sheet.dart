import 'package:flutter/material.dart';
import 'package:coba_1/services/api_service.dart';
import 'package:coba_1/shared_widgets/custom_form_field.dart';

class ApplyJobSheet extends StatefulWidget {
  final int jobId; // ID Job yang sedang dilamar

  const ApplyJobSheet({Key? key, required this.jobId}) : super(key: key);

  @override
  _ApplyJobSheetState createState() => _ApplyJobSheetState();
}

class _ApplyJobSheetState extends State<ApplyJobSheet> {
  final ApiService _apiService = ApiService();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Ambil data user agar form otomatis terisi
  void _loadUserData() async {
    final profile = await _apiService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _nameController.text = profile['fullname'] ?? "";
        _emailController.text = profile['email'] ?? "";
        _phoneController.text = profile['phone'] ?? "";
      });
    }
  }

  void _submitApplication() async {
    setState(() => _isLoading = true);

    // Panggil API Apply
    final result = await _apiService.applyJob(widget.jobId);

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        Navigator.pop(context); // Tutup sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Agar tingginya pas dengan konten
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          const Text(
            "Apply for Job",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Form Fields (Read Only disarankan jika data diambil dari profil)
          CustomFormField(hintText: "User Name", controller: _nameController),
          const SizedBox(height: 20),
          CustomFormField(hintText: "Email Address", controller: _emailController),
          const SizedBox(height: 20),
          CustomFormField(hintText: "Phone number", controller: _phoneController),
          const SizedBox(height: 30),

          // Tombol Submit
          ElevatedButton(
            onPressed: _isLoading ? null : _submitApplication,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text(
                  "SUBMIT APPLICATION",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          ),
          // Padding agar tidak terhalang gesture bar iOS/Android
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10), 
        ],
      ),
    );
  }
}