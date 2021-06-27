import 'package:flutter/material.dart';
import 'package:payflow/modules/barcode_scanner/barcode_scanner_controller.dart';
import 'package:payflow/modules/barcode_scanner/barcode_scanner_status.dart';
import 'package:payflow/shared/bottom_sheet/bottom_sheet.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/themes/app_text_styles.dart';
import 'package:payflow/shared/widgets/set_label_buttons/set_label_buttons.dart';

class BarCodeScannerPage extends StatefulWidget {
  const BarCodeScannerPage({Key? key}) : super(key: key);

  @override
  _BarCodeScannerPageState createState() => _BarCodeScannerPageState();
}

class _BarCodeScannerPageState extends State<BarCodeScannerPage> {
  final controller = BarcodeScannerController();

  @override
  void initState() {
    controller.getAvailableCameras();
    controller.statusNotifier.addListener(
      () {
        if (controller.status.hasBarcode) {
          Navigator.pushReplacementNamed(context, '/insert_boleto',
              arguments: controller.status.barcode);
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      left: true,
      right: true,
      child: Stack(
        children: [
          ValueListenableBuilder<BarCodeScannerStatus>(
            valueListenable: controller.statusNotifier,
            builder: (_, status, __) {
              if (status.showCamera) {
                return Container(
                  child: controller.cameraController!.buildPreview(),
                );
              } else {
                return Container();
              }
            },
          ),
          RotatedBox(
            quarterTurns: 1,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  'Escaneie o código de barras do boleto',
                  style: TextStyles.buttonBackground,
                ),
                centerTitle: true,
                leading: BackButton(color: AppColors.background),
              ),
              body: Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.black.withOpacity(0.6),
                  )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        color: Colors.transparent,
                      )),
                  Expanded(
                      child: Container(
                    color: Colors.black.withOpacity(0.6),
                  )),
                ],
              ),
              bottomNavigationBar: SetLabelButtons(
                primaryLabel: 'Inserir código do boleto',
                primaryOnPressed: () {
                  Navigator.pushReplacementNamed(context, '/insert_boleto');
                },
                secondaryLabel: 'Adicionar da galeria',
                secondaryOnPressed: () {},
              ),
            ),
          ),
          ValueListenableBuilder<BarCodeScannerStatus>(
            valueListenable: controller.statusNotifier,
            builder: (_, status, __) {
              if (status.hasError) {
                return BottomSheetWidget(
                  title: 'Não foi possível indentificar um código de barras',
                  subtitle:
                      'Tente escanear novamente ou digite o código do seu boleto',
                  primaryLabel: 'Escanear novamente',
                  primaryOnPressed: () {
                    controller.scanWithCamera();
                  },
                  secondaryLabel: 'Digitar código',
                  secondaryOnPressed: () {
                    Navigator.pushReplacementNamed(context, '/insert_boleto');
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
