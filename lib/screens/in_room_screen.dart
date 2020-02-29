import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<User> members=[];
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
    await for(var snapshot in _firestore.collection('places').document(widget.source).collection('rooms').document(widget.roomId).collection('requests').snapshots())
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
    try {
      await for (var snapshot in _firestore.collection('places').document(
          widget.source).collection('rooms')
          .document(widget.roomId)
          .snapshots()) {
        print("Doc Updated ${snapshot.data}");
        numberOfMembers = snapshot.data['numberOfMembers'];
        List<MemberCard> newList = [];
        members.clear();
        for (int i = 1; i <= numberOfMembers; i++) {
          User user = await fetchMemberProfile(snapshot.data['member$i']);
          members.add(user);
          newList.add(MemberCard(
            user, designation: i == 1 ? 'Owner' : widget.destination,));
        }
        setState(() {
          membersList = newList;
        });
      }
    }
    catch(e)
    {
      print('Exception $e caught in setMembers');
    }

  }

  void chatIntroduction(String text){
    Firestore.instance.collection('places').document(widget.source).collection('rooms').document(widget.roomId).collection('chatMessages').add({
      'sender':JourneyPlanScreen.username,
      'type': kIntroType,
      'text': text,
      'senderUid': IntroScreen.getUid(),
      'createdAt': Timestamp.now(),
    });
  }

  void leaveRoom(){
    List<User> localMembers = members;
    int getMemberPosition(){
      for(int i=0;i<4;i++){
        if(localMembers[i].uid==IntroScreen.getUid())
          return i;
      }
      return 1;
    }

    int mNumberOfMembers = numberOfMembers;
    DocumentReference documentReference = _firestore.collection('places').document(widget.source).collection('rooms').document(widget.roomId);
    try {
      if (mNumberOfMembers == 1) {
        documentReference.delete();
        print('Room Deleted');
      }
      else {
        chatIntroduction(kLeftRoom);
        documentReference.updateData({
          'numberOfMembers': mNumberOfMembers - 1,
        });

        int memberPosition = getMemberPosition()+1;
        for (int i = memberPosition; i < mNumberOfMembers; i++) {
          documentReference.updateData({
            'member$i': localMembers[i].uid,
          });
        }
        documentReference.updateData({
          'member$mNumberOfMembers': null,
        });
      }
    }
    catch(e){
      print('Exeption $e caught in leaveRoomMethod');
    }
    Navigator.push(context, MaterialPageRoute(
        builder: (context)=>JourneyPlanScreen(mUid: IntroScreen.getUid(),)
    ));
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => showRoomLeaveDialog(context),
    )) ?? false;
  }

  AlertDialog showRoomLeaveDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Leave',style: TextStyle(fontSize: 30),),
      content: Text('Once you leave you won\'t be able to join the room again'),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel'),
        ),
        FlatButton(
          onPressed: leaveRoom,
          child: Text('Ok'),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    User user = User();
    members.add(user);
    fetchRequests();
    setMembers();
    if(widget.introduce){
      widget.isOwner?chatIntroduction(kCreatedRoom):chatIntroduction(kJoinedRoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Padding(
          padding:EdgeInsets.only(left: 8,right: 8,top: 32,bottom: 8),
          child: Column(
            children: <Widget>[
              TitleRow(title: 'My Ride',
              onBackPress: (){
                  showDialog(context: context,
                  builder: (context)=>showRoomLeaveDialog(context));
              },),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    height: 120,
                    image: AssetImage('images/maps_markers.png'),
                  ),
                  SizedBox(width: 40,),
                  Column(
                    children: <Widget>[
                      Container(
                        width: 250,
                        color: Colors.grey[200],
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                          child: Text(widget.source,style: TextStyle(fontSize: 18),),
                        ),
                      ),
                      SizedBox(height: 50,),//TODO: No. of members to be shown
                      Container(
                        width: 250,
                        color: Colors.grey[200],
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                          child: Text(widget.destination,style: TextStyle(fontSize: 18),),
                        ),
                      ),
                    ],
                  ),
                ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: kBlack,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
                          child: Text('Chat',style: TextStyle(fontSize: 18,color: Colors.white),),
                        ),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>ChatScreen(source: widget.source,roomId: widget.roomId,)
                          ));
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: kRed,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16),
                          child: Text('See Requests',style: TextStyle(fontSize: 18,color: Colors.white),),
                        ),
                        onPressed:(){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestsPage(requestsList: requestsList,)));
                        }
                      ),
                    ),
                  ),
                ],
              ),
              BottomLargeButton(
                text: 'Book Cab',
                onPressed: (){
                  //Implement Booking Functionality
                },
              )
            ],
          ),
        ),
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
    await for(var snapshot in _firestore.collection('places').document(widget.source).collection('rooms').document(widget.roomId).collection('chatMessages').orderBy('createdAt').snapshots())
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
            type: type,
            isMe: senderUid == IntroScreen.getUid(),));
        }
        else if (type==kIntroType){
            newList.add(MessageBubble(
              text: '$sender $textMsg',
              sender: sender,
              type: type,
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value){
                          text = value;
                        },
                        controller: controller,
                        cursorColor: kRed,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  RaisedButton(
                    color: kThemeColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Send',style: TextStyle(color: Colors.white,fontSize: 18),),
                    ),
                    onPressed: (){
                      //SEND MESSAGE
                      controller.clear();
                      Firestore.instance.collection('places').document(widget.source).collection('rooms').document(widget.roomId).collection('chatMessages').add({
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
