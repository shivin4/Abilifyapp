import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/bootstrap.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_widgets.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneCtrl = TextEditingController(text: '+91');
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!AppBootstrap.firebaseEnabled) {
      if (mounted) context.go('/p/home');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final phone = _phoneCtrl.text.trim();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) context.go('/home');
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _error = e.message;
            _loading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _loading = false);
          if (mounted) {
            context.go('/otp', extra: {'phone': phone, 'verificationId': verificationId});
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _loading = false);
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppGradientHeader(
            title: 'Welcome back',
            subtitle: 'Sign in with your phone number to continue',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite, color: AppColors.primary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Abilify connects families to verified therapists and a caring parent community.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('Phone number', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '+91XXXXXXXXXX'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 28),
                  AppPrimaryButton(
                    label: 'Send OTP',
                    loading: _loading,
                    onPressed: _login,
                    icon: Icons.sms_outlined,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('New here? '),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: const Text(
                          'Create account',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
