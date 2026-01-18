import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/web_server.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InAppWebViewController? _webViewController;
  LocalWebServer? _webServer;
  bool _isLoading = true;
  String? _serverUrl;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _initWebServer();
  }

  Future<void> _initWebServer() async {
    try {
      // Copy web assets to a temporary directory
      final directory = await getApplicationDocumentsDirectory();
      final webDir = Directory('${directory.path}/web');

      if (!await webDir.exists()) {
        await webDir.create(recursive: true);
      }

      // Copy all web files from assets
      await _copyAssetToFile(
          'assets/web/index.html', '${webDir.path}/index.html');
      await _copyAssetToFile('assets/web/app.js', '${webDir.path}/app.js');
      await _copyAssetToFile(
          'assets/web/style.css', '${webDir.path}/style.css');
      await _copyAssetToFile('assets/web/i18n.js', '${webDir.path}/i18n.js');
      await _copyAssetToFile(
          'assets/web/jszip.min.js', '${webDir.path}/jszip.min.js');

      // Start local web server
      _webServer = LocalWebServer(webDir.path);
      final port = await _webServer!.start();

      setState(() {
        _serverUrl = 'http://localhost:$port/index.html';
      });
    } catch (e) {
      debugPrint('Error initializing web server: $e');
      // Fallback: try loading directly from assets
      setState(() {
        _serverUrl = 'about:blank';
      });
    }
  }

  Future<void> _copyAssetToFile(String assetPath, String filePath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final file = File(filePath);
      await file.writeAsBytes(bytes);
    } catch (e) {
      debugPrint('Error copying asset $assetPath: $e');
    }
  }

  @override
  void dispose() {
    _webServer?.stop();
    super.dispose();
  }

  Future<void> _pickAndLoadEgfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['egf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes != null) {
          // Convert file bytes to base64 and send to WebView
          final base64Data = base64Encode(file.bytes!);
          final fileName = file.name;

          // Call JavaScript function to load the file
          await _webViewController?.evaluateJavascript(source: '''
            (async function() {
              try {
                const base64 = '$base64Data';
                const binary = atob(base64);
                const bytes = new Uint8Array(binary.length);
                for (let i = 0; i < binary.length; i++) {
                  bytes[i] = binary.charCodeAt(i);
                }
                const blob = new Blob([bytes], { type: 'application/octet-stream' });
                const file = new File([blob], '$fileName', { type: 'application/octet-stream' });
                
                // Trigger the file input change event
                const dataTransfer = new DataTransfer();
                dataTransfer.items.add(file);
                const fileInput = document.getElementById('fileInput');
                fileInput.files = dataTransfer.files;
                fileInput.dispatchEvent(new Event('change', { bubbles: true }));
              } catch (e) {
                console.error('Error loading file:', e);
                alert('Error loading file: ' + e.message);
              }
            })();
          ''');
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0b0f14),
      body: SafeArea(
        child: Stack(
          children: [
            if (_serverUrl != null)
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_serverUrl!)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  allowFileAccess: true,
                  allowContentAccess: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  useHybridComposition: true,
                  supportZoom: false,
                  transparentBackground: true,
                  // Enable IndexedDB and localStorage persistence
                  cacheEnabled: true,
                  cacheMode: CacheMode.LOAD_DEFAULT,
                  // Use consistent Web SQL database path (Android)
                  allowUniversalAccessFromFileURLs: true,
                  allowFileAccessFromFileURLs: true,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;

                  // Add JavaScript handler for file picking
                  controller.addJavaScriptHandler(
                    handlerName: 'pickEgfFile',
                    callback: (args) async {
                      await _pickAndLoadEgfFile();
                      return true;
                    },
                  );
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _isLoading = true;
                  });
                },
                onLoadStop: (controller, url) async {
                  setState(() {
                    _isLoading = false;
                  });

                  // Inject JavaScript to mark this as a mobile app and show bottom nav
                  await controller.evaluateJavascript(source: '''
                    // Mark body as mobile app for CSS styling
                    document.body.classList.add('is-mobile-app');
                    document.body.classList.add('has-mobile-nav');
                    
                    // Show mobile bottom navigation
                    const mobileNav = document.getElementById('mobileBottomNav');
                    if (mobileNav) {
                      mobileNav.style.display = 'flex';
                    }
                    
                    // Set a flag for JavaScript detection
                    window.flutter_inappwebview = true;
                  ''');
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint('WebView Console: ${consoleMessage.message}');
                },
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4da3ff),
                ),
              ),

            // Loading indicator
            if (_isLoading && _serverUrl != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4da3ff),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
