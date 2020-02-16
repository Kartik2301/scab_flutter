import 'package:flutter/cupertino.dart';

Color kThemeColor = Color(0xFF4DB86F);

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