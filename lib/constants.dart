import 'package:flutter/cupertino.dart';

Color kThemeColor = Color(0xFF4DB86F);
Color kPrimaryColor = Color(0xFF8FD694);
Color kBlack = Color(0xFF000000);
Color kRed = Color(0xFFF72C25);

List<String> placesList = [
  'IIIT-A',
  'Allahabad Junction',
  'Allahabad City Station',
  'Allahabad Cheoki Station',
  'Bamrauli Airport',
  'Civil Lines',
];
var hourList = new List<int>.generate(24, (i) => i + 1);
var minuteList = new List<int>.generate(60, (i) => i + 1);

const kSPuid = 'userId';
const kSPfirstLogIn='firstLogIn';

const kJoinRequest = 'Join Request';
const kConfirmJoin = 'Confirm To Join';
const kPendingRequest = 'Pending Request';
const kRejectedRequest = 'Rejected Request';

const kMessageType='msg';
const kIntroType='intro';
const kCreatedRoom='has created the room';
const kJoinedRoom='has joined the room';
const kLeftRoom='has left the room';