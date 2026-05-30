// Tests for route_registry utilities
// (lib/widgets/search/route_registry.dart).
//
// Tests cover:
//   • toAppRole() — pure top-level function that maps a role string to AppRole
//   • AppRole enum values
//   • RouteParam constructor / field storage
//   • RouteMeta constructor / field storage
//   • allRoles and staffRoles constant sets
//
// No platform channels, network I/O, or BuildContext needed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/search/route_registry.dart';

void main() {
  // ─────────────────────────────────────────────────────────────
  // toAppRole
  // ─────────────────────────────────────────────────────────────
  group('toAppRole', () {
    test('returns PATIENT for "PATIENT"', () {
      expect(toAppRole('PATIENT'), AppRole.PATIENT);
    });

    test('returns CAREGIVER for "CAREGIVER"', () {
      expect(toAppRole('CAREGIVER'), AppRole.CAREGIVER);
    });

    test('returns FAMILY_LINK for "FAMILY_LINK"', () {
      expect(toAppRole('FAMILY_LINK'), AppRole.FAMILY_LINK);
    });

    test('returns ADMIN for "ADMIN"', () {
      expect(toAppRole('ADMIN'), AppRole.ADMIN);
    });

    test('is case-insensitive — lowercase "patient"', () {
      // toUpperCase() is applied internally.
      expect(toAppRole('patient'), AppRole.PATIENT);
    });

    test('is case-insensitive — mixed "Caregiver"', () {
      expect(toAppRole('Caregiver'), AppRole.CAREGIVER);
    });

    test('returns null for unknown role string', () {
      expect(toAppRole('unknown'), isNull);
    });

    test('returns null for empty string', () {
      expect(toAppRole(''), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // AppRole enum values
  // ─────────────────────────────────────────────────────────────
  group('AppRole enum', () {
    test('has exactly four values', () {
      expect(AppRole.values.length, 4);
    });

    test('contains PATIENT, CAREGIVER, FAMILY_LINK, ADMIN', () {
      expect(AppRole.values, containsAll([
        AppRole.PATIENT,
        AppRole.CAREGIVER,
        AppRole.FAMILY_LINK,
        AppRole.ADMIN,
      ]));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // allRoles and staffRoles constants
  // ─────────────────────────────────────────────────────────────
  group('role sets', () {
    test('allRoles contains all four AppRole values', () {
      expect(allRoles, containsAll(AppRole.values));
    });

    test('allRoles has four entries', () {
      expect(allRoles.length, 4);
    });

    test('staffRoles contains CAREGIVER and ADMIN', () {
      expect(staffRoles, containsAll([AppRole.CAREGIVER, AppRole.ADMIN]));
    });

    test('staffRoles does not contain PATIENT', () {
      expect(staffRoles, isNot(contains(AppRole.PATIENT)));
    });

    test('staffRoles does not contain FAMILY_LINK', () {
      expect(staffRoles, isNot(contains(AppRole.FAMILY_LINK)));
    });
  });

  // ─────────────────────────────────────────────────────────────
  // RouteParam
  // ─────────────────────────────────────────────────────────────
  group('RouteParam', () {
    test('stores key and label', () {
      const p = RouteParam(key: 'userId', label: 'User ID');
      expect(p.key, 'userId');
      expect(p.label, 'User ID');
    });

    test('isPathParam defaults to false', () {
      const p = RouteParam(key: 'q', label: 'Query');
      expect(p.isPathParam, isFalse);
    });

    test('isPathParam can be set to true', () {
      const p = RouteParam(key: 'id', label: 'ID', isPathParam: true);
      expect(p.isPathParam, isTrue);
    });

    test('defaultValue defaults to null', () {
      const p = RouteParam(key: 'tab', label: 'Tab');
      expect(p.defaultValue, isNull);
    });

    test('defaultValue can be set', () {
      const p = RouteParam(
          key: 'tab', label: 'Tab', defaultValue: 'dashboard');
      expect(p.defaultValue, 'dashboard');
    });
  });

  // ─────────────────────────────────────────────────────────────
  // RouteMeta
  // ─────────────────────────────────────────────────────────────
  group('RouteMeta', () {
    test('stores title, description, keywords', () {
      const meta = RouteMeta(
        title: 'Dashboard',
        description: 'Main dashboard',
        keywords: ['home', 'main'],
        kind: NavKind.routePath,
        path: '/dashboard',
        roles: {AppRole.PATIENT},
        icon: Icons.home,
      );

      expect(meta.title, 'Dashboard');
      expect(meta.description, 'Main dashboard');
      expect(meta.keywords, containsAll(['home', 'main']));
    });

    test('stores kind and path for routePath', () {
      const meta = RouteMeta(
        title: 'Settings',
        description: '',
        keywords: [],
        kind: NavKind.routePath,
        path: '/settings',
        roles: {},
        icon: Icons.settings,
      );

      expect(meta.kind, NavKind.routePath);
      expect(meta.path, '/settings');
    });

    test('launchable defaults to true', () {
      const meta = RouteMeta(
        title: 'Test',
        description: '',
        keywords: [],
        kind: NavKind.routePath,
        path: '/test',
        roles: {},
        icon: Icons.circle,
      );
      expect(meta.launchable, isTrue);
    });

    test('launchable can be set to false', () {
      const meta = RouteMeta(
        title: 'Complex',
        description: '',
        keywords: [],
        kind: NavKind.routePath,
        path: '/complex',
        roles: {},
        icon: Icons.circle,
        launchable: false,
      );
      expect(meta.launchable, isFalse);
    });

    test('params defaults to empty list', () {
      const meta = RouteMeta(
        title: 'T',
        description: '',
        keywords: [],
        kind: NavKind.routePath,
        roles: {},
        icon: Icons.circle,
      );
      expect(meta.params, isEmpty);
    });

    test('NavKind has routePath, routeName, widgetBuilder values', () {
      expect(NavKind.values, containsAll([
        NavKind.routePath,
        NavKind.routeName,
        NavKind.widgetBuilder,
      ]));
    });
  });
}
