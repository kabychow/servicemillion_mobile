import 'package:flutter/material.dart';
import 'package:servicemillion/helpers/components.dart';
import 'package:flutter/scheduler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:servicemillion/helpers/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

IOWebSocketChannel channel;

class ChatPage extends StatefulWidget {
  final _apiKey, _ticketId, _name, _email, _message;
  const ChatPage(this._apiKey, this._ticketId, this._name, this._email, this._message);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  var _data = [];

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect(HOST_WEB_SOCKET, headers: {'Authorization': widget._apiKey, 'Tid': widget._ticketId});
    channel.stream.listen(_receive, onDone: () {
      Future(() {
        Navigator.pop(context);
        alert(context, 'Connection closed', 'The client has closed the connection');
      });
    });
    _receive(widget._message);
    sendGreeting();
  }

  void sendGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _send(prefs.getString('greetings') ?? '');
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget._name,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _data.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(left: _data[index]['self'] ? 25 : 0, right: _data[index]['self'] ? 0 : 25),
                  child: Card(
                    color: _data[index]['self'] ? Colors.white : Colors.blue,
                    child: new Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        _data[index]['message'],
                        style: TextStyle(fontSize: 16, color: _data[index]['self'] ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: CustomTextField(
                    'Type your message here...',
                    type: TextInputType.multiline,
                    margin: EdgeInsets.all(5),
                    controller: _messageController,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _send(_messageController.text.trim()),
                  color: CustomColors.PRIMARY,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _send(text) {
    if (text.isNotEmpty) {
      channel.sink.add(text);
      setState(() {
        _data.add({'self': true, 'message': text});
        _messageController.clear();
      });
      _scrollToBottom();
    }
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
