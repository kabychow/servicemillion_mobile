import 'package:flutter/material.dart';
import 'package:servicemillion/helpers/api.dart';
import 'package:servicemillion/pages/login.dart';
import 'package:servicemillion/pages/home.dart';

Future main() async {
  final _api = Api();
  await _api.init();

  runApp(new MaterialApp(
    title: 'Superceed',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: _api.key == null ? LoginPage(_api) : HomePage(_api),
    debugShowCheckedModeBanner: false,
  ));
}
