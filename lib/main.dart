import 'dart:convert';

import 'package:carrotmmu/logic/api.dart';
import 'package:carrotmmu/ui/checkin.dart';
import 'package:carrotmmu/ui/home.dart';
import 'package:carrotmmu/ui/login.dart';
import 'package:carrotmmu/ui/pastyear.dart';
import 'package:carrotmmu/ui/profile.dart';
import 'package:carrotmmu/ui/timetable.dart';
import 'package:carrotmmu/widget/faded_indexed_stack.dart';
import 'package:carrotmmu/widget/fader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:shake/shake.dart';
import 'package:get/get.dart';

// void main() => runApp(TabPage());

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      theme: ThemeData(
        cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.light),
        appBarTheme: AppBarTheme(brightness: Brightness.light),
        primaryColor: Colors.amber[50],
        accentColor: Colors.amber[600],
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.dark),
        appBarTheme: AppBarTheme(brightness: Brightness.dark),
        // backgroundColor: Colors.black,s
        primaryColor: Colors.amber[50],
        accentColor: Colors.amber[600],
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey.shade900,
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).copyWith(
          bodyText1: TextStyle(color: Colors.white),
        ),
      ),
      // darkTheme: ThemeData.dark(),
      title: 'CarrotMMU',
      // home: App(),

      onGenerateRoute: (settings) {
        // If you push the PassArguments route
        if (settings.name == '/') {
          // Cast the arguments to the correct type: ScreenArguments.

          // Then, extract the required data from the arguments and
          // pass the data to the correct screen.
          return MaterialWithModalsPageRoute(
            builder: (context) {
              return App();
            },
          );
        }

        return null;
      },
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final box = GetStorage();
  int selectedIndex = 0;
  var padding = EdgeInsets.symmetric(horizontal: 18, vertical: 5);
  double gap = 10;
  var routeName = ['/home', '/timetable', '/paper', '/profile'];

  ShakeDetector detector = ShakeDetector.waitForStart(
      onPhoneShake: () {
        print('shakeeeee');
          Get.to(CheckInScreen());
      }
  );

  @override
  void initState() {

    

  if(API.isLogin()) detector.startListening();
    MyApp.observer.analytics.setCurrentScreen(
      screenName: '/main',
    );
    box.listen(() {
      print('gg');
      setState(() {});
      selectedIndex = 0;
      
      if(API.isLogin()) detector.startListening();
      else detector.stopListening();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;

    return (!API.isLogin())
        ? Login()
        : Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            // backgroundColor: Colors.white,
            extendBody: true,
            body: SafeArea(
              // top:false,
              bottom: false,

              child: FadeIndexedStack(
                index: selectedIndex,
                children: [
                  Home(),
                  Timetable(),
                  Pastyear(),
                  Profile(),
                ],
              ),
            ),
            // backgroundColor: Colors.green,
            // body: Container(color: Colors.red,),
            bottomNavigationBar: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 0,
                          blurRadius: 40,
                          color: Colors.black.withOpacity(.15),
                          offset: Offset(0, 20))
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2),
                  child: GNav(
                      tabBackgroundColor: !darkModeOn  ? Colors.amber[50] : Colors.amber[50].withOpacity(.1),
                      activeColor: !darkModeOn  ? Colors.amber[600] : Colors.amber[200],
                      color: Colors.grey.shade500,
                      curve: Curves.easeOutExpo,
                      duration: Duration(milliseconds: 900),
                      tabs: [
                        GButton(
                          gap: gap,

                          iconSize: 22,
                          padding: padding,
                          icon: FeatherIcons.home,
                          // textStyle: t.textStyle,
                          text: 'Home',
                        ),
                        GButton(
                          gap: gap,
                          iconSize: 22,
                          padding: padding,
                          icon: FeatherIcons.calendar,
                          text: 'Timetable',
                        ),
                        GButton(
                          gap: gap,
                          iconSize: 22,
                          padding: padding,
                          icon: FeatherIcons.fileText,
// textStyle: t.textStyle,
                          text: 'Papers',
                        ),
                        GButton(
                          gap: gap,
                          iconSize: 22,
                          padding: padding,
                          icon: FeatherIcons.user,
                          leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              radius: 12,
                              backgroundImage: NetworkImage(
                                  "https://mmls.mmu.edu.my/img/student/1161303833.png")),
// textStyle: t.textStyle,
                          text: 'Profile',
                        )
                      ],
                      selectedIndex: selectedIndex,
                      onTabChange: (index) {
                        // _debouncer.run(() {

                        // print(index);
                        setState(() {
                          selectedIndex = index;
                          // badge = badge + 1;
                        });

                        HapticFeedback.selectionClick();

                        MyApp.observer.analytics.setCurrentScreen(
                          screenName: routeName[index] ?? '/404'
                        );
                        // controller.jumpToPage(index);
                        // });
                      }),
                ),
              ),
            ),
          );
  }
}
