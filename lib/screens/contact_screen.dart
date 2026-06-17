import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ContactScreen extends StatefulWidget {
  final String? productName;
  const ContactScreen({super.key, this.productName});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  // Design tokens — exact match to web CSS variables
  static const Color primary = Color(0xFF008080);
  static const Color textMain = Color(0xFF1e293b);
  static const Color textMuted = Color(0xFF64748b);
  static const Color border = Color(0xFFe2e8f0);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // web: Pre-fill message from product query param
    if (widget.productName != null) {
      _messageController.text = 'I am interested in ${widget.productName}. Please provide more details.';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final success = await ApiService.sendEnquiry({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
      });
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // web: toast.success('Thank you for reaching out...')
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Thank you for reaching out. We will get back to you soon!')),
              ],
            ),
            backgroundColor: const Color(0xFF16a34a),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        // Clear form — web: setFormData({ name: '', email: '', message: '' })
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        // Pop back if opened from product details
        if (widget.productName != null) Navigator.pop(context);
      } else {
        _showErrorSnack('Failed to send message. Please try again.');
      }
    } catch (_) {
      _showErrorSnack('Failed to send message. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFdc2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // web: bg-white
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page header — web: text-center mb-16 h1 text-4xl
              const SizedBox(height: 8),
              const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Have questions? We're here to help.",
                style: TextStyle(fontSize: 15, color: textMuted),
              ),
              const SizedBox(height: 32),

              // Left column: Contact Info — web: h2 "Get In Touch" + 3 contact rows
              const Text(
                'Get In Touch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 20),

              // Contact details — web: div flex items-start gap-4 × 3
              _ContactInfoRow(
                icon: Icons.mail_outline_rounded,
                title: 'Email Address',
                value: 'rgwinhealthcare@gmail.com',
              ),
              const SizedBox(height: 16),
              _ContactInfoRow(
                icon: Icons.phone_outlined,
                title: 'Phone Number',
                value: '+91 8248703790',
              ),
              const SizedBox(height: 16),
              _ContactInfoRow(
                icon: Icons.location_on_outlined,
                title: 'Office Address',
                value: 'RG Win Health Care\n431, Bannerghatta Main Road,\nHulimavu, Bangalore-560072',
              ),

              const SizedBox(height: 40),

              // Right column: Form Card — web: card class (bg-white rounded-xl shadow-sm border)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name — web: label + input-field
                      _buildLabel('Full Name'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Your full name'),
                        validator: (v) => v!.trim().isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email Address
                      _buildLabel('Email Address'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('your@email.com'),
                        validator: (v) {
                          if (v!.trim().isEmpty) return 'Please enter your email';
                          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Message — web: textarea rows=4
                      _buildLabel('Message'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: _inputDecoration('How can we help you?'),
                        validator: (v) => v!.trim().isEmpty ? 'Please enter a message' : null,
                      ),
                      const SizedBox(height: 24),

                      // Submit button — web: btn-primary w-full flex justify-center items-center gap-2
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Send Message', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  SizedBox(width: 8),
                                  Icon(Icons.send_rounded, size: 16),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        // web: block text-sm font-medium text-[--color-text-main] mb-1
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textMain,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      // web: input-field class
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFef4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFef4444), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

// Contact info row widget — web: w-12 h-12 bg-[--color-primary-light] rounded-full + title + value
class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ContactInfoRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFe6f2f2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF008080), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e293b),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748b), height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
