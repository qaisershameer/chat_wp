import 'package:flutter/material.dart';
import 'package:chat_wp/pages/accounts/area_info.dart';

class MyListTile extends StatelessWidget {
  final int pageNo;
  final String text;
  final IconData icon;

  const MyListTile({super.key, required this.pageNo, required this.text, required this.icon});


  void _showPage(int pageNum, BuildContext context){
    switch (pageNum) {
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 5:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 6:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 7:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
      case 8:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const AreaInfo()));
        return;
    }
    }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:(){
        _showPage(1, context);
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
              child: Icon(icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            // title
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            // button to go blocked users page
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
