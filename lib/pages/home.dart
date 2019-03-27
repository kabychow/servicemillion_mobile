import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:servicemillion/helpers/api.dart';
import 'package:servicemillion/pages/chat.dart';
import 'package:servicemillion/pages/login.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  final Api _api;
  const HomePage(this._api);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _chats = [], _tickets = [], _responses = [];

  @override
  void initState() {
    super.initState();
    _loadFcm();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: <Widget>[
                Image.asset('assets/logo.png', height: 20),
                Text('  Superceed'),
              ],
            ),
            elevation: 0,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Chats'),
                Tab(text: 'Tickets'),
                Tab(text: 'Responses'),
                Tab(text: 'Settings'),
              ],
              isScrollable: true,
              indicator: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 5,
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _tabChats(),
              _tabTickets(),
              _tabResponses(),
              _tabSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabChats() {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 4.0,
          margin: new EdgeInsets.only(top: 8, left: 5, right: 5),
          child: Container(
            decoration: BoxDecoration(color: Colors.green[600]),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _chats[index]['name'],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  Padding(padding: EdgeInsets.only(top: 3)),
                  Text(
                    _chats[index]['email'],
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                  Text(
                    _chats[index]['message'],
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
              onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => ChatPage(widget._api, _chats[index]['id'], _chats[index]['name'], _chats[index]['message'])),
                  (_) => false),
            ),
          ),
        );
      },
    );
  }

  Widget _tabTickets() {
    return ListView.builder(
      itemCount: _tickets.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 4.0,
          margin: new EdgeInsets.only(top: 8, left: 5, right: 5),
          child: Container(
            decoration: BoxDecoration(color: Colors.red[400]),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _tickets[index]['name'],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  Padding(padding: EdgeInsets.only(top: 3)),
                  Text(
                    _tickets[index]['email'],
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                  Text(
                    _tickets[index]['message'],
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Reply as email'),
                        content: TextField(
                          decoration: InputDecoration(hintText: 'Body'),
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('CANCEL'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FlatButton(
                              child: Text('SEND'),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _tabResponses() {
    return ListView.builder(
        itemCount: _responses.length,
        itemBuilder: (_, index) {
          List<Widget> children = [];
          _responses[index]['data'].forEach((key, value) {
            if (value is List) {
              String tmp = '';
              for (final val in value) {
                tmp += "$val\n";
              }
              value = tmp.substring(0, tmp.length - 1);
            }
            children.add(ListTile(
                title: Text("$key"),
                subtitle: Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text("$value"),
                ),
                onTap: () {
                  Clipboard.setData(new ClipboardData(text: "$value"));
                }));
          });

          return Card(
            elevation: 4.0,
            margin: new EdgeInsets.only(top: 8, left: 5, right: 5),
            child: Container(
              child: ExpansionTile(
                title: Text("Response #${_responses[index]['id']}"),
                children: children,
              ),
            ),
          );
        });
  }

  Widget _tabSettings() {
    TextEditingController greetings = TextEditingController();
    greetings.text = widget._api.prefs.getString('greetings');
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Set greetings text'),
          subtitle: Text(widget._api.prefs.getString('greetings') ?? 'None'),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Greetings Text'),
                    content: TextField(
                      controller: greetings,
                      decoration: InputDecoration(labelText: 'Greetings'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('CANCEL'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            final value = greetings.text.trim();
                            if (value.isNotEmpty) {
                              setState(() {
                                Navigator.pop(context);
                              });
                              widget._api.prefs.setString('greetings', value);
                            }
                          }),
                    ],
                  ),
            );
          },
        ),
        ListTile(
          title: Text('Logout'),
          onTap: () {
            widget._api.prefs.clear();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage(widget._api)), (_) => false);
          },
        )
      ],
    );
  }

  Future init() async {
    final chats = await widget._api.getChats();
    final tickets = await widget._api.getTickets();
    final responses = await widget._api.getResponses();
    setState(() {
      _chats = chats.data;
      _tickets = tickets.data;
      _responses = responses.data;
    });
  }

  void _loadFcm() {
    final _fcm = FirebaseMessaging();
    _fcm.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.getToken().then(widget._api.updateFcmToken);
    _fcm.configure(
      onMessage: (Map<String, dynamic> data) async {
        if (data['action'] == 'data') init();
      },
      onResume: (Map<String, dynamic> data) async {
        if (data['action'] == 'data') init();
      },
    );
  }
}
