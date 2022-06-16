import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaleidoskop_app/app/base/base_stateful.dart';
import 'package:kaleidoskop_app/services/tensorflow_service.dart';
import 'package:kaleidoskop_app/view_models/local_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocalScreenState();
  }
}

class _LocalScreenState extends BaseStateful<LocalScreen, LocalViewModel> {
  ImagePicker _imagePicker = ImagePicker();

  double _imageHeight = 0;
  double _imageWidth = 0;

  @override
  void afterFirstBuild(BuildContext context) {
    super.afterFirstBuild(context);
  }

  @override
  void initState() {
    super.initState();
    loadModel(ModelType.YOLO);
  }

  void loadModel(ModelType type) async {
    await viewModel.loadModel(type);
  }

  void runModel(File image) async {
    if (mounted) {
      await viewModel.runModel(image);
      viewModel.isLoading = false;
    }
  }

  selectImage() async {
    viewModel.isLoading = true;
    XFile? _imageFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (_imageFile == null) {
      viewModel.isLoading = false;
      _imageFile = await _imagePicker.pickImage(source: ImageSource.camera);
      return;
    }
    viewModel.updateImageSelected(File(_imageFile.path));

    new FileImage(viewModel.state.imageSelected!)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    runModel(viewModel.state.imageSelected!);
  }

  @override
  Widget buildPageWidget(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        body: buildBodyWidget(context),
        floatingActionButton: buildButton(context));
  }

  Widget buildButton(BuildContext context) {
    return ElevatedButton(
      child: Container(
          child: Row(
        children: [
          Icon(
            Icons.file_upload_outlined,
            size: 100,
          ),
          Text(
            "Upload!",
            style: TextStyle(fontSize: 30),
          ),
        ],
      )),
      onPressed: selectImage,
      style: ElevatedButton.styleFrom(primary: Colors.green),
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.close();
  }

  @override
  Widget buildBodyWidget(BuildContext context) {
    return Consumer<LocalViewModel>(builder: (build, provide, _) {
      return contentWidget();
    });
  }

  Future<void> _showAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deteksi Gambar bermasalah!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Aplikasi tidak bisa membaca gambar dengan jelas.'),
                Text('Cobalah untuk menginputkan gambar lain!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> renderBoxes(Size screen) {
    if (_imageHeight == 0 || _imageWidth == 0) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;
    // Color blue = Color.fromRGBO(37, 213, 253, 1.0);
    return viewModel.state.recognitions.map((re) {
      return Positioned(
        left: re["rect"]["x"] * factorX,
        top: re["rect"]["y"] * factorY,
        width: re["rect"]["w"] * factorX,
        height: re["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
          ),
          child: Text(
            "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = Colors.green,
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget contentWidget() {
    List<Widget> stackChildren = renderBoxes(MediaQuery.of(context).size);
    if (viewModel.state.imageSelected == null) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.green, width: 2)),
        child: Image.network(
            "https://asset-a.grid.id//crop/0x0:0x0/700x465/photo/2021/10/25/memilah-sampahjpg-20211025082824.jpg"),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.green, width: 2)),
        child: Padding(
            padding: const EdgeInsets.all(0),
            child: Stack(
              children: [
                Positioned(
                    top: 0.0,
                    left: 0.0,
                    width: MediaQuery.of(context).size.width,
                    child: Image.file(viewModel.state.imageSelected!)),
                ...stackChildren
              ],
            )),
      );
    }
  }
}
