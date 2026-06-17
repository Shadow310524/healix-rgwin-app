import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class ContactScreen extends StatefulWidget {
  final String? productName;
  const ContactScreen({super.key, this.productName});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.productName != null) {
      // Pre-fill message when opened from a product page
      _messageController.text =
          'I am interested in ${widget.productName}. Please provide more details.';
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
        _showSnack(
          'Thank you for reaching out. We will get back to you soon!',
          AppColors.success,
          Icons.check_circle_outline,
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        if (widget.productName != null) Navigator.pop(context);
      } else {
        _showSnack('Failed to send message. Please try again.', AppColors.error, null);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to send message. Please try again.', AppColors.error, null);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String message, Color color, IconData? icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[Icon(icon, color: Colors.white), const SizedBox(width: 8)],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ContactHeader(),
              const SizedBox(height: 32),
              const _ContactInfoSection(),
              const SizedBox(height: 40),
              _ContactForm(
                formKey: _formKey,
                nameController: _nameController,
                emailController: _emailController,
                messageController: _messageController,
                isSubmitting: _isSubmitting,
                onSubmit: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ContactHeader extends StatelessWidget {
  const _ContactHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Have questions? We're here to help.",
          style: TextStyle(fontSize: 15, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ─── Contact Info ─────────────────────────────────────────────────────────────

class _ContactInfoSection extends StatelessWidget {
  const _ContactInfoSection();

  static const _contacts = [
    (Icons.mail_outline_rounded, 'Email Address', 'rgwinhealthcare@gmail.com'),
    (Icons.phone_outlined, 'Phone Number', '+91 8248703790'),
    (Icons.location_on_outlined, 'Office Address',
        'RG Win Health Care\n431, Bannerghatta Main Road,\nHulimavu, Bangalore-560072'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Get In Touch',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < _contacts.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _ContactInfoRow(
            icon: _contacts[i].$1,
            title: _contacts[i].$2,
            value: _contacts[i].$3,
          ),
        ],
      ],
    );
  }
}

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
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textMain)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────

class _ContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _ContactForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.messageController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormField(
              label: 'Full Name',
              controller: nameController,
              hint: 'Your full name',
              validator: (v) => v!.trim().isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            _FormField(
              label: 'Email Address',
              controller: emailController,
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.trim().isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _FormField(
              label: 'Message',
              controller: messageController,
              hint: 'How can we help you?',
              maxLines: 4,
              validator: (v) => v!.trim().isEmpty ? 'Please enter a message' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: isSubmitting
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
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMain),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          validator: validator,
        ),
      ],
    );
  }
}
