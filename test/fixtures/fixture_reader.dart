import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class FixtureJson {
  FixtureJson(this.name);

  final String name;

  Future<String> loadJson() async {
    return await rootBundle.loadString('assets/$name');
  }
}
