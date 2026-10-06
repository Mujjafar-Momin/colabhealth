import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:colabhealth/core/src/utils/app_logger.dart';
import 'package:colabhealth/data/src/model/sleep_model.dart';
import 'package:colabhealth/data/src/model/steps_model.dart';
import 'package:colabhealth/data/src/model/user_model.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Future<void> upsertUser(UserModel user) async {
    try {
      await _userDoc(user.uid).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      AppLogger.error('upsertUser', error: e);
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final snap = await _userDoc(uid).get();
      if (!snap.exists) return null;
      return UserModel.fromJson(snap.data()!..putIfAbsent('uid', () => uid));
    } catch (e) {
      AppLogger.error('getUser', error: e);
      return null;
    }
  }

  Future<void> saveStepsDaily(String uid, StepsModel steps) async {
    try {
      await _userDoc(uid)
          .collection('stepsDaily')
          .doc(steps.date.toIso8601String().split('T').first)
          .set(steps.toJson(), SetOptions(merge: true));
    } catch (e) {
      AppLogger.error('saveStepsDaily', error: e);
    }
  }

  Future<List<StepsModel>> getStepsRange(String uid, {int days = 7}) async {
    try {
      final snap = await _userDoc(uid)
          .collection('stepsDaily')
          .orderBy('date', descending: true)
          .limit(days)
          .get();
      return snap.docs.map((d) => StepsModel.fromJson(d.data())).toList();
    } catch (e) {
      AppLogger.error('getStepsRange', error: e);
      return [];
    }
  }

  Future<void> saveSleepLog(String uid, SleepModel log) async {
    try {
      await _userDoc(uid).collection('sleepLogs').doc(log.id).set(log.toJson());
    } catch (e) {
      AppLogger.error('saveSleepLog', error: e);
    }
  }

  Future<void> deleteSleepLog(String uid, String id) async {
    try {
      await _userDoc(uid).collection('sleepLogs').doc(id).delete();
    } catch (e) {
      AppLogger.error('deleteSleepLog', error: e);
    }
  }

  Future<List<SleepModel>> getSleepLogs(String uid, {int limit = 30}) async {
    try {
      final snap = await _userDoc(uid)
          .collection('sleepLogs')
          .orderBy('sleepEnd', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => SleepModel.fromJson(d.data())).toList();
    } catch (e) {
      AppLogger.error('getSleepLogs', error: e);
      return [];
    }
  }
}
