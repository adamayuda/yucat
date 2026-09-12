import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ProfileInitialEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class LogoutTapEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class DeleteAccountTapEvent extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class LoginTapEvent extends ProfileEvent {
  final BuildContext context;

  const LoginTapEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

class ResetOnboardingTapEvent extends ProfileEvent {
  final BuildContext context;

  const ResetOnboardingTapEvent({required this.context});

  @override
  List<Object?> get props => [context];
}

/// QA: sign out of Firebase, RevenueCat and OneSignal, clear local data and
/// restart from splash as a brand-new user. See `QaResetService`.
class ResetTestUserTapEvent extends ProfileEvent {
  final BuildContext context;

  const ResetTestUserTapEvent({required this.context});

  @override
  List<Object?> get props => [context];
}
