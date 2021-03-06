import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:my_app/data_model.dart';
import 'package:my_app/messageModel.dart';
// import 'package:emoji_picker/emoji_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/PhotoGalleryPage.dart';
import 'dart:math';
import 'package:dio/dio.dart';
void main() => runApp(MyApp());
String _username, _password;
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'talk room',
      home: LoginPage(),
    );
  }
}
// Login
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;
  Color _eyeColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              children: <Widget>[
                SizedBox(
                  height: kToolbarHeight,
                ),
                loginTopImg(),
                buildTitle(),
                SizedBox(height: 70.0),
                buildUsernameTextField(),
                SizedBox(height: 30.0),
                buildPasswordTextField(context),
                SizedBox(height: 60.0),
                buildLoginButton(context),
                SizedBox(height: 30.0),
              ],
            )));
  }

  Align buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: RaisedButton(
          child: Text(
            'Login',
            style: Theme.of(context).primaryTextTheme.headline,
          ),
          color: Colors.black,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              ///只有输入的内容符合要求通过才会到达此处
              _formKey.currentState.save();
              //TODO 执行登录方法
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(), maintainState: false));
            }
          },
          shape: StadiumBorder(side: BorderSide()),
        ),
      ),
    );
  }
  // The input username and password information
  TextFormField buildPasswordTextField(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => _password = value,
      obscureText: _isObscure,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Please enter the password';
        }
        if (value!='admin'){
          return 'The password is incorrect';
        }
      },
      decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: _eyeColor,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                  _eyeColor = _isObscure
                      ? Colors.grey
                      : Theme.of(context).iconTheme.color;
                });
              })),
    );
  }

  TextFormField buildUsernameTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Username',
      ),
      validator: (String value) {
        // var usernameReg = RegExp(
        //   r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)?");
        //     // r"[\w!#$%&'*+/=?^_`{|}~-]+(?:\.[\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\w](?:[\w-]*[\w])?\.)+[\w](?:[\w-]*[\w])?");
        List<String> values = ['damien','bilal','admin'];
        if (values.contains(value)==false) {
          return 'Please enter the correct username';
        }
      },
      onSaved: (String value) => _username = value,
    );
  }

  String imageUrl='images/depinfo.png';
  Padding loginTopImg()  {
    return new Padding(
      padding: EdgeInsets.all(40.0),
      child: new Image.asset(
        imageUrl
      ),
    );
  }

  Padding buildTitle() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Text(
        'CHAT ROOMS',
        style: TextStyle(fontSize: 30.0),
        ),
      )
    );
  }
}

// design of chatscreen
class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

