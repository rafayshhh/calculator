import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/kreate_logger.dart';

/// Centralized repository of all official Calculator open-source destinations,
/// creator social profiles, GitHub repositories, and issue tracker endpoints.
class KreateLinks {
  KreateLinks._();

  // Creator & Open-Source Destinations
  static const String creatorName = 'Muhammad Abdul Rafay';
  static const String creatorHandle = '@rafayshhh';
  static const String github = 'https://github.com/rafayshhh';
  static const String repo = 'https://github.com/rafayshhh/calculator';
  static const String website = 'https://kreatekode.website';
  static const String instagram = 'https://www.instagram.com/kreatekode/';
  static const String playStore = 'https://play.google.com/store/apps/developer?id=KreateKode';
  static const String issues = 'https://github.com/rafayshhh/calculator/issues';
  static const String discussions = 'https://github.com/rafayshhh/calculator/discussions';
  static const String docs = 'https://github.com/rafayshhh/calculator/tree/main/Documentation';

  // Support & Contact
  static const String supportEmail = 'rafayinreality@gmail.com';

  /// Safe external URL launcher with user feedback and clipboard fallback.
  static Future<bool> launchUrlExternal(
    BuildContext context,
    String urlString, {
    String? successMessage,
  }) async {
    try {
      final uri = Uri.parse(urlString);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        if (context.mounted && successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return true;
      }
    } catch (e, st) {
      KreateLogger.error('Failed to launch URL "$urlString": $e', e, st);
    }

    // Fallback: Copy to clipboard if external launching fails
    if (context.mounted) {
      await Clipboard.setData(ClipboardData(text: urlString));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link copied to clipboard: $urlString'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
    return false;
  }

  /// Launch email client with pre-filled subject and body.
  static Future<bool> launchEmail(
    BuildContext context, {
    required String subject,
    required String body,
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {'subject': subject, 'body': body},
    );

    try {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
    } catch (e, st) {
      KreateLogger.error('Failed to launch mail client: $e', e, st);
    }

    // Fallback: Copy email content to clipboard
    if (context.mounted) {
      final formattedText = 'To: $supportEmail\nSubject: $subject\n\n$body';
      await Clipboard.setData(ClipboardData(text: formattedText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email info copied to clipboard. Send to $supportEmail',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
    return false;
  }
}
