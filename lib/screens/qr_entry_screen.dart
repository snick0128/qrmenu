import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart'; // 👈 Added
import '../services/firebase_service.dart';
import '../services/seed_service.dart';
import '../utils/app_theme.dart';
import '../utils/scanner_overlay.dart';
import '../firebase_options.dart';

class QREntryScreen extends StatefulWidget {
  const QREntryScreen({super.key});

  @override
  State<QREntryScreen> createState() => _QREntryScreenState();
}

class _QREntryScreenState extends State<QREntryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  String? _error;
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    _initializeGuestUser();
    _requestCameraPermission(); // 👈 Ask for permission
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted && mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text('This app needs camera access to scan QR codes.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initializeGuestUser() async {
    try {
      final auth = FirebaseAuth.instance;

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
    } catch (e) {
      setState(() => _error = 'Failed to initialize guest session: $e');
    }
  }

  Future<void> _handleSeedData(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      await SeedService.seedAllDemoData();
      await FirebaseService.listAllAccessCodes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test data seeded successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to seed test data: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _validateCode(String code) async {
    if (_isLoading || code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final validationResult = await FirebaseService.validateCode(code);

      if (!mounted) return;

      if (validationResult.isValid) {
        final sessionId = await FirebaseService.initializeSession(
          FirebaseAuth.instance.currentUser!.uid,
          validationResult,
        );

        _animationController.reverse().then((_) {
          if (!mounted) return;

          if (validationResult.isDineIn) {
            Navigator.pushReplacementNamed(
              context,
              '/dine_in',
              arguments: {
                'sessionId': sessionId,
                'tableNumber': validationResult.tableNumber,
                'code': validationResult.code,
              },
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              '/parcel',
              arguments: {
                'sessionId': sessionId,
                'code': validationResult.code,
              },
            );
          }
        });
      } else {
        _showErrorDialog('Invalid code. Please try again.');
        _codeController.clear();
      }
    } catch (e) {
      _showErrorDialog('Failed to validate code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _animationController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 👈 Moves UI when keyboard appears
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            // 👈 Prevents overflow when typing
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to Our Restaurant',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Scan QR code or enter your code below',
                        style: TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // QR Scanner
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: MobileScanner(
                            controller: _scannerController =
                                MobileScannerController(),
                            onDetect: (capture) {
                              if (capture.barcodes.isNotEmpty) {
                                final barcode = capture.barcodes.first;
                                _validateCode(barcode.rawValue ?? '');
                              }
                            },
                          ),
                        ),
                        CustomPaint(
                          painter: ScannerOverlay(AppColors.primary),
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Manual Code Entry
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: _validateCode,
                          decoration: InputDecoration(
                            hintText: 'Enter code manually',
                            filled: true,
                            fillColor: AppColors.surfaceVariantDark,
                            prefixIcon: const Icon(Icons.keyboard),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => _validateCode(_codeController.text),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
