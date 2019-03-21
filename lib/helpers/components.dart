import 'package:flutter/material.dart';

class CustomColors {
  static const PRIMARY = Colors.blue;
  static const PRIMARY_DARK = Colors.blue;
  static const ACCENT = Colors.blueAccent;
}

class CustomAppBar extends AppBar {
  CustomAppBar({String title, List<Widget> menu})
      : super(
          title: title == null
              ? Row(
                  children: <Widget>[
                    Image.asset('assets/logo.png', height: 23),
                    Text('  Superceed'),
                  ],
                )
              : Text(title),
          actions: menu,
          elevation: 0,
        );
}

class CustomTabBar extends TabBar {
  CustomTabBar(List<Widget> tabs)
      : super(
          tabs: tabs,
          isScrollable: true,
          indicator: BoxDecoration(
            color: CustomColors.PRIMARY_DARK,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: CustomColors.PRIMARY,
              width: 5,
            ),
          ),
        );
}

class CustomText extends Padding {
  CustomText(String text, {EdgeInsets margin = EdgeInsets.zero, double size, FontWeight weight, Color color})
      : super(
          child: Text(
            text,
            style: TextStyle(
              fontSize: size,
              fontWeight: weight,
              color: color,
            ),
          ),
          padding: margin,
        );
}

class CustomTextField extends Padding {
  CustomTextField(String hint,
      {TextEditingController controller,
      ValueChanged<String> onChanged,
      bool password = false,
      EdgeInsets margin = EdgeInsets.zero,
      TextInputType type = TextInputType.text,
      bool autocorrect = true,
      int maxLines,
      String value = ''})
      : super(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
            ),
            obscureText: password,
            keyboardType: type,
            autocorrect: autocorrect,
            style: TextStyle(height: 1.5),
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
          ),
          padding: margin,
        );
}

class CustomButton extends Padding {
  CustomButton(String text, {VoidCallback onPressed, EdgeInsets padding, EdgeInsets margin = EdgeInsets.zero})
      : super(
          child: RaisedButton(
            child: Text(text),
            onPressed: onPressed,
            padding: padding,
            elevation: 0,
            colorBrightness: Brightness.dark,
            color: CustomColors.PRIMARY,
          ),
          padding: margin,
        );
}

class CustomButtonLight extends Padding {
  CustomButtonLight(String text, {VoidCallback onPressed, EdgeInsets padding, EdgeInsets margin = EdgeInsets.zero})
      : super(
          child: FlatButton(
            child: Text(text),
            onPressed: onPressed,
            padding: padding,
          ),
          padding: margin,
        );
}

void alert(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
  );
}

void navigateTo(BuildContext context, Widget page, {bool replace = false}) {
  if (!replace) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  } else {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => page), (_) => false);
  }
}
