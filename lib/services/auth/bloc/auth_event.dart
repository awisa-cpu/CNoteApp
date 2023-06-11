import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}


class AuthEventSendEmailVerification extends AuthEvent{
  const AuthEventSendEmailVerification();
}

class AuthEventRegister extends AuthEvent{
  final String email;
  final String passowrd;
  const AuthEventRegister(this.email, this.passowrd);
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}

class AuthEventRoute extends AuthEvent{
  final String? routeName;
  const AuthEventRoute(this.routeName);
}