import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  MobileScannerController controleurScanner = MobileScannerController();
  String? dernierCodeScanne;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              controleurScanner.toggleTorch();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: controleurScanner,
              onDetect: (capture) {
                final List<Barcode> codes = capture.barcodes;
                if (codes.isNotEmpty) {
                  String code = codes.first.rawValue ?? '';
                  setState(() {
                    dernierCodeScanne = code;
                  });

                  // Afficher le résultat
                  _afficherResultat(code);
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black.withOpacity(0.7),
            child: Column(
              children: [
                const Text(
                  'Pointez la caméra vers un QR Code',
                  style: TextStyle(color: Colors.white),
                ),
                if (dernierCodeScanne != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Dernier scan: $dernierCodeScanne',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _afficherResultat(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code détecté'),
        content: SelectableText(code),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              // Copier dans le presse-papier
              // TODO: Implémenter la copie
              Navigator.pop(context);
            },
            child: const Text('Copier'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controleurScanner.dispose();
    super.dispose();
  }
}