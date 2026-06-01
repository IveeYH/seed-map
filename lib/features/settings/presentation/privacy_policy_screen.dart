import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:minecraft_seedwalker_mobile/main.dart'; // To access languageManager

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String _policyText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    try {
      final languageCode = languageManager.locale?.languageCode ?? 'en';
      final fileName = languageCode == 'es' ? 'privacy_policy_es.md' : 'privacy_policy_en.md';
      final text = await rootBundle.loadString('assets/legal/$fileName');
      if (mounted) {
        setState(() {
          _policyText = text;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _policyText = 'Error loading privacy policy.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: MarkdownBody(
                data: _policyText,
                styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
              ),
            ),
    );
  }
}