var currentLocation;// null if we didn't do location
var currentGif;// null if we didn't choose a gif emoji
class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final String url = 'http://depinfo-chat.herokuapp.com/api/messages';
  var dataReceivor;
  List dataSentor;
  int messageCount = 0;
  MessageModel _lastMessage;
  DataModel _dataModel;
  Future<MessageModel> futureMessageModel;
  bool isShowSticker=false;
  bool isShowGIF=false;
  bool isImage = false;
  List photoList= [
      {'image': 'https://media1.giphy.com/media/F6PFPjc3K0CPe/giphy.gif?cid=65f61dd4c247eca35ce1edc117629d21983a2aac1bde43bf&rid=giphy.gif', 'id': '1'},
      {'image': 'https://media.giphy.com/media/sUNqplVFtsctW/giphy.gif', 'id': '2'},
      {'image': 'https://media.giphy.com/media/BVStb13YiR5Qs/giphy.gif', 'id': '3'},
      {'image': 'https://media.giphy.com/media/l3V0megwbBeETMgZa/giphy.gif', 'id': '4'},
      {'image': 'https://media2.giphy.com/media/f6zXzpkoUDGjmsnDPm/giphy.gif?cid=bb5a1c3a3b5c8d1deb92d1bc02735ecc92f62e6039b577f6&rid=giphy.gif', 'id': '5'},
      {'image': 'https://media2.giphy.com/media/iDm8R33l0iKf27HuF1/giphy.gif?cid=ecf05e4749ab28775fe7d7102f74226af3d57d57038ba32f&rid=giphy.gif', 'id': '6'},
      {'image': 'https://www.olybop.fr/wp-content/uploads/2016/07/studio-ghibli-totoro-gifs-exercise-motivation-cl-terry-4.gif', 'id': '7'},
      {'image': 'http://i.stack.imgur.com/SBv4T.gif', 'id': '8'},
      {'image': 'https://media2.giphy.com/media/TPl5N4Ci49ZQY/giphy.gif?cid=bb5a1c3ae41ccf83b4c5fd6ee54d2891e3d6d0490005496a&rid=giphy.gif', 'id': '9'},
    ];

  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();//read the message that we taped in.
  bool _isComposing = false;
  var now = DateTime.now();
  
  void getHttp(String sentence) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get("http://api.giphy.com/v1/gifs/search?q="+sentence+"&api_key=n8p5BuwduJRE6yeczG7PULUfEeVCMelN&limit=9");
    if (response.data['data']!=[]&&sentence.length>=2) {
      var i = 0;
      while (i<9) {
        if(response.data['data'][i]!=[]){
          photoList[i]['image'] = response.data['data'][i]['images']['downsized_large']['url'].toString();
        }
        else{
          photoList[i]['image'] = '';
        }
        i++;
      }
    }
  }

  // GET Message
  Future<MessageModel> getMessage() async {
    var username = _username;
    var password = _password;
    var basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var res = await http.get(
      Uri.encodeFull(url),
      headers: {'authorization': basicAuth,
        'Accept': 'application/json; charset=UTF-8'
        }
      );

    setState(() {
      var resBody = json.decode(res.body);
      dataReceivor = resBody;
      var index=0;
      bool out = false;
      while((dataReceivor[index]!=null)&&(out==false)){
        var lastmessage = dataReceivor[index];
        if(lastmessage['room']==6){
          _lastMessage = MessageModel.fromJson(lastmessage);
          out= true;
        }
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

  // GET update data
  Future<DataModel> getUpdate() async {

  }
  
  // GET room data
  Future<DataModel> getRoomData() async {
    var username = _username;
    var password = _password;
    var basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var res = await http.get(
      Uri.encodeFull('http://depinfo-chat.herokuapp.com/api/rooms'),
      headers: {'authorization': basicAuth,
        'Accept': 'application/json; charset=UTF-8'
        }
      );
      var responseBody = json.decode(res.body);
      var myroom = responseBody[0];
      _dataModel =  DataModel.fromJson(myroom);
      if(messageCount<_dataModel.messageCount){
          for( var i = 0 ; i< (min(_dataModel.messageCount,49)-messageCount); i++ ) {
            // print('nb message =');
            // print(min(_dataModel.messageCount,49)-i-1);
            ChatMessage message = new ChatMessage(
              name:_dataModel.lastMessages[min(_dataModel.messageCount,49)-messageCount-i-1].author,//now: 49, before: (_dataModel.messageCount-messageCount). maybe it is limited by the server
              text:_dataModel.lastMessages[min(_dataModel.messageCount,49)-messageCount-i-1].message,
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
      }
      // print('_messages=');
      // print(_messages);
      messageCount = _dataModel.messageCount;
      // print("messageCount"+messageCount.toString());
    return _dataModel;
  }

  // POST to create a room
  Future<DataModel> createState(String name) async{
    final String apiUrl='http://depinfo-chat.herokuapp.com/api/rooms/';
    var username = _username;
    var password = _password;
    var basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var response = await http.post(
      Uri.encodeFull(apiUrl),
      headers: {'authorization': basicAuth,
        'Accept': 'application/json'
        },
      body:({
        'title': name+"'s chat room",
        'user': name,
      }), );

    if(response.statusCode == 201){
        final String responseString = response.body;
        return dataModelFromJson(responseString);
    }
    else{
      return null;
    }
  }

  // POST to create a message
  Future<MessageModel> postMessage(String name,String message) async{
    final String apiUrl='http://depinfo-chat.herokuapp.com/api/messages/';
    var username = _username;
    var password = _password;
    var basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
    var response = await http.post(
      Uri.encodeFull(apiUrl),
      headers: {'authorization': basicAuth,
        'Accept': 'application/json'
        },
      body:({
        'author': name,
        'message': message,
        // "timestamp": time,
        'room': '1'
      }));
    if(response.statusCode == 201){
        final String responseString = response.body;
        return messageModelFromJson(responseString);
    }
    else{
      return null;
    }
  }

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
    _sendMessage(text: text);
    _updateMessage();
  }


  void _sendMessage({ String text, String imageUrl }) async{
    final MessageModel lastmessage = await postMessage(_username, text);//POST
    // ChatMessage message = new ChatMessage(
    //   name: _username,
    //   text: text,
    //   animationController: new AnimationController(
    //     duration: new Duration(milliseconds: 300),
    //     vsync: this
    //   )
    // );
    // setState((){
    //   _messages.insert(0, message);
    // });
    // message.animationController.forward();
    // await getRoomData();
  }

  void _updateMessage() async{
    await getRoomData();    
  }

  void checkLocation(){
    if (currentLocation!=null) {
      _handleSubmitted('My location is '+currentLocation.toString());
    }
    currentLocation=null;
  }
  void checkGif(){
    if (currentGif!=null) {
      _handleSubmitted(currentGif.toString());
    }
    currentGif=null;
  }

  List imgList = new List<File>(); 
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imgList.add(image);
    });
  }

  String _url = getNewDiceUrl();

  static String getNewDiceUrl() {
    var diceFace = Random().nextInt(7);
    while (diceFace == 0) {
      diceFace = Random().nextInt(7);
    }
    if (diceFace == 1) {
      return 'https://upload.wikimedia.org/wikipedia/commons/2/2c/Alea_1.png';
    }
    else if (diceFace == 2) {
      return 'https://upload.wikimedia.org/wikipedia/commons/b/b8/Alea_2.png';
    }
    else if (diceFace == 3) {
      return 'https://upload.wikimedia.org/wikipedia/commons/2/2f/Alea_3.png';
    }
    else if (diceFace == 4) {
      return 'https://upload.wikimedia.org/wikipedia/commons/8/8d/Alea_4.png';
    }
    else if (diceFace == 5) {
      return 'https://upload.wikimedia.org/wikipedia/commons/5/55/Alea_5.png';
    }
    else {
      return 'https://upload.wikimedia.org/wikipedia/commons/f/f4/Alea_6.png';
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).accentColor),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
                children: <Widget> [
                  new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                      onPressed: getImage,
                      tooltip: 'Pick Image',
                      icon: new Icon(Icons.add_a_photo),
                    ),
                  ),
                  Flexible(
                      child: TextField(
                        controller: _textController,
                        onChanged: (String text) {
                          setState((){
                            _isComposing = text.isNotEmpty;
                            // isShowGIF =false;//
                            if(text!=null){
                              getHttp(text);
                            }
                          });
                        },
                        // keyboardType:,
                        // onSubmitted:(isShowGIF=false)&&(isShowSticker = false)?():(),
                        // onSubmitted: _handleSubmitted,
                        decoration: InputDecoration.collapsed(hintText: 'messages'),
                      )
                  ),
                  new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 4.0),
                    child: new IconButton(
                      icon: new Icon(Icons.image),
                      onPressed: (){
                        // var imag =Image.asset("images/03.jpg");
                        setState(() {
                          isShowGIF = !isShowGIF;
                          if (isShowGIF) {
                            isShowSticker = false;
                          }
                        });
                        // _handleSubmitted(imag.image);
                      },
                      color: Colors.blue,
                    ),
                  ),
                  
                  // new Container(
                  //   margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  //   child: new IconButton(
                  //     icon: new Icon(Icons.face),
                  //     onPressed:() {
                  //       setState(() {
                  //         isShowSticker = !isShowSticker;
                  //         if (isShowSticker) {
                  //           isShowGIF = false;
                  //         }
                  //       });
                  //     },
                  //     color: Colors.blue,
                  //   ),
                  // ),

                  new Container(
                    // body: new Center(
                    child: new IconButton(
                      icon: new Icon(Icons.games),
                      onPressed: () {
                        setState(() {
                          _url = getNewDiceUrl();
                          _handleSubmitted(_url);
                        });
                      },
                    ),
                  ),
                  new Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed:
                          _isComposing ?() => _handleSubmitted(_textController.text) : null
                    ),
                  )
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('CHAT ROOM'),
        ),
        body: Column(
            children: <Widget>[
              Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _messages[index],
                    itemCount: _messages.length,
                  )
                  
              ),
              (isShowSticker ? buildSticker() : Container()),//sticker
              (isShowGIF ? _meetingPhotos(context) : Container()),//GIF
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
  Widget buildSticker() {
    // return EmojiPicker(
    //   rows: 3,
    //   columns: 7,
    //   buttonMode: ButtonMode.MATERIAL,
    //   recommendKeywords: ['racing', 'horse'],
    //   numRecommended: 10,
    //   onEmojiSelected: (emoji, category) {
    //     _handleSubmitted(emoji.emoji);
    //   },
    // );
  }

  Widget _meetingPhotos(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 16, 32, 8),
      child: GridView.builder(
        shrinkWrap: true, //解决 listview 嵌套报错
        physics: NeverScrollableScrollPhysics(), //禁用滑动事件
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //横轴元素个数
            crossAxisCount: 3,
            //纵轴间距
            mainAxisSpacing: 10.0,
            //横轴间距
            crossAxisSpacing: 10.0,
            //子组件宽高长度比例
            childAspectRatio: 1.0),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: (){
              _jumpToGallery(index, photoList);
            },
            child: Image.network(
              photoList[index]['image'],
              fit: BoxFit.cover,
            ),
          );
        },
        itemCount: photoList.length,
      ),
    );
  }
  // jump to photo gallery
  void _jumpToGallery(index, list) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotpGalleryPage(
        index: index,
        photoList: list,
      )),
    );
    currentGif = list[index]['image'];
  }

  @override
  void initState(){
    super.initState();
    const oneSecond = Duration(seconds:1);
    Timer.periodic(oneSecond, (Timer t) => getRoomData()); 
    // getRoomData();
    isShowSticker = false;
    checkLocation();
    checkGif();
  }
}

String imageUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ8D2ohlEMO3dmGGw6WQg9h4qBpEjD5UbLWLLFHLNK8jyFzcGtL&usqp=CAU';
class ChatMessage extends StatelessWidget {
  ChatMessage({this.name,this.text,this.animationController});
  final String text;
  final String name;
  final AnimationController animationController;
  bool isImage = false;
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
                    // child: CircleAvatar(//头像图片
                    //   child: new Image.network(
                    //     imageUrl,
                    //     scale: 2.0,
                    //   ),
                    // ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(name, style: Theme.of(context).textTheme.subhead),
                        Image.asset('images/online.gif',width: 10,height: 10,matchTextDirection:true),
                        Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: (_getText(text)?Image.network(text,width: 100.0):Text(text)),
                          width: MediaQuery.of(context).size.width*0.8,
                        )
                      ]
                  )
                ]
            )
        )
    );
  }

  bool _getText(String text){
    if(text.length<5){
      return false;
    }
    if (text.endsWith('.gif')==true||text.endsWith('.png')==true||text.endsWith('.jpg')==true) {
      isImage = true;
    }
    else{
      isImage = false;
    }
    return isImage;
  }
  // TODO: display user's identify photo
  void _getUserImage(){
  }
}

class MyApp1 extends StatefulWidget {
  @override
  State<MyApp1> createState() => SecondScreen();
}

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
            Center(
              child: RaisedButton(
                child: Text('back to chat room'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }
              ),
            ),
            Divider(height: 1.0),
            
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
            )
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        tooltip: 'Get Location',
        child: Icon(Icons.flag),
      ),

    );
  }
}