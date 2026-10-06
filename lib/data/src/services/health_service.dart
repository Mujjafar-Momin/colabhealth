import 'dart:io' show Platform;

import 'package:health/health.dart';

import 'package:colabhealth/core/src/utils/app_enums.dart';
import 'package:colabhealth/core/src/utils/app_logger.dart';
import 'package:colabhealth/data/src/model/sleep_model.dart';

class HealthService {
  HealthService._();

  static final HealthService instance = HealthService._();

  final Health _health = Health();

  static const List<HealthDataType> _stepTypes = [HealthDataType.STEPS];

  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<HealthStepsAvailability> stepsAvailability() async {
    try {
      await _ensureConfigured();
      if (!Platform.isAndroid) {
        return HealthStepsAvailability.available;
      }
      final status = await _health.getHealthConnectSdkStatus();
      switch (status) {
        case HealthConnectSdkStatus.sdkAvailable:
          return HealthStepsAvailability.available;
        case HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired:
          return HealthStepsAvailability.needsInstall;
        case HealthConnectSdkStatus.sdkUnavailable:
        default:
          return HealthStepsAvailability.needsInstall;
      }
    } catch (e) {
      AppLogger.error('stepsAvailability', error: e);
      return HealthStepsAvailability.notSupported;
    }
  }

  Future<void> installHealthConnect() async {
    try {
      await _ensureConfigured();
      await _health.installHealthConnect();
    } catch (e) {
      AppLogger.error('installHealthConnect', error: e);
    }
  }

  Future<bool> hasStepsPermission() async {
    try {
      await _ensureConfigured();
      return await _health.hasPermissions(_stepTypes, permissions: const [HealthDataAccess.READ]) ?? false;
    } catch (e) {
      AppLogger.error('hasStepsPermission', error: e);
      return false;
    }
  }

  Future<bool> requestStepsAuthorization() async {
    try {
      await _ensureConfigured();
      return await _health.requestAuthorization(_stepTypes, permissions: const [HealthDataAccess.READ]);
    } catch (e) {
      AppLogger.error('requestStepsAuthorization', error: e);
      return false;
    }
  }

  Future<int?> todaySteps() async {
    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      return await _health.getTotalStepsInInterval(midnight, now);
    } catch (e) {
      AppLogger.error('todaySteps', error: e);
      return null;
    }
  }

  static const List<HealthDataType> _sleepTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_SESSION,
  ];

  Future<bool> requestAuthorization() async {
    try {
      await _health.configure();
      return await _health.requestAuthorization(
        _sleepTypes,
        permissions: List.filled(_sleepTypes.length, HealthDataAccess.READ),
      );
    } catch (e) {
      AppLogger.error('health requestAuthorization', error: e);
      return false;
    }
  }

  Future<SleepModel?> importLastNight() async {
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(hours: 24));

      final points = await _health.getHealthDataFromTypes(types: _sleepTypes, startTime: from, endTime: now);
      if (points.isEmpty) return null;

      final deep = <SleepStageInterval>[];
      final rem = <SleepStageInterval>[];
      final light = <SleepStageInterval>[];
      final awake = <AwakePeriod>[];
      DateTime? sessionStart;
      DateTime? sessionEnd;

      for (final p in points) {
        final s = p.dateFrom;
        final e = p.dateTo;
        switch (p.type) {
          case HealthDataType.SLEEP_DEEP:
            deep.add(SleepStageInterval(s, e));
            break;
          case HealthDataType.SLEEP_REM:
            rem.add(SleepStageInterval(s, e));
            break;
          case HealthDataType.SLEEP_LIGHT:
          case HealthDataType.SLEEP_ASLEEP:
            light.add(SleepStageInterval(s, e));
            break;
          case HealthDataType.SLEEP_AWAKE:
            awake.add(AwakePeriod(s, e));
            break;
          case HealthDataType.SLEEP_SESSION:
            sessionStart = (sessionStart == null || s.isBefore(sessionStart)) ? s : sessionStart;
            sessionEnd = (sessionEnd == null || e.isAfter(sessionEnd)) ? e : sessionEnd;
            break;
          default:
            break;
        }
      }

      final all = [...deep, ...rem, ...light];
      sessionStart ??= all
          .map((e) => e.start)
          .fold<DateTime?>(null, (acc, d) => acc == null || d.isBefore(acc) ? d : acc);
      sessionEnd ??= all.map((e) => e.end).fold<DateTime?>(null, (acc, d) => acc == null || d.isAfter(acc) ? d : acc);

      if (sessionStart == null || sessionEnd == null) return null;

      return SleepModel(
        sleepStart: sessionStart,
        sleepEnd: sessionEnd,
        deep: deep,
        rem: rem,
        light: light,
        awakePeriods: awake,
        source: 'health',
      );
    } catch (e) {
      AppLogger.error('importLastNight', error: e);
      return null;
    }
  }
}
