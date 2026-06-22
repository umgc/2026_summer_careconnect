import 'package:care_connect_app/features/tasks/presentation/calendar_assisiant.dart';
import 'package:care_connect_app/features/invoices/screens/dashboard/invoice_dashboard_page.dart';
import 'package:care_connect_app/l10n/app_localizations.dart';
import 'package:care_connect_app/pages/settings_page.dart';
import 'package:care_connect_app/shared/widgets/more_features_bottom_drawer.dart';
import 'package:flutter/material.dart';

import '../../features/notetaker/presentation/notetaker_search.dart';

/// Widget for the More bottom drawer navigation item
class CaregiverMoreFeaturesBottomDrawerWidget extends StatelessWidget {
  const CaregiverMoreFeaturesBottomDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final List<FeatureItem> features = [
      FeatureItem(
        icon: Icons.calendar_month_outlined,
        iconColor: Colors.blue,
        title: t.caregivernavdrawer_calendarAssistantTitle,
        subtitle: t.caregivernavdrawer_calendarAssistantSubtitle,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CalendarAssistantScreen(),
            ),
          );
        },
      ),
      // FeatureItem(
      //   icon: Icons.file_open,
      //   iconColor: Colors.blue,
      //   title: 'File Management',
      //   subtitle: 'Manage your files',
      //   onTap: () {
      //     Navigator.pop(context);
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const FileManagementPage(),
      //       ),
      //     );
      //   },
      // ),
      FeatureItem(
        icon: Icons.payments,
        iconColor: Colors.blue,
        title: t.caregivernavdrawer_invoiceManagerTitle,
        subtitle: t.caregivernavdrawer_invoiceManagerSubtitle,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvoiceDashboardPage(),
            ),
          );
        },
      ),
      FeatureItem(
        icon: Icons.note_alt,
        iconColor: Colors.blue,
        title: t.caregivernavdrawer_medNotetakerTitle,
        subtitle: t.caregivernavdrawer_medNotetakerSubtitle,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotetakerSearchPage(),
            ),
          );
        },
      ),
      FeatureItem(
        icon: Icons.settings,
        iconColor: Colors.blue,
        title: t.caregivernavdrawer_settingsTitle,
        subtitle: t.caregivernavdrawer_settingsSubtitle,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        },
      ),
    ];

    return MoreFeaturesBottomDrawer(features: features);
  }
}
