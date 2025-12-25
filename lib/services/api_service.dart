import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; // Import file config URL tadi

class ApiService {
  
  // 1. REGISTER (Sesuai field Backend: fullname, email, password, phone)
  Future<bool> register(String fullname, String email, String password, String phone) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fullname": fullname,
        "email": email,
        "password": password,
        "phone": phone,
      }),
    );

    if (response.statusCode == 201) {
      return true; // Berhasil
    } else {
      // Anda bisa print error message dari server untuk debugging
      print('Register Gagal: ${jsonDecode(response.body)['message']}');
      return false;
    }
  }

  // 2. LOGIN & SIMPAN TOKEN
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['token'];
      
      // Simpan Token ke memori HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userName', data['user']['fullname']); // Simpan nama buat profil
      
      return true;
    } else {
      return false;
    }
  }

  // 3. GET JOBS (List Lowongan)
  Future<List<dynamic>> getJobs() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/jobs'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Mengembalikan List JSON
    } else {
      throw Exception('Gagal mengambil data lowongan');
    }
  }

  // 4. CREATE JOB (Butuh Token)
  Future<bool> createJob(String title, String company, String location, String salary, String desc, String type) async {
    // Ambil token dari memori HP
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return false; // Belum login

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/jobs'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token" // PENTING: Header Auth
      },
      body: jsonEncode({
        "title": title,
        "company_name": company,
        "location": location,
        "salary": salary, // Pastikan dikirim sebagai string/int sesuai kebutuhan, di sini string aman
        "description": desc,
        "job_type": type
      }),
    );

    return response.statusCode == 201;
  }

  // 5. LOGOUT (Hapus Token)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


  // 6. GET PROFILE (Butuh Token)
  Future<Map<String, dynamic>?> getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/profile'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // 7. UPDATE PROFILE (Update Parameter)
  Future<bool> updateProfile(String fullname, String phone, String jobTitle, String bio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('${Config.baseUrl}/profile'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "fullname": fullname,
        "phone": phone,
        "job_title": jobTitle, // Kirim ke server
        "bio": bio,            // Kirim ke server
      }),
    );

    if (response.statusCode == 200) {
      await prefs.setString('userName', fullname); 
      return true;
    } else {
      return false;
    }
  }
  // --- FITUR JOB CRUD (Tambahkan di bawah updateProfile) ---

  // 8. GET MY JOBS (Lowongan Saya)
  Future<List<dynamic>> getMyJobs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/my-jobs'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  // 9. UPDATE JOB
  Future<bool> updateJob(int id, String title, String company, String location, String salary, String desc, String type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('${Config.baseUrl}/jobs/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "title": title,
        "company_name": company,
        "location": location,
        "salary": salary,
        "description": desc,
        "job_type": type
      }),
    );

    return response.statusCode == 200;
  }

  // 10. DELETE JOB
  Future<bool> deleteJob(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/jobs/$id'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    return response.statusCode == 200;
  }

  // 11. APPLY JOB
  Future<Map<String, dynamic>> applyJob(int jobId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return {'success': false, 'message': 'Belum login'};

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/apply'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "job_id": jobId,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal melamar'};
    }
  }
}