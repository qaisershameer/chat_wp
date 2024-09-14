import 'package:flutter/material.dart';
import 'package:chat_wp/themes/const.dart';
import 'package:chat_wp/components/my_account_selection.dart';

class CashBankToggle extends StatefulWidget {
  final void Function(int selectedIndex, String? bankId, String? bankName,)? onSelectionChanged;
  final String acType;

  const CashBankToggle({super.key, this.onSelectionChanged, required this.acType});

  @override
  CashBankToggleState createState() => CashBankToggleState();

}

class CashBankToggleState extends State<CashBankToggle> {
  final List<bool> _isSelected = [true, false];
  String userId = kUserId; // Replace with actual user ID
  String type = kBank; // Replace with actual type

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with data from the previous screen
    type = widget.acType;
  }

  void _handleBankSelection(String bankId, String bankName) {
    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(1, bankId, bankName); // 1 indicates BANK is selected
    }
  }

  void _showBankDialog() async {
    final bankSelected = await showBankSelectionDialog(context, userId, type, _handleBankSelection);
    if (!bankSelected) {
      setState(() {
        // Reset toggle button to 'CASH'
        _isSelected[0] = true;
        _isSelected[1] = false;
      });
      if (widget.onSelectionChanged != null) {
        widget.onSelectionChanged!(0, null, null); // 0 indicates CASH is selected
      }
    }
  }

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
              _showBankDialog();
            } else {
              if (widget.onSelectionChanged != null) {
                widget.onSelectionChanged!(index, null, null);
              }
            }
          });
        },
        borderRadius: BorderRadius.circular(10.0),
        selectedColor: Colors.white,
        fillColor: Colors.teal,
        color: Colors.black,
        children:  [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Text('CASH'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(type== kBank ? 'ACCOUNT' : 'BANK'),
          ),
        ],
      ),
    );
  }
}
