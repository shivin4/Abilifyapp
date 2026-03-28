import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/bootstrap.dart';
import '../../core/widgets/app_widgets.dart';

class OTPPage extends StatefulWidget {
  final String phone;
  final String verificationId;
  final bool isSignup;
  final String name;

  const OTPPage({
    super.key,
    required this.phone,
    required this.verificationId,
    this.isSignup = false,
    this.name = '',
  });

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    if (!AppBootstrap.firebaseEnabled) {
      if (mounted) context.go('/p/home');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpCtrl.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      if (widget.isSignup) {
        context.go('/role-select', extra: {
          'name': widget.name,
          'phone': widget.phone,
        });
      } else {
        context.go('/home');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppGradientHeader(
            title: 'Verify OTP',
            subtitle: 'Enter the code sent to ${widget.phone}',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 8),
                    decoration: const InputDecoration(hintText: '• • • • • •'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  const Spacer(),
                  AppPrimaryButton(label: 'Verify & continue', loading: _loading, onPressed: _verify),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
