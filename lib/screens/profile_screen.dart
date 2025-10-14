import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_language_provider.dart';
import '../providers/order_history_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<AppLanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Guest User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Welcome to QR Menu',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings sections
            _buildSettingsSection(context, 'Preferences', [
              _buildSettingsTile(
                context,
                Icons.language,
                'Language',
                languageProvider.languageName,
                () => _showLanguageDialog(context, languageProvider),
              ),
              _buildSettingsTile(
                context,
                Icons.palette,
                'Theme',
                'System',
                () => _showThemeDialog(context),
              ),
            ]),

            const SizedBox(height: 16),

            _buildSettingsSection(context, 'Data', [
              _buildSettingsTile(
                context,
                Icons.delete_sweep,
                'Clear Order History',
                'Remove all saved orders',
                () => _showClearHistoryDialog(context),
                isDestructive: true,
              ),
            ]),

            const SizedBox(height: 16),

            _buildSettingsSection(context, 'About', [
              _buildSettingsTile(
                context,
                Icons.info,
                'App Version',
                '1.0.0',
                null,
              ),
              _buildSettingsTile(
                context,
                Icons.bug_report,
                'Debug Mode',
                'Development build',
                null,
              ),
            ]),

            const SizedBox(height: 32),

            // Footer
            Text(
              'Made with ❤️ for great dining experiences',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> tiles,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isDestructive ? AppColors.error : AppColors.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? AppColors.error : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    AppLanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              languageProvider,
              'en',
              'English',
              '🇺🇸',
            ),
            _buildLanguageOption(
              context,
              languageProvider,
              'hi',
              'Hindi',
              '🇮🇳',
            ),
            _buildLanguageOption(
              context,
              languageProvider,
              'mr',
              'Marathi',
              '🇮🇳',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    AppLanguageProvider languageProvider,
    String code,
    String name,
    String flag,
  ) {
    final isSelected = languageProvider.languageCode == code;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          languageProvider.setLanguage(code);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(child: Text(name)),
              if (isSelected) Icon(Icons.check, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: const Text(
          'Theme selection will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Order History'),
        content: const Text(
          'Are you sure you want to delete all your order history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<OrderHistoryProvider>().clearHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order history cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
