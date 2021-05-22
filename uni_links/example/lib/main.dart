import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';


void main() {
  ExampleLinkObserver.init();

  runApp(MyApp());
}

class ExampleLinkObserver extends LinkObserver {

  ExampleLinkObserver.init() : super.init();

  @override
  void handleUri(Uri uri) {
    final String path = uri.fragment;
    if (path.contains("home")) {
      maybeShowInSnackBar("Link contains 'home'");
    }
  }

}



abstract class LinkObserver with WidgetsBindingObserver {

  LinkObserver.init() {
    WidgetsBinding.instance?.addObserver(this);

    LinkListener.init(handleUri,handleError, true);
  }

  void dispose() {
    LinkListener.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LinkListener.init(handleUri, handleError, false);
    }
  }

  void handleError(Object error, StackTrace stackTrace) {
    print(error);
    print(stackTrace);
  }

  void handleUri(Uri uri);

}


typedef HandleUri = void Function(Uri uri);

typedef HandleUriError = void Function(Object error, StackTrace stackTrace);

class LinkListener {

  static StreamSubscription? _sub;

  static Future<void> init(HandleUri handleUri, HandleUriError handleError, bool initial) async {
    if (initial) {
      try {
        final Uri? initialUri = await getInitialUri();
        if (initialUri != null) {
          return handleUri(initialUri);
        }
      } on FormatException catch (error, stackTrace) {
        handleError(error, stackTrace);
      }
    }

    LinkListener._sub ??= uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          handleUri(uri);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        handleError(error, stackTrace);
      },
    );
  }

  static void dispose() {
    if (LinkListener._sub != null) {
      LinkListener._sub!.cancel();
      LinkListener._sub = null;
    }
  }

}

class NavigationKey {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
}

void maybeShowInSnackBar(String value) {
  try {
    final BuildContext? context = NavigationKey.key.currentContext;
    if (context == null) {
      return;
    }

    final ScaffoldMessengerState? scaffoldState = context == null ? null : ScaffoldMessenger.maybeOf(context);
    if (scaffoldState == null) {
      print("Could not show snackbar: ${value}");

      return;
    }

    scaffoldState.removeCurrentSnackBar();
    scaffoldState.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 5),
      content: Text(
        value,
        textAlign: TextAlign.center,
      ),
    ));
  } catch (e) {
    print("Could not show snackbar: ${value}");
  }
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('uni_links example app'),
      ),
      body: Text("Hello"),
    );
  }
}
