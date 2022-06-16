import 'package:kaleidoskop_app/services/tensorflow_service.dart';

import '/models/recognition.dart';

class CameraViewState {
  ModelType type;

  late List<Recognition> recognitions = <Recognition>[];

  int widthImage = 0;

  int heightImage = 0;

  int cameraIndex = 0;

  CameraViewState(this.type);

  bool isFrontCamera() {
    return cameraIndex == 1;
  }

  bool isBackCamera() {
    return cameraIndex == 0;
  }

  bool isYolo() {
    return type == ModelType.YOLO;
  }
}
