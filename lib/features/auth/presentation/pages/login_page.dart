import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../notifiers/auth_notifier.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Se connecter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              AppTextField(hint: 'Email', controller: _emailController, validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              AppTextField(hint: 'Mot de passe', controller: _passwordController, obscure: true, validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
              const SizedBox(height: 20),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              AppButton(label: 'Se connecter', onPressed: _submit, loading: _loading),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())), child: const Text("S'inscrire")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    final notifier = ref.read(authStateProvider.notifier);
    final res = await notifier.signIn(_emailController.text.trim(), _passwordController.text.trim());
    setState(() { _loading = false; });
    if (res != null) {
      setState(() { _error = res; });
    } else {
      // On success, navigate to home (to be implemented)
      // For now show success
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecté')));
    }
  }
}
