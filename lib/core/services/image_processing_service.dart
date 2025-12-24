import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Optimized image processing service for low-memory devices
/// All heavy processing happens in background isolates
class ImageProcessingService {
  // Target dimensions for optimized images
  static const int maxWidth = 1024;
  static const int maxHeight = 1024;
  static const int jpegQuality = 65; // Between 60-70 as specified
  static const int thumbnailWidth = 300;
  static const int thumbnailQuality = 80;

  /// Process image data in background isolate
  /// This runs completely off the UI thread
  static Uint8List? _processImageInIsolate(ImageProcessParams params) {
    try {
      // Decode image
      final image = img.decodeImage(params.bytes);
      if (image == null) {
        return null;
      }

      // Calculate target dimensions while maintaining aspect ratio
      int newWidth = image.width;
      int newHeight = image.height;
      
      if (image.width > params.maxWidth || image.height > params.maxHeight) {
        final aspectRatio = image.width / image.height;
        
        if (image.width > image.height) {
          newWidth = params.maxWidth;
          newHeight = (params.maxWidth / aspectRatio).round();
          if (newHeight > params.maxHeight) {
            newHeight = params.maxHeight;
            newWidth = (params.maxHeight * aspectRatio).round();
          }
        } else {
          newHeight = params.maxHeight;
          newWidth = (params.maxHeight * aspectRatio).round();
          if (newWidth > params.maxWidth) {
            newWidth = params.maxWidth;
            newHeight = (params.maxWidth / aspectRatio).round();
          }
        }
      }

      // Resize image
      final resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear, // Fastest
      );

      // Encode with compression
      final encodedBytes = img.encodeJpg(resized, quality: params.quality);
      return Uint8List.fromList(encodedBytes);
    } catch (e) {
      debugPrint('[IMAGE_PROCESSING] Error in isolate: $e');
      return null;
    }
  }

  /// Process and save image with compression (runs in background isolate)
  /// Returns the path to the processed image file
  static Future<String?> processAndSaveImage({
    required String sourcePath,
    required String outputPath,
    int? maxWidthOverride,
    int? maxHeightOverride,
    int? qualityOverride,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('[IMAGE_PROCESSING] Source file does not exist: $sourcePath');
        return null;
      }

      // Read bytes (this is fast, file I/O)
      final bytes = await sourceFile.readAsBytes();
      
      // Process in background isolate (non-blocking)
      final processedBytes = await compute(
        _processImageInIsolate,
        ImageProcessParams(
          bytes: bytes,
          maxWidth: maxWidthOverride ?? maxWidth,
          maxHeight: maxHeightOverride ?? maxHeight,
          quality: qualityOverride ?? jpegQuality,
        ),
      );

      if (processedBytes == null) {
        debugPrint('[IMAGE_PROCESSING] Failed to process image');
        return null;
      }

      // Write to file (fast, file I/O)
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(processedBytes);

      debugPrint(
        '[IMAGE_PROCESSING] Processed image saved: ${(processedBytes.length / 1024).toStringAsFixed(2)}KB',
      );

      return outputPath;
    } catch (e, stackTrace) {
      debugPrint('[IMAGE_PROCESSING] Error processing image: $e');
      debugPrint('[IMAGE_PROCESSING] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Create thumbnail from source image
  static Future<String?> createThumbnail({
    required String sourcePath,
    required String thumbnailPath,
  }) async {
    return processAndSaveImage(
      sourcePath: sourcePath,
      outputPath: thumbnailPath,
      maxWidthOverride: thumbnailWidth,
      maxHeightOverride: thumbnailWidth,
      qualityOverride: thumbnailQuality,
    );
  }

  /// Process image from camera capture (ULTRA-FAST version)
  /// Returns immediately after saving processed image, thumbnail created in background
  static Future<ImageProcessResult?> processCameraImage({
    required String cameraImagePath,
    required String outputDirectory,
    required String fileId,
  }) async {
    try {
      final originalPath = '$outputDirectory/$fileId.jpg';
      final thumbnailPath = '$outputDirectory/${fileId}_thumb.jpg';

      // Process main image in background isolate (non-blocking)
      final processedPath = await processAndSaveImage(
        sourcePath: cameraImagePath,
        outputPath: originalPath,
      );

      if (processedPath == null) {
        return null;
      }

      // Delete original camera file immediately (don't wait, fire and forget)
      _deleteFileAsync(cameraImagePath);

      // Create thumbnail in background isolate (fire and forget)
      // Don't await - this happens completely in background
      _createThumbnailAsync(processedPath, thumbnailPath);

      return ImageProcessResult(
        originalPath: processedPath,
        thumbnailPath: thumbnailPath,
      );
    } catch (e, stackTrace) {
      debugPrint('[IMAGE_PROCESSING] Error in processCameraImage: $e');
      debugPrint('[IMAGE_PROCESSING] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Process camera image asynchronously (fire and forget)
  /// Used when file is already saved - optimizes it in background
  static Future<void> processCameraImageAsync({
    required String cameraImagePath,
    required String savedImagePath,
    required String thumbnailPath,
  }) async {
    try {
      // Process main image in background isolate (replaces saved file with optimized version)
      final processedPath = await processAndSaveImage(
        sourcePath: cameraImagePath,
        outputPath: savedImagePath,
      );

      if (processedPath != null) {
        // Create thumbnail from processed image
        _createThumbnailAsync(processedPath, thumbnailPath);
      }

      // Delete original camera file
      _deleteFileAsync(cameraImagePath);
    } catch (e) {
      debugPrint('[IMAGE_PROCESSING] Error in async processing: $e');
    }
  }

  /// Delete file asynchronously (fire and forget)
  static void _deleteFileAsync(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('[IMAGE_PROCESSING] Failed to delete file: $e');
    }
  }

  /// Create thumbnail asynchronously in background isolate
  static void _createThumbnailAsync(String sourcePath, String thumbnailPath) async {
    try {
      // Read file
      final bytes = await File(sourcePath).readAsBytes();
      
      // Process in background isolate
      final thumbnailBytes = await compute(
        _processImageInIsolate,
        ImageProcessParams(
          bytes: bytes,
          maxWidth: thumbnailWidth,
          maxHeight: thumbnailWidth,
          quality: thumbnailQuality,
        ),
      );
      
      // Write thumbnail if processing succeeded
      if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
        await File(thumbnailPath).writeAsBytes(thumbnailBytes);
        debugPrint('[IMAGE_PROCESSING] Thumbnail created: $thumbnailPath');
      }
    } catch (e) {
      debugPrint('[IMAGE_PROCESSING] Thumbnail creation failed: $e');
    }
  }
}

/// Parameters for image processing in isolate
class ImageProcessParams {
  final Uint8List bytes;
  final int maxWidth;
  final int maxHeight;
  final int quality;

  ImageProcessParams({
    required this.bytes,
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
  });
}

/// Result of image processing
class ImageProcessResult {
  final String originalPath;
  final String thumbnailPath;

  ImageProcessResult({
    required this.originalPath,
    required this.thumbnailPath,
  });
}

