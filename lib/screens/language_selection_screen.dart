import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_language_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/order_history_provider.dart';
import '../models/restaurant_model.dart';
import '../utils/app_theme.dart';
import 'qr_scanner_screen.dart';
import 'main_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;

  final List<LanguageOption> languages = [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      icon: '🇺🇸',
    ),
    LanguageOption(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिंदी',
      icon: '🇮🇳',
    ),
    LanguageOption(
      code: 'mr',
      name: 'Marathi',
      nativeName: 'मराठी',
      icon: '🇮🇳',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Set default language to English
    selectedLanguage = 'en';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // App logo and welcome message
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Welcome to QR Menu',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Please select your preferred language',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Language options
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final isSelected = selectedLanguage == language.code;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedLanguage = language.code;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  language.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        language.nativeName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? AppColors.primary
                                                        .withOpacity(0.8)
                                                  : AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  )
                                else
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.textTertiary,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedLanguage != null
                      ? () => _continueWithLanguage(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 16),

              // Skip button
              TextButton(
                onPressed: () => _continueWithLanguage(context),
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Debug bypass button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bug_report, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _skipDirectlyToMenu(context),
                      child: Text(
                        'Debug: Skip to Demo Menu',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _continueWithLanguage(BuildContext context) {
    // Set the selected language in the provider
    if (selectedLanguage != null) {
      context.read<AppLanguageProvider>().setLanguage(selectedLanguage!);
    }

    // Navigate to QR scanner
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
  }

  void _skipDirectlyToMenu(BuildContext context) {
    // Set the selected language in the provider
    if (selectedLanguage != null) {
      context.read<AppLanguageProvider>().setLanguage(selectedLanguage!);
    }

    // Create mock restaurant data
    final restaurant = RestaurantModel(
      id: 'debug_001',
      name: '🐛 Debug Restaurant',
      address: 'Debug Mode Location',
      phone: '+91 9876543210',
      tableNumber: '99',
      logoUrl: 'https://via.placeholder.com/200x200/FF6B35/FFFFFF?text=DEBUG',
    );

    // Set restaurant data in provider
    context.read<MenuProvider>().setRestaurant(restaurant);

    // Navigate directly to main screen with mock data
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          // Initialize providers with mock data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<MenuProvider>().initializeWithMockData();
            context.read<OrderHistoryProvider>().initializeWithMockData();
          });
          return const MainScreen();
        },
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String icon;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.icon,
  });
}
