import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../main.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController(text: '30000');
  UserRole _selectedRole = UserRole.staff;
  bool _isLoading = false;

  void _handleSignup() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty || _salaryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _selectedRole == UserRole.admin ? 'admin' : 'staff',
      double.tryParse(_salaryController.text) ?? 30000.0,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully!'), backgroundColor: AppColors.green),
      );
      Navigator.pop(context); 
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.brand, AppColors.brandD],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Member',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create an account for your staff or administrators.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _InputField(hint: 'Full Name', icon: Icons.person_outline, controller: _nameController),
                  const SizedBox(height: 12),
                  _InputField(hint: 'Email Address', icon: Icons.email_outlined, controller: _emailController),
                  const SizedBox(height: 12),
                  _InputField(hint: 'Password', icon: Icons.lock_outline, isPassword: true, controller: _passwordController),
                  const SizedBox(height: 12),
                  _InputField(hint: 'Basic Salary', icon: Icons.payments_outlined, controller: _salaryController, keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  
                  // Role Selection
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Register as:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink2)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _RoleChip(
                        label: 'Staff',
                        isSelected: _selectedRole == UserRole.staff,
                        onTap: () => setState(() => _selectedRole = UserRole.staff),
                      ),
                      const SizedBox(width: 12),
                      _RoleChip(
                        label: 'Admin',
                        isSelected: _selectedRole == UserRole.admin,
                        onTap: () => setState(() => _selectedRole = UserRole.admin),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputField({
    required this.hint,
    required this.icon,
    this.isPassword = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppColors.line)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(border: InputBorder.none, icon: Icon(icon, color: AppColors.muted, size: 20), hintText: hint),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _RoleChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandSoft : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.brand : AppColors.line),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? AppColors.brandD : AppColors.ink2, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
