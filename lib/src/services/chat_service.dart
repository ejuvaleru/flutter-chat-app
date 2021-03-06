import 'package:chat_app/src/globals/environment.dart';
import 'package:chat_app/src/models/chat_mensaje_response.dart';
import 'package:chat_app/src/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:chat_app/src/models/usuario.dart';

class ChatService with ChangeNotifier {
  Usuario usuarioDestino;

  Future<List<LastMesanje>> getChat(String usuarioID) async {
    final response = await http.get('${Environment.apiUrl}/mensajes/$usuarioID',
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken()
        });

        final mensajesResponse = chatMensajeResponseFromJson(response.body);

        return mensajesResponse.lastMesanjes;
  }
}
