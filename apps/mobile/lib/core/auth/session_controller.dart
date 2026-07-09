import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_repository.dart';
import '../api/api_error.dart';
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
    this.errorMessage,
  });

  final SessionStatus status;
  final AppUser? user;
  final String? accessToken;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == SessionStatus.authenticated && user != null;

  bool get isBootstrapping => status == SessionStatus.unknown;

  bool get isAuthenticating => status == SessionStatus.authenticating;

  SessionState copyWith({
    SessionStatus? status,
    AppUser? user,
    String? accessToken,
    String? errorMessage,
    bool clearUser = false,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      accessToken: clearToken ? null : (accessToken ?? this.accessToken),
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const unknown = SessionState(status: SessionStatus.unknown);
  static const unauthenticated =
      SessionState(status: SessionStatus.unauthenticated);
}

/// Auth session controller: login, `/auth/me` restore, logout, 401 expiry.
class SessionController extends StateNotifier<SessionState> {
  SessionController({
    required this.tokenStorage,
    required this.authRepository,
  }) : super(SessionState.unknown) {
    ready = restore();
  }

  final TokenStorage tokenStorage;
  final AuthRepository authRepository;

  /// Completes when the initial [restore] finishes.
  late final Future<void> ready;

  /// Loads token from secure storage and validates via `/auth/me`.
  Future<void> restore() async {
    state = state.copyWith(
      status: SessionStatus.unknown,
      clearError: true,
    );
    final token = await tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      state = SessionState.unauthenticated;
      return;
    }

    try {
      final user = await authRepository.fetchCurrentUser();
      await tokenStorage.writeCurrentUserJson(jsonEncode(user.toJson()));
      state = SessionState(
        status: SessionStatus.authenticated,
        user: user,
        accessToken: token,
      );
    } on ApiError catch (error) {
      await tokenStorage.clear();
      if (error.isUnauthorized) {
        state = const SessionState(status: SessionStatus.expired);
        return;
      }
      // Prefer cached profile for transient network failures so cold start
      // still reaches the shell; next API call will re-validate.
      final cached = await tokenStorage.readCurrentUserJson();
      if (cached != null && cached.isNotEmpty && error.isNetwork) {
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
          // Fall through.
        }
      }
      await tokenStorage.clear();
      state = SessionState.unauthenticated;
    } catch (_) {
      await tokenStorage.clear();
      state = SessionState.unauthenticated;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: SessionStatus.authenticating,
      clearError: true,
      clearUser: true,
      clearToken: true,
    );
    try {
      final session = await authRepository.login(
        email: email,
        password: password,
      );
      await setAuthenticated(
        user: session.user,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return true;
    } on ApiError catch (error) {
      state = SessionState(
        status: SessionStatus.unauthenticated,
        errorMessage: error.message,
      );
      return false;
    } catch (error) {
      state = SessionState(
        status: SessionStatus.unauthenticated,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<void> setAuthenticated({
    required AppUser user,
    required String accessToken,
    String? refreshToken,
  }) async {
    await tokenStorage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await tokenStorage.writeCurrentUserJson(jsonEncode(user.toJson()));
    state = SessionState(
      status: SessionStatus.authenticated,
      user: user,
      accessToken: accessToken,
    );
  }

  Future<void> markExpired() async {
    await tokenStorage.clear();
    state = const SessionState(
      status: SessionStatus.expired,
      errorMessage: null,
    );
  }

  Future<void> clearExpiredBanner() async {
    if (state.status == SessionStatus.expired) {
      state = SessionState.unauthenticated;
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.logout();
    } on ApiError {
      // Always clear local session even if the network call fails.
    } catch (_) {
      // Ignore unexpected logout transport errors.
    }
    await tokenStorage.clear();
    state = SessionState.unauthenticated;
  }
}
