import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:dalili/core/localization/app_localizations.dart';
import 'package:dalili/core/utils/app_logger.dart';
import 'package:dalili/core/utils/book_link.dart';
import 'package:dalili/features/library/domain/entities/book.dart';
import 'package:dalili/features/library/domain/repositories/library_repository.dart';
import 'package:flutter/material.dart';

/// Opens the book behind a shared link.
///
/// Two ways in: the link that *launched* the app (it was closed when the link
/// was tapped) and links that arrive while it is already running. Both end the
/// same way — look the book up by the BibID in the link, then open its page.
class BookLinkService {
  BookLinkService({
    required this.navigatorKey,
    required LibraryRepository repository,
    required Widget Function(Book book) bookPage,
    AppLinks? appLinks,
  }) : _repository = repository,
       _bookPage = bookPage,
       _appLinks = appLinks ?? AppLinks();

  final GlobalKey<NavigatorState> navigatorKey;
  final LibraryRepository _repository;
  final Widget Function(Book book) _bookPage;
  final AppLinks _appLinks;

  StreamSubscription<Uri>? _subscription;

  /// The BibID last handled, so the same link delivered twice (the launch link
  /// can be reported by both the initial and the stream callbacks) opens once.
  String? _lastHandled;

  Future<void> start() async {
    _subscription = _appLinks.uriLinkStream.listen(
      handle,
      onError: (Object e) => AppLogger.error('Book link stream: $e'),
    );

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) await handle(initial);
    } catch (e) {
      AppLogger.error('Initial book link: $e');
    }
  }

  Future<void> dispose() async => _subscription?.cancel();

  /// Public so it can be driven directly in tests.
  Future<void> handle(Uri uri) async {
    final bibid = parseBibid(uri);
    if (bibid == null) return;

    if (_lastHandled == bibid) return;
    _lastHandled = bibid;

    final navigator = await _readyNavigator();
    if (navigator == null) return;

    try {
      final book = await _repository.getBookById(bibid);

      if (book == null) {
        _notify(AppLocalizations.linkBookNotFound);
        return;
      }

      // Replace nothing: the book opens on top of wherever the reader is, and
      // Back returns them there.
      await navigator.push(
        MaterialPageRoute<void>(builder: (_) => _bookPage(book)),
      );
    } catch (e) {
      AppLogger.error('Opening shared book $bibid: $e');
      _notify(AppLocalizations.linkOpenFailed);
    } finally {
      // Re-arm once the page is closed (or the attempt failed), so the same
      // link can be opened again — and retried after a network error.
      _lastHandled = null;
    }
  }

  /// On a cold start the link arrives before the first frame has built the
  /// navigator. Wait for it, briefly, rather than dropping the link.
  Future<NavigatorState?> _readyNavigator() async {
    for (var i = 0; i < 50; i++) {
      final state = navigatorKey.currentState;
      if (state != null) return state;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return null;
  }

  void _notify(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }
}
