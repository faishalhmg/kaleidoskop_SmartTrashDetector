import 'package:flutter/material.dart';
import 'package:kaleidoskop_app/dashboard/Dashboard_screen.dart';
import 'package:kaleidoskop_app/models/tabIcon_data.dart';
import 'package:kaleidoskop_app/pages/home_screen.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'chatbot/chatbot_screen.dart';
import 'waste_app_theme.dart';

class WasteAppHomeScreen extends StatefulWidget {
  @override
  _WasteAppHomeScreenState createState() => _WasteAppHomeScreenState();
}

class _WasteAppHomeScreenState extends State<WasteAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  List<TabIconData> tabIconsList = TabIconData.tabIconsList;

  Widget tabBody = Container(
    color: WasteAppTheme.background,
  );

  @override
  void initState() {
    tabIconsList.forEach((TabIconData tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = DashboardScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WasteAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            setState(() {
              tabBody = CameraScreen();
            });
            tabIconsList[0].isSelected = false;
            tabIconsList[1].isSelected = false;
          },
          changeIndex: (int index) {
            if (index == 0) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      DashboardScreen(animationController: animationController);
                });
              });
            } else if (index == 1) {
              animationController?.reverse().then<dynamic>((data) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  tabBody =
                      ChatbotScreen(animationController: animationController);
                });
              });
            }
          },
        ),
      ],
    );
  }
}
