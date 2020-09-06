import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:chat_app/src/globals/environment.dart';
import 'package:chat_app/src/models/login_response.dart';
import 'package:chat_app/src/models/usuario.dart';

class AuthService with ChangeNotifier {
  Usuario usuario;
  bool _estaAutenticando = false;

  // Create storage
  final _storage = new FlutterSecureStorage();

  bool get estaAutenticando => this._estaAutenticando;
  set estaAutenticando(bool valor) {
    this._estaAutenticando = valor;
    notifyListeners();
  }

  // Getter del token de forma estática
  static Future<String> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');

    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    this.estaAutenticando = true;
    final data = {'email': email, 'password': password};

    final response = await http.post('${Environment.apiUrl}/login',
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final loginResponse = loginResponseFromJson(response.body);

      print(response.body);
      this.usuario = loginResponse.usuario;
      await this.saveToken(loginResponse.token);
      this.estaAutenticando = false;
      return true;
    } else {
      this.estaAutenticando = false;
      return false;
    }
  }

  Future registerWithEmailAndPassword(
      String nombre, String email, String password) async {
    this.estaAutenticando = true;
    final data = {'nombre': nombre, 'email': email, 'password': password};

    final response = await http.post('${Environment.apiUrl}/login/new',
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final loginResponse = loginResponseFromJson(response.body);
      this.usuario = loginResponse.usuario;
      await this.saveToken(loginResponse.token);
      this.estaAutenticando = false;
      return true;
    } else {
      this.estaAutenticando = false;
      final respBody = jsonDecode(response.body);
      return respBody['msg'];
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await this._storage.read(key: 'token');

    final response = await http.get('${Environment.apiUrl}/login/renew',
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (response.statusCode == 200) {
      final loginResponse = loginResponseFromJson(response.body);
      this.usuario = loginResponse.usuario;
      await this.saveToken(loginResponse.token);
      return true;
    } else {
      this.logOut();
      return false;
    }
  }

  Future saveToken(String token) async {
    // Write value
    return await _storage.write(key: 'token', value: token);
  }

  Future logOut() async {
    // Delete value
    await _storage.delete(key: 'token');
  }
}
