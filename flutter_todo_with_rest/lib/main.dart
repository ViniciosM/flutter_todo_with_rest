import 'package:flutter/material.dart';
import 'package:flutter_todo_with_rest/providers/auth.dart';
import 'package:flutter_todo_with_rest/providers/todo.dart';
import 'package:flutter_todo_with_rest/views/loading.dart';
import 'package:flutter_todo_with_rest/views/login.dart';
import 'package:flutter_todo_with_rest/views/password_resert.dart';
import 'package:flutter_todo_with_rest/views/register.dart';
import 'package:flutter_todo_with_rest/views/todos.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/':(context) => Router(),
          '/login':(context) => LogIn(),
          '/register':(context) => Register(),
          '/password-reset': (context) => PasswordReset(),
        },
      )
    )
  );
}

class Router extends StatelessWidget {
  const Router({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);

    return Consumer<AuthProvider>(
      builder: (context, user, child){
        switch (user.status) {
          case Status.Uninitialized:
          return Loading();
          case Status.Unauthenticated:
          return LogIn();
          case Status.Authenticated:
          return ChangeNotifierProvider(
            create: (context) => TodoProvider(authProvider),
            child: Todos(),
          );
          default:
          return LogIn();
        }
      },
    );
  }
}

