import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppButton extends StatelessWidget {
  final String phoneNumber;
  final String? message;
  final bool compact;

  const WhatsAppButton({
    super.key,
    required this.phoneNumber,
    this.message,
    this.compact = false,
  });

  Future<void> _launchWhatsApp(BuildContext context) async {
    // Format number: remove non-digits, ensure country code
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!cleanNumber.startsWith('88')) {
      cleanNumber = '88$cleanNumber';
    }

    final String url =
        "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message ?? 'Hello from Gas Vendor')}";

    try {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        icon: const Icon(Icons.message, color: Colors.green),
        onPressed: () => _launchWhatsApp(context),
        tooltip: 'Chat on WhatsApp',
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _launchWhatsApp(context),
      icon: const Icon(Icons.message, size: 18),
      label: const Text('WhatsApp'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
