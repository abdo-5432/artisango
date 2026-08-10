import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'client';
  bool _loading = false;
  bool _obscure = true;

  void _register() async {
    if (_name.text.isEmpty || _email.text.isEmpty || _pass.text.isEmpty) {
      _showSnack('fill_fields'.tr(), red: true);
      return;
    }
    setState(() => _loading = true);
    final error =
        await Provider.of<AuthService>(context, listen: false).register(
      _email.text.trim(),
      _pass.text.trim(),
      _name.text.trim(),
      _role,
      phoneNumber: _phone.text.trim(),
    );
    setState(() => _loading = false);
    if (error != null) {
      _showSnack(error, red: true);
    } else {
      _showSnack('Account created! Please login.', red: false);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    }
  }

  void _showSnack(String msg, {bool red = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: red ? Colors.red : const Color(0xFF6C63FF),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('create_account'.tr(),
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('join_today'.tr(),
                  style: GoogleFonts.poppins(color: Colors.grey)),
              const SizedBox(height: 32),
              _buildTextField(_name, 'full_name'.tr(), Icons.person_outlined),
              const SizedBox(height: 16),
              _buildTextField(_email, 'email'.tr(), Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(_pass, 'password'.tr(), Icons.lock_outlined,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),
              const SizedBox(height: 16),
              _buildTextField(_phone, 'phone_number'.tr(), Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 24),
              Text('i_am'.tr(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                _roleCard('client', 'client'.tr(), Icons.search),
                const SizedBox(width: 16),
                _roleCard('artisan', 'artisan'.tr(), Icons.handyman),
              ]),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('create_account'.tr(),
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('already_account'.tr(),
                      style: GoogleFonts.poppins(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('login'.tr(),
                        style: GoogleFonts.poppins(
                            color: const Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon,
      {bool obscure = false,
      Widget? suffix,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _roleCard(String value, String title, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF6C63FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6C63FF)),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected ? Colors.white : const Color(0xFF6C63FF)),
              const SizedBox(height: 8),
              Text(title,
                  style: GoogleFonts.poppins(
                    color: selected ? Colors.white : const Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
