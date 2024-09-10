import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/components/my_account_selection.dart';

class CashBankToggle extends StatefulWidget {
  const CashBankToggle({super.key});

  @override
  CashBankToggleState createState() => CashBankToggleState();

}

class CashBankToggleState extends State<CashBankToggle> {
  final List<bool> _isSelected = [true, false];
  String userId = kUserId; // Replace with actual user ID
  String type = 'BANK'; // Replace with actual type

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        isSelected: _isSelected,
        onPressed: (int index) {
          setState(() {
            for (int i = 0; i < _isSelected.length; i++) {
              _isSelected[i] = i == index;
            }

            if (index == 1) {
              showBankSelectionDialog(context, userId, type);
            }
          });
        },
        borderRadius: BorderRadius.circular(10.0),
        selectedColor: Colors.white,
        fillColor: Colors.teal,
        color: Colors.black,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text('Cash'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text('Bank'),
          ),
        ],
      ),
    );
  }
}
