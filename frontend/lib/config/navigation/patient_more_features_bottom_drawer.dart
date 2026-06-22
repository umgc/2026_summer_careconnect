import 'package:care_connect_app/features/dashboard/presentation/sosscreen.dart';
import 'package:care_connect_app/features/health/medication-tracker/pages/medication-tracker.dart';
import 'package:care_connect_app/features/health/virtual_check_in/presentation/pages/patient_check_in_page.dart';
import 'package:care_connect_app/features/tasks/presentation/calendar_assisiant.dart';
import 'package:care_connect_app/features/informed_delivery/informed_delivery_screen.dart';
import 'package:care_connect_app/l10n/app_localizations.dart';
import 'package:care_connect_app/shared/widgets/more_features_bottom_drawer.dart';
import 'package:flutter/material.dart';

/// Widget for the More bottom drawer navigation item
class PatientMoreFeaturesBottomDrawerWidget extends StatelessWidget {
  const PatientMoreFeaturesBottomDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final List<FeatureItem> features = [
      FeatureItem(
        icon: Icons.sos,
        iconColor: Colors.red,
        title: t.patientnavdrawer_sosTitle,
        subtitle: t.patientnavdrawer_sosSubtitle,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SosScreen()),
          );
        },
      ),
      FeatureItem(
        icon: Icons.medication,
        iconColor: Colors.blue,
        title: t.patientnavdrawer_medTrackerTitle,
        subtitle: t.patientnavdrawer_medTrackerSubtitle,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicationsTrackerPage(),
            ),
          );
        },
      ),
      FeatureItem(
        icon: Icons.calendar_month_outlined,
        iconColor: Colors.blue,
        title: t.patientnavdrawer_calendarAssistantTitle,
        subtitle: t.patientnavdrawer_calendarAssistantSubtitle,
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
      FeatureItem(
        icon: Icons.mail,
        iconColor: Colors.blue,
        title: t.patientnavdrawer_informedDeliveryTitle,
        subtitle: t.patientnavdrawer_informedDeliverySubtitle,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InformedDeliveryScreen(),
            ),
          );
        },
      ),
      FeatureItem(
        icon: Icons.health_and_safety,
        iconColor: Colors.blue,
        title: t.patientnavdrawer_virtualCheckinTitle,
        subtitle: t.patientnavdrawer_virtualCheckinSubtitle,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PatientVirtualCheckIn(),
            ),
          );
        },
      ),
    ];

    return MoreFeaturesBottomDrawer(features: features);
  }
}
