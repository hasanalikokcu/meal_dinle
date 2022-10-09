import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meal/components/saved_tabIndex.dart';
import 'package:meal/components/theme_manager.dart';
import 'package:meal/widgets/cuz_page.dart';
import 'package:meal/widgets/sure_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => new ThemeNotifier(),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    init();
  }

  Future<void> init() async {
    SharedPreferences prefTabIndex = await SharedPreferences.getInstance();

    String? json = prefTabIndex.getString("keyTabIndex");

    if (json == null) {
      _selectedIndex = 0;
      print(json);
    } else {
      Map<String, dynamic> map = jsonDecode(json);

      final savedTabIndex = SavedTabIndex.fromJson(map);
      print(json);

      _selectedIndex = int.parse(savedTabIndex.tabIndex ?? "0");
    }
    setState(() {
      isLoading = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [CuzPage(), SurePage()];
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => MaterialApp(
        theme: theme.getTheme(),
        //debugShowCheckedModeBanner: false,
        home: !isLoading
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                      ),
                      onPressed: () {},
                    )
                  ],
                  title: Text("MEAL"),
                  centerTitle: true,
                ),
                drawer: Drawer(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(Icons.dark_mode),
                            Text("Koyu Mod"),
                            Switch(
                                value: theme.getThemeBool(),
                                onChanged: (bool newValue) {
                                  setState(() {
                                    if (theme.getThemeBool()) {
                                      theme.setLightMode();
                                    } else {
                                      theme.setDarkMode();
                                    }
                                  });
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // drawer: Column(
                  //   children: [

                  // Container(
                  //   padding: EdgeInsets.only(top: 100),
                  //   child: FlatButton(
                  //     onPressed: () => {
                  //       print('Set Light Theme'),
                  //       theme.setLightMode(),
                  //     },
                  //     child: Text('Set Light Theme'),
                  //   ),
                  // ),
                  // Container(
                  //   child: FlatButton(
                  //     onPressed: () => {
                  //       print('Set Dark theme'),
                  //       theme.setDarkMode(),
                  //     },
                  //     child: Text('Set Dark theme'),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 100.0),
                  //   child: Row(
                  //     children: [
                  //       Text("Koyu Mod"),
                  //       Switch(
                  //           value: theme.getThemeBool(),
                  //           onChanged: (bool newValue) {
                  //             setState(() {
                  //               if (theme.getThemeBool()) {
                  //                 theme.setLightMode();
                  //               } else {
                  //                 theme.setDarkMode();
                  //               }
                  //             });
                  //           }),
                  //     ],
                  //   ),
                  //   // )
                  // ],
                  // ),
                ),
                body: DoubleBackToCloseApp(
                  snackBar: const SnackBar(
                    content: Text('Uygulamadan çıkmak için tekrar basın!'),
                    duration: Duration(seconds: 1),
                  ),
                  child: Container(child: _children.elementAt(_selectedIndex)),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.apps_outlined),
                      label: 'Cüz',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.auto_awesome_motion_outlined),
                      label: 'Sureler',
                    ),
                  ],
                  selectedItemColor: Colors.amber[800],
                  onTap: _onItemTapped,
                ),
              ),
      ),
    );
  }

  late int _selectedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
