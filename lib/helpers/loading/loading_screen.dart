import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynote/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  LoadingScreen._instance();
  static final LoadingScreen _shared = LoadingScreen._instance();
  factory LoadingScreen() => _shared;

  LoadingScreenController? controller;

  LoadingScreenController showOverLay({
    required BuildContext context,
    required String text,
  }) {
    final textController = StreamController<String>();
    textController.add(text);

    OverlayState state = Overlay.of(context);
    //line 22 to 23 is possible because overlay's have no intrinsic sizes
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overLay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                minWidth: size.width * 0.5,
                maxHeight: size.height * 0.8,
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.5)),
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10.0,
                        ),
                        const CircularProgressIndicator(),
                        const SizedBox(
                          height: 20.0,
                        ),
                        StreamBuilder(
                          stream: textController.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data as String,
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return Container();
                            }
                          },
                        )
                      ],
                    ),
                  )),
            ),
          ),
        );
      },
    );

    state.insert(overLay);

    return LoadingScreenController(
      close: () {
        textController.close();
        overLay.remove();
        return true;
      },
      update: (text) {
        textController.add(text);
        return true;
      },
    );
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  void show({
    required BuildContext context,
    required String text,
  }) {
    if (controller?.update(text) ?? false) {
    } else {
      controller = showOverLay(context: context, text: text);
    }
  }
}
