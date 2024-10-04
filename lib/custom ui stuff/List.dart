import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String titleText;
  final VoidCallback onTap;
  final IconData leadingIcon;
  final bool showArrow;

  const CustomListTile({
    super.key,
    required this.titleText,
    required this.onTap,
    required this.leadingIcon,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(leadingIcon),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                titleText,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                ),
              ),
            ),
          ),
          if (showArrow)
            const Icon(Icons.arrow_forward_ios),        ],
      ),
      onTap: onTap,
    );
  }
}
