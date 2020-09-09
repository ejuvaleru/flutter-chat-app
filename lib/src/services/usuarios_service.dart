import 'package:http/http.dart' as http;

import 'package:chat_app/src/services/auth_service.dart';

import 'package:chat_app/src/globals/environment.dart';

import 'package:chat_app/src/models/usuarios_response.dart';
import 'package:chat_app/src/models/usuario.dart';

class UsuariosService {
  Future<List<Usuario>> getUsuarios() async {
    try {
      final response =
          await http.get('${Environment.apiUrl}/usuarios', headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken(),
      });

      final usuariosResponse = usuariosResponseFromJson(response.body);

      return usuariosResponse.usuarios;
    } catch (e) {
      return [];
    }
  }
}
