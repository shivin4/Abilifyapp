import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/bootstrap.dart';

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
      if (mounted) context.go('/p/dashboard');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final phone = _phoneCtrl.text.trim();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) context.go('/home');
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() { _error = e.message; _loading = false; });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _loading = false);
          if (mounted) context.go('/otp', extra: {'phone': phone, 'verificationId': verificationId});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _loading = false);
        },
      );
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phone (e.g., +91XXXXXXXXXX)'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

