import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:kaleidoskop_app/app/base/base_view_model.dart';
import 'package:kaleidoskop_app/models/recognition.dart';
import 'package:kaleidoskop_app/services/tensorflow_service.dart';
import 'package:kaleidoskop_app/view_states/camera_view_state.dart';

class CameraViewModel extends BaseViewModel<CameraViewState> {
  bool _isLoadModel = false;
  bool _isDetecting = false;

  late TensorFlowService _tensorFlowService;

  CameraViewModel(BuildContext context, this._tensorFlowService)
      : super(context, CameraViewState(_tensorFlowService.type));

  // Future switchCamera() async {
  //   state.cameraIndex = state.cameraIndex == 0 ? 1 : 0;
  //   this.notifyListeners();
  // }

  Future<void> loadModel(ModelType type) async {
    state.type = type;
    //if (type != this._tensorFlowService.type) {
    await this._tensorFlowService.loadModel(type);
    //}
    this._isLoadModel = true;
  }

  Future<void> runModel(CameraImage cameraImage) async {
    if (_isLoadModel && mounted) {
      if (!this._isDetecting && mounted) {
        this._isDetecting = true;
        int startTime = new DateTime.now().millisecondsSinceEpoch;
        var recognitions =
            await this._tensorFlowService.runModelOnFrame(cameraImage);
        int endTime = new DateTime.now().millisecondsSinceEpoch;
        print('Time detection: ${endTime - startTime}');
        if (recognitions != null && mounted) {
          state.recognitions = List<Recognition>.from(
              recognitions.map((model) => Recognition.fromJson(model)));
          state.widthImage = cameraImage.width;
          state.heightImage = cameraImage.height;
          notifyListeners();
        }
        this._isDetecting = false;
      }
    } else {
      print(
          'Please run `loadModel(type)` before running `runModel(cameraImage)`');
    }
  }

  Future<void> close() async {
    await this._tensorFlowService.close();
  }

  void updateTypeTfLite(ModelType item) {
    this._tensorFlowService.type = item;
  }
}
