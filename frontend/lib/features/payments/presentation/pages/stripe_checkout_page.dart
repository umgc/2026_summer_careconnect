import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/package_model.dart';

/// Stripe checkout is no longer used. Apple Pay and Google Pay are the payment methods.
/// This stub redirects to the package selection page.
class StripeCheckoutPage extends StatelessWidget {
  final PackageModel package;
  final String? userId;
  final String? paymentCustomerId;
  final bool fromPortal;

  const StripeCheckoutPage({
    super.key,
    required this.package,
    this.userId,
    this.paymentCustomerId,
    this.fromPortal = false,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/select-package');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
