import 'package:flutter/material.dart';
import '../pages/home.page.dart';
import '../pages/generate.page.dart';

final List<MenuItem> menuItems = <MenuItem>[
  MenuItem('Payload Viewer', HomePage()),
  MenuItem('Generate Payload', GeneratePage()),
];

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return MenuItemWidget(menuItems[index]);
        },
        itemCount: menuItems.length,
      ),
    );
  }
}

class MenuItem {
  MenuItem(this.title, this.page);

  final String title;
  final Widget page;
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem item;
  const MenuItemWidget(this.item);

  Widget _buildMenu(MenuItem menuItem, context) {
    return ListTile(
      title: Text(menuItem.title),
      onTap: () {
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => menuItem.page,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMenu(this.item, context);
  }
}