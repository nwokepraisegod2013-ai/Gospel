import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gospel_stream/services/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _formError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState state) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _formError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success;
    if (_isLoginMode) {
      success = await state.login(email, password);
    } else {
      final name = _nameController.text.trim();
      success = await state.register(name, email, password);
    }

    if (!success) {
      setState(() {
        _formError = state.errorMessage;
      });
      return;
    }

    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(_isLoginMode
              ? 'Logged in successfully'
              : 'Registered successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.isAuthenticated) {
      final user = state.currentUser ?? {};
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Profile',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('Name: ${user['name'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Email: ${user['email'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Role: ${user['role'] ?? 'user'}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                state.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLoginMode ? 'Login to Gospel Stream' : 'Create your account',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Use your account to manage creator uploads, like content, and participate in chat.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ToggleButtons(
            isSelected: [_isLoginMode, !_isLoginMode],
            onPressed: (index) => setState(() {
              _isLoginMode = index == 0;
              _formError = null;
            }),
            borderRadius: BorderRadius.circular(16),
            children: const [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Login')),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Register'))
            ],
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (!_isLoginMode)
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (!_isLoginMode && value.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_formError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _formError!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ElevatedButton(
                  onPressed: state.isLoading ? null : () => _submit(state),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isLoginMode ? 'Login' : 'Register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
