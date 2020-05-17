// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'src/locations.dart' as locations;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:my_app/data_model.dart';
import 'package:my_app/messageModel.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'talk room',
      home: ChatScreen(),
    );
  }
}

class MyApp1 extends StatefulWidget {
  @override
  State<MyApp1> createState() => SecondScreen();
}

class DataMessage {
  final int id;
  final String title;

  DataMessage({this.id, this.title});

  factory DataMessage.fromJson(Map<String, dynamic> json) {
    return DataMessage(
      id: json['id'],
      title: json['title'],
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final String url = 'http://depinfo-chat.herokuapp.com/api/messages';
  var dataReceivor;
  List dataSentor;
  // DataModel _data;
  // List<MessageModel> _message;
  MessageModel _lastMessage;
  Future<MessageModel> futureMessageModel;

  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();//read the message that we taped in.
  bool _isComposing = false;
  var now = DateTime.now();
  // GET
  Future<MessageModel> getMessage() async {
    var username = 'Linxue';
    var password = 'admin';
    var basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
    print(basicAuth);

    var res = await http.get(
      Uri.encodeFull(url),
      headers: {'authorization': basicAuth,
        'Accept': 'application/json; charset=UTF-8'
        }
      );

    setState(() {
      var resBody = json.decode(res.body);
      // print(res.body);
      dataReceivor = resBody;
      print('dataReceivor=');
      print(dataReceivor);
      var index=0;

      bool out = false;
      while((dataReceivor[index]!=null)&&(out==false)){
        var lastmessage = dataReceivor[index];
        print(lastmessage);
        if(lastmessage['room']==6){
                // _message
          print(MessageModel.fromJson(lastmessage));
          _lastMessage = MessageModel.fromJson(lastmessage);
          print('author=${_lastMessage.author},message = ${_lastMessage.message},time=${_lastMessage.timestamp}');
          out= true;
          break;
        }
        // print(dataReceivor["last_messages"][index]);
        index++;
      }

    });
    ChatMessage message = new ChatMessage(
      name: _lastMessage.author,
      text: _lastMessage.message,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 300),
        vsync: this
      )
    );
    setState((){
      _messages.insert(0, message);
    });
    message.animationController.forward();
    
    return _lastMessage;
  }

  // Future<http.Response> createMessage(String title) async {
  //   var username = 'linxue';
  //   var password = 'admin';
  //   var basicAuth =
  //     'Basic ' + base64Encode(utf8.encode('$username:$password'));
  //   print(basicAuth);
    
