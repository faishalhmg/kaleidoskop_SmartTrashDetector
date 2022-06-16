import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaleidoskop_app/app/app_resources.dart';
import 'package:kaleidoskop_app/app/base/base_stateful.dart';
import 'package:kaleidoskop_app/main.dart';
import 'package:kaleidoskop_app/services/tensorflow_service.dart';
import 'package:kaleidoskop_app/view_models/camera_view_model.dart';
import 'package:kaleidoskop_app/widgets/aperture/aperture_widget.dart';
import 'package:kaleidoskop_app/widgets/confidence_widget.dart';

import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CameraScreenState();
  }
}

class _CameraScreenState extends BaseStateful<CameraScreen, CameraViewModel>
    with WidgetsBindingObserver {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  late StreamController<Map> apertureController;

  @override
  bool get wantKeepAlive => true;

  @override
  void afterFirstBuild(BuildContext context) {
    super.afterFirstBuild(context);
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void initState() {
    super.initState();
    loadModel(viewModel.state.type);
    initCamera();

    apertureController = StreamController<Map>.broadcast();
  }

  void initCamera() {
    _cameraController = CameraController(
        cameras[viewModel.state.cameraIndex], ResolutionPreset.high);
    _initializeControllerFuture = _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController.setFlashMode(FlashMode.off);

      /// TODO: Run Model
      setState(() {});
      _cameraController.startImageStream((image) async {
        if (!mounted) {
          return;
        }
        await viewModel.runModel(image);
      });
    });
  }

  void loadModel(ModelType type) async {
    await viewModel.loadModel(type);
  }

  Future<void> runModel(CameraImage image) async {
    if (mounted) {
      await viewModel.runModel(image);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    apertureController.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    /// TODO: Check Camera
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController.dispose();
    } else {
      initCamera();
    }
  }

  @override
  Widget buildPageWidget(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: buildBodyWidget(context),
    );
  }

  @override
  Widget buildBodyWidget(BuildContext context) {
    bool isInitialized = _cameraController.value.isInitialized;

    final Size screen = MediaQuery.of(context).size;
    final double screenHeight = max(screen.height, screen.width);
    final double screenWidth = min(screen.height, screen.width);

    final Size previewSize =
        isInitialized ? _cameraController.value.previewSize! : Size(100, 100);
    final double previewHeight = max(previewSize.height, previewSize.width);
    final double previewWidth = min(previewSize.height, previewSize.width);

    final double screenRatio = screenHeight / screenWidth;
    final double previewRatio = previewHeight / previewWidth;
    final maxHeight =
        screenRatio > previewRatio ? screenHeight : screenWidth * previewRatio;
    final maxWidth =
        screenRatio > previewRatio ? screenHeight / previewRatio : screenWidth;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      color: Colors.grey.shade900,
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
              width: MediaQuery.of(context).size.width,
              // child: Screenshot(
              //     controller: screenshotController,
              child: Stack(
                children: <Widget>[
                  OverflowBox(
                    maxHeight: maxHeight,
                    maxWidth: maxWidth,
                    child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CameraPreview(_cameraController);
                          } else {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.blue));
                          }
                        }),
                  ),
                  Consumer<CameraViewModel>(builder: (_, cameraViewModel, __) {
                    return ConfidenceWidget(
                      heightAppBar: 0,
                      entities: cameraViewModel.state.recognitions,
                      previewHeight: max(cameraViewModel.state.heightImage,
                          cameraViewModel.state.widthImage),
                      previewWidth: min(cameraViewModel.state.heightImage,
                          cameraViewModel.state.widthImage),
                      screenWidth: MediaQuery.of(context).size.width,
                      screenHeight: MediaQuery.of(context).size.height,
                      type: cameraViewModel.state.type,
                    );
                  }),
                  OverflowBox(
                    maxHeight: maxHeight,
                    maxWidth: maxWidth,
                    child: ApertureWidget(
                      apertureController: apertureController,
                    ),
                  ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.red, width: 2)),
                  // )
                ],
              ))),
    );
  }

  // @override
  // Widget buildBottomWidget(BuildContext context) {
  //   return FloatingActionButton(
  //       onPressed: () {
  //         // Navigator.pop(context);
  //       },
  //       backgroundColor: Colors.green,
  //       child: const Icon(Icons.arrow_back));
  // }
}
