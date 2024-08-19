import 'package:chat_wp/services/accounts/search_list.dart';
import 'package:flutter/material.dart';

import 'package:chat_wp/pages/accounts/area_info.dart';
import 'package:chat_wp/pages/accounts/account_info.dart';
import 'package:chat_wp/pages/accounts/voucher_cpv_info.dart';

import 'package:chat_wp/pages/inventory/customer_info.dart';
import 'package:chat_wp/pages/inventory/supplier_info.dart';

import 'package:chat_wp/pages/logins_chat/blocked_users_page.dart';
import 'package:chat_wp/pages/logins_chat/crud_page.dart';
import 'package:chat_wp/pages/logins_chat/currency_page.dart';

class MyListTile extends StatelessWidget {
  final int pageNo;
  final String text;
  final IconData icon;

  const MyListTile(
      {super.key,
      required this.pageNo,
      required this.text,
      required this.icon});

  void _showPage(int pageNum, BuildContext context) {
    // print (pageNum);

    switch (pageNum) {
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AccountInfo()));
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const VoucherCpvInfo()));
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CustomerInfo()));
      case 5:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CustomerInfo()));
      case 6:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CustomerInfo()));
      case 7:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CustomerInfo()));
      case 8:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CustomerInfo()));
      case 9:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CurrencyPage()));
      case 10:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const CrudPage()));
      case 11:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BlockedUsersPage()));
      case 12:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const CrudPage()));
      case 13:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CurrencyPage()));
      case 14:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchList()));
      case 15:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const CrudPage()));
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (pageNo != 0) {
          _showPage(pageNo, context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            // title
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // button to go blocked users page
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
