import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_state.dart';
import 'package:dalili/features/library/presentation/screens/book_detail/book_detail_screen.dart';
import 'package:dalili/features/library/presentation/widgets/overlay_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _cameraController = MobileScannerController();
  late final ScannerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ScannerCubit>();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _cubit.close();
    super.dispose();
  }

  /// Set once a book is found, so a late second event cannot open it twice.
  bool _openedBook = false;

  /// The camera only runs while the scanner is scanning.
  ///
  /// Left running under a result it kept filming — and, because a page fades in
  /// over the one before it, showed through the first moments of the next
  /// screen. Stopping it the moment a lookup starts releases the camera (and
  /// its privacy indicator) straight away; "scan again" starts it again.
  Future<void> _syncCamera(ScannerStatus status) async {
    try {
      final running = _cameraController.value.isRunning;
      if (status == ScannerStatus.scanning) {
        if (!running) await _cameraController.start();
      } else if (running) {
        await _cameraController.stop();
      }
    } catch (e) {
      // A stop/start that races the screen closing is harmless; the
      // controller is disposed with the screen either way.
      debugPrint('debug - scanner camera sync failed: $e');
    }
  }

  /// A recognized book goes straight to its own page — there is no
  /// intermediate result screen. The scanner is *replaced*, not covered, so
  /// Back from the book returns to where scanning started rather than to a
  /// camera that has nothing left to show.
  Future<void> _openBook(Book book) async {
    if (_openedBook) return;
    _openedBook = true;

    // Camera off before the page changes, so nothing of it shows through.
    await _syncCamera(ScannerStatus.found);
    if (!mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => BookDetailScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) => BlocProvider<ScannerCubit>.value(
    value: _cubit,
    child: BlocListener<ScannerCubit, ScannerState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ScannerStatus.found) {
          _openBook(state.book!);
        } else {
          _syncCamera(state.status);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _cameraController,
              onDetect: (capture) => _cubit.onBarcodeDetected(
                capture.barcodes.firstOrNull?.rawValue,
              ),
            ),
            const _CornerOverlay(),
            BlocBuilder<ScannerCubit, ScannerState>(
              builder: (context, state) => _buildStateLayer(context, state),
            ),
            _TopBar(cameraController: _cameraController),
          ],
        ),
      ),
    ),
  );

  Widget _buildStateLayer(
    BuildContext context,
    ScannerState state,
  ) => switch (state.status) {
    ScannerStatus.scanning => _ScanningPanel(onTestScan: _cubit.scanSample),
    ScannerStatus.loading => const _LoadingOverlay(),
    // Already leaving for the book's page; keep the loading cover up for the
    // few frames before it arrives rather than flashing the camera.
    ScannerStatus.found => const _LoadingOverlay(),
    ScannerStatus.notFound => _NotFoundOverlay(
      scannedCode: state.scannedCode,
      onReset: _cubit.reset,
    ),
    ScannerStatus.error => _ErrorOverlay(
      message: state.errorMessage,
      onRetry: _cubit.reset,
    ),
  };
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.cameraController});

  final MobileScannerController cameraController;

  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Row(
        children: [
          OverlayIconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.read<ScannerCubit>().reset();
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          OverlayIconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Scanning state — bottom hint panel
// ---------------------------------------------------------------------------

class _ScanningPanel extends StatelessWidget {
  const _ScanningPanel({required this.onTestScan});

  final VoidCallback onTestScan;

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: context.cameraPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.pointCameraAtBook,
            style: TextStyle(color: context.appTheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          // A development shortcut; readers never see it.
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.stackMd),
            ElevatedButton.icon(
              onPressed: onTestScan,
              icon: const Icon(Icons.bug_report),
              label: const Text('Test Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appTheme.accent,
                foregroundColor: context.appTheme.onAccent,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Loading state
// ---------------------------------------------------------------------------

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) => Container(
    color: context.colors.surface.withValues(alpha: 0.6),
    child: Center(
      child: CircularProgressIndicator(color: context.colors.secondary),
    ),
  );
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

/// A lookup that failed for a reason other than "no such book" — the server
/// unreachable, or too old to know the route. Kept on screen with a retry
/// instead of flashing a snackbar, so it is not mistaken for the book being
/// missing and cannot loop while the barcode is still in view.
class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    color: context.cameraPanel,
    child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 80,
                color: context.appTheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text(
                AppLocalizations.error,
                style: context.textStyles.displaySmall?.copyWith(
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (message.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.stackSm),
                Text(
                  message,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.appTheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.stackLg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appTheme.accent,
                  foregroundColor: context.appTheme.onAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Not Found state
// ---------------------------------------------------------------------------

class _NotFoundOverlay extends StatelessWidget {
  const _NotFoundOverlay({required this.scannedCode, required this.onReset});

  /// What the barcode said; empty when there was no barcode to report.
  final String scannedCode;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Container(
    color: context.cameraPanel,
    child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: context.appTheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text(
                AppLocalizations.bookNotFound,
                style: context.textStyles.displaySmall?.copyWith(
                  color: context.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.stackSm),
              Text(
                scannedCode.isEmpty
                    ? AppLocalizations.bookNotFoundDesc
                    // Isolated, so a code like "DLB-1415" keeps its order
                    // inside an Arabic sentence instead of being reshuffled.
                    : AppLocalizations.bookNotFoundGn(
                        '\u2066$scannedCode\u2069',
                      ),
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.appTheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.stackLg),
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(AppLocalizations.scanAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appTheme.accent,
                  foregroundColor: context.appTheme.onAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Corner overlay painter (unchanged)
// ---------------------------------------------------------------------------

class _CornerOverlay extends StatelessWidget {
  const _CornerOverlay();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _CornerPainter(color: context.colors.secondary));
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const boxSize = 220.0;
    const cornerLen = 30.0;
    const r = 12.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - boxSize / 2;
    final top = cy - boxSize / 2;
    final right = cx + boxSize / 2;
    final bottom = cy + boxSize / 2;

    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLen)
        ..lineTo(left, top + r)
        ..arcToPoint(Offset(left + r, top), radius: const Radius.circular(r))
        ..lineTo(left + cornerLen, top),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLen, top)
        ..lineTo(right - r, top)
        ..arcToPoint(Offset(right, top + r), radius: const Radius.circular(r))
        ..lineTo(right, top + cornerLen),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - cornerLen)
        ..lineTo(left, bottom - r)
        ..arcToPoint(Offset(left + r, bottom), radius: const Radius.circular(r))
        ..lineTo(left + cornerLen, bottom),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLen, bottom)
        ..lineTo(right - r, bottom)
        ..arcToPoint(
          Offset(right, bottom - r),
          radius: const Radius.circular(r),
          clockwise: false,
        )
        ..lineTo(right, bottom - cornerLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}
