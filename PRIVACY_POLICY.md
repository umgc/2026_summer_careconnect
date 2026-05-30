# Care Connect Privacy Policy

*Last updated: March 2026*

## Introduction

Care Connect ("the Application") is a healthcare coordination platform developed 
by the Care Connect development team at the University of Maryland Global Campus 
(UMGC). This Privacy Policy explains how we collect, use, store, and protect 
information when you use the Care Connect application.

By using Care Connect, you agree to the collection and use of information in 
accordance with this policy.

---

## Information We Collect

### Account Information
- Full name
- Email address
- Password (stored in encrypted form)
- Account creation date

### Health and Caregiving Information
- Care task assignments and completion records
- Health tracking data entered by caregivers or patients
- Appointment and reminder records
- Clinical notes and caregiving activity logs

### Billing and Subscription Information
- Subscription plan selection
- Billing address and state (used for tax calculation)
- Transaction references and subscription status
- Payment verification records (processed through Apple App Store or Google Play)

Care Connect does not collect or store raw payment card numbers. All payment 
processing is handled by Apple StoreKit or Google Play Billing.

### Device and Usage Information
- Device type and operating system
- App usage activity
- Notification delivery status
- Error and diagnostic logs

---

## How We Use Your Information

We use the information we collect to:

- Provide and maintain the Care Connect service
- Manage caregiver and patient care coordination
- Send care reminders and appointment notifications via AWS SNS and SES
- Process subscription billing through Apple and Google native billing systems
- Calculate applicable taxes on subscription purchases
- Maintain audit logs for caregiving activity
- Improve application performance and reliability
- Comply with applicable legal and regulatory requirements

---

## Data Retention

Care Connect is subject to the Health Insurance Portability and Accountability 
Act (HIPAA) and applicable state health data retention laws.

- **Health and caregiving records** are retained for a minimum of **6 years** 
  from the date of creation or last use, as required by federal law
- **Billing and subscription records** are retained in accordance with applicable 
  financial regulations
- **Account credentials** may be deactivated upon request
- **Notification history tied to care events** is retained as part of the 
  caregiving record

---

## Data Sharing

Care Connect does not sell your personal information to third parties.

We may share information with:

- **Amazon Web Services (AWS)** — for notification delivery via SNS and SES, 
  and for application hosting infrastructure
- **Apple** — for subscription verification via StoreKit
- **Google** — for subscription verification via Google Play Billing and for 
  address autocomplete via Google Places API
- **Law enforcement or regulatory authorities** — when required by law or to 
  protect the rights and safety of users

---

## Data Security

Care Connect implements the following security measures to protect your information:

- All data transmitted between the application and backend services is encrypted 
  using TLS
- Passwords are stored using industry-standard encryption
- Database data is encrypted at rest using AES-256
- Access to backend systems is controlled using AWS IAM least-privilege policies
- Static analysis and security scanning tools are integrated into the development 
  pipeline to detect and prevent security vulnerabilities before release
- API keys and credentials are stored in secure environment variables and are 
  never embedded in application code

---

## Your Rights

Depending on your location, you may have the right to:

- Access the personal information we hold about you
- Request correction of inaccurate information
- Request deactivation of your account
- Request information about how your data is used

To exercise any of these rights, contact us at:
**careconnect.support@gmail.com**

Please note that health and caregiving records are subject to HIPAA retention 
requirements and cannot be permanently deleted upon request. See our 
[Account Deletion Policy](ACCOUNT_DELETION.md) for full details.

---

## Children's Privacy

Care Connect is intended for use by adults aged 18 and older. We do not 
knowingly collect personal information from anyone under the age of 18. 
If you believe a minor has provided personal information through the 
application, please contact us immediately at careconnect.support@gmail.com.

---

## Notifications

Care Connect uses Amazon SNS and Amazon SES to deliver care reminders, 
appointment alerts, and system notifications. Notification content is 
limited to general messages and does not include protected health 
information (PHI) in delivery payloads. Full care details are only 
accessible within the authenticated application.

You may manage your notification preferences within the application settings.

---

## Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be posted 
to this page with an updated date. Continued use of the application after 
changes are posted constitutes acceptance of the updated policy.

---

## Contact

For questions, concerns, or requests related to this Privacy Policy, contact:

**careconnect.support@gmail.com**

Care Connect Development Team
University of Maryland Global Campus (UMGC)
Spring 2026

---

*Care Connect — UMGC Spring 2026*
