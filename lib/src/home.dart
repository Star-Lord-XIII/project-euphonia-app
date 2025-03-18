// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import 'modes/train_mode_controller.dart';
import 'modes/transcribe_mode_controller.dart';
import 'settings/settings_controller.dart';

class HomeController extends StatefulWidget {
  const HomeController({super.key, required this.title});

  final String title;

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const TrainModeController(),
    const TranscribeModeController(),
    const Center(
      child: IconButton(
        icon: Icon(Icons.construction),
        iconSize: 80,
        onPressed: null,
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(widget.title)),
      body: _widgetOptions[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Project Euphonia',
                style: TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_sharp),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsController(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Train'),
          BottomNavigationBarItem(
            icon: Icon(Icons.hearing),
            label: 'Transcribe',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
