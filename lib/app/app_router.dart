import 'package:flutter/material.dart';
import 'package:kaleidoskop_app/chatbot/chatbot_screen.dart';
import 'package:kaleidoskop_app/dashboard/Dashboard_screen.dart';
import 'package:kaleidoskop_app/pages/home_screen.dart';
import 'package:kaleidoskop_app/pages/local_screen.dart';
import 'package:kaleidoskop_app/pages/splash_screen.dart';
import 'package:kaleidoskop_app/services/tensorflow_service.dart';
import 'package:kaleidoskop_app/view_models/camera_view_model.dart';
import 'package:kaleidoskop_app/view_models/local_view_model.dart';
import 'package:kaleidoskop_app/waste_app_home_screen.dart';

import 'package:provider/provider.dart';

class AppRoute {
  static const homeScreen = '/homeScreen';
  static const dashboardScreen = '/dashboardScreen';
  static const chatScreen = '/chatScreen';
  static const splashScreen = '/splashScreen';
  static const home = '/home';
  static const localScreen = '/localScreen';

  static final AppRoute _instance = AppRoute._private();
  factory AppRoute() {
    return _instance;
  }
  AppRoute._private();

  static AppRoute get instance => _instance;

  static Widget createProvider<P extends ChangeNotifier>(
    P Function(BuildContext context) provider,
    Widget child,
  ) {
    return ChangeNotifierProvider<P>(
      create: provider,
      builder: (_, __) {
        return child;
      },
    );
  }

  Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return AppPageRoute(builder: (_) => SplashScreen());

      case homeScreen:
        Duration? duration;
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          if ((args['isWithoutAnimation'] as bool)) {
            duration = Duration.zero;
          }
        }
        return AppPageRoute(
            appTransitionDuration: duration,
            appSettings: settings,
            builder: (_) => ChangeNotifierProvider(
                create: (context) => CameraViewModel(context,
                    Provider.of<TensorFlowService>(context, listen: false)),
                builder: (_, __) => WasteAppHomeScreen()));
      case home:
        Duration? duration;
        if (settings.arguments != null) {
          final args = settings.arguments as Map<String, dynamic>;
          if ((args['isWithoutAnimation'] as bool)) {
            duration = Duration.zero;
          }
        }
        return AppPageRoute(
            appTransitionDuration: duration,
            appSettings: settings,
            builder: (_) => ChangeNotifierProvider(
                create: (context) => CameraViewModel(context,
                    Provider.of<TensorFlowService>(context, listen: false)),
                builder: (_, __) => CameraScreen()));
      case dashboardScreen:
        return AppPageRoute(
            appSettings: settings,
            builder: (_) => ChangeNotifierProvider(
                create: (context) => LocalViewModel(context,
                    Provider.of<TensorFlowService>(context, listen: false)),
                builder: (_, __) => DashboardScreen()));
      case chatScreen:
        return AppPageRoute(
            appSettings: settings,
            builder: (_) => ChangeNotifierProvider(
                create: (context) => LocalViewModel(context,
                    Provider.of<TensorFlowService>(context, listen: false)),
                builder: (_, __) => ChatbotScreen()));
      case localScreen:
        return AppPageRoute(
            appSettings: settings,
            builder: (_) => ChangeNotifierProvider(
                create: (context) => LocalViewModel(context,
                    Provider.of<TensorFlowService>(context, listen: false)),
                builder: (_, __) => LocalScreen()));
    }
  }
}

class AppPageRoute extends MaterialPageRoute<Object> {
  Duration? appTransitionDuration;

  RouteSettings? appSettings;

  AppPageRoute(
      {required WidgetBuilder builder,
      this.appSettings,
      this.appTransitionDuration})
      : super(builder: builder);

  @override
  Duration get transitionDuration =>
      appTransitionDuration ?? super.transitionDuration;

  @override
  RouteSettings get settings => appSettings ?? super.settings;
}
