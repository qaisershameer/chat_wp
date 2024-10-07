import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';

  // constant Global Parameters Project Level
  final AuthService _authService = AuthService();

  // GET CURRENT USER ID
  // String kUserId = 'CAKf9wMH4IfA58EmzDVJlMjLuRh2';
  String kUserId = _authService.getCurrentUser()!.uid;
  String? kUserEmail = _authService.getCurrentUser()!.email;

  int kUserIdNew = 1;
  String kUserName = 'Qaiser Shameer';
  String? kUserEmailNew = 'qrdevteam@gmail.com';

  String kCPV = 'CP';
  String kCRV = 'CR';
  String kJV = 'JV';

  String kCash = 'CASH';
  String kBank = 'BANK';

  String apiUrl = 'http://10.0.2.2:8000/api/';
  // String apiUrl='https://api.qrdpro.com/public/api';

  // String kToken = '1|IldYuTylZ8HIV4MIRqRCrh6IFewUIOBgDQFMIMSja2aa25d7';
  String kToken = '32|IaMDxg2FqoH6Nf4pcK5lWLtHOsjYpfeZyrLt7Wlb8006b0d7';

  Map<String, String> kHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $kToken',
  };

  final DateTime stDate = DateTime(DateTime.now().year, 7, 1);
  final String kStartDate = DateFormat('dd-MMM-yyyy').format(stDate);

// Color primaryColor = HexColor('#023B47');
// Color secondaryColor = HexColor('#1F7879');
// Color secondaryTextColor = HexColor('#658E92');

double deviceWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double deviceHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);