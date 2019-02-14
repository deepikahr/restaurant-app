import 'package:flutter/material.dart';
import 'login-bloc.dart';

class LoginStateProvider extends InheritedWidget {
  final LoginBloc loginBloc = LoginBloc();

  LoginStateProvider({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_) => true;

  static LoginBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(LoginStateProvider)
            as LoginStateProvider)
        .loginBloc;
  }
}
