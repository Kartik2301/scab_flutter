import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scab_flutter/constants.dart';
import 'package:scab_flutter/resources/components.dart';
import 'package:scab_flutter/resources/objects.dart';
import 'package:scab_flutter/screens/intro_screen.dart';
import 'package:scab_flutter/screens/journey_plan_screen.dart';

final _firestore = Firestore.instance;

class InRoom extends StatefulWidget {
  final String roomId,source,destination;
  final bool isOwner,introduce;

  InRoom({@required this.roomId,@required this.source,@required this.destination,@required this.isOwner,this.introduce});

  @override
  _InRoomState createState() => _InRoomState();
}
class _InRoomState extends State<InRoom> {

  List<MemberCard> membersList = [];
  List<RequestCard> requestsList=[];
  User member1,member2,member3,member4;
  int numberOfMembers=0;
  List<MessageBubble> messagesList = [];

  Future<User> fetchMemberProfile(String uid) async{
    User _user = User();
    final _firestore= Firestore.instance;
    var document = await _firestore.collection('users').document(uid).get();
    print(document.data);
    _user.uid=uid;
    _user.imageUrl=document.data['imageUrl'];
    _user.fullName= document.data['fullName'];
    _user.email=document.data['email'];
    _user.gender=document.data['gender'];
    _user.phoneNumber=document.data['phoneNumber'];
    _user.rollNo=_user.email.substring(0,_user.email.indexOf('@')).toUpperCase();
    return _user;
  }

  void fetchRequests () async
  {
    await for(var snapshot in _firestore.collection(widget.source).document(widget.roomId).collection('requests').snapshots())
    {
      List<RequestCard> updatedRoomsList = [];
      for(var message in snapshot.documents)
      {
        String requestedUid,status;
        requestedUid = message.data['uid']??"UID NOT FOUND";
        status = message.data['status']??'STATUS NOT FOUND';

        updatedRoomsList.add(RequestCard(requestedUID: requestedUid,roomId: widget.roomId,source: widget.source,status: status));
      }
      setState(() {
        requestsList = updatedRoomsList;
      });
    }
  }

  void setMembers() async{
    await for(var snapshot in _firestore.collection(widget.source).document(widget.roomId).snapshots()){
      print("Doc Updated ${snapshot.data}");
      numberOfMembers = snapshot.data['numberOfMembers'];
      List<MemberCard> newList=[];
      for(int i=1;i<=numberOfMembers;i++){
        User user = await fetchMemberProfile(snapshot.data['member$i']);
        newList.add(MemberCard(user,designation: i==1?'Owner':widget.destination,));
      }
      setState(() {
        membersList=newList;
      });
    }

  }

  void chatIntroduction(){
    Firestore.instance.collection(widget.source).document(widget.roomId).collection('chatMessages').add({
      'sender':JourneyPlanScreen.username,
      'type': kIntroType,
      'senderUid': IntroScreen.getUid(),
      'createdAt': Timestamp.now(),
    });
  }

  @override
  void initState() {
    super.initState();
    fetchRequests();
    setMembers();
    if(widget.introduce){
      chatIntroduction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('In Room'),backgroundColor: kThemeColor,),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(widget.source),
                ),
                Text('Members: $numberOfMembers'),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(widget.destination),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              child: ListView.builder(
                itemCount: membersList.length,
                itemBuilder: (BuildContext context,int index){
                  return membersList[index];
                },
              ),
            ),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                child: Text('SEE JOINING REQUESTS'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestsPage(requestsList: requestsList,)));
                },
              ),
              RaisedButton(
                child: Text('Chat'),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>ChatScreen(source: widget.source,roomId: widget.roomId,)
                  ));
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class RequestsPage extends StatelessWidget {

  final List<RequestCard> requestsList;
  RequestsPage({this.requestsList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: requestsList,
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String source,roomId;
  ChatScreen({this.source,this.roomId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<MessageBubble> messagesList = [];

  void fetchChatMessages() async{
    await for(var snapshot in _firestore.collection(widget.source).document(widget.roomId).collection('chatMessages').orderBy('createdAt').snapshots())
    {
      List<MessageBubble> newList = [];
      for(var message in snapshot.documents)
      {
        String textMsg,sender,type,senderUid;
        textMsg=message.data['text'];
        sender=message.data['sender'];
        type=message.data['type'];
        senderUid=message.data['senderUid'];
        if(type==kMessageType) {
          newList.add(MessageBubble(text: textMsg,
            sender: sender,
            isMe: senderUid == IntroScreen.getUid(),));
        }
        else if (type==kIntroType){
            newList.add(MessageBubble(
              text: '$sender has joined the room',
              sender: sender,
              isMe: false,));
          }
      }
      setState(() {
        messagesList=newList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchChatMessages();
  }
  String text;
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: ListView.builder(
              itemCount: messagesList.length,
              itemBuilder: (context,index){
                return messagesList[index];
              },
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value){
                        text = value;
                      },
                      controller: controller,
                    ),
                  ),
                  RaisedButton(
                    child: Text('Send'),
                    onPressed: (){
                      //SEND MESSAGE
                      controller.clear();
                      Firestore.instance.collection(widget.source).document(widget.roomId).collection('chatMessages').add({
                        'text':text,
                        'sender':JourneyPlanScreen.username,
                        'type': kMessageType,
                        'senderUid': IntroScreen.getUid(),
                        'createdAt':Timestamp.now(),
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
