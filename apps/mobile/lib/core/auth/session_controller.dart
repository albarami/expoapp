import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_user.dart';
import 'token_storage.dart';

/// Session lifecycle states from `13_NAVIGATION_AND_STATE.md`.
enum SessionStatus {
  unknown,
  unauthenticated,
  authenticating,
  authenticated,
  expired,
}

@immutable
class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.accessToken,
  });

  final SessionStatus status;
  final AppUser? user;
  final String? accessToken;

  bool get isAuthenticated =>
      status == SessionStatus.authenticated && user != null;

  SessionState copyWith({
    SessionStatus? status,
    AppUser? user,
    String? accessToken,
    bool clearUser = false,
    bool clearToken = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      accessToken: clearToken ? null : (accessToken ?? this.accessToken),
    );
  }

  static const unknown = SessionState(status: SessionStatus.unknown);
  static const unauthenticated =
      SessionState(status: SessionStatus.unauthenticated);
}

/// Foundation session controller — restores tokens; full `/auth/me` in T-MOB-02.
class SessionController extends StateNotifier<SessionState> {
  SessionController(this._tokenStorage) : super(SessionState.unknown) {
    restore();
  }

  final TokenStorage _tokenStorage;

  Future<void> restore() async {
    state = state.copyWith(status: SessionStatus.unknown);
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      state = SessionState.unauthenticated;
      return;
    }

    final cached = await _tokenStorage.readCurrentUserJson();
    if (cached != null && cached.isNotEmpty) {
      try {
        final user =
            AppUser.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        state = SessionState(
          status: SessionStatus.authenticated,
          user: user,
          accessToken: token,
        );
        return;
      } on FormatException {
        // Fall through to unauthenticated if cache is corrupt.
      }
    }

    // Token present but no user cache yet — treat as unauthenticated until
    // T-MOB-02 wires `/auth/me`. Clear stale token to avoid half-sessions.
    await _tokenStorage.clear();
    state = SessionState.unauthenticated;
  }

  Future<void> setAuthenticated({
    required AppUser user,
    required String accessToken,
    String? refreshToken,
  }) async {
    await _tokenStorage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _tokenStorage.writeCurrentUserJson(jsonEncode(user.toJson()));
    state = SessionState(
      status: SessionStatus.authenticated,
      user: user,
      accessToken: accessToken,
    );
  }

  Future<void> markExpired() async {
    await _tokenStorage.clear();
    state = const SessionState(status: SessionStatus.expired);
  }

  Future<void> signOut() async {
    await _tokenStorage.clear();
    state = SessionState.unauthenticated;
  }
}
