import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/theme/app_theme.dart';

class CommunicationService {
  static Future<void> makePhoneCall(
    String phoneNumber,
    BuildContext context,
  ) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final TargetPlatform platform = Theme.of(context).platform;

      if (platform == TargetPlatform.android) {
        var status = await Permission.phone.status;
        if (!status.isGranted) {
          status = await Permission.phone.request();
          if (!status.isGranted) {
            if (!context.mounted) {
              return;
            }
            _showError('Call permission denied', context);
            return;
          }
        }
      }

      final Uri uri = Uri.parse('tel:$cleanPhone');
      final bool canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (!context.mounted) {
          return;
        }
        _showError('Cannot launch phone app', context);
        return;
      }

      await launchUrl(uri);
    } catch (error) {
      debugPrint('Phone call error: $error');
      if (!context.mounted) {
        return;
      }
      _showError('Failed to make call: $error', context);
    }
  }

  static Future<void> sendSMS(
    String phoneNumber,
    BuildContext context, {
    String? message,
  }) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      String smsUri = 'sms:$cleanPhone';
      if (message != null && message.isNotEmpty) {
        smsUri += '?body=${Uri.encodeComponent(message)}';
      }

      final Uri uri = Uri.parse(smsUri);
      final bool canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (!context.mounted) {
          return;
        }
        _showError('Cannot launch SMS app', context);
        return;
      }

      await launchUrl(uri);
    } catch (error) {
      debugPrint('SMS error: $error');
      if (!context.mounted) {
        return;
      }
      _showError('Failed to send SMS: $error', context);
    }
  }

  static Future<void> startVideoCall(
    String patientId,
    String patientName,
    BuildContext context,
  ) async {
    try {
      final String meetingId =
          'careconnect-$patientId-${DateTime.now().millisecondsSinceEpoch}';
      final Uri uri = Uri.parse('https://meet.jit.si/$meetingId');

      var cameraStatus = await Permission.camera.status;
      var micStatus = await Permission.microphone.status;

      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        if (!context.mounted) {
          return;
        }
        _showError(
          'Camera and microphone permissions are required for video calls',
          context,
        );
        return;
      }

      final bool canLaunch = await canLaunchUrl(uri);
      if (!context.mounted) {
        return;
      }
      if (!canLaunch) {
        _showError('Cannot launch video call', context);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting video call with $patientName')),
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('Video call error: $error');
      if (!context.mounted) {
        return;
      }
      _showError('Failed to start video call: $error', context);
    }
  }

  static void _showError(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.error),
    );
  }
}
