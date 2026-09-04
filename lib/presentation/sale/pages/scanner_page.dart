import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:ocam_pos/core/utils/app_config.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool isScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isScanned = true;
        });

        // Sozlamalar -> "Shtrix-kod skaneri" da o'chirib qo'yish mumkin.
        if (AppConfig.scannerHaptics) await HapticFeedback.vibrate();

        if (mounted) {
          Navigator.pop(context, barcode.rawValue);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shtrix-kodni skanerlang"),
        actions: [
          ValueListenableBuilder(
            valueListenable: cameraController,
            builder: (context, state, child) {
              final IconData icon = state.torchState == TorchState.on
                  ? Icons.flash_on
                  : Icons.flash_off;
              final Color color = state.torchState == TorchState.on
                  ? Colors.yellow
                  : Colors.grey;
              return IconButton(
                icon: Icon(icon, color: color),
                onPressed: () => cameraController.toggleTorch(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skaner ekranini ochadi va o'qilgan shtrix-kodni qaytaradi.
/// Foydalanuvchi bekor qilsa `null` qaytadi.
///
/// Skaner faqat sotuv ekranida emas — mahsulot qo'shish/tahrirlash
/// formalarida ham kerak, shu sababli bitta joyda turadi.
Future<String?> openBarcodeScanner(BuildContext context) =>
    Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerPage()),
    );
