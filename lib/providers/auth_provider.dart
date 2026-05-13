import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
      (ref) => AuthNotifier(),
    );

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _init() {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        state = const AsyncValue.data(null);
      } else {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          state = AsyncValue.data(UserModel.fromMap(doc.data()!, user.uid));
        } else {
          state = const AsyncValue.data(null);
        }
      }
    });
  }

  Future<void> register({
    required String name,
    required String username,
    required String password,
    required NDType ndType,
  }) async {
    state = const AsyncValue.loading();
    try {
      final email = '$username@neurofriend.app';
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = UserModel(
        uid: cred.user!.uid,
        name: name,
        username: username,
        ndType: ndType,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(user.uid).set(user.toMap());
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final email = '$username@neurofriend.app';
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      state = AsyncValue.data(UserModel.fromMap(doc.data()!, cred.user!.uid));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncValue.data(null);
  }
}
