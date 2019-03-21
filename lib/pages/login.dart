import 'package:flutter/material.dart';
import 'package:servicemillion/helpers/components.dart';
import 'package:servicemillion/helpers/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servicemillion/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: ListView(
        children: <Widget>[
          CustomText(
            'Please sign in to continue',
            margin: EdgeInsets.only(top: 10),
          ),
          CustomTextField(
            'Email Address',
            controller: _email,
            type: TextInputType.emailAddress,
            margin: EdgeInsets.only(top: 15),
          ),
          CustomTextField(
            'Password',
            controller: _password,
            password: true,
            margin: EdgeInsets.only(top: 10),
          ),
          CustomButton(
            'Login',
            onPressed: _login,
            padding: EdgeInsets.all(18),
            margin: EdgeInsets.only(top: 25),
          ),
          CustomButtonLight(
            'Don\'t have an account? Register now!',
            onPressed: () => {},
            margin: EdgeInsets.only(top: 10),
          ),
          CustomButtonLight(
            'Forgot password?',
            onPressed: () => {},
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
      final response = await http.post('$HOST_API/auth', body: {'email': email, 'password': password});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('api_key', data['api_key']);
        prefs.setBool('status', data['status'] == 1);
        navigateTo(context, HomePage(data['api_key']), replace: true);
      } else if (response.statusCode == 401) {
        alert(context, 'Login failed', 'Incorrect credentials');
      } else if (response.statusCode == 422) {
        alert(context, 'Login failed', 'Invalid format for input data');
      } else {
        alert(context, 'Login failed', 'Unknown server error occurred');
      }
    } else {
      alert(context, 'Login failed', 'All fields are required');
    }
  }
}
