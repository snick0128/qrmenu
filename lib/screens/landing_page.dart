import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../utils/seed_data.dart' as local_seed;
import '../utils/firebase_seeder.dart' as firebase_seeder;
import '../providers/menu_provider.dart';
import '../providers/dining_provider.dart';
import '../services/firestore_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoading = true;
  String? _error;
  String? _tableNumber;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase (safe to call even if not used on local seeding)
      try {
        await FirebaseService.initialize();
      } catch (_) {
        // Ignore Firebase init errors when working with local mock data
      }

      // Get table number from URL if present
      final uri = Uri.base;
      _tableNumber = uri.queryParameters['table'];

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize app: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Material(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: const _DevFab(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1F1D2B), const Color(0xFF2D2D3F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D3F),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tableNumber != null
                              ? 'Table $_tableNumber'
                              : 'Welcome to Our Restaurant',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'How would you like to proceed?',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 40),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              _OrderButton(
                                icon: Icons.restaurant,
                                label: 'Dine In',
                                onPressed: () => _handleDineIn(context),
                                isPrimary: _tableNumber != null,
                              ),
                              const SizedBox(height: 16),
                              _OrderButton(
                                icon: Icons.delivery_dining,
                                label: 'Take Away',
                                onPressed: () => _handleTakeAway(context),
                                isPrimary: _tableNumber == null,
                              ),
                              // Development-only button for seeding test data
                              if (const bool.fromEnvironment(
                                    'dart.vm.product',
                                  ) ==
                                  false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 24),
                                  child: _OrderButton(
                                    icon: Icons.data_array,
                                    label: 'Seed Test Data',
                                    onPressed: () => _handleSeedData(context),
                                    isPrimary: false,
                                  ),
                                ),
                              if (const bool.fromEnvironment(
                                    'dart.vm.product',
                                  ) ==
                                  false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: _OrderButton(
                                    icon: Icons.cloud_upload,
                                    label: 'Seed Firebase Data (dev)',
                                    onPressed: () =>
                                        _handleSeedFirebase(context),
                                    isPrimary: false,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDineIn(BuildContext context) {
    if (_tableNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan the QR code at your table first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Start dine-in session
    context.read<DiningProvider>().startDineInSession(_tableNumber!);
    Navigator.pushReplacementNamed(context, '/menu');
  }

  void _handleTakeAway(BuildContext context) {
    context.read<DiningProvider>().startTakeAwaySession();
    Navigator.pushReplacementNamed(context, '/menu');
  }

  Future<void> _handleSeedData(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      // Load local seeded data and populate providers (no Firestore writes)
      final restaurant = await local_seed.SeedData.loadRestaurant();
      final items = await local_seed.SeedData.loadMenuItems();

      // Inject into MenuProvider if available
      try {
        final menuProvider = context.read<MenuProvider>();
        menuProvider.setDataFromSeed(restaurant, items);
      } catch (_) {
        // ignore - MenuProvider not available in this context
      }

      // Show success; UI will use existing mock data if providers read it
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test data seeded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to seed test data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSeedFirebase(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      await firebase_seeder.FirebaseSeeder.seedIfAbsent();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase seed completed (created missing data).'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase seed failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _DevFab extends StatelessWidget {
  const _DevFab();

  @override
  Widget build(BuildContext context) {
    if (!const bool.fromEnvironment('dart.vm.product')) {
      return GestureDetector(
        onLongPress: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clearing demo data...')),
          );
          await FirestoreService.clearSeedData();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Clear finished')));
          }
        },
        child: FloatingActionButton(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Seeding demo data...')),
            );
            await FirestoreService.seedDemoData();
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Seeding finished')));
            }
          },
          child: const Icon(Icons.developer_mode),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _OrderButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _OrderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<_OrderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isPrimary
                  ? [const Color(0xFF6C63FF), const Color(0xFF5A54D9)]
                  : [const Color(0xFF3D3D4F), const Color(0xFF2D2D3F)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.isPrimary
                          ? const Color(0xFF6C63FF).withOpacity(0.3)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(widget.icon, size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
