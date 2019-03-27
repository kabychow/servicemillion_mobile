import 'package:flutter/material.dart';
import 'package:servicemillion/helpers/api.dart';
import 'package:servicemillion/pages/home.dart';

class LoginPage extends StatefulWidget {
  final Api _api;
  const LoginPage(this._api);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Image.asset('assets/logo.png', height: 20),
            Text('  Superceed'),
          ],
        ),
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 10)),
          Text('Please sign in to continue'),
          Padding(padding: EdgeInsets.only(top: 15)),
          TextField(
            decoration: InputDecoration(labelText: 'Email Address'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
            controller: _password,
            obscureText: true,
          ),
          Padding(padding: EdgeInsets.only(top: 25)),
          RaisedButton(
            child: Text('Login'),
            padding: EdgeInsets.all(18),
            elevation: 0,
            color: Theme.of(context).primaryColor,
            colorBrightness: Brightness.dark,
            onPressed: _login,
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          FlatButton(
            child: Text('Forgot password?'),
            onPressed: () {},
          ),
        ],
        padding: EdgeInsets.all(15),
      ),
    );
  }

  Future _login() async {
    final email = _email.text.trim();
    final password = _password.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      final response = await widget._api.login(email, password);
      if (response.code == 200) {
        widget._api.key = response.data['api_key'];
        widget._api.prefs.setString('api_key', response.data['api_key']);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage(widget._api)), (_) => false);
      } else if (response.code == 401) {
        error('Incorrect credentials');
      } else if (response.code == 422) {
        error('Invalid format for input data');
      } else {
        error('Unknown server error occurred');
      }
    } else {
      error('All fields are required');
    }
  }

  void error(message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Login failed'),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
