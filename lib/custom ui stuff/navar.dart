import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final Function(int) onTabSelected;
  final int selectedIndex;

  NavBar({super.key, required this.onTabSelected, required this.selectedIndex});

  final List<NavBarItem> _navBarItems = [
    NavBarItem(icon: Icons.home, title: "Home", selectedColor: Colors.purple),
    NavBarItem(icon: Icons.grid_view, title: "Profiles", selectedColor: Colors.pink),
    NavBarItem(icon: Icons.camera_alt, title: "Scan", selectedColor: Colors.orange),
    NavBarItem(icon: Icons.favorite, title: "Saved", selectedColor: Colors.red),
    NavBarItem(icon: Icons.person, title: "Profile", selectedColor: Colors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final unselectedColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _navBarItems.asMap().entries.map((entry) {
          int index = entry.key;
          NavBarItem item = entry.value;
          return _buildNavItem(
            context: context,
            icon: item.icon,
            title: item.title,
            selectedColor: item.selectedColor,
            unselectedColor: unselectedColor,
            index: index,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color selectedColor,
    required Color unselectedColor,
    required int index,
  }) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
          ),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarItem {
  final IconData icon;
  final String title;
  final Color selectedColor;

  NavBarItem({required this.icon, required this.title, required this.selectedColor});
}
