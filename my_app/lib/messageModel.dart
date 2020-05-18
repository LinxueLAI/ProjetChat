// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
    String author;
    String message;
    DateTime timestamp;
    int room;

    MessageModel({
        this.author,
        this.message,
        // this.timestamp,
        this.room,
    });

    factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        author: json["author"],
        message: json["message"],
        // timestamp: DateTime.parse(json["timestamp"]),
        room: json["room"],
    );

    Map<String, dynamic> toJson() => {
        "author": author,
        "message": message,
        // "timestamp": timestamp.toIso8601String(),
        "room": room,
    };
}