  //   final http.Response response = await http.post(
  //     'http://depinfo-chat.herokuapp.com/api/rooms',
  //     headers: <String, String>{
  //       'authorization': basicAuth,
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(<String, String>{
  //       'title': title,
  //     }),
  //   );
  //   if (response.statusCode == 201) {
  //   // If the server did return a 201 CREATED response,
  //   // then parse the JSON.
  //     var data;
  //     data=DataMessage.fromJson(json.decode(response.body));
  //     print(data);
  //     return data;
  //   }
  //   else {
  //   // If the server did not return a 201 CREATED response,
  //   // then throw an exception.
  //     throw Exception('Failed to load message');
  //   }
  // }

  // POST to create a room
  Future<DataModel> createState(String name) async{
    final String apiUrl='http://depinfo-chat.herokuapp.com/api/rooms/';
    print('test5');

    var username = 'linxue';
    var password = 'admin';
    var basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
    print(basicAuth);
    print('test6');
    var response = await http.post(
      Uri.encodeFull(apiUrl),
      headers: {'authorization': basicAuth,
        'Accept': 'application/json'
        },
      body:({
        'title': name+"'s chat room",
        'user': name,
      }), );
    print('test7');

      // print(response.body);
      print(response.statusCode);
      print(response.body);

    if(response.statusCode == 201){
        print('test8');    
        final String responseString = response.body;
        // print(responseString);
        return dataModelFromJson(responseString);
    }
    else{
      print('test failed');
      return null;
    }
  }

  // POST to create a message
  Future<MessageModel> postMessage(String name,String message,String time) async{
    final String apiUrl='http://depinfo-chat.herokuapp.com/api/messages/';
    print('test5');

    var username = 'linxue';
    var password = 'admin';
    var basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
    print(basicAuth);
    print('test6');
    var response = await http.post(
      Uri.encodeFull(apiUrl),
      headers: {'authorization': basicAuth,
        'Accept': 'application/json'
        },
      body:({
        "author": name,
        "message": message,
        // "timestamp": time,
        "room": '6'
      }));
    // print('test7');

      // print(response.body);
      print(response.statusCode);
      print(response.body);

    if(response.statusCode == 201){
        print('test8');    
        final String responseString = response.body;
        // print(responseString);
        return messageModelFromJson(responseString);
    }
    else{
      print('test failed');
      return null;
    }
  }

  // @override
  // Widget build(BuildContext context){
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('data'),
  //       backgroundColor: Colors.amberAccent,
  //     ),
  //     body: ListView.builder(
  //       itemCount: data == null?0:data.length,
  //       itemBuilder: (BuildContext context,int index){
  //         return new Container(
  //           child: Center(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: <Widget>[
  //                 Card(
  //                   child:Container(
  //                     padding: EdgeInsets.all(15.0),
  //                     child: Text(data[index]['title'],
  //                         style: TextStyle(fontSize: 18.0,color: Colors.black54
  //                         )),
  //                   ),
  //                 ),
  //                 Card(
  //                   child:Container(
  //                     padding: EdgeInsets.all(15.0),
  //                     child: Text(data[index]['user'],
  //                         style: TextStyle(fontSize: 18.0,color: Colors.black54
  //                         )),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  // @override
  // void initState(){
  //   super.initState();
  //   this.getMessage();
  // }


  @override
  void dispose() {
    for(var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  Future _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing =false;
    });
    // await _ensureLoggedIn();
    _sendMessage(text: text);
    _updateMessage();
  }
  void _sendMessage({ String text }) async{
    final MessageModel lastmessage = await postMessage('Linxue', text, now.toString());//POST
    print('name=${'linxue'},message=${_textController.text},time=${now.toString()}');//
    ChatMessage message = new ChatMessage(
      name: 'linxue',
      text: text,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: 300),
        vsync: this
      )
    );
    setState((){
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }
  void _updateMessage() async{
    // Future<MessageModel> lastone=getMessage();
    // lastone
    
  }
  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
                children: <Widget> [
                  Flexible(
                      child: TextField(
                        controller: _textController,
                        onChanged: (String text) {
                          setState((){
                            _isComposing = text.isNotEmpty;
                          });
                        },
                        onSubmitted: _handleSubmitted,
                        decoration: InputDecoration.collapsed(hintText: 'messages'),
                      )
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed:
                        // () async{ 
                            // print('test0');
                            // final String name = 'linxue';
                            // final LastMessage messagel = new LastMessage();
                            // messagel.author = name;
                            // messagel.message=  message;
                            // messagel.timestamp = time;
                            // print('test1');
                            // final DataModel data = await createState(name, messagel, time);

                            // setState(() {
                              // print('test3');
                              // _data=data;
                              _isComposing ?() => _handleSubmitted(_textController.text) : null
                              // print('test4');
                            // });
                            // },
                    ),
                  )
                ]
            )
        )
    );
  }
  // final TextEditingController _controller = TextEditingController();
  // Future<http.Response> _futureAlbum;

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Create Data Example',
  //     theme: ThemeData(
  //       primarySwatch: Colors.blue,
  //     ),
  //     home: Scaffold(
  //       appBar: AppBar(
  //         title: Text('Create Data Example'),
  //       ),
  //       body: Container(
  //         alignment: Alignment.center,
  //         padding: const EdgeInsets.all(8.0),
  //         child: (_futureAlbum == null)
  //             ? Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: <Widget>[
  //                   TextField(
  //                     controller: _controller,
  //                     decoration: InputDecoration(hintText: 'Enter Title'),
  //                   ),
  //                   RaisedButton(
  //                     child: Text('Create Data'),
  //                     onPressed: () {
  //                       setState(() {
  //                         _futureAlbum = createMessage(_controller.text);
  //                       });
  //                     },
  //                   ),
  //                 ],
  //               )
  //             : FutureBuilder<dynamic>(
  //                 future: _futureAlbum,
  //                 builder: (context, snapshot) {
  //                   if (snapshot.hasData) {
  //                     return Text(snapshot.data.title);
  //                   } else if (snapshot.hasError) {
  //                     return Text('${snapshot.error}');
  //                   }

  //                   return CircularProgressIndicator();
  //                 },
  //               ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('chat room'),
        ),
        body: Column(
            children: <Widget>[
              Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _messages[index],
                    itemCount: _messages.length,
                    // itemCount: dataReceivor == null?0:dataReceivor.length,
                    // itemBuilder: (BuildContext context,int index){
                    //   return new Container(
                    //     child: Center(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.stretch,
                    //         children: <Widget>[
                    //           Card(
                    //             child:Container(
                    //               padding: EdgeInsets.all(15.0),
                    //               child: Text(dataReceivor[index]['title'],
                    //                   style: TextStyle(fontSize: 18.0,color: Colors.black54
                    //                   )),
                    //             ),
                    //           ),
                    //           Card(
                    //             child:Container(
                    //               padding: EdgeInsets.all(15.0),
                    //               child: Text(dataReceivor[index]['user'],
                    //                   style: TextStyle(fontSize: 18.0,color: Colors.black54
                    //                   )),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   );
                    // },
                  )
              ),
              Center(
                child: RaisedButton(
                  child: Text('Go to map'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp1()),
                      );
                    }
                ),
              ),
              Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: _buildTextComposer(),
              )
            ]
        )
    );
  }
  @override
  void initState(){
    super.initState();
    futureMessageModel=getMessage();
    // _updateMessage();
    // futureMessageModel
  }
}

// const String _name = 'linxue';
class ChatMessage extends StatelessWidget {
  ChatMessage({this.name,this.text, this.animationController});
  final String text;
  final String name;
  final AnimationController animationController;
  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor: CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOut
        ),
        axisAlignment: 0.0,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(child: Text(name[0])),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(name, style: Theme.of(context).textTheme.subhead),
                        Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: Text(text),
                        )
                      ]
                  )
                ]
            )
        )
    );
  }
}


var currentLocation;
class SecondScreen extends State<MyApp1> {
  final Map<String, Marker> _markers = {};
  void _getLocation() async {
    currentLocation = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _markers.clear();
      final marker = Marker(
          markerId: MarkerId('curr_loc'),
          position: LatLng(currentLocation.latitude, currentLocation.longitude),//48.0,6.0
          infoWindow: InfoWindow(title: 'Your Location:${currentLocation}')

      );
      _markers['Current Location'] = marker;
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Location'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
          children: <Widget>[
            Flexible(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: const LatLng(0, 0),
                  zoom: 2,
                ),
                markers: _markers.values.toSet(),
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
//              child: _buildTextComposer(),
            )
          ]
      ),
//          new Center(
//            child: new RaisedButton(
//              onPressed: () {
//                Navigator.pop(context);},
//          child: new Text('Go back!'),
//          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        tooltip: 'Get Location',
        child: Icon(Icons.flag),
      ),

    );
  }
}