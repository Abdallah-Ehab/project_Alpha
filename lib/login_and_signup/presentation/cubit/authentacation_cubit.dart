
import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

//the cubit

class AuthCubit extends Cubit<AuthState> {
  final SupabaseClient _supabase;
  late final StreamSubscription _authSub;

  AuthCubit(this._supabase) : super(AuthInitial()) {
    // Check current session at startup
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      emit(Authenticated(session!.user));
    } else {
      emit(Unauthenticated());
    }

    // Listen for auth state changes
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        emit(Authenticated(session.user));
      } else if (event == AuthChangeEvent.signedOut) {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      log(e.toString());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final session = response.session;
      if (session?.user != null) {
        emit(Authenticated(session!.user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      log(e.toString());
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _supabase.auth.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }





}