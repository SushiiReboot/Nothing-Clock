import 'package:flutter/material.dart';
import 'package:nothing_clock/screens/settings_screen.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function(int) callback;

  const TopBar(
      {super.key,
      this.scaffoldKey,
      required this.callback,
      required this.selectedIndex});

  final int selectedIndex;

  @override
  // ignore: library_private_types_in_public_api
  _TopBarState createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (widget.selectedIndex != _tabController.index) {
        widget.callback(_tabController.index);
      }
    });
  }

  @override
  void didUpdateWidget(TopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _tabController.index) {
      _tabController.index = widget.selectedIndex;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    _tabController.index = widget.selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: AppBar(
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        title: TabBar(
          onTap: (value) {
            setState(() {
              widget.callback(value);
            });
          },
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.red,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          unselectedLabelColor: theme.colorScheme.onSurface,
          indicatorColor: Colors.transparent,
          tabs: const [
            Tab(text: "CLOCK"),
            Tab(text: "ALARMS"),
            Tab(text: "TIMER"),
            Tab(text: "STOPWATCH"),
          ],
        ),
      ),
    );
  }
}
