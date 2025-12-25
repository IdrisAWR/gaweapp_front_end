import 'package:flutter/material.dart';
import 'package:coba_1/shared_widgets/custom_form_field.dart';
import 'forgot_password_screen.dart';
import 'package:coba_1/services/api_service.dart';

// UBAH JADI STATEFUL WIDGET
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final ApiService _apiService = ApiService();
  
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Tambahan

  bool _isLoading = false;

  void _handleRegister() async {
    // Validasi sederhana
    if (_emailController.text.isEmpty || 
        _nameController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Semua kolom harus diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _apiService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _phoneController.text.isEmpty ? "-" : _phoneController.text, // Default dash jika kosong
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Kembali ke halaman Login
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Gagal. Email mungkin sudah dipakai."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color(0xFFF9F7FF);
    Color primaryColor = const Color(0xFF9634FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/gawee.png', width: 200),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Create an account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 30),

                // Form Fields dengan Controller
                CustomFormField(
                  hintText: "Full Name",
                  controller: _nameController,
                ),
                const SizedBox(height: 20),
                CustomFormField(
                  hintText: "Email Address",
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                // Tambahan Field Phone
                CustomFormField(
                  hintText: "Phone Number",
                  controller: _phoneController,
                  // keyboardType: TextInputType.phone, // Jika CustomFormField support ini
                ),
                const SizedBox(height: 20),
                CustomFormField(
                  hintText: "Password",
                  obscureText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 30),

                // Tombol Submit
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: primaryColor))
                    : ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("SUBMIT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                
                const SizedBox(height: 20),
                // ... Sisa kode (Forgot Password, Sign In Link) ...
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                      children: [
                        const TextSpan(text: "Forgot your password? "),
                        TextSpan(
                          text: "Reset here",
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Center(child: Text("Already have an account", style: TextStyle(color: Colors.grey.shade600, fontSize: 15))),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: primaryColor, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("SIGN IN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}