import 'dart:ui';

import 'package:dalili/core/constants/app_spacing.dart';
import 'package:dalili/core/di/injection_container.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/theme/app_theme_extension.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_cubit.dart';
import 'package:dalili/features/library/presentation/cubits/scanner/scanner_state.dart';
import 'package:dalili/features/library/presentation/screens/book_detail/book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dalili/core/utils/display.dart';

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

  @override
  Widget build(BuildContext context) => BlocProvider<ScannerCubit>.value(
    value: _cubit,
    child: BlocListener<ScannerCubit, ScannerState>(
      listener: (context, state) {
        if (state.status == ScannerStatus.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          _cubit.reset();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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

  Widget _buildStateLayer(BuildContext context, ScannerState state) =>
      switch (state.status) {
        ScannerStatus.scanning => _ScanningPanel(
          onTestScan: () => _cubit.onBarcodeDetected(null),
        ),
        ScannerStatus.loading => const _LoadingOverlay(),
        ScannerStatus.found => _FoundOverlay(
          book: state.book!,
          onViewDetails: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (_) => BookDetailScreen(book: state.book!),
            ),
          ),
          onReset: _cubit.reset,
        ),
        ScannerStatus.notFound => _NotFoundOverlay(onReset: _cubit.reset),
        ScannerStatus.error => const SizedBox.shrink(),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.read<ScannerCubit>().reset();
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
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
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.pointCameraAtBook,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.stackMd),
          ElevatedButton.icon(
            onPressed: onTestScan,
            icon: const Icon(Icons.bug_report),
            label: const Text('Test Scan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.secondary,
              foregroundColor: Colors.white,
            ),
          ),
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
    color: Colors.black54,
    child: Center(
      child: CircularProgressIndicator(color: context.colors.secondary),
    ),
  );
}

// ---------------------------------------------------------------------------
// Found state — full-screen book detail overlay
// ---------------------------------------------------------------------------

class _FoundOverlay extends StatelessWidget {
  const _FoundOverlay({
    required this.book,
    required this.onViewDetails,
    required this.onReset,
  });

  final Book book;
  final VoidCallback onViewDetails;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      // Blurred cover background when available
      if (book.cover case final cover? when cover.isNotEmpty)
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Image.network(
            cover,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: context.colors.primary),
          ),
        )
      else
        Container(color: context.colors.primary),
      Container(color: Colors.black54),
      SafeArea(
        child: Column(
          children: [
            // Book cover image
            Expanded(
              flex: 2,
              child: Center(child: _FoundCover(url: book.cover)),
            ),
            // Detail card
            Expanded(
              flex: 3,
              child: _FoundDetailCard(
                book: book,
                onViewDetails: onViewDetails,
                onReset: onReset,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _FoundCover extends StatelessWidget {
  const _FoundCover({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      boxShadow: [
        BoxShadow(color: Colors.black45, blurRadius: 24, offset: Offset(0, 10)),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
      child: hasText(url)
          ? Image.network(
              url!,
              height: 170,
              width: 115,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(context),
            )
          : _placeholder(context),
    ),
  );

  Widget _placeholder(BuildContext context) => Container(
    height: 170,
    width: 115,
    decoration: BoxDecoration(
      color: context.appTheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.appTheme.radiusMd),
    ),
    child: Icon(
      Icons.menu_book_rounded,
      size: 56,
      color: context.colors.secondary,
    ),
  );
}

class _FoundDetailCard extends StatelessWidget {
  const _FoundDetailCard({
    required this.book,
    required this.onViewDetails,
    required this.onReset,
  });

  final Book book;
  final VoidCallback onViewDetails;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(context.appTheme.radiusXl),
      topRight: Radius.circular(context.appTheme.radiusXl),
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: context.appTheme.surfaceContainerHigh.withValues(alpha: .2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.appTheme.radiusXl),
            topRight: Radius.circular(context.appTheme.radiusXl),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.stackLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Recognized badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.bookRecognized,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.stackSm),
              // Title
              Text(
                book.title,
                style: context.textStyles.displayMedium?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.stackSm / 2),
              // Author
              Text(
                book.author,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              Divider(
                color: context.appTheme.outlineVariant,
                height: AppSpacing.stackLg,
              ),
              _InfoRow(AppLocalizations.publisher, book.publisher),
              _InfoRow(AppLocalizations.year, book.year?.toString()),
              _InfoRow(AppLocalizations.bookLanguage, book.language),
              _InfoRow(
                AppLocalizations.classification,
                joinParts([
                  book.location.name,
                  book.shelfLabel,
                ], separator: ' - '),
                icon: Icons.location_on,
              ),
              _InfoRow(AppLocalizations.callNumber, book.callNumber),
              _InfoRow(AppLocalizations.isbn, book.isbn),
              const SizedBox(height: AppSpacing.stackMd),
              // View Details button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(AppLocalizations.viewDetails),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        context.appTheme.radiusLg,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.stackSm),
              // Scan Again text button
              TextButton(
                onPressed: onReset,
                child: Text(
                  AppLocalizations.scanAgain,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Renders nothing when the catalogue has no value for this field.
class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.icon});

  final String label;
  final String? value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (!hasText(value)) return const SizedBox.shrink();
    return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      spacing: AppSpacing.stackSm,
      children: [
        Text(
          label,
          style: context.textStyles.labelLarge?.copyWith(
            color: context.appTheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value!,
              maxLines: 1,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }
}

// ---------------------------------------------------------------------------
// Not Found state
// ---------------------------------------------------------------------------

class _NotFoundOverlay extends StatelessWidget {
  const _NotFoundOverlay({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black87,
    child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 80,
                color: Colors.white24,
              ),
              const SizedBox(height: AppSpacing.stackLg),
              Text(
                AppLocalizations.bookNotFound,
                style: context.textStyles.displaySmall?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.stackSm),
              Text(
                AppLocalizations.bookNotFoundDesc,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.stackLg),
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(AppLocalizations.scanAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondary,
                  foregroundColor: Colors.white,
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
