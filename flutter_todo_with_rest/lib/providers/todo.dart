import 'package:flutter/material.dart';

import 'package:flutter_todo/providers/auth.dart';
import 'package:flutter_todo/utils/exceptions.dart';
import 'package:flutter_todo/utils/todo_response.dart';
import 'package:flutter_todo/services/api.dart';
import 'package:flutter_todo/models/todo.dart';
import 'package:flutter_todo_with_rest/providers/auth.dart';
import 'package:flutter_todo_with_rest/utils/exceptions.dart';
import 'package:flutter_todo_with_rest/utils/todo_response.dart';

import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  bool _initialized = false;

  // AuthProvier
  AuthProvider authProvider;

  // Stores separate lists for open and closed todos.
  List<Todo> _openTodos = List<Todo>();
  List<Todo> _closedTodos = List<Todo>();

  // The API is paginated. If there are more results we store
  // the API url in order to lazily load them later.
  String _openTodosApiMore; 
  String _closedTodosApiMore;

  // API Service
  ApiService apiService;

  // Provides access to private variables.
  bool get initialized => _initialized;
  List<Todo> get openTodos => _openTodos;
  List<Todo> get closedTodos => _closedTodos;
  String get openTodosApiMore => _openTodosApiMore;
  String get closedTodosApiMore => _closedTodosApiMore;

  // AuthProvider is required to instaniate our ApiService.
  // This gives the service access to the user token and provider methods.
  TodoProvider(AuthProvider authProvider) {
    this.apiService = ApiService(authProvider);
    this.authProvider = authProvider;

    init();
  }

  void init() async {
    try {
      TodoResponse openTodosResponse = apiService.getTodos('open');
      TodoResponse closedTodosResponse = apiService.getTodos('closed');

      _initialized = true;
      _openTodos = openTodosResponse.todos;
      _openTodosApiMore = openTodosResponse.apiMore;
      _closedTodos = closedTodosResponse.todos;
      _closedTodosApiMore = closedTodosResponse.apiMore;

      notifyListeners();
    } 
    on AuthException {
       // API returned a AuthException, so user is logged out.
      await authProvider.logOut(true);
    }
    catch(e){
      print(e);
    }
  }

}