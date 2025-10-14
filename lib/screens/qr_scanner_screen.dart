import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/restaurant_model.dart';
import '../providers/menu_provider.dart';
import '../utils/app_theme.dart';
import 'menu_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  bool hasPermission = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;

    if (status.isDenied || status.isRestricted) {
      // Request permission
      final result = await Permission.camera.request();
      setState(() {
        hasPermission = result.isGranted;
        if (result.isPermanentlyDenied) {
          errorMessage =
              'Camera permission is permanently denied. Please enable it in Settings.';
        } else if (result.isDenied) {
          errorMessage = 'Camera permission is required to scan QR codes';
        }
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        hasPermission = false;
        errorMessage =
            'Camera permission is permanently denied. Please enable it in Settings.';
      });
    } else {
      setState(() {
        hasPermission = status.isGranted;
        if (!hasPermission) {
          errorMessage = 'Camera permission is required to scan QR codes';
        }
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (!isScanning) return;

      setState(() {
        isScanning = false;
      });

      _processScanResult(scanData.code);
    });
  }

  void _processScanResult(String? code) {
    if (code == null || code.isEmpty) {
      _showErrorAndRetry('Invalid QR code');
      return;
    }

    try {
      // Try to parse as JSON (real QR code format)
      final data = jsonDecode(code);
      final restaurant = RestaurantModel.fromJson(data);

      _navigateToMenu(restaurant);
    } catch (e) {
      // If not JSON, check if it's a URL or simple table number
      if (code.startsWith('http')) {
        // URL format - extract restaurant ID and table
        _handleUrlFormat(code);
      } else if (code.contains('table') || code.contains('Table')) {
        // Simple table format
        _handleTableFormat(code);
      } else {
        // For demo purposes, use any QR code to proceed with mock data
        _navigateToMenuWithMockData();
      }
    }
  }

  void _handleUrlFormat(String url) {
    try {
      final uri = Uri.parse(url);
      final restaurantId = uri.queryParameters['restaurant'] ?? 'demo';
      final tableNumber = uri.queryParameters['table'] ?? '1';

      final restaurant = RestaurantModel(
        id: restaurantId,
        name: 'Scanned Restaurant',
        address: 'Location from QR',
        phone: '+91 0000000000',
        tableNumber: tableNumber,
        logoUrl: 'https://via.placeholder.com/200x200/FF6B35/FFFFFF?text=QR',
      );

      _navigateToMenu(restaurant);
    } catch (e) {
      _navigateToMenuWithMockData();
    }
  }

  void _handleTableFormat(String code) {
    final tableMatch = RegExp(r'(\d+)').firstMatch(code);
    final tableNumber = tableMatch?.group(1) ?? '1';

    final restaurant = RestaurantModel(
      id: 'table_$tableNumber',
      name: 'Restaurant Table $tableNumber',
      address: 'Scanned Location',
      phone: '+91 0000000000',
      tableNumber: tableNumber,
      logoUrl:
          'https://via.placeholder.com/200x200/FF6B35/FFFFFF?text=T$tableNumber',
    );

    _navigateToMenu(restaurant);
  }

  void _navigateToMenuWithMockData() {
    // Use mock restaurant data for demonstration
    final restaurant = RestaurantModel(
      id: 'demo_001',
      name: 'Demo Restaurant',
      address: 'Demo Location',
      phone: '+91 9876543210',
      tableNumber: '7',
      logoUrl: 'https://via.placeholder.com/200x200/FF6B35/FFFFFF?text=DEMO',
    );

    _navigateToMenu(restaurant);
  }

  void _navigateToMenu(RestaurantModel restaurant) {
    // Set restaurant data in provider
    context.read<MenuProvider>().setRestaurant(restaurant);

    // Navigate using go_router to the validated route
    // This will trigger proper URL-based validation
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _showErrorAndRetry(String message) {
    setState(() {
      errorMessage = message;
    });

    // Reset scanning after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isScanning = true;
          errorMessage = null;
        });
      }
    });
  }

  void _onFlashToggle() {
    controller?.toggleFlash();
  }

  void _onCameraSwitch() {
    controller?.flipCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _onFlashToggle,
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: _onCameraSwitch,
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      body: !hasPermission
          ? _buildPermissionDenied()
          : Column(
              children: [
                Expanded(
                  flex: 4,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: AppColors.primary,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 250,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (errorMessage != null) ...[
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ] else if (!isScanning) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Processing QR code...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ] else ...[
                          Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Point your camera at the QR code',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The QR code should be clearly visible within the frame',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Demo button for testing
                        ElevatedButton(
                          onPressed: () => _navigateToMenuWithMockData(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                          ),
                          child: const Text('Demo Menu (For Testing)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPermissionDenied() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 24),
          Text(
            'Camera Permission Required',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Please grant camera permission to scan QR codes',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Primary action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Open Settings'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _checkPermission,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Check Permission Again'),
            ),
          ),

          const SizedBox(height: 32),

          // Debug bypass section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.bug_report, color: AppColors.warning, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Debug Mode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Skip camera permission and continue with demo data for testing purposes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToMenuWithMockData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.skip_next, size: 20),
                        const SizedBox(width: 8),
                        const Text('Skip & Continue with Demo'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
