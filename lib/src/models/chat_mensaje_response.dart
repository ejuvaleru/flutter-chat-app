// To parse this JSON data, do
//
//     final chatMensajeResponse = chatMensajeResponseFromJson(jsonString);

import 'dart:convert';

ChatMensajeResponse chatMensajeResponseFromJson(String str) => ChatMensajeResponse.fromJson(json.decode(str));

String chatMensajeResponseToJson(ChatMensajeResponse data) => json.encode(data.toJson());

class ChatMensajeResponse {
    ChatMensajeResponse({
        this.ok,
        this.msg,
        this.lastMesanjes,
    });

    bool ok;
    String msg;
    List<LastMesanje> lastMesanjes;

    factory ChatMensajeResponse.fromJson(Map<String, dynamic> json) => ChatMensajeResponse(
        ok: json["ok"],
        msg: json["msg"],
        lastMesanjes: List<LastMesanje>.from(json["lastMesanjes"].map((x) => LastMesanje.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "msg": msg,
        "lastMesanjes": List<dynamic>.from(lastMesanjes.map((x) => x.toJson())),
    };
}

class LastMesanje {
    LastMesanje({
        this.origen,
        this.destino,
        this.mensaje,
        this.createdAt,
        this.updatedAt,
    });

    String origen;
    String destino;
    String mensaje;
    DateTime createdAt;
    DateTime updatedAt;

    factory LastMesanje.fromJson(Map<String, dynamic> json) => LastMesanje(
        origen: json["origen"],
        destino: json["destino"],
        mensaje: json["mensaje"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "origen": origen,
        "destino": destino,
        "mensaje": mensaje,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}
