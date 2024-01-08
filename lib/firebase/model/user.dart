import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class User {
  final String name;
  final String email;
  final String department;
  final String team;
  final String? bugyoId;
  final String? bugyoPassword;
  final String deviceId;
  final bool? isLocation;
  final Array? location;
  final String? vmartId;
  final DateTime createdAt;

  const User({
    required this.name,
    required this.email,
    required this.department,
    required this.team,
    required this.deviceId,
    this.bugyoId,
    this.bugyoPassword,
    this.isLocation,
    this.location,
    this.vmartId,
    required this.createdAt,
  });

  User.fromJson(Map<String, Object?> json)
      : this(
          name: json["name"] as String,
          email: json["email"] as String,
          department: json["department"] as String,
          team: json["team"] as String,
          deviceId: json["deviceId"] as String,
          isLocation: json["isLocation"] as bool,
          createdAt: (json['createdAt']! as Timestamp).toDate() as DateTime,
        );

  // insert
  Map<String, Object?> insertUserData() {
    return {
      "name": name,
      "email": email,
      "department": department,
      "team": team,
      "deviceId": deviceId,
      "bugyoId": null,
      "bugyoPassword": null,
      "isLocation": false,
      "location": null,
      "vmartId": null,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  // update
  Map<String, Object> updateUserData() {
    return {};
  }
}
