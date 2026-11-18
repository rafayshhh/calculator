import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'web_download_stub.dart'
    if (dart.library.js_interop) 'web_download_web.dart';

/// Platform-safe service to capture, download, and share calculation cards as images.
class ImageShareService {
  ImageShareService._();

  /// Captures a RenderRepaintBoundary widget into high-resolution PNG byte data.
  static Future<Uint8List?> capturePng(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Platform-aware saving to device storage or browser download.
  static Future<bool> saveImageToDevice(
    BuildContext context,
    Uint8List bytes,
    String filename,
  ) async {
    try {
      if (kIsWeb) {
        // Trigger browser blob download in Web environment
        downloadFileWeb(bytes, filename);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloading $filename...'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return true;
      } else {
        // Multi-platform file share / save
        final xFile = XFile.fromData(
          bytes,
          name: filename,
          mimeType: 'image/png',
        );
        await SharePlus.instance.share(
          ShareParams(
            files: [xFile],
            text: 'Saved from Calculator',
          ),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported $filename successfully!'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return true;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save file to disk on this device.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  /// Native multi-platform share sheet integration.
  static Future<bool> shareImageFile(
    BuildContext context,
    Uint8List bytes,
    String filename, {
    String text = 'Calculated with Calculator',
  }) async {
    try {
      final xFile = XFile.fromData(
        bytes,
        name: filename,
        mimeType: 'image/png',
      );
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: text,
        ),
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Platform share sheet could not be opened.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }
}
