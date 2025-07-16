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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'generated/l10n/app_localizations.dart';
import 'modes/admin_mode_controller.dart';
import 'modes/record_mode_controller.dart';
import 'modes/transcribe_mode_controller.dart';
import 'repos/phrases_repository.dart';
import 'repos/settings_repository.dart';
import 'repos/uploader.dart';
import 'settings/settings_controller.dart';

class HomeController extends StatefulWidget {
  final bool isCurrentUserAdmin;

  const HomeController({super.key, this.isCurrentUserAdmin = false});

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  int _selectedIndex = 0;

  @override
  void initState() {
    Provider.of<PhrasesRepository>(context, listen: false).initFromAssetFile();
    Provider.of<SettingsRepository>(context, listen: false)
        .initFromPreferences();
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getRecordedCount() {
    final storage = FirebaseStorage.instance;
    storage.setMaxOperationRetryTime(const Duration(seconds: 5));
    final storageRef = storage.ref();
    final userToken = FirebaseAuth.instance.currentUser?.uid ?? "data";
    final userStorageRef = storageRef.child(userToken);
    final children = userStorageRef.listAll();
    return FutureBuilder(
        future: children.then((x) => x.prefixes.length),
        builder: (context, snapshot) =>
            Text('${snapshot.data ?? 0} recordings'));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const RecordModeController(),
      const TranscribeModeController(),
      const AdminModeController(),
      const Center(
        child: IconButton(
          icon: Icon(Icons.construction),
          iconSize: 80,
          onPressed: null,
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Column(children: [
            Text(AppLocalizations.of(context)!.appTitle),
            Text(FirebaseAuth.instance.currentUser?.email ?? "",
                style: Theme.of(context).textTheme.bodySmall)
          ]),
          actions: [
            Consumer<Uploader>(
                builder: (context, uploader, _) => Stack(children: [
                      Visibility(
                          visible: uploader.showProgressIndicator,
                          child: const CircularProgressIndicator(
                              color: Colors.blue)),
                      Visibility(
                          visible: uploader.showUploadProgressIcon,
                          child: Container(
                              padding: const EdgeInsets.all(6),
                              child: uploader.uploadIcon))
                    ])),
            const SizedBox(width: 24)
          ]),
      body: widgetOptions[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_sharp),
              title:
                  Text(AppLocalizations.of(context)!.settingsMenuDrawerTitle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsController(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(AppLocalizations.of(context)!.profileMenuItemTitle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<ProfileScreen>(
                    builder: (context) => ProfileScreen(
                      appBar: AppBar(
                        title: Text(
                            AppLocalizations.of(context)!.profileMenuItemTitle),
                      ),
                      actions: [
                        SignedOutAction((context) {
                          Navigator.of(context).pop();
                        })
                      ],
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(2.0, 16.0, 2.0, 8.0),
                          child: Text("Email",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 4.0, 2.0, 16.0),
                          child: Text(
                              FirebaseAuth.instance.currentUser?.email ?? ""),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(2.0, 16.0, 2.0, 8.0),
                          child: Text("Total recordings",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 4.0, 2.0, 16.0),
                          child: _getRecordedCount(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: const Icon(Icons.mic),
                  label: AppLocalizations.of(context)!.recordModeTitle),
              BottomNavigationBarItem(
                icon: const Icon(Icons.hearing),
                label: AppLocalizations.of(context)!.transcribeModeTitle,
              ),
            ] +
            (widget.isCurrentUserAdmin
                ? [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.admin_panel_settings),
                      label: AppLocalizations.of(context)!.adminModeTitle,
                    ),
                  ]
                : []),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
