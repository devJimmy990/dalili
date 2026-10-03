import 'dart:async';

import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/services/shared_camera_lock.dart';
import 'package:dalili/core/utils/qr_payload.dart';
import 'package:dalili/features/library/data/models/navigation/library_map_model.dart';
import 'package:dalili/features/library/presentation/screens/navigation/qr_node_resolver.dart';
import 'package:flutter/foundation.dart';
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
  // autoStart is off: this screen sits right after ArNavigationScreen in
  // every "pick a destination" flow, and that screen's `camera` plugin
  // session may still be mid-release when this one mounts (Android only
  // allows one owner of the physical camera). Starting immediately would
  // race that release and come up frozen on the last frame instead of a
  // live feed. See SharedCameraLock.
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
  );
  bool _starting = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    setState(() {
      _starting = true;
      _errorMessage = null;
    });

    try {
      await SharedCameraLock.awaitRelease();

      if (!mounted) return;

      await _controller.start();

      if (!mounted) return;

      setState(() => _starting = false);
    } catch (e) {
      // Without this, any failure here (camera still busy, permission
      // hiccup, plugin-side timeout) leaves _starting stuck at true
      // forever — a loading spinner with no way out, since nothing else
      // ever flips it back off.
      if (!mounted) return;

      setState(() {
        _starting = false;
        _errorMessage = AppLocalizations.navCameraStartError(e.toString());
      });
    }
  }

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

    _popWithRelease(selectedNode);
  }
  //--------------------------------------------------

  /// Releases the camera *before* popping, instead of leaving it to
  /// [dispose] — which Flutter only calls once the pop transition
  /// animation finishes, well after the `Navigator.push` caller (e.g.
  /// ArNavigationScreen re-acquiring its own camera right after this
  /// screen returns) has already resumed. Without this, the next screen
  /// can start racing this screen's still-alive `mobile_scanner` session
  /// for the physical camera. See [SharedCameraLock].
  void _popWithRelease(String? nodeId) {
    final future = _controller.stop();
    SharedCameraLock.pendingRelease = future;
    unawaited(future);
    Navigator.pop(context, nodeId);
  }
  //--------------------------------------------------

  void _handleBarcode(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;

    if (rawValue == null) {
      return;
    }

    debugPrint("debug - QR Scanned : $rawValue");

    // The code carries {"id": <map node id>, "name": ...}; only the id is
    // used to place the visitor. The name is just a friendlier label for
    // the "unrecognized" message.
    final payload = QrPayload.parse(rawValue);
    final matchedNode = resolveQrNode(widget.map.nodes, payload);

    if (matchedNode == null) {
      debugPrint(
        "debug - No node with id \"${payload.id}\" on the map. Node ids: "
        "${widget.map.nodes.map((n) => n.id).join(', ')}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.navUnrecognizedQr(payload.name ?? payload.id),
          ),
        ),
      );
      return;
    }

    _popWithRelease(matchedNode.id);
  }

  //--------------------------------------------------

  @override
  void dispose() {
    // Not awaited (dispose() can't be async) — recorded on the shared
    // lock so the next screen to open a camera (another QR scan, or
    // ArNavigationScreen) waits for this release instead of racing it.
    final future = _controller.dispose();
    SharedCameraLock.pendingRelease = future;
    super.dispose();
  }

  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.mode) {
      QRScanMode.startNavigation => AppLocalizations.navScanStartQrTitle,
      QRScanMode.relocate => AppLocalizations.navScanCurrentQrTitle,
    };

    final buttonText = switch (widget.mode) {
      QRScanMode.startNavigation => "Fake Start QR",
      QRScanMode.relocate => "Fake Current QR",
    };

    return PopScope(
      // canPop:false + manual pop (instead of letting the system/AppBar
      // back button pop directly) so _popWithRelease always runs first —
      // otherwise a plain back-gesture exit skips the proactive camera
      // release and falls back to dispose()'s deferred timing, reopening
      // the same race this screen's push/pop counterpart
      // (ArNavigationScreen) was fixed for.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithRelease(null);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _popWithRelease(null),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Always built (never conditionally swapped out) — the
            // controller only finishes "attaching" once this widget is
            // actually in the tree, and start() waits on that attachment.
            // Hiding this behind the loading/error overlay below used to
            // mean start() was called before anything could ever attach to
            // it, which is exactly what threw controllerNotAttached.
            MobileScanner(controller: _controller, onDetect: _handleBarcode),

            if (_errorMessage != null)
              ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white54,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _startScanning,
                          child: Text(AppLocalizations.navRetryLabel),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_starting)
              const ColoredBox(
                color: Colors.black,
                child: Center(child: CircularProgressIndicator()),
              ),

            // Dev-only bypass for testing without printed QR codes — must
            // never reach a release build, since it would let anyone skip
            // scanning entirely.
            if (kDebugMode)
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
      ),
    );
  }
}
