import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/data/models/navigation/node_model.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

enum QRScanMode { startNavigation, relocate }

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key, required this.mode, required this.map});

  final QRScanMode mode;
  final LibraryMapModel map;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  //--------------------------------------------------
  Future<void> _fakeScan() async {
    final selectedNode = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Fake QR"),
        content: SizedBox(
          width: 320,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.map.nodes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final node = widget.map.nodes[index];

              return ListTile(
                title: Text(node.id),
                subtitle: Text(node.name),
                trailing: Text(
                  "(${node.x.toStringAsFixed(1)}, ${node.y.toStringAsFixed(1)})",
                ),
                onTap: () => Navigator.pop(context, node.id),
              );
            },
          ),
        ),
      ),
    );

    if (selectedNode == null || !mounted) {
      return;
    }

    Navigator.pop(context, selectedNode);
  }
  //--------------------------------------------------

  void _handleBarcode(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;

    if (rawValue == null) {
      return;
    }

    debugPrint("debug - QR Scanned : $rawValue");

    final matchedNode = _resolveNode(rawValue);

    if (matchedNode == null) {
      debugPrint(
        "debug - No node found with qr == \"$rawValue\". Available QR "
        "codes: ${widget.map.nodes.where((n) => n.qr != null).map((n) => n.qr).join(', ')}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unrecognized QR code: $rawValue")),
      );
      return;
    }

    Navigator.pop(context, matchedNode.id);
  }

  /// Matches a raw scanned QR string against each node's `qr` field
  /// (case/whitespace-insensitive), returning the node whose id should
  /// actually be used for navigation.
  NodeModel? _resolveNode(String rawValue) {
    final normalized = rawValue.trim().toUpperCase().replaceAll(' ', '');

    for (final node in widget.map.nodes) {
      final nodeQr = node.qr?.trim().toUpperCase().replaceAll(' ', '');
      if (nodeQr != null && nodeQr == normalized) {
        return node;
      }
    }

    return null;
  }

  //--------------------------------------------------

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.mode) {
      QRScanMode.startNavigation => "Scan Start QR",
      QRScanMode.relocate => "Scan Current QR",
    };

    final buttonText = switch (widget.mode) {
      QRScanMode.startNavigation => "Fake Start QR",
      QRScanMode.relocate => "Fake Current QR",
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleBarcode),

          // Dev-only bypass for testing without printed QR codes — must
          // never reach a release build, since it would let anyone skip
          // scanning entirely.
          // if (kDebugMode)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.black54,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _fakeScan,
                  child: Text(buttonText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
