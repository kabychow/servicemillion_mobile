import 'package:flutter/material.dart';
import 'package:servicemillion/helpers/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicemillion/pages/login.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _messageController = TextEditingController();
  String greetings = '';

  @override
  void initState() {
    super.initState();
    _getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: ListView(
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Greetings'),
                  Divider(color: Colors.grey),
                  CustomTextField(
                    'Type your messages here...',
                    controller: _messageController,
                    type: TextInputType.multiline,
                    maxLines: 3,
                    onChanged: (text) => _setPrefs(),
                    margin: EdgeInsets.all(0),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text('Logout'),
            onTap: _logout,
          )
        ],
      ),
    );
  }

  Future _getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _messageController.text = prefs.getString('greetings') ?? '';
    });
  }

  Future _setPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('greetings', _messageController.text);
    });
  }

  Future _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    navigateTo(context, LoginPage(), replace: true);
  }
}
