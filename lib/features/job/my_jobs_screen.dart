import 'package:flutter/material.dart';
import 'package:coba_1/services/api_service.dart';
import 'package:coba_1/features/job/post_job_screen.dart'; 
import 'package:coba_1/shared_widgets/app_drawer.dart'; // IMPORT DRAWER

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({Key? key}) : super(key: key);

  @override
  _MyJobsScreenState createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  // Key untuk membuka drawer secara manual jika tombol custom ditekan
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final ApiService _apiService = ApiService();
  List<dynamic> _myJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyJobs();
  }

  // READ: Ambil data dari API
  void _fetchMyJobs() async {
    final jobs = await _apiService.getMyJobs();
    if (mounted) {
      setState(() {
        _myJobs = jobs;
        _isLoading = false;
      });
    }
  }

  // DELETE: Hapus job
  void _deleteJob(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Lowongan"),
        content: const Text("Yakin ingin menghapus lowongan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() => _isLoading = true);
      bool success = await _apiService.deleteJob(id);
      
      if (success) {
        _fetchMyJobs(); // Refresh list setelah hapus
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Pasang Key
      drawer: const AppDrawer(), // Pasang Drawer di sini
      appBar: AppBar(
        title: const Text("My Posted Jobs", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          // Tombol opsi untuk buka Drawer (mirip ProfileScreen)
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer(); // Buka Drawer
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Navigasi ke Form Tambah (Create)
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const PostJobScreen()));
          _fetchMyJobs(); // Refresh saat kembali
        },
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
        : _myJobs.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Belum ada lowongan.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _myJobs.length,
              itemBuilder: (context, index) {
                final job = _myJobs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.business_center, color: Theme.of(context).primaryColor),
                    ),
                    title: Text(job['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(job['company_name']),
                        const SizedBox(height: 2),
                        Text("\$${job['salary'] ?? '-'}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blueGrey),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          // Navigasi ke Form Edit (Update)
                          await Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => PostJobScreen(jobData: job))
                          );
                          _fetchMyJobs();
                        } else if (value == 'delete') {
                          _deleteJob(job['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Edit")])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}