import 'package:flutter/material.dart';
import '../waste_app_theme.dart';

class ChatView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const ChatView({Key? key, this.animationController, this.animation})
      : super(key: key);
  Future<void> _showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chatbot saat ini tidak bisa digunakan'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Chatbot is under maintenance'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 0, bottom: 0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: WasteAppTheme.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                                topRight: Radius.circular(8.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: WasteAppTheme.grey.withOpacity(0.4),
                                  offset: Offset(1.1, 1.1),
                                  blurRadius: 10.0),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.topLeft,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10, bottom: 10, top: 10),
                                  height: 60,
                                  width: double.infinity,
                                  color: Colors.white,
                                  child: Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlue,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                              hintText:
                                                  "Chatbot is under maintenance...",
                                              hintStyle: TextStyle(
                                                  color: Colors.black54),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      FloatingActionButton(
                                        onPressed: () {
                                          _showMyDialog(context);
                                        },
                                        child: Icon(
                                          Icons.send,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        backgroundColor: Colors.blue,
                                        elevation: 0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
