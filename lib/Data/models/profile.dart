import 'package:flutter/foundation.dart';

class Profile {
  String? id;
  String name;
  String email;

  Profile({
    this.id,
    this.name = '',
    required this.email,
  });
}