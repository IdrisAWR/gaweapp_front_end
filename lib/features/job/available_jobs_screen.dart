// lib/available_jobs_screen.dart
import 'package:flutter/material.dart';
import 'package:coba_1/features/job/widgets/apply_job_sheet.dart';
import 'package:coba_1/shared_widgets/app_drawer.dart';
import 'gallery_screen.dart'; 

class AvailableJobsScreen extends StatefulWidget {
  // 1. TERIMA DATA JOB DARI LUAR
  final Map<String, dynamic>? jobData; 

  const AvailableJobsScreen({Key? key, this.jobData}) : super(key: key);

  @override
  _AvailableJobsScreenState createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends State<AvailableJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isBookmarked = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showApplySheet(BuildContext context) {
    // Ambil ID dari data yang dikirim, jika null pakai 0 (tapi seharusnya tidak null)
    int jobId = widget.jobData?['id'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // 2. KIRIM JOB ID KE FORM APPLY
        child: ApplyJobSheet(jobId: jobId), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color titleColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final Color subtitleColor = Theme.of(context).hintColor;

    // Gunakan data dinamis jika ada, jika tidak pakai data dummy
    String jobTitle = widget.jobData?['title'] ?? "Software Engineer";
    String location = widget.jobData?['location'] ?? "Medan, Indonesia";
    String salary = widget.jobData?['salary']?.toString() ?? "500 - 1,000";

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Image.asset('assets/images/cosax.png', width: 40),
            const SizedBox(width: 10),
            Text(
              widget.jobData?['company_name'] ?? "Cosax Studios", // Dinamis
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: subtitleColor),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTag(widget.jobData?['job_type'] ?? "FULLTIME", primaryColor),
                const SizedBox(width: 10),
                _buildTag("REMOTE", primaryColor),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              jobTitle, // Dinamis
              style: TextStyle(
                color: titleColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              location, // Dinamis
              style: TextStyle(color: subtitleColor, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$$salary", // Dinamis
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Salary range (monthly)",
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // ... (Sisa kode TabBar sama persis dengan yang Anda kirim) ...
            TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: subtitleColor,
              indicatorColor: primaryColor,
              tabs: const [
                Tab(text: "Job Description"),
                Tab(text: "Our Gallery"),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400, // Beri tinggi agar TabView muncul
              child: TabBarView(
                controller: _tabController,
                children: [
                   _buildJobDescriptionTab(titleColor, subtitleColor),
                   _buildOurGalleryTab(titleColor),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, primaryColor, subtitleColor),
    );
  }

  // ... (Paste sisa widget _buildTag, _buildJobDescriptionTab, dll di sini sama persis) ...
  
  // Pastikan _buildOurGalleryTab Anda seperti ini:
  Widget _buildOurGalleryTab(Color titleColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GalleryScreen()),
        );
      },
      child: Container(
        height: 60, // Beri tinggi
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, color: titleColor),
            const SizedBox(width: 10),
            Text(
              "View Gallery",
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // Pastikan _buildBottomBar tombolnya memanggil _showApplySheet(context)
  Widget _buildBottomBar(BuildContext context, Color primaryColor, Color subtitleColor) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          // ... (Tombol Bookmark biarkan sama) ...
          GestureDetector(
             onTap: () => setState(() => _isBookmarked = !_isBookmarked),
             child: Container(
               width: 60, height: 60,
               decoration: BoxDecoration(
                 color: Theme.of(context).cardColor,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey.shade300),
               ),
               child: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _isBookmarked ? Colors.yellow[800] : Colors.grey, size: 30),
             ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showApplySheet(context); // PANGGIL SHEET DI SINI
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("APPLY JOB", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Widget _buildRequirementRow, _buildTag, _buildJobDescriptionTab paste saja) ...
   Widget _buildTag(String text, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildJobDescriptionTab(Color titleColor, Color subtitleColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lorem ipsum dolor sit amet...", style: TextStyle(color: subtitleColor, fontSize: 15, height: 1.5)),
          const SizedBox(height: 20),
          Text("Requirements", style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildRequirementRow("Sed ut perspiciatis unde omnis", subtitleColor),
          _buildRequirementRow("Doloremque laudantium", subtitleColor),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 15, height: 1.4))),
        ],
      ),
    );
  }
}