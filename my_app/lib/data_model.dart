// To parse this JSON data, do
//
//     final dataModel = dataModelFromJson(jsonString);

import 'dart:convert';

DataModel dataModelFromJson(String str) => DataModel.fromJson(json.decode(str));

String dataModelToJson(DataModel data) => json.encode(data.toJson());

class DataModel {
    String title;
    bool staffOnly;
    List<LastMessage> lastMessages;
    String user;
    int messageCount;

    DataModel({
        this.title,
        this.staffOnly,
        this.lastMessages,
        this.user,
        this.messageCount,
    });

    factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
        title: json["title"],
        staffOnly: json["staff_only"],
        lastMessages: List<LastMessage>.from(json["last_messages"].map((x) => LastMessage.fromJson(x))),
        user: json["user"],
        messageCount: json["message_count"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "staff_only": staffOnly,
        "last_messages": List<dynamic>.from(lastMessages.map((x) => x.toJson())),
        "user": user,
        "message_count": messageCount,
    };
}

class LastMessage {
    String author;
    String message;
    DateTime timestamp;

    LastMessage({
        this.author,
        this.message,
        this.timestamp,
    });

    factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        author: json["author"],
        message: json["message"],
        timestamp: DateTime.parse(json["timestamp"]),
    );

    Map<String, dynamic> toJson() => {
        "author": author,
        "message": message,
        "timestamp": timestamp.toIso8601String(),
    };
}