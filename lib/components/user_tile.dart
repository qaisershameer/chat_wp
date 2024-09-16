import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const UserTile(
      {super.key,
      required this.text,
      required this.onTap,
      required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  )
              ),
              child: const CircleAvatar(
                backgroundImage: AssetImage('images/pk01.jpg'),
              ),
            ),

            // icon
            // const Icon(Icons.person),

            // icon & text vertical gap in width
            const SizedBox(
              width: 10,
            ),

            // user name
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
