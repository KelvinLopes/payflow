class BarCodeScannerStatus {
  final bool isCameraAvailable;
  final String error;
  final String barcode;
  final bool stopScanner;

  BarCodeScannerStatus({
    this.isCameraAvailable = false,
    this.error = '',
    this.barcode = '',
    this.stopScanner = false,
  });

  factory BarCodeScannerStatus.available() =>
      BarCodeScannerStatus(isCameraAvailable: true, stopScanner: false);

  factory BarCodeScannerStatus.error(String message) =>
      BarCodeScannerStatus(error: message, stopScanner: true);

  factory BarCodeScannerStatus.barcode(String barcode) =>
      BarCodeScannerStatus(barcode: barcode, stopScanner: true);

  bool get showCamera => isCameraAvailable && error.isEmpty;

  bool get hasError => error.isNotEmpty;

  bool get hasBarcode => barcode.isNotEmpty;
}
