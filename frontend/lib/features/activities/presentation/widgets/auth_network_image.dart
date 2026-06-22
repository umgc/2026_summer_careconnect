import 'package:care_connect_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/services/auth_token_manager.dart';
import 'package:http/http.dart' as http;

/// Loads an image from [url] with auth headers and displays it, or [fallback] on error.
class AuthNetworkImage extends StatelessWidget {
  final String url;
  final Widget fallback;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AuthNetworkImage({
    super.key,
    required this.url,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = ApiService.resolveImageUrl(url);
    if (resolved == null || resolved.isEmpty) return fallback;
    return FutureBuilder<http.Response>(
      future: _fetchImage(resolved),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.statusCode == 200 &&
            snapshot.data!.bodyBytes.isNotEmpty) {
          return Image.memory(
            snapshot.data!.bodyBytes,
            width: width,
            height: height,
            fit: fit,
          );
        }
        return fallback;
      },
    );
  }

  static Future<http.Response> _fetchImage(String fullUrl) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await http.get(Uri.parse(fullUrl), headers: headers);
  }
}

/// Returns Material icon for ADL/IADL activity name (fallback when no URL).
IconData iconForActivityName(String name, String category, BuildContext context) {
  final t = AppLocalizations.of(context)!;
  final n = name.toLowerCase().trim();
  if (category.toUpperCase() == 'ADL') {
    if (n.contains(t.authnetworkimg_bathingText)) return Icons.bathtub;
    if (n.contains(t.authnetworkimg_dressingText)) return Icons.checkroom;
    if (n.contains(t.authnetworkimg_toiletingText)) return Icons.wc;
    if (n.contains(t.authnetworkimg_transferringText)) return Icons.transfer_within_a_station;
    if (n.contains(t.authnetworkimg_mobilityText) || n.contains(t.authnetworkimg_ambulationText)) return Icons.directions_walk;
    if (n.contains(t.authnetworkimg_eatingText)) return Icons.restaurant;
    if (n.contains(t.authnetworkimg_hygieneText) || n.contains(t.authnetworkimg_groomingText)) return Icons.face;
  } else {
    if (n.contains(t.authnetworkimg_mealText) && n.contains(t.authnetworkimg_prepText)) return Icons.soup_kitchen;
    if (n.contains(t.authnetworkimg_housekeepingText)) return Icons.cleaning_services;
    if (n.contains(t.authnetworkimg_laundryText)) return Icons.local_laundry_service;
    if (n.contains(t.authnetworkimg_medicationText)) return Icons.medication;
    if (n.contains(t.authnetworkimg_moneyText)) return Icons.attach_money;
    if (n.contains(t.authnetworkimg_transportationText)) return Icons.directions_car;
    if (n.contains(t.authnetworkimg_communicationText)) return Icons.chat;
    if (n.contains(t.authnetworkimg_communityText) || n.contains(t.authnetworkimg_participationText)) return Icons.people;
    if (n.contains(t.authnetworkimg_shoppingText)) return Icons.shopping_cart;
    if (n.contains(t.authnetworkimg_safetyText)) return Icons.health_and_safety;
  }
  return Icons.task_alt;
}
