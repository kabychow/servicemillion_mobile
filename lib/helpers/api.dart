import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const HOST = 'http://172.20.10.2/servicemillion_api';
  SharedPreferences prefs;
  String key;

  Future init() async {
    prefs = await SharedPreferences.getInstance();
    key = prefs.getString('api_key');
  }

  Future<_Response> login(String email, String password) async =>
      _Response(await http
          .post('$HOST/auth', body: {'email': email, 'password': password}));

  Future<_Response> updateFcmToken(String token) async =>
      _Response(await http.put('$HOST/users/me/fcm_token',
          body: {'fcm_token': token}, headers: {'Authorization': key}));

  Future<_Response> getChats() async =>
      _Response(await http.get('$HOST/chats', headers: {'Authorization': key}));

  Future<_Response> getTickets() async => _Response(
      await http.get('$HOST/tickets', headers: {'Authorization': key}));

  Future<_Response> getResponses() async => _Response(
      await http.get('$HOST/responses', headers: {'Authorization': key}));
}

class _Response {
  final http.Response response;
  _Response(this.response);

  get code => response.statusCode;
  get data => (response.body.length > 0) ? jsonDecode(response.body) : [];
}
