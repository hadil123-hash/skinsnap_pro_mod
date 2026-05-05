import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final app = context.read<AppProvider>();
    try {
      await app.sendPasswordResetEmail(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de réinitialisation envoyé'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } on AuthUiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BeautyCircleIcon(
                  icon: Icons.arrow_back_ios_new_rounded,
                  size: 44,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 28),
                const GradientText(
                  'Réinitialiser le mot de passe',
                  style: TextStyle(fontSize: 32, height: 1.14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text(
                  'Entrez votre email et Firebase vous enverra un lien sécurisé.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 26),
                BeautyCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Champ obligatoire';
                            if (!value.contains('@')) return 'Email invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        _submitting
                            ? const CircularProgressIndicator(color: AppColors.hotPink)
                            : GradientButton(
                                label: 'Envoyer le lien',
                                icon: Icons.mark_email_read_rounded,
                                onTap: _submit,
                              ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
