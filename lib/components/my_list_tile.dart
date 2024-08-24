import 'package:chat_wp/reports/rpt_ac_ledger.dart';
import 'package:flutter/material.dart';

import 'package:chat_wp/services/accounts/search_list.dart';
import 'package:chat_wp/pages/accounts/area_info.dart';
import 'package:chat_wp/pages/accounts/account_info.dart';

import 'package:chat_wp/pages/accounts/voucher_cpv_info.dart';
import 'package:chat_wp/pages/accounts/voucher_crv_info.dart';
import 'package:chat_wp/pages/accounts/voucher_jv_info.dart';

import 'package:chat_wp/reports/rpt_cash_book.dart';

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

    // ACCOUNTS MENU
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CurrencyPage()));
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AccountInfo()));
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const VoucherCrvInfo()));
      case 5:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const VoucherCpvInfo()));
      case 6:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const VoucherJvInfo()));
      case 7:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RptCashBook()));
      case 8:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RptAcLedger()));
    // case 9:
    //   // Navigator.push(context,
    //   //     MaterialPageRoute(builder: (context) => const TrialBalance()));
    // case 10:
    //   // Navigator.push(context,
    //   //     MaterialPageRoute(builder: (context) => const ProfitLoss()));
    // case 11:
    //   // Navigator.push(
    //   //     context, MaterialPageRoute(builder: (context) => const BalanceSheet()));

    // INVENTORY MENU
    // case 16:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const GroupInfo()));
    // case 17:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const GroupInfo()));
    // case 18:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const ItemsInfo()));
    // case 19:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const CustomerInfo()));
    // case 20:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const SupplierInfo()));
    // case 21:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const PurchaseInvoice()));
    // case 22:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const SaleInvoice()));
    // case 23:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const PartyLedger()));
    // case 24:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const PartyBalances()));
    // case 25:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const PurchaseReport()));
    // case 26:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const SaleReport()));
    // case 27:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const ItemLedger()));
    // case 28:
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => const StockReport()));

    // SETTINGS MENU
      case 31:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => BlockedUsersPage()));
      case 32:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const CrudPage()));
      case 33:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SearchList()));
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