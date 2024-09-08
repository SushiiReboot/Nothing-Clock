import 'package:flutter/material.dart';

class DrawerPopup extends StatelessWidget {
  const DrawerPopup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          ListTile(
            title: Text("Settings"),
            leading: Icon(Icons.settings_outlined),
          ),
          ListTile(
            title: Text("About"),
            leading: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
