import 'package:flutter/material.dart';

class CustomListTileCard extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final IconData trailingIcon;
  final VoidCallback onTap;

  const CustomListTileCard({
    Key? key,
    required this.leadingIcon,
    required this.title,
    this.trailingIcon = Icons.chevron_right, // Default trailing icon
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25), // Rounded corners
      ),
      elevation: 2, // Slight shadow
      child: ListTile(
        leading: Icon(leadingIcon), // Custom leading icon
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(trailingIcon), // Custom trailing icon
        onTap: onTap, // onTap action
      ),
    );
  }
}
