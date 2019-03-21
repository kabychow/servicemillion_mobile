import 'package:flutter/material.dart';
import 'package:servicemillion/helpers/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicemillion/helpers/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:servicemillion/pages/chat.dart';
import 'package:servicemillion/pages/settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  final _apiKey;
  const HomePage(this._apiKey);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  bool _status = false;
  var _data = [];

  @override
  void initState() {
    super.initState();
    _loadFcm();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        menu: <Widget>[
          CustomButton(
            _status ? 'ONLINE  \u{25CF}' : 'AWAY  \u{25CB}',
            onPressed: _toggleStatus,
          ),
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: () => navigateTo(context, SettingsPage()),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            child: new Card(
              color: _data[index]['status'] == 1 ? Colors.green : Colors.red,
              child: new Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomText(
                      _data[index]['name'],
                      color: Colors.white,
                      size: 15,
                      weight: FontWeight.w500,
                    ),
                    CustomText(
                      _data[index]['email'],
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 3),
                    ),
                    Divider(
                      color: Colors.white,
                    ),
                    CustomText(
                      _data[index]['message'],
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
            onTap: _data[index]['status'] == 1 ? () async {
              navigateTo(context, ChatPage(widget._apiKey, _data[index]['id'], _data[index]['name'], _data[index]['email'], _data[index]['message']));
            } : () {}
          );
        },
      ),
    );
  }



  Future init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _status = prefs.getBool('status') ?? false);
    http.get('$HOST_API/chats', headers: {'Authorization': widget._apiKey}).then((response) {
      setState(() => _data = jsonDecode(response.body));
    });
  }

  Future _toggleStatus() async {
    http.put('$HOST_API/users/me/status', body: {'status': _status ? '0' : '1'}, headers: {'Authorization': widget._apiKey}).then((response) async {
      if (response.statusCode == 200) {
        setState(() => _status = !_status);
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('status', _status);
      }
    });
  }

  void _loadFcm() {
    _fcm.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.getToken().then((token){
      http.put('$HOST_API/users/me/fcm_token', body: {'fcm_token': token}, headers: {'Authorization': widget._apiKey});
    });
    _fcm.configure(
      onMessage: (Map<String, dynamic> data) async {
        if (data['action'] == 'chat') init();
      },
      onResume: (Map<String, dynamic> data) async {
        if (data['action'] == 'chat') init();
      },
    );
  }
}
