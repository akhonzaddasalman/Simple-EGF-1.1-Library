import 'dart:io';
import 'package:flutter/foundation.dart';

/// A simple local HTTP server to serve web assets
class LocalWebServer {
  final String _webDirectory;
  HttpServer? _server;
  
  // Use a fixed port for consistent IndexedDB origin
  static const int _defaultPort = 8765;

  LocalWebServer(this._webDirectory);

  /// Starts the server and returns the port number
  Future<int> start() async {
    // Try to bind to fixed port for consistent IndexedDB persistence
    // If the port is already in use, try a few alternatives
    int port = _defaultPort;
    for (int attempt = 0; attempt < 10; attempt++) {
      try {
        _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
        break;
      } catch (e) {
        debugPrint('Port $port is in use, trying ${port + 1}');
        port++;
      }
    }
    
    // Fallback to random port if all else fails
    _server ??= await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    
    debugPrint('Local web server started on port ${_server!.port}');
    
    _server!.listen((HttpRequest request) async {
      try {
        await _handleRequest(request);
      } catch (e) {
        debugPrint('Error handling request: $e');
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      }
    });
    
    return _server!.port;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    String path = request.uri.path;
    
    // Default to index.html
    if (path == '/' || path.isEmpty) {
      path = '/index.html';
    }
    
    // Remove leading slash
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    
    final filePath = '$_webDirectory/$path';
    final file = File(filePath);
    
    if (await file.exists()) {
      // Set content type based on file extension
      final contentType = _getContentType(path);
      request.response.headers.contentType = contentType;
      
      // Add CORS headers
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      request.response.headers.add('Access-Control-Allow-Headers', '*');
      
      // Serve the file
      final content = await file.readAsBytes();
      request.response.add(content);
    } else {
      debugPrint('File not found: $filePath');
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('File not found: $path');
    }
    
    await request.response.close();
  }

  ContentType _getContentType(String path) {
    final extension = path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'html':
        return ContentType.html;
      case 'css':
        return ContentType('text', 'css', charset: 'utf-8');
      case 'js':
        return ContentType('application', 'javascript', charset: 'utf-8');
      case 'json':
        return ContentType.json;
      case 'png':
        return ContentType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return ContentType('image', 'jpeg');
      case 'gif':
        return ContentType('image', 'gif');
      case 'svg':
        return ContentType('image', 'svg+xml');
      case 'webp':
        return ContentType('image', 'webp');
      case 'mp3':
        return ContentType('audio', 'mpeg');
      case 'mp4':
        return ContentType('video', 'mp4');
      case 'webm':
        return ContentType('video', 'webm');
      case 'ogg':
        return ContentType('audio', 'ogg');
      case 'wav':
        return ContentType('audio', 'wav');
      case 'woff':
        return ContentType('font', 'woff');
      case 'woff2':
        return ContentType('font', 'woff2');
      case 'ttf':
        return ContentType('font', 'ttf');
      case 'eot':
        return ContentType('application', 'vnd.ms-fontobject');
      default:
        return ContentType.binary;
    }
  }

  /// Stops the server
  Future<void> stop() async {
    await _server?.close();
    _server = null;
    debugPrint('Local web server stopped');
  }
}
