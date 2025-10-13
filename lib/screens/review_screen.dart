import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/firebase_service.dart';

class ReviewScreen extends StatelessWidget {
  final String sessionId;
  final String tableNumber;

  const ReviewScreen({super.key, required this.sessionId, required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thank you!'),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.thumb_up, size: 84, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Thank you for dining with us!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Table $tableNumber',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            _ReviewForm(sessionId: sessionId),
          ],
        ),
      ),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final String sessionId;
  const _ReviewForm({required this.sessionId});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _saving = false;
  Map<String, dynamic>? _submittedReview;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitAndContinue() async {
    final name = _nameController.text.trim();
    final message = _messageController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter your name'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseService.saveReview(widget.sessionId, name, message);
      if (mounted) {
        // Store the submitted review to display
        setState(() {
          _submittedReview = {
            'name': name,
            'message': message,
          };
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Thanks for your feedback!'), backgroundColor: AppColors.success),
        );
        
        // Navigate to home after a short delay to show the success message
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving review: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show submitted review if available
    if (_submittedReview != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Submitted',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Name: ${_submittedReview!['name']}',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
                if (_submittedReview!['message']?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Message: ${_submittedReview!['message']}',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Redirecting to home...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      );
    }

    // Show form if not yet submitted
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter your name (optional)',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Share your experience with us (optional)',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _submitAndContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Submit & Done'),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _saving ? null : () {
            // Continue ordering without submitting review
            Navigator.of(context).pushNamedAndRemoveUntil('/menu', (r) => false);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Continue Ordering'),
        ),
      ],
    );
  }
}
