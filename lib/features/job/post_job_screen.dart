import 'package:flutter/material.dart';
import 'package:coba_1/services/api_service.dart';
import 'package:coba_1/shared_widgets/custom_form_field.dart';

class PostJobScreen extends StatefulWidget {
  // Jika jobData NULL = Create Mode, Jika ADA = Edit Mode
  final Map<String, dynamic>? jobData;

  const PostJobScreen({Key? key, this.jobData}) : super(key: key);

  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final ApiService _apiService = ApiService();
  
  // Controllers
  late TextEditingController _titleCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _descCtrl;
  
  String _jobType = "Full Time"; 
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.jobData != null; // Cek mode

    // Isi form jika edit, kosongkan jika baru
    _titleCtrl = TextEditingController(text: widget.jobData?['title'] ?? "");
    _companyCtrl = TextEditingController(text: widget.jobData?['company_name'] ?? "");
    _locationCtrl = TextEditingController(text: widget.jobData?['location'] ?? "");
    _salaryCtrl = TextEditingController(text: widget.jobData?['salary']?.toString() ?? "");
    _descCtrl = TextEditingController(text: widget.jobData?['description'] ?? "");
    _jobType = widget.jobData?['job_type'] ?? "Full Time";
  }

  void _handleSubmit() async {
    if (_titleCtrl.text.isEmpty || _companyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Judul & Perusahaan wajib diisi")));
      return;
    }

    setState(() => _isLoading = true);
    bool success;

    if (_isEditMode) {
      // LOGIKA UPDATE
      success = await _apiService.updateJob(
        widget.jobData!['id'],
        _titleCtrl.text,
        _companyCtrl.text,
        _locationCtrl.text,
        _salaryCtrl.text,
        _descCtrl.text,
        _jobType
      );
    } else {
      // LOGIKA CREATE
      success = await _apiService.createJob(
        _titleCtrl.text,
        _companyCtrl.text,
        _locationCtrl.text,
        _salaryCtrl.text,
        _descCtrl.text,
        _jobType
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditMode ? "Job Updated!" : "Job Posted!")));
      Navigator.pop(context); // Kembali ke list
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Edit Job" : "Post New Job", style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black), // Tombol Back warna hitam
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomFormField(hintText: "Job Title (e.g. Flutter Dev)", controller: _titleCtrl),
            const SizedBox(height: 16),
            CustomFormField(hintText: "Company Name", controller: _companyCtrl),
            const SizedBox(height: 16),
            CustomFormField(hintText: "Location", controller: _locationCtrl),
            const SizedBox(height: 16),
            CustomFormField(hintText: "Salary (e.g. 5000000)", controller: _salaryCtrl),
            const SizedBox(height: 16),
            
            // Dropdown Tipe Pekerjaan
            DropdownButtonFormField<String>(
              value: _jobType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ["Full Time", "Part Time", "Freelance"]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (val) => setState(() => _jobType = val!),
            ),
            const SizedBox(height: 16),

            // Deskripsi Area
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Job Description...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isEditMode ? "UPDATE NOW" : "POST NOW", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}