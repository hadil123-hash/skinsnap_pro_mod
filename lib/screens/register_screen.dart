import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final app = context.read<AppProvider>();
    try {
      await app.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BeautyCircleIcon(
                  icon: Icons.arrow_back_ios_new_rounded,
                  size: 44,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 24),
                const GradientText(
                  'Créer votre profil beauté',
                  style: TextStyle(fontSize: 34, height: 1.14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Créez votre compte pour sauvegarder vos favoris, votre routine et votre historique.',
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
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nom complet',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Champ obligatoire' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Champ obligatoire';
                            if (value.length < 6) return '6 caractères minimum';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        _submitting
                            ? const CircularProgressIndicator(color: AppColors.hotPink)
                            : GradientButton(
                                label: 'Créer mon compte',
                                icon: Icons.person_add_alt_1_rounded,
                                onTap: _submit,
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('Déjà un compte ? Se connecter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
