import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:chat_app/src/globals/environment.dart';
import 'package:chat_app/src/services/auth_service.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;


  void connect() async {

    final token = await AuthService.getToken();

    // Dart client
    this._socket = IO.io(Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
      'extraHeaders': {
        'x-token': token
      }
    });
    this._socket.on('connect', (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
    // socket.on('nuevo-mensaje', (payload) {
    //   print("nombre " + payload['nombre']);
    //   print("mensaje " + payload['mensaje']);
    //   // Para manejar excepciones en propiedades que no existen o no estamos seguros si contienen información
    //   // print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No existe');
    //   notifyListeners();
    // });
  }

  void disconnect (){
    this._socket.disconnect();
  }

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
}