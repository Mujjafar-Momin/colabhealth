import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:colabhealth/core/src/utils/app_enums.dart';
import 'package:colabhealth/core/src/utils/app_logger.dart';

class PedometerService {
  PedometerService._();

  static final PedometerService instance = PedometerService._();

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  Future<TrackingPermission> requestPermission() async {
    try {
      final status = await Permission.activityRecognition.request();
      if (status.isGranted) return TrackingPermission.granted;
      if (status.isPermanentlyDenied || status.isRestricted) {
        return TrackingPermission.restricted;
      }
      return TrackingPermission.denied;
    } catch (e) {
      AppLogger.error('activityRecognition permission', error: e);
      return TrackingPermission.unknown;
    }
  }

  Future<bool> get isGranted async => await Permission.activityRecognition.isGranted;

  void listenStepCount({required void Function(int totalSteps) onData, void Function(Object error)? onError}) {
    _stepSub?.cancel();
    _stepSub = Pedometer.stepCountStream.listen(
      (event) => onData(event.steps),
      onError: (e) {
        AppLogger.error('stepCountStream', error: e);
        onError?.call(e);
      },
      cancelOnError: false,
    );
  }

  void listenPedestrianStatus(void Function(String status) onData) {
    _statusSub?.cancel();
    _statusSub = Pedometer.pedestrianStatusStream.listen(
      (event) => onData(event.status),
      onError: (e) => AppLogger.error('pedestrianStatusStream', error: e),
      cancelOnError: false,
    );
  }

  void dispose() {
    _stepSub?.cancel();
    _statusSub?.cancel();
    _stepSub = null;
    _statusSub = null;
  }
}
