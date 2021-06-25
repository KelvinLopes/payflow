import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payflow/modules/barcode_scanner/barcode_scanner_status.dart';

class BarcodeScannerController {
  final statusNotifier =
      ValueNotifier<BarCodeScannerStatus>(BarCodeScannerStatus());
  BarCodeScannerStatus get status => statusNotifier.value;
  set status(BarCodeScannerStatus status) => statusNotifier.value = status;

  final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  InputImage? imagePicker;

  void getAvailableCameras() async {
    try {
      final response = await availableCameras();
      final camera = response.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back);
      final cameraController =
          CameraController(camera, ResolutionPreset.max, enableAudio: false);
      await cameraController.initialize();
      status = BarCodeScannerStatus.available(cameraController);
      scanWithCamera();
    } catch (e) {
      status = BarCodeScannerStatus.error(e.toString());
    }
  }

  Future<void> scannerBarCode(InputImage inputImage) async {
    try {
      if (status.cameraController != null) {
        if (status.cameraController!.value.isStreamingImages)
          status.cameraController!.stopImageStream();
      }
      final barcodes = await barcodeScanner.processImage(inputImage);
      var barcode;
      for (Barcode item in barcodes) {
        barcode = item.value.displayValue;
      }

      if (barcode != null && status.barcode.isEmpty) {
        status = BarCodeScannerStatus.barcode(barcode);
        status.cameraController!.dispose();
      } else {
        getAvailableCameras();
      }

      return;
    } catch (e) {
      print("ERRO DA LEITURA $e");
    }
  }

  void scanWithImagePicker() async {
    await status.cameraController!.stopImageStream();
    final response = await ImagePicker().getImage(source: ImageSource.gallery);
    final inputImage = InputImage.fromFilePath(response!.path);
    scannerBarCode(inputImage);
  }

  void scanWithCamera() {
    Future.delayed(Duration(seconds: 10)).then((value) {
      if (status.cameraController != null) {
        if (status.cameraController!.value.isStreamingImages)
          status.cameraController!.stopImageStream();
      }
      status = BarCodeScannerStatus.error("Timeout de leitura de boleto");
    });
    listenCamera();
  }

  void listenCamera() {
    if (status.cameraController!.value.isStreamingImages == false)
      status.cameraController!.startImageStream((cameraImage) async {
        try {
          final WriteBuffer allBytes = WriteBuffer();
          for (Plane plane in cameraImage.planes) {
            allBytes.putUint8List(plane.bytes);
          }
          final bytes = allBytes.done().buffer.asUint8List();
          final Size imageSize =
              Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
          final InputImageRotation imageRotation =
              InputImageRotation.Rotation_0deg;
          final InputImageFormat inputImageFormat =
              InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
                  InputImageFormat.NV21;
          final planeData = cameraImage.planes.map(
            (Plane plane) {
              return InputImagePlaneMetadata(
                bytesPerRow: plane.bytesPerRow,
                height: plane.height,
                width: plane.width,
              );
            },
          ).toList();

          final inputImageData = InputImageData(
            size: imageSize,
            imageRotation: imageRotation,
            inputImageFormat: inputImageFormat,
            planeData: planeData,
          );
          final inputImageCamera = InputImage.fromBytes(
              bytes: bytes, inputImageData: inputImageData);
          await Future.delayed(Duration(seconds: 3));
          await scannerBarCode(inputImageCamera);
        } catch (e) {
          print(e);
        }
      });
  }

  void dispose() {
    statusNotifier.dispose();
    barcodeScanner.close();
    if (status.showCamera) {
      status.cameraController!.dispose();
    }
  }
}