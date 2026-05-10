import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';

class ModelController {
  static Future<ClassificationModel> loadModel() async {
    return await PytorchLite.loadClassificationModel(
        'assets/models/model.pt', 224, 224, 46,
        labelPath: 'assets/labels.txt');
  }

  static Future<void> runModel() async {
    ClassificationModel imageModel = await ModelController.loadModel();
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(
        source: (ImageSource.gallery), maxHeight: 224, maxWidth: 224);
    //get prediction
    final mean = [0.485, 0.456, 0.406];
    final std = [0.229, 0.224, 0.225];
    Uint8List bytes = await File(image!.path).readAsBytes();
    String? prediction =
        await imageModel.getImagePrediction(bytes, mean: mean, std: std);
  }

  static Future<String> runModelWithImage(XFile image) async {
    ClassificationModel imageModel = await ModelController.loadModel();
    //get prediction
    final mean = [0.485, 0.456, 0.406];
    final std = [0.229, 0.224, 0.225];
    Uint8List bytes = await File(image.path).readAsBytes();
    String? prediction =
        await imageModel.getImagePrediction(bytes, mean: mean, std: std);
    return (prediction);
  }
}
