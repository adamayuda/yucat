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

class RestorePurchasesTapEvent extends ProfileEvent {
  final BuildContext context;

  const RestorePurchasesTapEvent({required this.context});

  @override
  List<Object?> get props => [context];
}
