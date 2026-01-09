
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  String? _otpAuthUrl;
  String? _secret;
  final _codeController = TextEditingController();
  bool _isLoading = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _enable2FA();
  }

  Future<void> _enable2FA() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final data = await authProvider.enable2FA();
      setState(() {
        _otpAuthUrl = data['otpauth'];
        _secret = data['secret'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load 2FA setup: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifySetup() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;

    setState(() => _isVerifying = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.verify2FASetup(code);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Two-Factor Authentication Enabled!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Go back to settings
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Code'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  void _copySecret() {
    if (_secret != null) {
      Clipboard.setData(ClipboardData(text: _secret!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Secret copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup 2FA')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Scan this QR Code with Google Authenticator',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  if (_otpAuthUrl != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                           BoxShadow(color: Colors.black12, blurRadius: 10),
                        ]
                      ),
                      child: QrImageView(
                        data: _otpAuthUrl!,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Secret Key: $_secret',
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copySecret,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Enter the 6-digit code to verify:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '000000',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifySetup,
                      child: _isVerifying
                          ? const CircularProgressIndicator()
                          : const Text('Verify and Enable'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
