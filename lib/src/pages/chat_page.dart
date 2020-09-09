import 'dart:io';

import 'package:chat_app/src/models/chat_mensaje_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/src/services/auth_service.dart';
import 'package:chat_app/src/services/socket_service.dart';

import 'package:chat_app/src/services/chat_service.dart';
import 'package:chat_app/src/widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  ChatService chatService;
  SocketService socketService;
  AuthService authService;

  List<ChatBubble> _messages = [];

  bool _isWriting = false;

  @override
  void initState() {
    super.initState();

    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    this.socketService.socket.on('mensaje-personal', _escucharMensajes);

    _cargarHistorial(this.chatService.usuarioDestino.uid);
  }

  void _cargarHistorial(String uid) async {
    List<LastMesanje> chat = await this.chatService.getChat(uid);

    final historial = chat.map(
      (m) => new ChatBubble(
        texto: m.mensaje,
        uid: m.origen,
        animationController: new AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 100),
        )..forward(),
      ),
    );

    setState(() {
      _messages.insertAll(0, historial);
    });
  }

  void _escucharMensajes(dynamic data) {
    ChatBubble message = new ChatBubble(
        texto: data['mensaje'],
        uid: data['desde'],
        animationController: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 200),
        ));

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final usuarioDestino = chatService.usuarioDestino;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(
                usuarioDestino.nombre.substring(0, 1),
                style: TextStyle(fontSize: 12.0),
              ),
              backgroundColor: Colors.blue.shade100,
              maxRadius: 14.0,
            ),
            SizedBox(
              height: 3.0,
            ),
            Text(usuarioDestino.nombre,
                style: TextStyle(color: Colors.black87, fontSize: 12))
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
              ),
            ),
            Divider(
              height: 1,
            ),
            Container(
              color: Colors.white,
              child: _inputChat(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (String texto) {
                  setState(() {
                    if (texto.trim().length > 0) {
                      _isWriting = true;
                    } else {
                      _isWriting = false;
                    }
                  });
                },
                decoration:
                    InputDecoration.collapsed(hintText: 'Escribe tu rmensaje'),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: _isWriting
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                      child: Text('Enviar'),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconTheme(
                        data: IconThemeData(color: Colors.blue.shade400),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(
                            Icons.send,
                          ),
                          onPressed: _isWriting
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String texto) {
    if (texto.length == 0) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = new ChatBubble(
      uid: authService.usuario.uid,
      texto: texto,
      animationController: new AnimationController(
          vsync: this, duration: Duration(milliseconds: 250)),
    );
    _messages.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _isWriting = false;
    });

    this.socketService.socket.emit('mensaje-personal', {
      'origen': this.authService.usuario.uid,
      'destino': this.chatService.usuarioDestino.uid,
      'mensaje': texto
    });
  }

  @override
  void dispose() {
    // Off del socket cuando lo tenga
    for (ChatBubble message in _messages) {
      message.animationController.dispose();
    }
    this.socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}
