import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../services/auth_token_manager.dart';
import '../../../../services/billing_quote_service.dart';
import '../../../../config/app_config.dart';

class WebPayPage extends StatefulWidget {
  final int tierId;
  final String? tier;
  final String? email;
  final int? userId;
  final String? state;

  const WebPayPage({
    super.key,
    this.tierId = 0,
    this.tier,
    this.email,
    this.userId,
    this.state,
  });

  @override
  State<WebPayPage> createState() => _WebPayPageState();
}

class _WebPayPageState extends State<WebPayPage> {
  final String backendBase = AppConfig.getBackendBaseUrl();

  BillingQuote? _billingQuote;
  bool _loadingQuote = true;
  String? _quoteError;
  bool _isProcessing = false;
  bool _paymentSuccess = false;
  String? _transactionId;

  late int _tierId;
  int? _userId;
  late String _selectedState;

  static const List<String> _usStates = [
    'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
    'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
    'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
    'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
    'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY','DC',
  ];

  @override
  void initState() {
    super.initState();
    _tierId = widget.tierId;
    _userId = widget.userId;
    _selectedState = widget.state ?? 'CA';
    _fetchBillingQuote();
  }

  bool get _showApplePay {
    if (kIsWeb) return true;
    try { return Platform.isIOS; } catch (_) { return false; }
  }

  bool get _showGooglePay {
    if (kIsWeb) return true;
    try { return Platform.isAndroid; } catch (_) { return false; }
  }

  Future<void> _fetchBillingQuote() async {
    setState(() { _loadingQuote = true; _quoteError = null; });
    try {
      final service = BillingQuoteService(backendBase: backendBase);
      final quote = await service.getQuote(
        tierId: _tierId,
        userId: _userId,
        state: _selectedState,
      );
      if (mounted) setState(() { _billingQuote = quote; _loadingQuote = false; });
    } catch (e) {
      if (mounted) setState(() { _quoteError = e.toString(); _loadingQuote = false; });
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    try {
      final authHeaders = await AuthTokenManager.getAuthHeaders();
      headers.addAll(authHeaders);
    } catch (_) {}
    return headers;
  }

  Future<void> _processPayment(String platform) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final uri = Uri.parse('$backendBase/v1/api/billing/pay/$platform');
      final token = '${platform.toUpperCase()}_PAY_TOKEN_${DateTime.now().millisecondsSinceEpoch}';

      final body = {
        'token': token,
        'tierId': _tierId,
        'state': _selectedState,
        if (_userId != null) 'userId': _userId,
      };

      final headers = await _buildHeaders();
      final resp = await http.post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) throw Exception('Payment failed: ${resp.body}');

      final responseBody = jsonDecode(resp.body) as Map<String, dynamic>;
      if (responseBody['success'] != true) {
        throw Exception(responseBody['message'] ?? 'Payment failed');
      }

      if (mounted) {
        setState(() {
          _paymentSuccess = true;
          _transactionId = responseBody['transactionId']?.toString();
        });
        Future.delayed(const Duration(seconds: 3), () { if (mounted) context.go('/subscription'); });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Purchase'),
        backgroundColor: const Color(0xFF00A7C8),
        foregroundColor: Colors.white,
      ),
      body: _paymentSuccess ? _buildSuccessView() : _buildBody(),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A7C8))),
            const SizedBox(height: 12),
            if (_transactionId != null)
              Text('Transaction: $_transactionId', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingQuote) return const Center(child: CircularProgressIndicator());

    if (_quoteError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading quote: $_quoteError', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchBillingQuote, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_billingQuote == null) return const Center(child: Text('No quote available'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatePicker(),
          const SizedBox(height: 24),
          _buildOrderSummary(),
          const SizedBox(height: 32),
          const Text('Select Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A7C8))),
          const SizedBox(height: 16),
          if (_showApplePay) ...[
            _buildPaymentButton(
              label: 'Pay with Apple Pay',
              icon: Icons.apple,
              backgroundColor: Colors.black,
              onPressed: () => _processPayment('apple'),
            ),
            const SizedBox(height: 12),
          ],
          if (_showGooglePay)
            _buildPaymentButton(
              label: 'Pay with Google Pay',
              icon: Icons.payment,
              onPressed: () => _processPayment('google'),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaymentButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : onPressed,
        icon: _isProcessing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF00A7C8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildStatePicker() {
    return Row(
      children: [
        const Text('Tax State: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _selectedState,
          items: _usStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) {
            if (val != null && val != _selectedState) {
              setState(() => _selectedState = val);
              _fetchBillingQuote();
            }
          },
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    final quote = _billingQuote!;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A7C8))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(quote.tierName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(quote.subtotalDisplay, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ]),
          Container(height: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(vertical: 12)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Taxes (${quote.taxPercentageDisplay})', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text(quote.taxJurisdiction, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ]),
            Text(quote.taxDisplay, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ]),
          Container(height: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(vertical: 12)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A7C8))),
            Text(quote.totalDisplay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A7C8))),
          ]),
          const SizedBox(height: 8),
          Text('Currency: ${quote.currency}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
