import 'package:flutter/material.dart';

class NotificationModel {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final bool isRead;

  const NotificationModel({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.isRead,
  });

  NotificationModel copyWith({
    String? title,
    String? description,
    String? time,
    IconData? icon,
    bool? isRead,
  }) {
    return NotificationModel(
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
    );
  }
}