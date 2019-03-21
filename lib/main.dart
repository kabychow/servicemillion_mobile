import 'package:flutter/material.dart';
import 'package:servicemillion/helpers/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicemillion/pages/login.dart';
import 'package:servicemillion/pages/home.dart';

Future main() async {
  final _prefs = await SharedPreferences.getInstance();
  final _apiKey = _prefs.getString('api_key');

  runApp(new MaterialApp(
    title: 'Superceed',
    theme: ThemeData(
      primarySwatch: CustomColors.PRIMARY,
    ),
    home: _apiKey == null ? LoginPage() : HomePage(_apiKey),
    debugShowCheckedModeBanner: false,
  ));
}
