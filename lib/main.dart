import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// An Android shell for the unmodified GreenLeaf HTML design.
/// The UI is an offline demo; nothing sends WhatsApp messages or charges users.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF181727),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFFFFFFF),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const GreenLeafExactApp());
}

class GreenLeafExactApp extends StatelessWidget {
  const GreenLeafExactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenLeaf',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F6F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF181727),
        ),
      ),
      home: const GreenLeafExactScreen(),
    );
  }
}

class GreenLeafExactScreen extends StatefulWidget {
  const GreenLeafExactScreen({super.key});

  @override
  State<GreenLeafExactScreen> createState() => _GreenLeafExactScreenState();
}

class _GreenLeafExactScreenState extends State<GreenLeafExactScreen> {
  late final WebViewController _webview;
  bool _loading = true;
  String? _error;
  bool _backInProgress = false;

  @override
  void initState() {
    super.initState();

    // ONE local WebView is kept alive throughout the app. Switching tabs is
    // handled by the original HTML JavaScript without reloading the document.
    _webview = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF6F6F8))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _error = null;
          });
        },
        onWebResourceError: (WebResourceError err) {
          if (err.isForMainFrame != true || !mounted) return;
          setState(() {
            _error = err.description;
            _loading = false;
          });
        },
      ));

    _openDocument();
  }

  Future<void> _openDocument() async {
    try {
      await _webview.loadFlutterAsset('assets/index.html');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Native Android back controls the existing modal, chat and billing pages.
  /// We only exit the Android app when the user is already on Home.
  Future<void> _androidBack() async {
    if (_backInProgress) return;
    _backInProgress = true;
    try {
      if (_loading || _error != null) {
        await SystemNavigator.pop();
        return;
      }
      final response = await _webview.runJavaScriptReturningResult(r'''
        (() => {
          const modal = document.getElementById('modalOverlay');
          if (modal && modal.classList.contains('show')) {
            modal.classList.remove('show');
            return 'handled';
          }
          const conversation = document.getElementById('conversation');
          if (conversation && conversation.classList.contains('open')) {
            conversation.classList.remove('open');
            return 'handled';
          }
          const activePage = document.querySelector('.page.active');
          if (activePage && activePage.id === 'screen-billing') {
            if (typeof window.showPage === 'function') window.showPage('more');
            return 'handled';
          }
          if (activePage && activePage.id !== 'screen-home') {
            if (typeof window.showPage === 'function') window.showPage('home');
            return 'handled';
          }
          return 'exit';
        })()
      ''');
      if (response.toString().replaceAll('"', '').trim() == 'exit') {
        await SystemNavigator.pop();
      }
    } catch (_) {
      // A Back event during early WebView setup should not crash the app.
    } finally {
      _backInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _androidBack();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          // Android status/navigation/gesture bars stay outside the UI viewport.
          child: Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(controller: _webview),
              if (_loading)
                const ColoredBox(
                  color: Color(0xFFF6F6F8),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF181727),
                      strokeWidth: 2.6,
                    ),
                  ),
                ),
              if (_error != null)
                ColoredBox(
                  color: const Color(0xFFF6F6F8),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to open GreenLeaf',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                _loading = true;
                                _error = null;
                              });
                              _openDocument();
                            },
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
