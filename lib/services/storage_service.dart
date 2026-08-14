import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class StorageService {
  static const _channel = MethodChannel('com.spendwise.app/storage');

  /// Checks if the device has low storage (less than 100 MB free)
  /// and shows an alert dialog if space is indeed low.
  static Future<void> checkLowStorage(BuildContext context) async {
    try {
      final int? freeBytes = await _channel.invokeMethod<int>('getFreeStorageSpace');
      if (freeBytes != null) {
        final double freeMb = freeBytes / (1024 * 1024);
        // If free space is less than 100 MB, alert the user
        if (freeMb < 100) {
          if (context.mounted) {
            _showAdaptiveLowStorageDialog(context, freeMb);
          }
        }
      }
    } catch (_) {
      // Fail silently to prevent interrupting user experience on unsupported environments
    }
  }

  static void _showAdaptiveLowStorageDialog(BuildContext context, double freeMb) {
    final title = 'Low Storage Warning';
    final content = 'Your device is extremely low on storage (${freeMb.toStringAsFixed(1)} MB remaining). '
        'Please free up some space to ensure smooth performance and prevent database sync issues.';

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              child: const Text('Dismiss'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text(
                'Low Storage Warning',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            content,
            style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Dismiss', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }
}
