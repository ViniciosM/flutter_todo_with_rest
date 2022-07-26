import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_todo_with_rest/widgets/notification_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthProvider with ChangeNotifier {
  Status _status = Status.Uninitialized;
  String _token = '';
  NotificationText? _notification;

  Status get status => _status;
  String get token => _token;
  NotificationText get notification => _notification!;

  final String api = 'https://laravelreact.com/api/v1/auth';

  initAuthProvider() async {
    String token = await getToken();
    if (token != null) {
      _token = token;
      _status = Status.Authenticated;
    } else {
      _status = Status.Unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = Status.Authenticating;
    _notification = null;
    notifyListeners();

    final url = '$api/login';

    Map<String, String> body = {
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri(path: url),
      body: body,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> apiResponse = json.decode(response.body);
      _status = Status.Authenticated;
      _token = apiResponse['access_token'];
      await storeUserData(apiResponse);

      notifyListeners();
      return true;
    } else if (response.statusCode == 401) {
      _status = Status.Unauthenticated;
      _notification = NotificationText('E-mail ou senha inválida');
      notifyListeners();
      return false;
    }

    _status = Status.Unauthenticated;
    _notification = NotificationText('Erro no servidor...');
    notifyListeners();
    return false;
  }

  Future<Map> register(String name, String email, String password,
      String passwordConfirm) async {
    final url = "$api/register";

    Map<String, String> body = {
      'name': name,
      'email': email,
      'password': password,
      'passwordConfirm': passwordConfirm,
    };

    Map<String, dynamic> result = {
      "success": false,
      "message": "Erro desconhecido.",
    };

    final response = await http.post(Uri(path: url), body: body);

    if (response.statusCode == 200) {
      _notification =
          NotificationText('Registro com sucesso! Fazer login.', type: 'info');
      notifyListeners();
      result['success'] = true;
      return result;
    }

    Map apiResponse = json.decode(response.body);

    if (response.statusCode == 422) {
      if (apiResponse['errors'].containsKey('email')) {
        result['message'] = apiResponse['errors']['email'][0];
        return result;
      }

      if (apiResponse['errors'].containsKey('password')) {
        result['message'] = apiResponse['errors']['password'][0];
        return result;
      }

      return result;
    }

    return result;
  }

  Future<bool> passwordReset(String email) async {
    final url = "$api/forgot-password";

    Map<String, String> body = {'email': email};

    final response = await http.post(Uri(path: url), body: body);

    if (response.statusCode == 200) {
      _notification = NotificationText(
          'Um link para redefinição de senha foi enviado para o e-mail informado');
      notifyListeners();
      return true;
    }

    return false;
  }

  storeUserData(apiResponse) async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setString('token', apiResponse['access_token']);
    await storage.setString('name', apiResponse['user']['name']);
  }

  Future<String> getToken() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    String token = storage.getString('token')!;
    return token;
  }

  logOut([bool tokenExpired = false]) async {
    _status = Status.Unauthenticated;
    if (tokenExpired == true) {
      _notification = NotificationText(
          'Sessão expirada, por favor, refaça o login novamente',
          type: 'info');
    }
    notifyListeners();

    SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.clear();
  }
}
