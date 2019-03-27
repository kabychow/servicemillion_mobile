import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:servicemillion/helpers/api.dart';
import 'package:servicemillion/pages/home.dart';

IOWebSocketChannel channel;

class ChatPage extends StatefulWidget {
  final Api _api;
  final _ticketId, _name, _message;
  const ChatPage(this._api, this._ticketId, this._name, this._message);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  bool _sendable = false, _done = false;
  var _data = [];

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://172.20.10.2:8845', headers: {'Authorization': widget._api.key, 'Tid': widget._ticketId});
    channel.stream.listen((raw) {
      final data = jsonDecode(raw);
      if (data['action'] == 'text') {
        _receive(data['data']);
      } else if (data['action'] == 'end') {
        _receive(data['data']);
        setState(() => _done = true);
      }
    });
    _receive(widget._message);
    _send(widget._api.prefs.getString('greetings') ?? 'Agent joined the chat');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget._name),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.close),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text('Leave chat'),
                        content: Text('Are you sure to leave chat?'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('CANCEL'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FlatButton(
                            child: Text('OK'),
                            onPressed: () =>
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage(widget._api)), (_) => false),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 1,
                child: ListView.builder(
                  padding: EdgeInsets.all(5),
                  controller: _scrollController,
                  itemCount: _data.length,
                  itemBuilder: (context, index) => Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: _data[index]['self'] ? 25 : 0,
                            right: _data[index]['self'] ? 0 : 25,
                          ),
                          child: Card(
                            color: _data[index]['self'] ? Colors.blue : Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                _data[index]['message'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _data[index]['self'] ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        alignment: _data[index]['self'] ? Alignment.centerRight : Alignment.centerLeft,
                      ),
                ),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(hintText: 'Type your message here...'),
                        enabled: !_done,
                        onChanged: (text) => setState(() => _sendable = text.trim().isNotEmpty),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _done || !_sendable ? null : () => _send(_messageController.text.trim()),
                    color: Theme.of(context).primaryColor,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _send(text) {
    channel.sink.add(text);
    setState(() {
      _data.add({'self': true, 'message': text});
      _messageController.clear();
      _sendable = false;
    });
    _scrollToBottom();
  }

  void _receive(message) {
    setState(() => _data.add({'self': false, 'message': message}));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
