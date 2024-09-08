import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
              icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        title: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
