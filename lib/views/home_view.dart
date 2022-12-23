import 'package:flutter/material.dart';
import 'package:nerdcollector/constants/menu_action.dart';
import 'package:nerdcollector/constants/routes.dart';
import 'package:nerdcollector/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;

import 'package:nerdcollector/views/camera_view.dart';
import 'package:nerdcollector/views/audio_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // if (snapshot.data == null){
  //   final snapdata = snapshot.data;
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nerd Collector'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.photo_camera)),
              Tab(icon: Icon(Icons.favorite_border_outlined)),
              Tab(icon: Icon(Icons.public)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                devtools.log(
                  value.toString(),
                );
                switch (value) {
                  case MenuAction.logout:
                    final isLogout = await logoutDialogue(context);
                    if (isLogout) {
                      devtools.log('User logged out');
                      await AuthService.firebase().logOut();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text('Logout'),
                  ),
                ];
              },
            )
          ],
        ),
        body: const TabBarView(
          children: [
            CameraView(),
            AudioView(),
            // Icon(Icons.favorite_border_outlined),
            Icon(Icons.public),
            Icon(Icons.settings),
          ],
        ),
      ),
    );
  }
}

Future<bool> logoutDialogue(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
